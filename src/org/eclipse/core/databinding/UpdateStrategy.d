/*******************************************************************************
 * Copyright (c) 2007, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *     Matt Carter - Bug 180392
 *                 - Character support completed (bug 197679)
 *******************************************************************************/

module org.eclipse.core.databinding.UpdateStrategy;
import org.eclipse.core.databinding.BindingException;

import java.lang.all;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.util.HashMap;
import java.util.Map;

import org.eclipse.core.databinding.conversion.IConverter;
import org.eclipse.core.databinding.conversion.NumberToStringConverter;
import org.eclipse.core.databinding.conversion.StringToNumberConverter;
import org.eclipse.core.databinding.util.Policy;
import org.eclipse.core.internal.databinding.ClassLookupSupport;
import org.eclipse.core.internal.databinding.Pair;
import org.eclipse.core.internal.databinding.conversion.CharacterToStringConverter;
import org.eclipse.core.internal.databinding.conversion.IdentityConverter;
import org.eclipse.core.internal.databinding.conversion.IntegerToStringConverter;
import org.eclipse.core.internal.databinding.conversion.NumberToBigDecimalConverter;
import org.eclipse.core.internal.databinding.conversion.NumberToBigIntegerConverter;
import org.eclipse.core.internal.databinding.conversion.NumberToByteConverter;
import org.eclipse.core.internal.databinding.conversion.NumberToDoubleConverter;
import org.eclipse.core.internal.databinding.conversion.NumberToFloatConverter;
import org.eclipse.core.internal.databinding.conversion.NumberToIntegerConverter;
import org.eclipse.core.internal.databinding.conversion.NumberToLongConverter;
import org.eclipse.core.internal.databinding.conversion.NumberToShortConverter;
import org.eclipse.core.internal.databinding.conversion.ObjectToStringConverter;
import org.eclipse.core.internal.databinding.conversion.StringToByteConverter;
import org.eclipse.core.internal.databinding.conversion.StringToCharacterConverter;
import org.eclipse.core.internal.databinding.conversion.StringToShortConverter;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;

import com.ibm.icu.text.NumberFormat;

/**
 * @since 1.0
 *
 */
