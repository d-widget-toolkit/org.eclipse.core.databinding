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

module org.eclipse.core.internal.databinding.conversion.NumberToBigDecimalConverter;
import org.eclipse.core.internal.databinding.conversion.NumberToNumberConverter;

import java.lang.all;

import java.math.BigDecimal;
import java.math.BigInteger;

import com.ibm.icu.text.NumberFormat;

/**
 * Converts from a Number to a BigDecimal.
 * <p>
 * Class is thread safe.
 * </p>
 * 
 * @since 1.0
 */
public class NumberToBigDecimalConverter : NumberToNumberConverter {
    /**
     * @param numberFormat
     * @param fromType
     */
    public this(NumberFormat numberFormat, TypeInfo fromType) {     
        super(numberFormat, fromType, typeid(BigDecimal));
    }

    /* (non-Javadoc)
     * @see org.eclipse.core.internal.databinding.conversion.NumberToNumberConverter#doConvert(java.lang.Number)
     */
    protected Number doConvert(Number number) {
        if ( null !is cast(BigInteger)number ) {
            return new BigDecimal(cast(BigInteger) number);
        }
        
        return new BigDecimal(number.doubleValue());
    }
}
