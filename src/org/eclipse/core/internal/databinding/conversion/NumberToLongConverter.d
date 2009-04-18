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

module org.eclipse.core.internal.databinding.conversion.NumberToLongConverter;
import org.eclipse.core.internal.databinding.conversion.NumberToNumberConverter;
import org.eclipse.core.internal.databinding.conversion.StringToNumberParser;

import java.lang.all;

import com.ibm.icu.text.NumberFormat;

/**
 * Converts from a Number to a Long.
 * <p>
 * Class is thread safe.
 * </p>
 * @since 1.0
 */
public class NumberToLongConverter : NumberToNumberConverter {
    /**
     * @param numberFormat
     * @param fromType
     * @param primitive
     */
    public this(NumberFormat numberFormat, TypeInfo fromType,
            bool primitive) {
        super(numberFormat, fromType, (primitive) ? Long.TYPE : typeid(Long));
    }

    /* (non-Javadoc)
     * @see org.eclipse.core.internal.databinding.conversion.NumberToNumberConverter#doConvert(java.lang.Number)
     */
    protected Number doConvert(Number number) {
        if (StringToNumberParser.inLongRange(number)) {
            return new Long(number.longValue());
        }
        
        return null;
    }
}
