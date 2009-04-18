/*******************************************************************************
 * Copyright (c) 2007, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *     Matt Carter - Character support completed (bug 197679)
 *     Tom Schindl<tom.schindl@bestsolution.at> - bugfix for 217940
 *******************************************************************************/

module org.eclipse.core.databinding.UpdateValueStrategy;
import org.eclipse.core.databinding.UpdateStrategy;

import java.lang.all;

import java.util.Date;
import java.util.HashMap;

import org.eclipse.core.databinding.conversion.IConverter;
import org.eclipse.core.databinding.observable.value.IObservableValue;
import org.eclipse.core.databinding.validation.IValidator;
import org.eclipse.core.databinding.validation.ValidationStatus;
import org.eclipse.core.internal.databinding.BindingMessages;
import org.eclipse.core.internal.databinding.Pair;
import org.eclipse.core.internal.databinding.conversion.NumberToBigDecimalConverter;
import org.eclipse.core.internal.databinding.conversion.NumberToBigIntegerConverter;
import org.eclipse.core.internal.databinding.conversion.NumberToByteConverter;
import org.eclipse.core.internal.databinding.conversion.NumberToDoubleConverter;
import org.eclipse.core.internal.databinding.conversion.NumberToFloatConverter;
import org.eclipse.core.internal.databinding.conversion.NumberToIntegerConverter;
import org.eclipse.core.internal.databinding.conversion.NumberToLongConverter;
import org.eclipse.core.internal.databinding.conversion.NumberToNumberConverter;
import org.eclipse.core.internal.databinding.conversion.NumberToShortConverter;
import org.eclipse.core.internal.databinding.conversion.StringToCharacterConverter;
import org.eclipse.core.internal.databinding.conversion.StringToDateConverter;
import org.eclipse.core.internal.databinding.validation.NumberFormatConverter;
import org.eclipse.core.internal.databinding.validation.NumberToByteValidator;
import org.eclipse.core.internal.databinding.validation.NumberToDoubleValidator;
import org.eclipse.core.internal.databinding.validation.NumberToFloatValidator;
import org.eclipse.core.internal.databinding.validation.NumberToIntegerValidator;
import org.eclipse.core.internal.databinding.validation.NumberToLongValidator;
import org.eclipse.core.internal.databinding.validation.NumberToShortValidator;
import org.eclipse.core.internal.databinding.validation.NumberToUnboundedNumberValidator;
import org.eclipse.core.internal.databinding.validation.ObjectToPrimitiveValidator;
import org.eclipse.core.internal.databinding.validation.StringToByteValidator;
import org.eclipse.core.internal.databinding.validation.StringToCharacterValidator;
import org.eclipse.core.internal.databinding.validation.StringToDateValidator;
import org.eclipse.core.internal.databinding.validation.StringToDoubleValidator;
import org.eclipse.core.internal.databinding.validation.StringToFloatValidator;
import org.eclipse.core.internal.databinding.validation.StringToIntegerValidator;
import org.eclipse.core.internal.databinding.validation.StringToLongValidator;
import org.eclipse.core.internal.databinding.validation.StringToShortValidator;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;

/**
 * Customizes a {@link Binding} between two
 * {@link IObservableValue observable values}. The following behaviors can be
 * customized via the strategy:
 * <ul>
 * <li>Validation</li>
 * <li>Conversion</li>
 * <li>Automatic processing</li>
 * </ul>
 * <p>
 * The update phases are:
 * <ol>
 * <li>Validate after get - {@link #validateAfterGet(Object)}</li>
 * <li>Conversion - {@link #convert(Object)}</li>
 * <li>Validate after conversion - {@link #validateAfterConvert(Object)}</li>
 * <li>Validate before set - {@link #validateBeforeSet(Object)}</li>
 * <li>Value set - {@link #doSet(IObservableValue, Object)}</li>
 * </ol>
 * </p>
 * <p>
 * Validation:<br/> {@link IValidator Validators} validate the value at
 * multiple phases in the update process. Statuses returned from validators are
 * aggregated into a <code>MultiStatus</code> until a status of
 * <code>ERROR</code> or <code>CANCEL</code> is encountered. Either of these
 * statuses will abort the update process. These statuses are available as the
 * {@link Binding#getValidationStatus() binding validation status}.
 * </p>
 * <p>
 * Conversion:<br/> A {@link IConverter converter} will convert the value from
 * the type of the source observable into the type of the destination. The
 * strategy has the ability to default converters for common scenarios.
 * </p>
 * <p>
 * Automatic processing:<br/> The processing to perform when the source
 * observable changes. This behavior is configured via policies provided on
 * construction of the strategy (e.g. {@link #POLICY_NEVER},
 * {@link #POLICY_CONVERT}, {@link #POLICY_ON_REQUEST}, {@link #POLICY_UPDATE}).
 * </p>
 *
 * @see DataBindingContext#bindValue(IObservableValue, IObservableValue,
 *      UpdateValueStrategy, UpdateValueStrategy)
 * @see Binding#getValidationStatus()
 * @see IValidator
 * @see IConverter
 * @since 1.0
 */
