/*******************************************************************************
 * Copyright (c) 2006, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *     Tom Schindl<tom.schindl@bestsolution.at> - bugfix for 217940
 *******************************************************************************/

module org.eclipse.core.internal.databinding.validation.ObjectToPrimitiveValidator;

import java.lang.all;

import org.eclipse.core.databinding.validation.IValidator;
import org.eclipse.core.databinding.validation.ValidationStatus;
import org.eclipse.core.internal.databinding.BindingMessages;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;

/**
 * @since 3.2
 *
 */
public class ObjectToPrimitiveValidator : IValidator {

    private ClassInfo toType;

    private ClassInfo[][] primitiveMap = new ClassInfo[][] [
            [ Integer.TYPE, Integer.classinfo ], [ Short.TYPE, Short.classinfo ],
            [ Long.TYPE, Long.classinfo ], [ Double.TYPE, Double.classinfo ],
            [ Byte.TYPE, Byte.classinfo ], [ Float.TYPE, Float.classinfo ],
            [ Boolean.TYPE, Boolean.classinfo ],
            [ Character.TYPE, Character.classinfo ] ];

    /**
     * @param toType
     */
    public this(ClassInfo toType) {
        this.toType = toType;
    }

    protected ClassInfo getToType() {
        return this.toType;
    }

    public IStatus validate(Object value) {
        return doValidate(value);
    }

    private IStatus doValidate(Object value) {
        if (value !is null) {
            if (!mapContainsValues(toType, value.getClass())) {
                return ValidationStatus.error(getClassHint());
            }
            return Status.OK_STATUS;
        }
        return ValidationStatus.error(getNullHint());
    }

    private bool mapContainsValues(ClassInfo toType, ClassInfo fromType) {
        for (int i = 0; i < primitiveMap.length; i++) {
            if ((primitiveMap[i][0].equals(toType))
                    && (primitiveMap[i][1].equals(fromType))) {
                return true;
            }
        }
        return false;
    }

    /**
     * @return a hint string
     */
    public String getNullHint() {
        return BindingMessages.getStringcast(BindingMessages.VALIDATE_CONVERSION_TO_PRIMITIVE);
    }

    /**
     * @return a hint string
     */
    public String getClassHint() {
        return BindingMessages
                .getStringcast(BindingMessages.VALIDATE_CONVERSION_FROM_CLASS_TO_PRIMITIVE);
    }
}
