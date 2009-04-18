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

module org.eclipse.core.internal.databinding.validation.NumberToDoubleValidator;
import org.eclipse.core.internal.databinding.validation.NumberToNumberValidator;

import java.lang.all;

import org.eclipse.core.internal.databinding.conversion.NumberToDoubleConverter;
import org.eclipse.core.internal.databinding.conversion.StringToNumberParser;

/**
 * Validates if a Number can fit in a Double.
 * <p>
 * Class is thread safe.
 * </p>
 * @since 1.0
 */
public class NumberToDoubleValidator : NumberToNumberValidator {
    private static Double MIN;
    private static Double MAX;
    
    /**
     * @param converter
     */
    public this(NumberToDoubleConverter converter) {
        if( MIN is null || MAX is null ){
            MIN = new Double(Double.MIN_VALUE);
            MAX = new Double(Double.MAX_VALUE);
        }
        super(converter, MIN, MAX);
    }

    /* (non-Javadoc)
     * @see org.eclipse.core.internal.databinding.validation.NumberToNumberValidator#inRange(java.lang.Number)
     */
    protected bool inRange(Number number) {
        return StringToNumberParser.inDoubleRange(number);
    }
}
