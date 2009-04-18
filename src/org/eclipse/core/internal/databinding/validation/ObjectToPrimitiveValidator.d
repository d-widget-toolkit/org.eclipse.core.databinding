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
import java.nonstandard.RuntimeTraits;

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

    private TypeInfo toType;

    private static TypeInfo[][] primitiveMap;
    static this(){
        primitiveMap = [
            [ Integer.TYPE, typeid(Integer) ], [ Short.TYPE, typeid(Short) ],
            [ Long.TYPE, typeid(Long) ], [ Double.TYPE, typeid(Double) ],
            [ Byte.TYPE, typeid(Byte) ], [ Float.TYPE, typeid(Float) ],
            [ Boolean.TYPE, typeid(Boolean) ],
            [ Character.TYPE, typeid(Character) ] ];
    }

    /**
     * @param toType
     */
    public this(TypeInfo toType) {
        this.toType = toType;
    }

    protected TypeInfo getToType() {
        return this.toType;
    }

    public IStatus validate(Object value) {
        return doValidate(value);
    }

    private IStatus doValidate(Object value) {
        if (value !is null) {
            if (!mapContainsValues(toType, getTypeInfo(value.classinfo))) {
                return ValidationStatus.error(getClassHint());
            }
            return Status.OK_STATUS;
        }
        return ValidationStatus.error(getNullHint());
    }

    private bool mapContainsValues(TypeInfo toType, TypeInfo fromType) {
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
