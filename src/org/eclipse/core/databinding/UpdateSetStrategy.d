/*******************************************************************************
 * Copyright (c) 2008 Matthew Hall and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Matthew Hall - initial API and implementation (bug 124684)
 *     IBM Corporation - through UpdateListStrategy.java
 ******************************************************************************/

module org.eclipse.core.databinding.UpdateSetStrategy;
import org.eclipse.core.databinding.UpdateStrategy;

import java.lang.all;

import org.eclipse.core.databinding.conversion.IConverter;
import org.eclipse.core.databinding.observable.set.IObservableSet;
import org.eclipse.core.databinding.validation.ValidationStatus;
import org.eclipse.core.internal.databinding.BindingMessages;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;

    /**
     * Helper method allowing API evolution of the above constant values. The
     * compiler will not inline constant values into client code if values are
     * "computed" using this helper.
     * 
     * @param i
     *            an integer
     * @return the same integer
     */
    private int notInlined(int i) {
        return i;
    }

/**
 * Customizes a {@link Binding} between two
 * {@link IObservableSet observable sets}. The following behaviors can be
 * customized via the strategy:
 * <ul>
 * <li>Conversion</li>
 * <li>Automatic processing</li>
 * </ul>
 * <p>
 * Conversion:<br/> When elements are added they can be
 * {@link #convertcast(Object) converted} to the destination element type.
 * </p>
 * <p>
 * Automatic processing:<br/> The processing to perform when the source
 * observable changes. This behavior is configured via policies provided on
 * construction of the strategy (e.g. {@link #POLICY_NEVER},
 * {@link #POLICY_ON_REQUEST}, {@link #POLICY_UPDATE}).
 * </p>
 * 
 * 
 * @see DataBindingContext#bindSet(IObservableSet, IObservableSet,
 *      UpdateSetStrategy, UpdateSetStrategy)
 * @see IConverter
 * @since 1.1
 */
public class UpdateSetStrategy : UpdateStrategy {

    /**
     * Policy constant denoting that the source observable's state should not be
     * tracked and that the destination observable's state should never be
     * updated.
     */
    public final static int POLICY_NEVER = notInlined(1);

    /**
     * Policy constant denoting that the source observable's state should not be
     * tracked, but that conversion and updating the destination observable's
     * state should be performed when explicitly requested.
     */
    public final static int POLICY_ON_REQUEST = notInlined(2);

    /**
     * Policy constant denoting that the source observable's state should be
     * tracked, and that conversion and updating the destination observable's
     * state should be performed automatically on every change of the source
     * observable state.
     */
    public final static int POLICY_UPDATE = notInlined(8);

    protected IConverter converter;

    private int updatePolicy;

    protected bool provideDefaults;

    /**
     * Creates a new update list strategy for automatically updating the
     * destination observable list whenever the source observable list changes.
     * A default converter will be provided. The defaults can be changed by
     * calling one of the setter methods.
     */
    public this() {
        this(true, POLICY_UPDATE);
    }

    /**
     * Creates a new update list strategy with a configurable update policy. A
     * default converter will be provided. The defaults can be changed by
     * calling one of the setter methods.
     * 
     * @param updatePolicy
     *            one of {@link #POLICY_NEVER}, {@link #POLICY_ON_REQUEST}, or
     *            {@link #POLICY_UPDATE}
     */
    public this(int updatePolicy) {
        this(true, updatePolicy);
    }

    /**
     * Creates a new update list strategy with a configurable update policy. A
     * default converter will be provided if <code>provideDefaults</code> is
     * <code>true</code>. The defaults can be changed by calling one of the
     * setter methods.
     * 
     * @param provideDefaults
     *            if <code>true</code>, default validators and a default
     *            converter will be provided based on the observable list's
     *            type.
     * @param updatePolicy
     *            one of {@link #POLICY_NEVER}, {@link #POLICY_ON_REQUEST}, or
     *            {@link #POLICY_UPDATE}
     */
    public this(bool provideDefaults, int updatePolicy) {
        this.provideDefaults = provideDefaults;
        this.updatePolicy = updatePolicy;
    }

    /**
     * When an element is added to the destination converts the element from the
     * source element type to the destination element type.
     * <p>
     * Default implementation will use the
     * {@link #setConvertercast(IConverter) converter} if one exists. If no
     * converter exists no conversion occurs.
     * </p>
     * 
     * @param element
     * @return the converted element
     */
    public Object convert(Object element) {
        return converter is null ? element : converter.convert(element);
    }

    /**
     * 
     * @param source
     * @param destination
     */
    protected void fillDefaults(IObservableSet source,
            IObservableSet destination) {
        Object sourceType = source.getElementType();
        Object destinationType = destination.getElementType();
        if (provideDefaults && sourceType !is null && destinationType !is null) {
            if (converter is null) {
                setConverter(createConverter(sourceType, destinationType));
            }
        }
        if (converter !is null) {
            if (sourceType !is null) {
                checkAssignable(converter.getFromType(), sourceType,
                        "converter does not convert from type " ~ String_valueOf(sourceType)); //$NON-NLS-1$
            }
            if (destinationType !is null) {
                checkAssignable(converter.getToType(), destinationType,
                        "converter does not convert to type " ~ String_valueOf(destinationType)); //$NON-NLS-1$
            }
        }
    }
    package void fillDefaults_package(IObservableSet source, IObservableSet destination) {
        fillDefaults(source, destination);
    }

    /**
     * @return the update policy
     */
    public int getUpdatePolicy() {
        return updatePolicy;
    }

    /**
     * Sets the converter to be invoked when converting added elements from the
     * source element type to the destination element type.
     * 
     * @param converter
     * @return the receiver, to enable method call chaining
     */
    public UpdateSetStrategy setConverter(IConverter converter) {
        this.converter = converter;
        return this;
    }

    /**
     * Adds the given element at the given index to the given observable list.
     * Clients may extend but must call the super implementation.
     * 
     * @param observableSet
     * @param element
     * @return a status
     */
    protected IStatus doAdd(IObservableSet observableSet, Object element) {
        try {
            observableSet.add(element);
        } catch (Exception ex) {
            return ValidationStatus.error(BindingMessages
                    .getString("ValueBinding_ErrorWhileSettingValue"), //$NON-NLS-1$
                    ex);
        }
        return Status.OK_STATUS;
    }
    package IStatus doAdd_package( IObservableSet observableSet, Object element) {
        return doAdd(observableSet, element);
    }

    /**
     * Removes the element at the given index from the given observable list.
     * Clients may extend but must call the super implementation.
     * 
     * @param observableSet
     * @param element 
     * @return a status
     */
    protected IStatus doRemove(IObservableSet observableSet, Object element) {
        try {
            observableSet.remove(element);
        } catch (Exception ex) {
            return ValidationStatus.error(BindingMessages
                    .getString("ValueBinding_ErrorWhileSettingValue"), //$NON-NLS-1$
                    ex);
        }
        return Status.OK_STATUS;
    }
    package IStatus doRemove_package(IObservableSet observableSet, Object element) {
        return doRemove(observableSet, element );
    }
}
