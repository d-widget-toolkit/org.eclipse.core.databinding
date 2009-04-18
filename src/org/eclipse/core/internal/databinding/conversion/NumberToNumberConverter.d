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

module org.eclipse.core.internal.databinding.conversion.NumberToNumberConverter;
import org.eclipse.core.internal.databinding.conversion.StringToNumberParser;

import java.lang.all;
import java.nonstandard.RuntimeTraits;

import org.eclipse.core.databinding.conversion.Converter;

import com.ibm.icu.text.NumberFormat;

/**
 * Base class for number to number converters.
 * <p>
 * This class is thread safe.
 * </p>
 * 
 * @since 1.0
 */
public abstract class NumberToNumberConverter : Converter {
    private NumberFormat numberFormat;

    private bool primitive;

    private String outOfRangeMessage;

    protected this(NumberFormat numberFormat,
            TypeInfo fromType, TypeInfo toType) {
        super(fromType, toType);
        this.numberFormat = numberFormat;
        this.primitive = isJavaPrimitive(toType);
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.eclipse.core.databinding.conversion.IConverter#convert(java.lang.Object)
     */
    // DWT not final, need to override to reimplement interface IConvert
    public /+final+/ Object convert(Object fromObject) {
        if (fromObject is null) {
            if (primitive) {
                throw new IllegalArgumentException(
                        "Parameter 'fromObject' cannot be null."); //$NON-NLS-1$    
            }

            return null;
        }

        if (!( null !is cast(Number)fromObject )) {
            throw new IllegalArgumentException(
                    "Parameter 'fromObject' must be of type Number."); //$NON-NLS-1$
        }

        Number number = cast(Number) fromObject;
        Number result = doConvert(number);

        if (result !is null) {
            return result;
        }

        synchronized (this) {
            if (outOfRangeMessage is null) {
                outOfRangeMessage = StringToNumberParser
                        .createOutOfRangeMessage(new Short(Short.MIN_VALUE),
                                new Short(Short.MAX_VALUE), numberFormat);
            }

            throw new IllegalArgumentException(outOfRangeMessage);
        }
    }

    /**
     * Invoked when the number should converted.
     * 
     * @param number
     * @return number if conversion was successfule, <code>null</code> if the
     *         number was out of range
     */
    protected abstract Number doConvert(Number number);

    /**
     * NumberFormat being used by the converter. Access to the format must be
     * synchronized on the number format instance.
     * 
     * @return number format
     */
    public NumberFormat getNumberFormat() {
        return numberFormat;
    }
}
