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

    private Class toType;

    private static Class[][] primitiveMap;
    static this(){
        primitiveMap = [
            [ Integer.TYPE, Class.fromType!(Integer) ], [ Short.TYPE, Class.fromType!(Short) ],
            [ Long.TYPE, Class.fromType!(Long) ], [ Double.TYPE, Class.fromType!(Double) ],
            [ Byte.TYPE, Class.fromType!(Byte) ], [ Float.TYPE, Class.fromType!(Float) ],
            [ Boolean.TYPE, Class.fromType!(Boolean) ],
            [ Character.TYPE, Class.fromType!(Character) ] ];
    }

    /**
     * @param toType
     */
    public this(Class toType) {
        this.toType = toType;
    }

    protected Class getToType() {
        return this.toType;
    }

    public IStatus validate(Object value) {
        return doValidate(value);
    }

    private IStatus doValidate(Object value) {
        if (value !is null) {
            if (!mapContainsValues(toType, Class.fromObject(value))) {
                return ValidationStatus.error(getClassHint());
            }
            return Status.OK_STATUS;
        }
        return ValidationStatus.error(getNullHint());
    }

    private bool mapContainsValues(Class toType, Class fromType) {
        for (int i = 0; i < primitiveMap.length; i++) {
            if ((primitiveMap[i][0] == toType )
                    && (primitiveMap[i][1] == fromType )) {
                return true;
            }
        }
        return false;
    }

    /**
     * @return a hint string
     */
    public String getNullHint() {
        return BindingMessages.getString(BindingMessages.VALIDATE_CONVERSION_TO_PRIMITIVE);
    }

    /**
     * @return a hint string
     */
    public String getClassHint() {
        return BindingMessages
                .getString(BindingMessages.VALIDATE_CONVERSION_FROM_CLASS_TO_PRIMITIVE);
    }
}
