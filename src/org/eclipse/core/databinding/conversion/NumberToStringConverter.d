/*******************************************************************************
 * Copyright (c) 2007 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 ******************************************************************************/

module org.eclipse.core.databinding.conversion.NumberToStringConverter;

import java.lang.all;

import java.math.BigInteger;

import com.ibm.icu.text.NumberFormat;

/**
 * Converts a Number to a String using <code>NumberFormat.format(...)</code>.
 * This class is thread safe.
 * 
 * @since 1.0
 */
public class NumberToStringConverter : Converter {
    private final NumberFormat numberFormat;
    private final ClassInfo fromType;
    private bool fromTypeIsLong;
    private bool fromTypeIsDecimalType;
    private bool fromTypeIsBigInteger;

    /**
     * Constructs a new instance.
     * <p>
     * Private to restrict public instantiation.
     * </p>
     * 
     * @param numberFormat
     * @param fromType
     */
    private this(NumberFormat numberFormat, ClassInfo fromType) {
        super(fromType, String.classinfo);

        this.numberFormat = numberFormat;
        this.fromType = fromType;

        if (Integer.classinfo.equals(fromType) || Integer.TYPE.equals(fromType)
                || Long.classinfo.equals(fromType) || Long.TYPE.equals(fromType)) {
            fromTypeIsLong = true;
        } else if (Float.classinfo.equals(fromType) || Float.TYPE.equals(fromType)
                || Double.classinfo.equals(fromType)
                || Double.TYPE.equals(fromType)) {
            fromTypeIsDecimalType = true;
        } else if (BigInteger.classinfo.equals(fromType)) {
            fromTypeIsBigInteger = true;
        }
    }

    /**
     * Converts the provided <code>fromObject</code> to a <code>String</code>.
     * If the converter was constructed for an object type, non primitive, a
     * <code>fromObject</code> of <code>null</code> will be converted to an
     * empty string.
     * 
     * @param fromObject
     *            value to convert. May be <code>null</code> if the converter
     *            was constructed for a non primitive type.
     * @see org.eclipse.core.databinding.conversion.IConverter#convert(java.lang.Object)
     */
    public Object convert(Object fromObject) {
        // Null is allowed when the type is not primitve.
        if (fromObject is null && !fromType.isPrimitive()) {
            return ""; //$NON-NLS-1$
        }

        Number number = cast(Number) fromObject;
        String result = null;
        if (fromTypeIsLong) {
            synchronized (numberFormat) {
                result = numberFormat.format(number.longValue());
            }
        } else if (fromTypeIsDecimalType) {
            synchronized (numberFormat) {
                result = numberFormat.format(number.doubleValue());
            }
        } else if (fromTypeIsBigInteger) {
            synchronized (numberFormat) {
                result = numberFormat.format(cast(BigInteger) number);
            }
        }

        return result;
    }

    /**
     * @param primitive
     *            <code>true</code> if the type is a double
     * @return Double converter for the default locale
     */
    public static NumberToStringConverter fromDouble(bool primitive) {
        return fromDouble(NumberFormat.getNumberInstance(), primitive);
    }

    /**
     * @param numberFormat
     * @param primitive
     * @return Double converter with the provided numberFormat
     */
    public static NumberToStringConverter fromDouble(NumberFormat numberFormat,
            bool primitive) {
        return new NumberToStringConverter(numberFormat,
                (primitive) ? Double.TYPE : Double.classinfo);
    }

    /**
     * @param primitive
     *            <code>true</code> if the type is a long
     * @return Long converter for the default locale
     */
    public static NumberToStringConverter fromLong(bool primitive) {
        return fromLong(NumberFormat.getIntegerInstance(), primitive);
    }

    /**
     * @param numberFormat
     * @param primitive
     * @return Long convert with the provided numberFormat
     */
    public static NumberToStringConverter fromLong(NumberFormat numberFormat,
            bool primitive) {
        return new NumberToStringConverter(numberFormat,
                (primitive) ? Long.TYPE : Long.classinfo);
    }

    /**
     * @param primitive
     *            <code>true</code> if the type is a float
     * @return Float converter for the default locale
     */
    public static NumberToStringConverter fromFloat(bool primitive) {
        return fromFloat(NumberFormat.getNumberInstance(), primitive);
    }

    /**
     * @param numberFormat
     * @param primitive
     * @return Float converter with the provided numberFormat
     */
    public static NumberToStringConverter fromFloat(NumberFormat numberFormat,
            bool primitive) {
        return new NumberToStringConverter(numberFormat,
                (primitive) ? Float.TYPE : Float.classinfo);
    }

    /**
     * @param primitive
     *            <code>true</code> if the type is a int
     * @return Integer converter for the default locale
     */
    public static NumberToStringConverter fromInteger(bool primitive) {
        return fromInteger(NumberFormat.getIntegerInstance(), primitive);
    }

    /**
     * @param numberFormat
     * @param primitive
     * @return Integer converter with the provided numberFormat
     */
    public static NumberToStringConverter fromInteger(
            NumberFormat numberFormat, bool primitive) {
        return new NumberToStringConverter(numberFormat,
                (primitive) ? Integer.TYPE : Integer.classinfo);
    }

    /**
     * @return BigInteger convert for the default locale
     */
    public static NumberToStringConverter fromBigInteger() {
        return fromBigInteger(NumberFormat.getIntegerInstance());
    }

    /**
     * @param numberFormat
     * @return BigInteger converter with the provided numberFormat
     */
    public static NumberToStringConverter fromBigInteger(
            NumberFormat numberFormat) {
        return new NumberToStringConverter(numberFormat, BigInteger.classinfo);
    }
}