public class UpdateValueStrategy : UpdateStrategy {

    /**
     * Policy constant denoting that the source observable's state should not be
     * tracked and that the destination observable's value should never be
     * updated.
     */
    public static int POLICY_NEVER = notInlined(1);

    /**
     * Policy constant denoting that the source observable's state should not be
     * tracked, but that validation, conversion and updating the destination
     * observable's value should be performed when explicitly requested.
     */
    public static int POLICY_ON_REQUEST = notInlined(2);

    /**
     * Policy constant denoting that the source observable's state should be
     * tracked, including validating changes except for
     * {@link #validateBeforeSet(Object)}, but that the destination
     * observable's value should only be updated on request.
     */
    public static int POLICY_CONVERT = notInlined(4);

    /**
     * Policy constant denoting that the source observable's state should be
     * tracked, and that validation, conversion and updating the destination
     * observable's value should be performed automaticlly on every change of
     * the source observable value.
     */
    public static int POLICY_UPDATE = notInlined(8);

    /**
     * Helper method allowing API evolution of the above constant values. The
     * compiler will not inline constant values into client code if values are
     * "computed" using this helper.
     *
     * @param i
     *            an integer
     * @return the same integer
     */
    private static int notInlined(int i) {
        return i;
    }

    protected IValidator afterGetValidator;
    protected IValidator afterConvertValidator;
    protected IValidator beforeSetValidator;
    protected IConverter converter;

    private int updatePolicy;

    private static ValidatorRegistry validatorRegistry;
    private static HashMap validatorsByConverter;
    static this(){
        validatorRegistry = new ValidatorRegistry();
        validatorsByConverter = new HashMap();
    }

    protected bool provideDefaults;

    /**
     * <code>true</code> if we defaulted the converter
     */
    private bool defaultedConverter = false;

    /**
     * Creates a new update value strategy for automatically updating the
     * destination observable value whenever the source observable value
     * changes. Default validators and a default converter will be provided. The
     * defaults can be changed by calling one of the setter methods.
     */
    public this() {
        this(true, POLICY_UPDATE);
    }

    /**
     * Creates a new update value strategy with a configurable update policy.
     * Default validators and a default converter will be provided. The defaults
     * can be changed by calling one of the setter methods.
     *
     * @param updatePolicy
     *            one of {@link #POLICY_NEVER}, {@link #POLICY_ON_REQUEST},
     *            {@link #POLICY_CONVERT}, or {@link #POLICY_UPDATE}
     */
    public this(int updatePolicy) {
        this(true, updatePolicy);
    }

    /**
     * Creates a new update value strategy with a configurable update policy.
     * Default validators and a default converter will be provided if
     * <code>provideDefaults</code> is <code>true</code>. The defaults can
     * be changed by calling one of the setter methods.
     *
     * @param provideDefaults
     *            if <code>true</code>, default validators and a default
     *            converter will be provided based on the observable value's
     *            type.
     * @param updatePolicy
     *            one of {@link #POLICY_NEVER}, {@link #POLICY_ON_REQUEST},
     *            {@link #POLICY_CONVERT}, or {@link #POLICY_UPDATE}
     */
    public this(bool provideDefaults, int updatePolicy) {
        this.provideDefaults = provideDefaults;
        this.updatePolicy = updatePolicy;
    }

