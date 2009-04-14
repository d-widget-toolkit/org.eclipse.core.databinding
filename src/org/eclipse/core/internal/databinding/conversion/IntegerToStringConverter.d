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

module org.eclipse.core.internal.databinding.conversion.IntegerToStringConverter;

import java.lang.all;

import org.eclipse.core.databinding.conversion.Converter;

import com.ibm.icu.text.NumberFormat;

/**
 * Converts a value that is an integer, non decimal, to a String using a
 * NumberFormat.
 * <p>
 * This class is a temporary as this ability exists in NumberToStringConverter
 * except that short and byte are missing.
 * </p>
 * 
 * @since 1.0
 */
public class IntegerToStringConverter : Converter {
    private final bool primitive;
    private final NumberFormat numberFormat;
    private final ClassInfo boxedType;

    /**
     * @param numberFormat
     * @param fromType
     * @param boxedType
     */
    private this(NumberFormat numberFormat, ClassInfo fromType,
            ClassInfo boxedType) {
        super(fromType, String.classinfo);
        this.primitive = fromType.isPrimitive();
        this.numberFormat = numberFormat;
        this.boxedType = boxedType;
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.eclipse.core.databinding.conversion.IConverter#convert(java.lang.Object)
     */
    public Object convert(Object fromObject) {
        // Null is allowed when the type is not primitve.
        if (fromObject is null && !primitive) {
            return ""; //$NON-NLS-1$
        }

        if (!boxedType.isInstance(fromObject)) {
            throw new IllegalArgumentException(
                    "'fromObject' is not of type [" + boxedType + "]."); //$NON-NLS-1$//$NON-NLS-2$
        }

        return numberFormat.format((cast(Number) fromObject).longValue());
    }

    /**
     * @param primitive
     * @return converter
     */
    public static IntegerToStringConverter fromShort(bool primitive) {
        return fromShort(NumberFormat.getIntegerInstance(), primitive);
    }

    /**
     * @param numberFormat
     * @param primitive
     * @return converter
     */
    public static IntegerToStringConverter fromShort(NumberFormat numberFormat,
            bool primitive) {
        return new IntegerToStringConverter(numberFormat,
                primitive ? Short.TYPE : Short.classinfo, Short.classinfo);
    }

    /**
     * @param primitive
     * @return converter
     */
    public static IntegerToStringConverter fromByte(bool primitive) {
        return fromByte(NumberFormat.getIntegerInstance(), primitive);
    }

    /**
     * @param numberFormat
     * @param primitive
     * @return converter
     */
    public static IntegerToStringConverter fromByte(NumberFormat numberFormat,
            bool primitive) {
        return new IntegerToStringConverter(numberFormat, primitive ? Byte.TYPE
                : Byte.classinfo, Byte.classinfo);
    }
}
