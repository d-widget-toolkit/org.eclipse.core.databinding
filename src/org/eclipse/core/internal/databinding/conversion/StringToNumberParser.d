/*******************************************************************************
 * Copyright (c) 2007, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *******************************************************************************/

module org.eclipse.core.internal.databinding.conversion.StringToNumberParser;

import java.lang.all;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.text.ParsePosition;

import org.eclipse.core.internal.databinding.BindingMessages;

import com.ibm.icu.text.NumberFormat;

/**
 * Utility class for the parsing of strings to numbers.
 *
 * @since 1.0
 */
public class StringToNumberParser {
    private static BigDecimal FLOAT_MAX_BIG_DECIMAL;
    private static BigDecimal FLOAT_MIN_BIG_DECIMAL;
    private static BigDecimal DOUBLE_MAX_BIG_DECIMAL;
    private static BigDecimal DOUBLE_MIN_BIG_DECIMAL;
    static this(){
        FLOAT_MAX_BIG_DECIMAL = new BigDecimal(
                Float.MAX_VALUE);
        FLOAT_MIN_BIG_DECIMAL = new BigDecimal(
                -Float.MAX_VALUE);

        DOUBLE_MAX_BIG_DECIMAL = new BigDecimal(
                Double.MAX_VALUE);
        DOUBLE_MIN_BIG_DECIMAL = new BigDecimal(
                -Double.MAX_VALUE);
    }

    /**
     * @param value
     * @param numberFormat
     * @param primitive
     * @return result
     */
    public static ParseResult parse(Object value, NumberFormat numberFormat,
            bool primitive) {
        if (!( null !is cast(ArrayWrapperString)value )) {
            throw new IllegalArgumentException(
                    "Value to convert is not a String"); //$NON-NLS-1$
        }

        String source = stringcast( value );
        ParseResult result = new ParseResult();
        if (!primitive && source.trim().length() is 0) {
            return result;
        }

        synchronized (numberFormat) {
            ParsePosition position = new ParsePosition(0);
            Number parseResult = null;
            parseResult = numberFormat.parse(source, position);

            if (position.getIndex() !is source.length()
                    || position.getErrorIndex() > -1) {

                result.position = position;
            } else {
                result.number = parseResult;
            }
        }

        return result;
    }

    /**
     * The result of a parse operation.
     *
     * @since 1.0
     */
    public static class ParseResult {
        /* package */Number number;
        /* package */ParsePosition position;

        /**
         * The number as a result of the conversion. <code>null</code> if the
         * value could not be converted or if the type is not a primitive and
         * the value was an empty string.
         *
         * @return number
         */
        public Number getNumber() {
            return number;
        }

        /**
         * ParsePosition if an error occurred while parsing. <code>null</code>
         * if no error occurred.
         *
         * @return parse position
         */
        public ParsePosition getPosition() {
            return position;
        }
    }

    /**
     * Formats an appropriate message for a parsing error.
     *
     * @param value
     * @param position
     * @return message
     */
    public static String createParseErrorMessage(String value,
            ParsePosition position) {
        int errorIndex = (position.getErrorIndex() > -1) ? position
                .getErrorIndex() : position.getIndex();

        if (errorIndex < value.length()) {
            return BindingMessages.formatString(BindingMessages.VALIDATE_NUMBER_PARSE_ERROR,
                    [cast(Object) stringcast(value), new Integer(errorIndex + 1),
                            new Character(value.charAt(errorIndex)) ]);
        }
        return BindingMessages.formatString(BindingMessages.VALIDATE_NUMBER_PARSE_ERROR_NO_CHARACTER,
                [cast(Object) stringcast(value), new Integer(errorIndex + 1) ]);
    }

    /**
     * Formats an appropriate message for an out of range error.
     *
     * @param minValue
     * @param maxValue
     * @param numberFormat when accessed method synchronizes on instance
     * @return message
     */
    public static String createOutOfRangeMessage(Number minValue,
            Number maxValue, NumberFormat numberFormat) {
        String min = null;
        String max = null;

        synchronized (numberFormat) {
            min = numberFormat.format(minValue);
            max = numberFormat.format(maxValue);
        }

        return BindingMessages.formatString(
                "Validate_NumberOutOfRangeError", [ cast(Object)stringcast(min), stringcast(max) ]); //$NON-NLS-1$
    }

    /**
     * Returns <code>true</code> if the provided <code>number</code> is in
     * the range of a integer.
     *
     * @param number
     * @return <code>true</code> if a valid integer
     * @throws IllegalArgumentException
     *             if the number type is unsupported
     */
    public static bool inIntegerRange(Number number) {
        return checkInteger(number, 31);
    }

