/*
 * Copyright cast(C) 2005 db4objects Inc.  http://www.db4o.com  and others.
 * 
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     db4objects - Initial API and implementation
 *     Matt Carter - Character support completed (bug 197679)
 */
module org.eclipse.core.internal.databinding.conversion.IdentityConverter;

import java.lang.all;

import org.eclipse.core.databinding.BindingException;
import org.eclipse.core.databinding.conversion.IConverter;

/**
 * TheIdentityConverter. Returns the source value (the identity function).
 */
public class IdentityConverter : IConverter {

    private ClassInfo fromType;

    private ClassInfo toType;

    /**
     * @param type
     */
    public this(ClassInfo type) {
        this.fromType = type;
        this.toType = type;
    }

    /**
     * @param fromType
     * @param toType
     */
    public this(ClassInfo fromType, ClassInfo toType) {
        this.fromType = fromType;
        this.toType = toType;
    }

    private ClassInfo[][] primitiveMap = new ClassInfo[][] [
            [ Integer.TYPE, Integer.classinfo ], [ Short.TYPE, Short.classinfo ],
            [ Long.TYPE, Long.classinfo ], [ Double.TYPE, Double.classinfo ],
            [ Byte.TYPE, Byte.classinfo ], [ Float.TYPE, Float.classinfo ],
            [ Boolean.TYPE, Boolean.classinfo ],
            [ Character.TYPE, Character.classinfo ] ];

    /*
     * (non-Javadoc)
     * 
     * @see org.eclipse.jface.binding.converter.IConverter#convert(java.lang.Object)
     */
    public Object convert(Object source) {
        if (toType.isPrimitive()) {
            if (source is null) {
                throw new BindingException("Cannot convert null to a primitive"); //$NON-NLS-1$
            }
        }
        if (source !is null) {
            ClassInfo sourceClass = source.getClass();
            if (toType.isPrimitive() || sourceClass.isPrimitive()) {
                if (sourceClass.equals(toType)
                        || isPrimitiveTypeMatchedWithBoxed(sourceClass, toType)) {
                    return source;
                }
                throw new BindingException(
                        "Boxed and unboxed types do not match"); //$NON-NLS-1$
            }
            if (!toType.isAssignableFrom(sourceClass)) {
                throw new BindingException(sourceClass.getName()
                        + " is not assignable to " + toType.getName()); //$NON-NLS-1$
            }
        }
        return source;
    }

    /**
     * (Non-API) isPrimitiveTypeMatchedWithBoxed.
     * 
     * @param sourceClass
     * @param toClass
     * @return true if sourceClass and toType are matched primitive/boxed types
     */
    public bool isPrimitiveTypeMatchedWithBoxed(ClassInfo sourceClass,
            ClassInfo toClass) {
        for (int i = 0; i < primitiveMap.length; i++) {
            if (toClass.equals(primitiveMap[i][0])
                    && sourceClass.equals(primitiveMap[i][1])) {
                return true;
            }
            if (sourceClass.equals(primitiveMap[i][0])
                    && toClass.equals(primitiveMap[i][1])) {
                return true;
            }
        }
        return false;
    }

    public Object getFromType() {
        return fromType;
    }

    public Object getToType() {
        return toType;
    }

}