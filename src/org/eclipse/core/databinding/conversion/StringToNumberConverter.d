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

module org.eclipse.core.databinding.conversion.StringToNumberConverter;

import java.lang.all;
import java.nonstandard.RuntimeTraits;

import java.math.BigDecimal;
import java.math.BigInteger;

import org.eclipse.core.internal.databinding.conversion.StringToNumberParser;
import org.eclipse.core.internal.databinding.validation.NumberFormatConverter;

import com.ibm.icu.text.NumberFormat;

/**
 * Converts a String to a Number using <code>NumberFormat.parse(...)</code>.
 * This class is thread safe.
 * 
 * @since 1.0
 */
public class StringToNumberConverter : NumberFormatConverter {
    private TypeInfo toType;
    /**
     * NumberFormat instance to use for conversion. Access must be synchronized.
     */
    private NumberFormat numberFormat;

    /**
     * Minimum possible value for the type. Can be <code>null</code> as
     * BigInteger doesn't have bounds.
     */
    private final Number min;
    /**
     * Maximum possible value for the type. Can be <code>null</code> as
     * BigInteger doesn't have bounds.
     */
    private final Number max;

    /**
     * The boxed type of the toType;
     */
    private final TypeInfo boxedType;

    private static const Integer MIN_INTEGER;
    private static const Integer MAX_INTEGER;

    private static const Double MIN_DOUBLE;
    private static const Double MAX_DOUBLE;

    private static const Long MIN_LONG;
    private static const Long MAX_LONG;

    private static const Float MIN_FLOAT;
    private static const Float MAX_FLOAT;

    static this(){
        MIN_INTEGER = new Integer(Integer.MIN_VALUE);
        MAX_INTEGER = new Integer(Integer.MAX_VALUE);

        MIN_DOUBLE = new Double(-Double.MAX_VALUE);
        MAX_DOUBLE = new Double(Double.MAX_VALUE);

        MIN_LONG = new Long(Long.MIN_VALUE);
        MAX_LONG = new Long(Long.MIN_VALUE);

        MIN_FLOAT = new Float(-Float.MAX_VALUE);
        MAX_FLOAT = new Float(Float.MAX_VALUE);
    }

    /**
     * @param numberFormat
     * @param toType
     * @param min
     *            minimum possible value for the type, can be <code>null</code>
     *            as BigInteger doesn't have bounds
     * @param max
     *            maximum possible value for the type, can be <code>null</code>
     *            as BigInteger doesn't have bounds
     * @param boxedType
     *            a convenience that allows for the checking against one type
     *            rather than boxed and unboxed types
     */
    private this(NumberFormat numberFormat, TypeInfo toType,
            Number min, Number max, TypeInfo boxedType) {
        super(typeid(StringCls), toType, numberFormat);

        this.toType = toType;
        this.numberFormat = numberFormat;
        this.min = min;
        this.max = max;
        this.boxedType = boxedType;
    }

    /**
     * Converts the provided <code>fromObject</code> to the requested
     * {@link #getToType() to type}.
     * 
     * @see org.eclipse.core.databinding.conversion.IConverter#convert(java.lang.Object)
     * @throws IllegalArgumentException
     *             if the value isn't in the format required by the NumberFormat
     *             or the value is out of range for the
     *             {@link #getToType() to type}.
     * @throws IllegalArgumentException
     *             if conversion was not possible
     */
    public Object convert(Object fromObject) {
        StringToNumberParser.ParseResult result = StringToNumberParser.parse(fromObject,
                numberFormat, isJavaPrimitive(toType));

        if (result.getPosition() !is null) {
            // this shouldn't happen in the pipeline as validation should catch
            // it but anyone can call convert so we should return a properly
            // formatted message in an exception
            throw new IllegalArgumentException(StringToNumberParser
                    .createParseErrorMessage(stringcast(fromObject), result
                            .getPosition()));
        } else if (result.getNumber() is null) {
            // if an error didn't occur and the number is null then it's a boxed
            // type and null should be returned
            return null;
        }

        /*
         * Technically the checks for ranges aren't needed here because the
         * validator should have validated this already but we shouldn't assume
         * this has occurred.
         */
        if (typeid(Integer) is (boxedType)) {
            if (StringToNumberParser.inIntegerRange(result.getNumber())) {
                return new Integer(result.getNumber().intValue());
            }
        } else if (typeid(Double) is (boxedType)) {
            if (StringToNumberParser.inDoubleRange(result.getNumber())) {
                return new Double(result.getNumber().doubleValue());
            }
        } else if (typeid(Long) is (boxedType)) {
            if (StringToNumberParser.inLongRange(result.getNumber())) {
                return new Long(result.getNumber().longValue());
            }
        } else if (typeid(Float) is (boxedType)) {
            if (StringToNumberParser.inFloatRange(result.getNumber())) {
                return new Float(result.getNumber().floatValue());
            }
        } else if (typeid(BigInteger) is (boxedType)) {
            return (new BigDecimal(result.getNumber().doubleValue()))
                    .toBigInteger();
        }

        if (min !is null && max !is null) {
            throw new IllegalArgumentException(StringToNumberParser
                    .createOutOfRangeMessage(min, max, numberFormat));
        }

        /*
         * Fail safe. I don't think this could even be thrown but throwing the
         * exception is better than returning null and hiding the error.
         */
        throw new IllegalArgumentException(
                Format("Could not convert [{}] to type [{}]", fromObject, toType)); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
    }

