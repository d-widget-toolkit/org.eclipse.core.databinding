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

module org.eclipse.core.internal.databinding.validation.NumberToLongValidator;

import java.lang.all;

import org.eclipse.core.internal.databinding.conversion.NumberToLongConverter;
import org.eclipse.core.internal.databinding.conversion.StringToNumberParser;

/**
 * Validates if a Number can fit in a Long.
 * <p>
 * Class is thread safe.
 * </p>
 * @since 1.0
 */
public class NumberToLongValidator : NumberToNumberValidator {
    private static final Long MIN = new Longcast(Long.MIN_VALUE);
    private static final Long MAX = new Longcast(Long.MAX_VALUE);
    
    /**
     * @param converter
     */
    public this(NumberToLongConverter converter) {
        super(converter, MIN, MAX);
    }

    /* (non-Javadoc)
     * @see org.eclipse.core.internal.databinding.validation.NumberToNumberValidator#inRange(java.lang.Number)
     */
    protected bool inRange(Number number) {
        return StringToNumberParser.inLongRange(number);
    }
}