    /**
     * Converts the value from the source type to the destination type.
     * <p>
     * Default implementation will use the
     * {@link #setConverter(IConverter) converter} if one exists. If no
     * converter exists no conversion occurs.
     * </p>
     *
     * @param value
     * @return the converted value
     */
    public Object convert(Object value) {
        return converter is null ? value : converter.convert(value);
    }

    /**
     * Tries to create a validator that can validate values of type fromType.
     * Returns <code>null</code> if no validator could be created. Either
     * toType or modelDescription can be <code>null</code>, but not both.
     *
     * @param fromType
     * @param toType
     * @return an IValidator, or <code>null</code> if unsuccessful
     */
    protected IValidator createValidator(Object fromType, Object toType) {
        if (fromType is null || toType is null) {
            return new class() IValidator {

                public IStatus validate(Object value) {
                    return Status.OK_STATUS;
                }
            };
        }

        return findValidator(fromType, toType);
    }

    /**
     * Fills out default values based upon the provided <code>source</code>
     * and <code>destination</code>. If the strategy is to default values it
     * will attempt to default a converter. If the converter can be defaulted an
     * attempt is made to default the
     * {@link #validateAfterGet(Object) after get validator}. If a validator
     * cannot be defaulted it will be <code>null</code>.
     *
     * @param source
     * @param destination
     */
    protected void fillDefaults(IObservableValue source,
            IObservableValue destination) {
        Object sourceType = source.getValueType();
        Object destinationType = destination.getValueType();
        if (provideDefaults && sourceType !is null && destinationType !is null) {
            if (converter is null) {
                IConverter converter = createConverter(sourceType,
                        destinationType);
                defaultedConverter = (converter !is null);
                setConverter(converter);
            }

            if (afterGetValidator is null) {
                afterGetValidator = createValidator(sourceType, destinationType);
            }
        }
        if (converter !is null) {
            if (sourceType !is null) {
                checkAssignable(converter.getFromType(), sourceType,
                        Format("converter does not convert from type {}", sourceType)); //$NON-NLS-1$
            }
            if (destinationType !is null) {
                checkAssignable(converter.getToType(), destinationType,
                        Format("converter does not convert to type {}", destinationType)); //$NON-NLS-1$
            }
        }
    }
    package void fillDefaults_package(IObservableValue source,
            IObservableValue destination) {
        fillDefaults(source, destination );
    }

