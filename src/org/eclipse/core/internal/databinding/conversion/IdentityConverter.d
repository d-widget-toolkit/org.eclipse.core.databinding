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

    private Class fromType;

    private Class toType;

    /**
     * @param type
     */
    public this(Class type) {
        this.fromType = type;
        this.toType = type;
        initPrimitiveMap();
    }

    /**
     * @param fromType
     * @param toType
     */
    public this(Class fromType, Class toType) {
        this.fromType = fromType;
        this.toType = toType;
        initPrimitiveMap();
    }

    private Class[][] primitiveMap;

    private void initPrimitiveMap(){
        primitiveMap = [
            [ cast(Class)Integer.TYPE, Class.fromType!(Integer) ], [ cast(Class)Short.TYPE, Class.fromType!(Short) ],
            [ cast(Class)Long.TYPE, Class.fromType!(Long) ], [ cast(Class)Double.TYPE, Class.fromType!(Double) ],
            [ cast(Class)Byte.TYPE, Class.fromType!(Byte) ], [ cast(Class)Float.TYPE, Class.fromType!(Float) ],
            [ cast(Class)Boolean.TYPE, Class.fromType!(Boolean) ],
            [ cast(Class)Character.TYPE, Class.fromType!(Character) ] ];
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.eclipse.jface.binding.converter.IConverter#convert(java.lang.Object)
     */
    public Object convert(Object source) {
        if ( toType.isPrimitive()) {
            if (source is null) {
                throw new BindingException("Cannot convert null to a primitive"); //$NON-NLS-1$
            }
        }
        if (source !is null) {
            Class sourceClass = Class.fromObject(source);
            if (toType.isPrimitive() || sourceClass.isPrimitive()) {
                if (sourceClass.opEquals(toType)
                        || isPrimitiveTypeMatchedWithBoxed(sourceClass, toType)) {
                    return source;
                }
                throw new BindingException(
                        "Boxed and unboxed types do not match"); //$NON-NLS-1$
            }
            if (!toType.isAssignableFrom(sourceClass)) {
                throw new BindingException(Class.fromObject(sourceClass).getName()
                        ~ " is not assignable to " ~ Class.fromObject(toType).getName()); //$NON-NLS-1$
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
    public bool isPrimitiveTypeMatchedWithBoxed(Class sourceClass,
            Class toClass) {
        for (int i = 0; i < primitiveMap.length; i++) {
            if (toClass.opEquals(primitiveMap[i][0])
                    && sourceClass.opEquals(primitiveMap[i][1])) {
                return true;
            }
            if (sourceClass.opEquals(primitiveMap[i][0])
                    && toClass.opEquals(primitiveMap[i][1])) {
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
