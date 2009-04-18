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

module org.eclipse.core.internal.databinding.validation.AbstractStringToNumberValidator;
import org.eclipse.core.internal.databinding.validation.NumberFormatConverter;

import java.lang.all;
import java.nonstandard.RuntimeTraits;

import org.eclipse.core.databinding.validation.IValidator;
import org.eclipse.core.databinding.validation.ValidationStatus;
import org.eclipse.core.internal.databinding.conversion.StringToNumberParser;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;

/**
 * Validates a number that is to be converted by a {@link NumberFormatConverter}.
 * Validation is comprised of parsing the String and range checks.
 * 
 * @since 1.0
 */
public abstract class AbstractStringToNumberValidator : IValidator {
    private final NumberFormatConverter converter;
    private final bool toPrimitive;

    private final Number min;
    private final Number max;

    private String outOfRangeMessage;

    /**
     * Constructs a new instance.
     * 
     * @param converter converter and thus formatter to be used in validation
     * @param min minimum value, used for reporting a range error to the user
     * @param max maximum value, used for reporting a range error to the user
     */
    protected this(NumberFormatConverter converter,
            Number min, Number max) {
        this.converter = converter;
        this.min = min;
        this.max = max;

        if (null !is cast(TypeInfo)converter.getToType()) {
            TypeInfo clazz = cast(TypeInfo) converter.getToType();
            toPrimitive = isJavaPrimitive(clazz);
        } else {
            toPrimitive = false;
        }
    }

    /**
     * Validates the provided <code>value</code>.  An error status is returned if:
     * <ul>
     * <li>The value cannot be parsed.</li>
     * <li>The value is out of range.</li>
     * </ul>
     * 
     * @see org.eclipse.core.databinding.validation.IValidator#validate(java.lang.Object)
     */
    public final IStatus validate(Object value) {
        StringToNumberParser.ParseResult result = StringToNumberParser.parse(value, converter
                .getNumberFormat(), toPrimitive);

        if (result.getNumber() !is null) {
            if (!isInRange(result.getNumber())) {
                if (outOfRangeMessage is null) {
                    outOfRangeMessage = StringToNumberParser
                            .createOutOfRangeMessage(min, max, converter
                                    .getNumberFormat());
                }

                return ValidationStatus.error(outOfRangeMessage);
            }
        } else if (result.getPosition() !is null) {
            String parseErrorMessage = StringToNumberParser.createParseErrorMessage(
                    stringcast(value), result.getPosition());

            return ValidationStatus.error(parseErrorMessage);
        }

        return Status.OK_STATUS;
    }

    /**
     * Invoked by {@link #validatecast(Object)} when the range is to be validated.
     * 
     * @param number
     * @return <code>true</code> if in range
     */
    protected abstract bool isInRange(Number number);
}