    private IValidator findValidator(Object fromType, Object toType) {
        IValidator result = null;

        // We only default the validator if we defaulted the converter since the
        // two are tightly coupled.
        if (defaultedConverter) {
            if (typeid(StringCls) is fromType) {
                result = cast(IValidator) validatorsByConverter.get(cast(Object)converter);

                if (result is null) {
                    // TODO sring based lookup
                    if (typeid(Integer).opEquals(toType)
                            || Integer.TYPE.opEquals(toType)) {
                        result = new StringToIntegerValidator(
                                cast(NumberFormatConverter) converter);
                    } else if (typeid(Long).opEquals(toType)
                            || Long.TYPE.opEquals(toType)) {
                        result = new StringToLongValidator(
                                cast(NumberFormatConverter) converter);
                    } else if (typeid(Float).opEquals(toType)
                            || Float.TYPE.opEquals(toType)) {
                        result = new StringToFloatValidator(
                                cast(NumberFormatConverter) converter);
                    } else if (typeid(Double).opEquals(toType)
                            || Double.TYPE.opEquals(toType)) {
                        result = new StringToDoubleValidator(
                                cast(NumberFormatConverter) converter);
                    } else if (typeid(Byte).opEquals(toType)
                            || Byte.TYPE.opEquals(toType)) {
                        result = new StringToByteValidator(
                                cast(NumberFormatConverter) converter);
                    } else if (typeid(Short).opEquals(toType)
                            || Short.TYPE.opEquals(toType)) {
                        result = new StringToShortValidator(
                                cast(NumberFormatConverter) converter);
                    } else if (typeid(Character).opEquals(toType)
                            || Character.TYPE.opEquals(toType)
                            && null !is cast(StringToCharacterConverter)converter ) {
                        result = new StringToCharacterValidator(
                                cast(StringToCharacterConverter) converter);
                    } else if (typeid(Date).opEquals(toType)
                            && null !is cast(StringToDateConverter)converter ) {
                        result = new StringToDateValidator(
                                cast(StringToDateConverter) converter);
                    }

                    if (result !is null) {
                        validatorsByConverter.put(cast(Object)converter, cast(Object)result);
                    }
                }
            } else if ( null !is cast(NumberToNumberConverter)converter ) {
                result = cast(IValidator) validatorsByConverter.get(cast(Object)converter);

                if (result is null) {
                    if ( null !is cast(NumberToByteConverter)converter ) {
                        result = new NumberToByteValidator(
                                cast(NumberToByteConverter) converter);
                    } else if ( null !is cast(NumberToShortConverter)converter ) {
                        result = new NumberToShortValidator(
                                cast(NumberToShortConverter) converter);
                    } else if ( null !is cast(NumberToIntegerConverter)converter ) {
                        result = new NumberToIntegerValidator(
                                cast(NumberToIntegerConverter) converter);
                    } else if ( null !is cast(NumberToLongConverter)converter ) {
                        result = new NumberToLongValidator(
                                cast(NumberToLongConverter) converter);
                    } else if ( null !is cast(NumberToFloatConverter)converter ) {
                        result = new NumberToFloatValidator(
                                cast(NumberToFloatConverter) converter);
                    } else if ( null !is cast(NumberToDoubleConverter)converter ) {
                        result = new NumberToDoubleValidator(
                                cast(NumberToDoubleConverter) converter);
                    } else if ( null !is cast(NumberToBigIntegerConverter)converter 
                            || null !is cast(NumberToBigDecimalConverter)converter ) {
                        result = new NumberToUnboundedNumberValidator(
                                cast(NumberToNumberConverter) converter);
                    }
                }
            }

            if (result is null) {
                // TODO string based lookup
                result = validatorRegistry.get(fromType, toType);
            }
        }

        return result;
    }

    /**
     * @return the update policy
     */
    public int getUpdatePolicy() {
        return updatePolicy;
    }

    /**
     * Sets the validator to be invoked after the source value is converted to
     * the type of the destination observable.
     *
     * @param validator
     * @return the receiver, to enable method call chaining
     */
    public UpdateValueStrategy setAfterConvertValidator(IValidator validator) {
        this.afterConvertValidator = validator;
        return this;
    }

    /**
     * Sets the validator to be invoked after the source value is retrieved at
     * the beginning of the synchronization process.
     *
     * @param validator
     * @return the receiver, to enable method call chaining
     */
    public UpdateValueStrategy setAfterGetValidator(IValidator validator) {
        this.afterGetValidator = validator;
        return this;
    }

    /**
     * Sets the validator to be invoked before the value is to be set on the
     * destination at the end of the synchronization process.
     *
     * @param validator
     * @return the receiver, to enable method call chaining
     */
    public UpdateValueStrategy setBeforeSetValidator(IValidator validator) {
        this.beforeSetValidator = validator;
        return this;
    }

    /**
     * Sets the converter to be invoked when converting from the source type to
     * the destination type.
     *
     * @param converter
     * @return the receiver, to enable method call chaining
     */
    public UpdateValueStrategy setConverter(IConverter converter) {
        this.converter = converter;
        return this;
    }

    /**
     * Validates the value after it is converted.
     * <p>
     * Default implementation will use the
     * {@link #setAfterConvertValidator(IValidator) validator} if one exists. If
     * one does not exist no validation will occur.
     * </p>
     *
     * @param value
     * @return an ok status
     */
    public IStatus validateAfterConvert(Object value) {
        return afterConvertValidator is null ? Status.OK_STATUS
                : afterConvertValidator.validate(value);
    }

    /**
     * Validates the value after it is retrieved from the source.
     * <p>
     * Default implementation will use the
     * {@link #setAfterGetValidator(IValidator) validator} if one exists. If one
     * does not exist no validation will occur.
     * </p>
     *
     * @param value
     * @return an ok status
     */
    public IStatus validateAfterGet(Object value) {
        return afterGetValidator is null ? Status.OK_STATUS : afterGetValidator
                .validate(value);
    }

