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

module org.eclipse.core.internal.databinding.validation.NumberToShortValidator;
import org.eclipse.core.internal.databinding.validation.NumberToNumberValidator;

import java.lang.all;

import org.eclipse.core.internal.databinding.conversion.NumberToShortConverter;
import org.eclipse.core.internal.databinding.conversion.StringToNumberParser;

/**
 * Validates if a Number can fit in a Short.
 * <p>
 * Class is thread safe.
 * </p>
 * 
 * @since 1.0
 */
public class NumberToShortValidator : NumberToNumberValidator {
    private static Short MIN;
    private static Short MAX;
    
    /**
     * @param converter
     */
    public this(NumberToShortConverter converter) {
        if( MIN is null || MAX is null ){
            MIN = new Short(Short.MIN_VALUE);
            MAX = new Short(Short.MAX_VALUE);
        }
        super(converter, MIN, MAX);
    }
    
    /* (non-Javadoc)
     * @see org.eclipse.core.internal.databinding.validation.NumberToNumberValidator#inRange(java.lang.Number)
     */
    protected bool inRange(Number number) {
        return StringToNumberParser.inShortRange(number);
    }
}