    /**
     * Validates the range of the provided <code>number</code>.
     *
     * @param number
     * @param bitLength number of bits allowed to be in range
     * @return <code>true</code> if in range
     */
    private static bool checkInteger(Number number, int bitLength) {
        BigInteger bigInteger = null;

        if ( null !is cast(Integer )number || null !is cast(Long)number ) {
            bigInteger = BigInteger.valueOf(number.longValue());
        } else if ( null !is cast(Float )number || null !is cast(Double)number ) {
            double doubleValue = number.doubleValue();
            /*
             * doubleValue is doubleValue is used to check for NaN because NaN !is
             * NaN. The only way to check for NaN is to compare that the value
             * is equal to itself.
             */
            if (doubleValue is doubleValue
                    && doubleValue !is Double.NEGATIVE_INFINITY
                    && doubleValue !is Double.POSITIVE_INFINITY) {
                bigInteger = (new BigDecimal(doubleValue)).toBigInteger();
            } else {
                return false;
            }
        } else if ( null !is cast(BigInteger)number ) {
            bigInteger = cast(BigInteger) number;
        } else if ( null !is cast(BigDecimal)number ) {
            bigInteger = (cast(BigDecimal) number).toBigInteger();
        } else {
            /*
             * The else is necessary as the ICU4J plugin has it's own BigDecimal
             * implementation which isn't part of the replacement plugin. So
             * that this will work we fall back on the double value of the
             * number.
             */
            bigInteger = (new BigDecimal(number.doubleValue())).toBigInteger();
        }

        if (bigInteger !is null) {
            return bigInteger.bitLength() <= bitLength;
        }

        throw new IllegalArgumentException(
                Format("Number of type [{}] is not supported.", number.classinfo.name )); //$NON-NLS-1$ //$NON-NLS-2$
    }

    /**
     * Returns <code>true</code> if the provided <code>number</code> is in
     * the range of a long.
     *
     * @param number
     * @return <code>true</code> if in range
     * @throws IllegalArgumentException
     *             if the number type is unsupported
     */
    public static bool inLongRange(Number number) {
        return checkInteger(number, 63);
    }

    /**
     * Returns <code>true</code> if the provided <code>number</code> is in
     * the range of a float.
     *
     * @param number
     * @return <code>true</code> if in range
     * @throws IllegalArgumentException
     *             if the number type is unsupported
     */
    public static bool inFloatRange(Number number) {
        return checkDecimal(number, FLOAT_MIN_BIG_DECIMAL, FLOAT_MAX_BIG_DECIMAL);
    }

    private static bool checkDecimal(Number number, BigDecimal min, BigDecimal max) {
        BigDecimal bigDecimal = null;
        if ( null !is cast(Integer )number || null !is cast(Long)number ) {
            bigDecimal = new BigDecimal(number.doubleValue());
        } else if ( null !is cast(Float )number || null !is cast(Double)number ) {
            double doubleValue = number.doubleValue();

            /*
             * doubleValue is doubleValue is used to check for NaN because NaN !is
             * NaN. The only way to check for NaN is to compare that the value
             * is equal to itself.
             */
            if (doubleValue is doubleValue
                    && doubleValue !is Double.NEGATIVE_INFINITY
                    && doubleValue !is Double.POSITIVE_INFINITY) {
                bigDecimal = new BigDecimal(doubleValue);
            } else {
                return false;
            }
        } else if ( null !is cast(BigInteger)number ) {
            bigDecimal = new BigDecimal(cast(BigInteger) number);
        } else if ( null !is cast(BigDecimal)number ) {
            bigDecimal = cast(BigDecimal) number;
        } else {
            /*
             * The else is necessary as the ICU4J plugin has it's own BigDecimal
             * implementation which isn't part of the replacement plugin. So
             * that this will work we fall back on the double value of the
             * number.
             */
            bigDecimal = new BigDecimal(number.doubleValue());
        }

        if (bigDecimal !is null) {
            return max.compareTo(bigDecimal) >= 0
                    && min.compareTo(bigDecimal) <= 0;
        }

        throw new IllegalArgumentException(
                Format("Number of type [{}] is not supported.", number.classinfo.name)); //$NON-NLS-1$ //$NON-NLS-2$
    }

    /**
     * Returns <code>true</code> if the provided <code>number</code> is in
     * the range of a double.
     *
     * @param number
     * @return <code>true</code> if in range
     * @throws IllegalArgumentException
     *             if the number type is unsupported
     */
    public static bool inDoubleRange(Number number) {
        return checkDecimal(number, DOUBLE_MIN_BIG_DECIMAL, DOUBLE_MAX_BIG_DECIMAL);
    }

    /**
     * Returns <code>true</code> if the provided <code>number</code> is in
     * the range of a short.
     *
     * @param number
     * @return <code>true</code> if in range
     */
    public static bool inShortRange(Number number) {
        return checkInteger(number, 15);
    }

    /**
     * Returns <code>true</code> if the provided <code>number</code> is in
     * the range of a byte.
     *
     * @param number
     * @return <code>true</code> if in range
     */
    public static bool inByteRange(Number number) {
        return checkInteger(number, 7);
    }
}