    /**
     * Validates the value before it is set on the destination.
     * <p>
     * Default implementation will use the
     * {@link #setBeforeSetValidator(IValidator) validator} if one exists. If
     * one does not exist no validation will occur.
     * </p>
     *
     * @param value
     * @return an ok status
     */
    public IStatus validateBeforeSet(Object value) {
        return beforeSetValidator is null ? Status.OK_STATUS
                : beforeSetValidator.validate(value);
    }

    /**
     * Sets the current value of the given observable to the given value.
     * Clients may extend but must call the super implementation.
     *
     * @param observableValue
     * @param value
     * @return status
     */
    protected IStatus doSet(IObservableValue observableValue, Object value) {
        try {
            observableValue.setValue(value);
        } catch (Exception ex) {
            return ValidationStatus.error(BindingMessages
                    .getString(BindingMessages.VALUEBINDING_ERROR_WHILE_SETTING_VALUE),
                    ex);
        }
        return Status.OK_STATUS;
    }
    package IStatus doSet_package(IObservableValue observableValue, Object value) {
        return doSet(observableValue,value);
    }

    private static class ValidatorRegistry {

        private HashMap validators;

        /**
         * Adds the system-provided validators to the current validator
         * registry. This is done automatically for the validator registry
         * singleton.
         */
        private this() {
validators = new HashMap();
            // Standalone validators here...
            associate(typeid(Integer), Integer.TYPE,
                    new ObjectToPrimitiveValidator(Integer.TYPE));
            associate(typeid(Byte), Byte.TYPE, new ObjectToPrimitiveValidator(
                    Byte.TYPE));
            associate(typeid(Short), Short.TYPE, new ObjectToPrimitiveValidator(
                    Short.TYPE));
            associate(typeid(Long), Long.TYPE, new ObjectToPrimitiveValidator(
                    Long.TYPE));
            associate(typeid(Float), Float.TYPE, new ObjectToPrimitiveValidator(
                    Float.TYPE));
            associate(typeid(Double), Double.TYPE,
                    new ObjectToPrimitiveValidator(Double.TYPE));
            associate(typeid(Boolean), Boolean.TYPE,
                    new ObjectToPrimitiveValidator(Boolean.TYPE));

            associate(typeid(Object), Integer.TYPE,
                    new ObjectToPrimitiveValidator(Integer.TYPE));
            associate(typeid(Object), Byte.TYPE, new ObjectToPrimitiveValidator(
                    Byte.TYPE));
            associate(typeid(Object), Short.TYPE, new ObjectToPrimitiveValidator(
                    Short.TYPE));
            associate(typeid(Object), Long.TYPE, new ObjectToPrimitiveValidator(
                    Long.TYPE));
            associate(typeid(Object), Float.TYPE, new ObjectToPrimitiveValidator(
                    Float.TYPE));
            associate(typeid(Object), Double.TYPE,
                    new ObjectToPrimitiveValidator(Double.TYPE));
            associate(typeid(Object), Boolean.TYPE,
                    new ObjectToPrimitiveValidator(Boolean.TYPE));
        }

        /**
         * Associate a particular validator that can validate the conversion
         * (fromClass, toClass)
         *
         * @param fromClass
         *            The Class to convert from
         * @param toClass
         *            The Class to convert to
         * @param validator
         *            The IValidator
         */
        private void associate(Object fromClass, Object toClass,
                IValidator validator) {
            validators.put(new Pair(fromClass, toClass), cast(Object)validator);
        }

        /**
         * Return an IValidator for a specific fromClass and toClass.
         *
         * @param fromClass
         *            The Class to convert from
         * @param toClass
         *            The Class to convert to
         * @return An appropriate IValidator
         */
        private IValidator get(Object fromClass, Object toClass) {
            IValidator result = cast(IValidator) validators.get(new Pair(fromClass,
                    toClass));
            if (result !is null)
                return result;
            if (fromClass !is null && toClass !is null && fromClass is toClass) {
                return new class() IValidator {
                    public IStatus validate(Object value) {
                        return Status.OK_STATUS;
                    }
                };
            }
            return new class() IValidator {
                public IStatus validate(Object value) {
                    return Status.OK_STATUS;
                }
            };
        }
    }

}