    /**
     * @param primitive
     *            <code>true</code> if the convert to type is an int
     * @return to Integer converter for the default locale
     */
    public static StringToNumberConverter toInteger(bool primitive) {
        return toInteger(NumberFormat.getIntegerInstance(), primitive);
    }

    /**
     * @param numberFormat
     * @param primitive
     * @return to Integer converter with the provided numberFormat
     */
    public static StringToNumberConverter toInteger(NumberFormat numberFormat,
            bool primitive) {
        return new StringToNumberConverter(numberFormat,
                (primitive) ? Integer.TYPE : typeid(Integer), MIN_INTEGER,
                MAX_INTEGER, typeid(Integer));
    }

    /**
     * @param primitive
     *            <code>true</code> if the convert to type is a double
     * @return to Double converter for the default locale
     */
    public static StringToNumberConverter toDouble(bool primitive) {
        return toDouble(NumberFormat.getNumberInstance(), primitive);
    }

    /**
     * @param numberFormat
     * @param primitive
     * @return to Double converter with the provided numberFormat
     */
    public static StringToNumberConverter toDouble(NumberFormat numberFormat,
            bool primitive) {
        return new StringToNumberConverter(numberFormat,
                (primitive) ? Double.TYPE : typeid(Double), MIN_DOUBLE,
                MAX_DOUBLE, typeid(Double));
    }

    /**
     * @param primitive
     *            <code>true</code> if the convert to type is a long
     * @return to Long converter for the default locale
     */
    public static StringToNumberConverter toLong(bool primitive) {
        return toLong(NumberFormat.getIntegerInstance(), primitive);
    }

    /**
     * @param numberFormat
     * @param primitive
     * @return to Long converter with the provided numberFormat
     */
    public static StringToNumberConverter toLong(NumberFormat numberFormat,
            bool primitive) {
        return new StringToNumberConverter(numberFormat,
                (primitive) ? Long.TYPE : typeid(Long), MIN_LONG, MAX_LONG,
                typeid(Long));
    }

    /**
     * @param primitive
     *            <code>true</code> if the convert to type is a float
     * @return to Float converter for the default locale
     */
    public static StringToNumberConverter toFloat(bool primitive) {
        return toFloat(NumberFormat.getNumberInstance(), primitive);
    }

    /**
     * @param numberFormat
     * @param primitive
     * @return to Float converter with the provided numberFormat
     */
    public static StringToNumberConverter toFloat(NumberFormat numberFormat,
            bool primitive) {
        return new StringToNumberConverter(numberFormat,
                (primitive) ? Float.TYPE : typeid(Float), MIN_FLOAT, MAX_FLOAT,
                typeid(Float));
    }

    /**
     * @return to BigInteger converter for the default locale
     */
    public static StringToNumberConverter toBigInteger() {
        return toBigInteger(NumberFormat.getIntegerInstance());
    }

    /**
     * @param numberFormat
     * @return to BigInteger converter with the provided numberFormat
     */
    public static StringToNumberConverter toBigInteger(NumberFormat numberFormat) {
        return new StringToNumberConverter(numberFormat, typeid(BigInteger),
                null, null, typeid(BigInteger));
    }
}