/* package */class UpdateStrategy {

    private static final String BOOLEAN_TYPE = "java.lang.Boolean.TYPE"; //$NON-NLS-1$

    private static final String SHORT_TYPE = "java.lang.Short.TYPE"; //$NON-NLS-1$

    private static final String BYTE_TYPE = "java.lang.Byte.TYPE"; //$NON-NLS-1$

    private static final String DOUBLE_TYPE = "java.lang.Double.TYPE"; //$NON-NLS-1$

    private static final String FLOAT_TYPE = "java.lang.Float.TYPE"; //$NON-NLS-1$

    private static final String INTEGER_TYPE = "java.lang.Integer.TYPE"; //$NON-NLS-1$

    private static final String LONG_TYPE = "java.lang.Long.TYPE"; //$NON-NLS-1$

    private static final String CHARACTER_TYPE = "java.lang.Character.TYPE"; //$NON-NLS-1$

    private static Map converterMap;

    private static Class autoboxed(Class clazz) {
        if (clazz is Float.TYPE)
            return Class.fromType!(Float);
        else if (clazz is Double.TYPE)
            return Class.fromType!(Double);
        else if (clazz is Short.TYPE)
            return Class.fromType!(Short);
        else if (clazz is Integer.TYPE)
            return Class.fromType!(Integer);
        else if (clazz is Long.TYPE)
            return Class.fromType!(Long);
        else if (clazz is Byte.TYPE)
            return Class.fromType!(Byte);
        else if (clazz is Boolean.TYPE)
            return Class.fromType!(Boolean);
        else if (clazz is Character.TYPE)
            return Class.fromType!(Character);
        return clazz;
    }

    final protected void checkAssignable(Object toType, Object fromType,
            String errorString) {
        Boolean assignableFromModelToModelConverter = isAssignableFromTo(
                fromType, toType);
        if (assignableFromModelToModelConverter !is null
                && !assignableFromModelToModelConverter.booleanValue()) {
            throw new BindingException(errorString
                    ~ Format(" Expected: {}, actual: {}", fromType, toType)); //$NON-NLS-1$//$NON-NLS-2$
        }
    }

    /**
     * Tries to create a converter that can convert from values of type
     * fromType. Returns <code>null</code> if no converter could be created.
     * Either toType or modelDescription can be <code>null</code>, but not
     * both.
     *
     * @param fromType
     * @param toType
     * @return an IConverter, or <code>null</code> if unsuccessful
     */
    protected IConverter createConverter(Object fromType, Object toType) {
        if (!( null !is cast(Class)fromType ) || !( null !is cast(Class)toType )) {
            return new DefaultConverter(fromType, toType);
        }
        Class toClass = cast(Class) toType;
        Class originalToClass = toClass;
        if (toClass.isPrimitive()) {
            toClass = autoboxed(toClass);
        }
        Class fromClass = cast(Class) fromType;
        Class originalFromClass = fromClass;
        if (fromClass.isPrimitive()) {
            fromClass = autoboxed(fromClass);
        }
        if (!(cast(Class) toType).isPrimitive()
                && toClass.isAssignableFrom(fromClass)) {
            return new IdentityConverter(originalFromClass, originalToClass);
        }
        if ((cast(Class) fromType).isPrimitive() && (cast(Class) toType).isPrimitive()
                && fromType.opEquals(toType)) {
            return new IdentityConverter(originalFromClass, originalToClass);
        }
        Map converterMap = getConverterMap();
        Class[] supertypeHierarchyFlattened = ClassLookupSupport
                .getTypeHierarchyFlattened(fromClass);
        for (int i = 0; i < supertypeHierarchyFlattened.length; i++) {
            Class currentFromClass = supertypeHierarchyFlattened[i];
            if (currentFromClass is toType) {
                // converting to toType is just a widening
                return new IdentityConverter(fromClass, toClass);
            }
            Pair key = new Pair(stringcast(getKeyForClass(fromType, currentFromClass)),
                    stringcast(getKeyForClass(toType, toClass)));
            Object converterOrClassname = converterMap.get(key);
            if ( null !is cast(IConverter)converterOrClassname ) {
                return cast(IConverter) converterOrClassname;
            } else if ( null !is cast(ArrayWrapperString)converterOrClassname ) {
                String classname = stringcast( converterOrClassname);
                Class converterClass;
                try {
                    converterClass = Class.forName(classname);
                    IConverter result = cast(IConverter) converterClass
                            .newInstance();
                    converterMap.put(stringcast(key), cast(Object)result);
                    return result;
                } catch (Exception e) {
                    Policy
                            .getLog()
                            .log(
                                    new Status(
                                            IStatus.ERROR,
                                            Policy.JFACE_DATABINDING,
                                            0,
                                            "Error while instantiating default converter", e)); //$NON-NLS-1$
                }
            }
        }
        // Since we found no converter yet, try a "downcast" converter;
        // the IdentityConverter will automatically check the actual types at
        // runtime.
        if (fromClass.isAssignableFrom(toClass)) {
            return new IdentityConverter(originalFromClass, originalToClass);
        }
        return new DefaultConverter(fromType, toType);
    }

    private synchronized static Map getConverterMap() {
        // using string-based lookup avoids loading of too many classes
        if (converterMap is null) {
            // NumberFormat to be shared across converters for the formatting of
            // integer values
            NumberFormat integerFormat = NumberFormat.getIntegerInstance();
            // NumberFormat to be shared across converters for formatting non
            // integer values
            NumberFormat numberFormat = NumberFormat.getNumberInstance();

            converterMap = new HashMap();
            // Standard and Boxed Types
            converterMap
                    .put(
                            new Pair("java.util.Date", "java.lang.String"), "org.eclipse.core.internal.databinding.conversion.DateToStringConverter"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
            converterMap
                    .put(
                            new Pair("java.lang.String", "java.lang.Boolean"), "org.eclipse.core.internal.databinding.conversion.StringToBooleanConverter"); //$NON-NLS-1$//$NON-NLS-2$ //$NON-NLS-3$
            converterMap
                    .put(
                            new Pair("java.lang.String", "java.lang.Byte"), StringToByteConverter.toByte(integerFormat, false)); //$NON-NLS-1$//$NON-NLS-2$
            converterMap
                    .put(
                            new Pair("java.lang.String", "java.util.Date"), "org.eclipse.core.internal.databinding.conversion.StringToDateConverter"); //$NON-NLS-1$//$NON-NLS-2$ //$NON-NLS-3$
            converterMap
                    .put(
                            new Pair("java.lang.String", "java.lang.Short"), StringToShortConverter.toShort(integerFormat, false)); //$NON-NLS-1$//$NON-NLS-2$
            converterMap
                    .put(
                            new Pair("java.lang.String", "java.lang.Character"), StringToCharacterConverter.toCharacter(false)); //$NON-NLS-1$//$NON-NLS-2$
            converterMap
                    .put(
                            new Pair("java.lang.String", "java.lang.Integer"), StringToNumberConverter.toInteger(integerFormat, false)); //$NON-NLS-1$//$NON-NLS-2$
            converterMap
                    .put(
                            new Pair("java.lang.String", "java.lang.Double"), StringToNumberConverter.toDouble(numberFormat, false)); //$NON-NLS-1$//$NON-NLS-2$
            converterMap
                    .put(
                            new Pair("java.lang.String", "java.lang.Long"), StringToNumberConverter.toLong(integerFormat, false)); //$NON-NLS-1$//$NON-NLS-2$
            converterMap
                    .put(
                            new Pair("java.lang.String", "java.lang.Float"), StringToNumberConverter.toFloat(numberFormat, false)); //$NON-NLS-1$//$NON-NLS-2$
            converterMap
                    .put(
                            new Pair("java.lang.String", "java.math.BigInteger"), StringToNumberConverter.toBigInteger(integerFormat)); //$NON-NLS-1$//$NON-NLS-2$
            converterMap
                    .put(
                            new Pair("java.lang.Integer", "java.lang.String"), NumberToStringConverter.fromInteger(integerFormat, false)); //$NON-NLS-1$//$NON-NLS-2$
            converterMap
                    .put(
                            new Pair("java.lang.Long", "java.lang.String"), NumberToStringConverter.fromLong(integerFormat, false)); //$NON-NLS-1$//$NON-NLS-2$
            converterMap
                    .put(
                            new Pair("java.lang.Double", "java.lang.String"), NumberToStringConverter.fromDouble(numberFormat, false)); //$NON-NLS-1$//$NON-NLS-2$
            converterMap
                    .put(
                            new Pair("java.lang.Float", "java.lang.String"), NumberToStringConverter.fromFloat(numberFormat, false)); //$NON-NLS-1$//$NON-NLS-2$
            converterMap
                    .put(
                            new Pair("java.math.BigInteger", "java.lang.String"), NumberToStringConverter.fromBigInteger(integerFormat)); //$NON-NLS-1$//$NON-NLS-2$
            converterMap
                    .put(
                            new Pair("java.lang.Byte", "java.lang.String"), IntegerToStringConverter.fromByte(integerFormat, false)); //$NON-NLS-1$//$NON-NLS-2$
            converterMap
                    .put(
                            new Pair("java.lang.Short", "java.lang.String"), IntegerToStringConverter.fromShort(integerFormat, false)); //$NON-NLS-1$//$NON-NLS-2$
            converterMap
                    .put(
                            new Pair("java.lang.Character", "java.lang.String"), CharacterToStringConverter.fromCharacter(false)); //$NON-NLS-1$//$NON-NLS-2$

            converterMap
                    .put(
                            new Pair("java.lang.Object", "java.lang.String"), "org.eclipse.core.internal.databinding.conversion.ObjectToStringConverter"); //$NON-NLS-1$//$NON-NLS-2$ //$NON-NLS-3$

            // Integer.TYPE
            converterMap
                    .put(
                            new Pair("java.lang.String", INTEGER_TYPE), StringToNumberConverter.toInteger(integerFormat, true)); //$NON-NLS-1$
            converterMap
                    .put(
                            new Pair(INTEGER_TYPE, "java.lang.Integer"), new IdentityConverter(Integer.TYPE, Class.fromType!(Integer))); //$NON-NLS-1$
            converterMap
                    .put(
                            new Pair(INTEGER_TYPE, "java.lang.Object"), new IdentityConverter(Integer.TYPE, Class.fromType!(Object))); //$NON-NLS-1$
            converterMap
                    .put(
                            new Pair(INTEGER_TYPE, "java.lang.String"), NumberToStringConverter.fromInteger(integerFormat, true)); //$NON-NLS-1$

            // Byte.TYPE
            converterMap
                    .put(
                            new Pair("java.lang.String", BYTE_TYPE), StringToByteConverter.toByte(integerFormat, true)); //$NON-NLS-1$
            converterMap
                    .put(
                            new Pair(BYTE_TYPE, "java.lang.Byte"), new IdentityConverter(Byte.TYPE, Class.fromType!(Byte))); //$NON-NLS-1$
            converterMap
                    .put(
                            new Pair(BYTE_TYPE, "java.lang.String"), IntegerToStringConverter.fromByte(integerFormat, true)); //$NON-NLS-1$
            converterMap
                    .put(
                            new Pair(BYTE_TYPE, "java.lang.Object"), new IdentityConverter(Byte.TYPE, Class.fromType!(Object))); //$NON-NLS-1$

            // Double.TYPE
            converterMap
                    .put(
                            new Pair("java.lang.String", DOUBLE_TYPE), StringToNumberConverter.toDouble(numberFormat, true)); //$NON-NLS-1$
            converterMap
                    .put(
                            new Pair(DOUBLE_TYPE, "java.lang.String"), NumberToStringConverter.fromDouble(numberFormat, true)); //$NON-NLS-1$

            converterMap
                    .put(
                            new Pair(DOUBLE_TYPE, "java.lang.Double"), new IdentityConverter(Double.TYPE, Class.fromType!(Double))); //$NON-NLS-1$
            converterMap
                    .put(
                            new Pair(DOUBLE_TYPE, "java.lang.Object"), new IdentityConverter(Double.TYPE, Class.fromType!(Object))); //$NON-NLS-1$

            // Boolean.TYPE
            converterMap
                    .put(
                            new Pair("java.lang.String", BOOLEAN_TYPE), "org.eclipse.core.internal.databinding.conversion.StringToBooleanPrimitiveConverter"); //$NON-NLS-1$ //$NON-NLS-2$
            converterMap
                    .put(
                            new Pair(BOOLEAN_TYPE, "java.lang.Boolean"), new IdentityConverter(Boolean.TYPE, Class.fromType!(Boolean))); //$NON-NLS-1$
            converterMap
                    .put(
                            new Pair(BOOLEAN_TYPE, "java.lang.String"), new ObjectToStringConverter(Boolean.TYPE)); //$NON-NLS-1$
            converterMap
                    .put(
                            new Pair(BOOLEAN_TYPE, "java.lang.Object"), new IdentityConverter(Boolean.TYPE, Class.fromType!(Object))); //$NON-NLS-1$

            // Float.TYPE
            converterMap
                    .put(
                            new Pair("java.lang.String", FLOAT_TYPE), StringToNumberConverter.toFloat(numberFormat, true)); //$NON-NLS-1$
            converterMap
                    .put(
                            new Pair(FLOAT_TYPE, "java.lang.String"), NumberToStringConverter.fromFloat(numberFormat, true)); //$NON-NLS-1$
            converterMap
                    .put(
                            new Pair(FLOAT_TYPE, "java.lang.Float"), new IdentityConverter(Float.TYPE, Class.fromType!(Float))); //$NON-NLS-1$
            converterMap
                    .put(
                            new Pair(FLOAT_TYPE, "java.lang.Object"), new IdentityConverter(Float.TYPE, Class.fromType!(Object))); //$NON-NLS-1$

            // Short.TYPE
            converterMap
                    .put(
                            new Pair("java.lang.String", SHORT_TYPE), StringToShortConverter.toShort(integerFormat, true)); //$NON-NLS-1$
            converterMap
                    .put(
                            new Pair(SHORT_TYPE, "java.lang.Short"), new IdentityConverter(Short.TYPE, Class.fromType!(Short))); //$NON-NLS-1$
            converterMap
                    .put(
                            new Pair(SHORT_TYPE, "java.lang.String"), IntegerToStringConverter.fromShort(integerFormat, true)); //$NON-NLS-1$
            converterMap
                    .put(
                            new Pair(SHORT_TYPE, "java.lang.Object"), new IdentityConverter(Short.TYPE, Class.fromType!(Object))); //$NON-NLS-1$

            // Long.TYPE
            converterMap
                    .put(
                            new Pair("java.lang.String", LONG_TYPE), StringToNumberConverter.toLong(integerFormat, true)); //$NON-NLS-1$
            converterMap
                    .put(
                            new Pair(LONG_TYPE, "java.lang.String"), NumberToStringConverter.fromLong(integerFormat, true)); //$NON-NLS-1$
            converterMap
                    .put(
                            new Pair(LONG_TYPE, "java.lang.Long"), new IdentityConverter(Long.TYPE, Class.fromType!(Long))); //$NON-NLS-1$
            converterMap
                    .put(
                            new Pair(LONG_TYPE, "java.lang.Object"), new IdentityConverter(Long.TYPE, Class.fromType!(Object))); //$NON-NLS-1$

            // Character.TYPE
            converterMap
                    .put(
                            new Pair("java.lang.String", CHARACTER_TYPE), StringToCharacterConverter.toCharacter(true)); //$NON-NLS-1$
            converterMap
                    .put(
                            new Pair(CHARACTER_TYPE, "java.lang.Character"), new IdentityConverter(Character.TYPE, Class.fromType!(Character))); //$NON-NLS-1$
            converterMap
                    .put(
                            new Pair(CHARACTER_TYPE, "java.lang.String"), CharacterToStringConverter.fromCharacter(true)); //$NON-NLS-1$
            converterMap
                    .put(
                            new Pair(CHARACTER_TYPE, "java.lang.Object"), new IdentityConverter(Character.TYPE, Class.fromType!(Object))); //$NON-NLS-1$

            // Miscellaneous
            converterMap
                    .put(
                            new Pair(
                                    "org.eclipse.core.runtime.IStatus", "java.lang.String"), "org.eclipse.core.internal.databinding.conversion.StatusToStringConverter"); //$NON-NLS-1$//$NON-NLS-2$ //$NON-NLS-3$

            addNumberToByteConverters(converterMap, integerFormat,
                    integerClasses);
            addNumberToByteConverters(converterMap, numberFormat, floatClasses);

            addNumberToShortConverters(converterMap, integerFormat,
                    integerClasses);
            addNumberToShortConverters(converterMap, numberFormat, floatClasses);

            addNumberToIntegerConverters(converterMap, integerFormat,
                    integerClasses);
            addNumberToIntegerConverters(converterMap, numberFormat,
                    floatClasses);

            addNumberToLongConverters(converterMap, integerFormat,
                    integerClasses);
            addNumberToLongConverters(converterMap, numberFormat, floatClasses);

            addNumberToFloatConverters(converterMap, integerFormat,
                    integerClasses);
            addNumberToFloatConverters(converterMap, numberFormat, floatClasses);

            addNumberToDoubleConverters(converterMap, integerFormat,
                    integerClasses);
            addNumberToDoubleConverters(converterMap, numberFormat,
                    floatClasses);

            addNumberToBigIntegerConverters(converterMap, integerFormat,
                    integerClasses);
            addNumberToBigIntegerConverters(converterMap, numberFormat,
                    floatClasses);

            addNumberToBigDecimalConverters(converterMap, integerFormat,
                    integerClasses);
            addNumberToBigDecimalConverters(converterMap, numberFormat,
                    floatClasses);
        }

        return converterMap;
    }

    private static Class[] integerClasses;
    private static Class[] floatClasses;
    static this(){
            integerClasses = [ Byte.TYPE,
                           Class.fromType!(Byte), Short.TYPE, Class.fromType!(Short), Integer.TYPE, Class.fromType!(Integer),
                           Long.TYPE, Class.fromType!(Long), Class.fromType!(BigInteger) ];
            floatClasses = [ Float.TYPE,
                         Class.fromType!(Float), Double.TYPE, Class.fromType!(Double), Class.fromType!(BigDecimal) ];
    }


    /**
     * Registers converters to boxed and unboxed types from a list of from
     * classes.
     *
     * @param map
     * @param numberFormat
     * @param fromTypes
     */
    private static void addNumberToByteConverters(Map map,
            NumberFormat numberFormat, Class[] fromTypes) {

        for (int i = 0; i < fromTypes.length; i++) {
            Class fromType = fromTypes[i];
            if (fromType != Class.fromType!(Byte) && fromType != Byte.TYPE) {
                String fromName = fromType.isPrimitive() ? getKeyForClass(
                        fromType, null) : fromType.getName();

                map
                        .put(new Pair(fromName, BYTE_TYPE),
                                new NumberToByteConverter(numberFormat,
                                        fromType, true));
                map
                        .put(new Pair(fromName, Class.fromType!(Byte).getName()),
                                new NumberToByteConverter(numberFormat,
                                        fromType, false));
            }
        }
    }

    /**
     * Registers converters to boxed and unboxed types from a list of from
     * classes.
     *
     * @param map
     * @param numberFormat
     * @param fromTypes
     */
    private static void addNumberToShortConverters(Map map,
            NumberFormat numberFormat, Class[] fromTypes) {
        for (int i = 0; i < fromTypes.length; i++) {
            Class fromType = fromTypes[i];
            if (fromType != Class.fromType!(Short) && fromType != Short.TYPE) {
                String fromName = fromType.isPrimitive() ? getKeyForClass(
                        fromType, null) : fromType.getName();

                map
                        .put(new Pair(fromName, SHORT_TYPE),
                                new NumberToShortConverter(numberFormat,
                                        fromType, true));
                map.put(new Pair(fromName, Class.fromType!(Short).getName()),
                        new NumberToShortConverter(numberFormat, fromType,
                                false));
            }
        }
    }

    /**
     * Registers converters to boxed and unboxed types from a list of from
     * classes.
     *
     * @param map
     * @param numberFormat
     * @param fromTypes
     */
    private static void addNumberToIntegerConverters(Map map,
            NumberFormat numberFormat, Class[] fromTypes) {
        for (int i = 0; i < fromTypes.length; i++) {
            Class fromType = fromTypes[i];
            if (fromType != Class.fromType!(Integer)
                    && fromType != Integer.TYPE) {
                String fromName = fromType.isPrimitive() ? getKeyForClass(
                        fromType, null) : fromType.getName();

                map.put(new Pair(fromName, INTEGER_TYPE),
                        new NumberToIntegerConverter(numberFormat, fromType,
                                true));
                map.put(new Pair(fromName, Class.fromType!(Integer).getName()),
                        new NumberToIntegerConverter(numberFormat, fromType,
                                false));
            }
        }
    }

    /**
     * Registers converters to boxed and unboxed types from a list of from
     * classes.
     *
     * @param map
     * @param numberFormat
     * @param fromTypes
     */
    private static void addNumberToLongConverters(Map map,
            NumberFormat numberFormat, Class[] fromTypes) {
        for (int i = 0; i < fromTypes.length; i++) {
            Class fromType = fromTypes[i];
            if (fromType != Class.fromType!(Long) && fromType != Long.TYPE) {
                String fromName = fromType.isPrimitive() ? getKeyForClass(
                        fromType, null) : fromType.getName();

                map
                        .put(new Pair(fromName, LONG_TYPE),
                                new NumberToLongConverter(numberFormat,
                                        fromType, true));
                map
                        .put(new Pair(fromName, Class.fromType!(Long).getName()),
                                new NumberToLongConverter(numberFormat,
                                        fromType, false));
            }
        }
    }

    /**
     * Registers converters to boxed and unboxed types from a list of from
     * classes.
     *
     * @param map
     * @param numberFormat
     * @param fromTypes
     */
    private static void addNumberToFloatConverters(Map map,
            NumberFormat numberFormat, Class[] fromTypes) {
        for (int i = 0; i < fromTypes.length; i++) {
            Class fromType = fromTypes[i];
            if (fromType != Class.fromType!(Float) && fromType != Float.TYPE) {
                String fromName = fromType.isPrimitive() ? getKeyForClass(
                        fromType, null) : fromType.getName();

                map
                        .put(new Pair(fromName, FLOAT_TYPE),
                                new NumberToFloatConverter(numberFormat,
                                        fromType, true));
                map.put(new Pair(fromName, Class.fromType!(Float).getName()),
                        new NumberToFloatConverter(numberFormat, fromType,
                                false));
            }
        }
    }

    /**
     * Registers converters to boxed and unboxed types from a list of from
     * classes.
     *
     * @param map
     * @param numberFormat
     * @param fromTypes
     */
    private static void addNumberToDoubleConverters(Map map,
            NumberFormat numberFormat, Class[] fromTypes) {
        for (int i = 0; i < fromTypes.length; i++) {
            Class fromType = fromTypes[i];
            if (fromType != Class.fromType!(Double) && fromType != Double.TYPE) {
                String fromName = fromType.isPrimitive() ? getKeyForClass(
                        fromType, null) : fromType.getName();

                map.put(new Pair(fromName, DOUBLE_TYPE),
                        new NumberToDoubleConverter(numberFormat, fromType,
                                true));
                map.put(new Pair(fromName, Class.fromType!(Double).getName()),
                        new NumberToDoubleConverter(numberFormat, fromType,
                                false));
            }
        }
    }

    /**
     * Registers converters to boxed and unboxed types from a list of from
     * classes.
     *
     * @param map
     * @param numberFormat
     * @param fromTypes
     */
    private static void addNumberToBigIntegerConverters(Map map,
            NumberFormat numberFormat, Class[] fromTypes) {
        for (int i = 0; i < fromTypes.length; i++) {
            Class fromType = fromTypes[i];
            if (!fromType.opEquals(Class.fromType!(BigInteger))) {
                String fromName = fromType.isPrimitive() ? getKeyForClass(
                        fromType, null) : fromType.getName();

                map
                        .put(new Pair(fromName, Class.fromType!(BigInteger).getName()),
                                new NumberToBigIntegerConverter(numberFormat,
                                        fromType));
            }
        }
    }

    /**
     * Registers converters to boxed and unboxed types from a list of from
     * classes.
     *
     * @param map
     * @param numberFormat
     * @param fromTypes
     */
    private static void addNumberToBigDecimalConverters(Map map,
            NumberFormat numberFormat, Class[] fromTypes) {
        for (int i = 0; i < fromTypes.length; i++) {
            Class fromType = fromTypes[i];
            if (!fromType.opEquals(Class.fromType!(BigDecimal))) {
                String fromName = fromType.isPrimitive() ? getKeyForClass(
                        fromType, null) : fromType.getName();

                map
                        .put(new Pair(fromName, Class.fromType!(BigDecimal).getName()),
                                new NumberToBigDecimalConverter(numberFormat,
                                        fromType));
            }
        }
    }

    private static String getKeyForClass(Object originalValue,
            Class filteredValue) {
        if ( null !is cast(Class)originalValue ) {
            Class originalClass = cast(Class) originalValue;
            if (originalClass == Integer.TYPE) {
                return INTEGER_TYPE;
            } else if (originalClass == Byte.TYPE) {
                return BYTE_TYPE;
            } else if (originalClass == Boolean.TYPE) {
                return BOOLEAN_TYPE;
            } else if (originalClass == Double.TYPE) {
                return DOUBLE_TYPE;
            } else if (originalClass == Float.TYPE) {
                return FLOAT_TYPE;
            } else if (originalClass == Long.TYPE) {
                return LONG_TYPE;
            } else if (originalClass == Short.TYPE) {
                return SHORT_TYPE;
            }
        }
        return filteredValue.getName();
    }

    /**
     * Returns {@link Boolean#TRUE} if the from type is assignable to the to
     * type, or {@link Boolean#FALSE} if it not, or <code>null</code> if
     * unknown.
     * 
     * @param fromType
     * @param toType
     * @return whether fromType is assignable to toType, or <code>null</code>
     *         if unknown
     */
    protected Boolean isAssignableFromTo(Object fromType, Object toType) {
        if ( null !is cast(Class)fromType && null !is cast(Class)toType ) {
            Class toClass = cast(Class) toType;
            if (toClass.isPrimitive()) {
                toClass = autoboxed(toClass);
            }
            Class fromClass = cast(Class) fromType;
            if (fromClass.isPrimitive()) {
                fromClass = autoboxed(fromClass);
            }
            return toClass.isAssignableFrom(fromClass) ? Boolean.TRUE
                    : Boolean.FALSE;
        }
        return null;
    }

    /*
     * Default converter implementation, does not perform any conversion.
     */
    protected static final class DefaultConverter : IConverter {

        private final Object toType;

        private final Object fromType;

        /**
         * @param fromType
         * @param toType
         */
        this(Object fromType, Object toType) {
            this.toType = toType;
            this.fromType = fromType;
        }

        public Object convert(Object fromObject) {
            return fromObject;
        }

        public Object getFromType() {
            return fromType;
        }

        public Object getToType() {
            return toType;
        }
    }

}
