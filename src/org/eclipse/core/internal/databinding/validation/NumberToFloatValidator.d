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

module org.eclipse.core.internal.databinding.validation.NumberToFloatValidator;

import java.lang.all;

import org.eclipse.core.internal.databinding.conversion.NumberToFloatConverter;
import org.eclipse.core.internal.databinding.conversion.StringToNumberParser;

/**
 * Validates if a Number can fit in a Float.
 * <p>
 * Class is thread safe.
 * </p>
 * @since 1.0
 */
public class NumberToFloatValidator : NumberToNumberValidator {
    private static final Float MIN = new Floatcast(Float.MIN_VALUE);
    private static final Float MAX = new Floatcast(Float.MAX_VALUE);
    
    /**
     * @param converter
     */
    public this(NumberToFloatConverter converter) {
        super(converter, MIN, MAX);
    }

    /* (non-Javadoc)
     * @see org.eclipse.core.internal.databinding.validation.NumberToNumberValidator#inRange(java.lang.Number)
     */
    protected bool inRange(Number number) {
        return StringToNumberParser.inFloatRange(number);
    }
}
