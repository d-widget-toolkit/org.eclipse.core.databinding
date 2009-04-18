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
import java.nonstandard.RuntimeTraits;

import org.eclipse.core.databinding.BindingException;
import org.eclipse.core.databinding.conversion.IConverter;

/**
 * TheIdentityConverter. Returns the source value (the identity function).
 */
public class IdentityConverter : IConverter {

    private TypeInfo fromType;

    private TypeInfo toType;

    /**
     * @param type
     */
    public this(TypeInfo type) {
        this.fromType = type;
        this.toType = type;
        initPrimitiveMap();
    }

    /**
     * @param fromType
     * @param toType
     */
    public this(TypeInfo fromType, TypeInfo toType) {
        this.fromType = fromType;
        this.toType = toType;
        initPrimitiveMap();
    }

    private TypeInfo[][] primitiveMap;

    private void initPrimitiveMap(){
        primitiveMap = [
            [ cast(TypeInfo)Integer.TYPE, typeid(Integer) ], [ cast(TypeInfo)Short.TYPE, typeid(Short) ],
            [ cast(TypeInfo)Long.TYPE, typeid(Long) ], [ cast(TypeInfo)Double.TYPE, typeid(Double) ],
            [ cast(TypeInfo)Byte.TYPE, typeid(Byte) ], [ cast(TypeInfo)Float.TYPE, typeid(Float) ],
            [ cast(TypeInfo)Boolean.TYPE, typeid(Boolean) ],
            [ cast(TypeInfo)Character.TYPE, typeid(Character) ] ];
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.eclipse.jface.binding.converter.IConverter#convert(java.lang.Object)
     */
    public Object convert(Object source) {
        if ( isJavaPrimitive(toType)) {
            if (source is null) {
                throw new BindingException("Cannot convert null to a primitive"); //$NON-NLS-1$
            }
        }
        if (source !is null) {
            TypeInfo sourceClass = getTypeInfo(source.classinfo);
            if (isJavaPrimitive(toType) || isJavaPrimitive(sourceClass)) {
                if (sourceClass.opEquals(toType)
                        || isPrimitiveTypeMatchedWithBoxed(sourceClass, toType)) {
                    return source;
                }
                throw new BindingException(
                        "Boxed and unboxed types do not match"); //$NON-NLS-1$
            }
            if (!isImplicitly(sourceClass, toType)) {
                throw new BindingException(asClass(sourceClass).name
                        ~ " is not assignable to " ~ asClass(toType).name); //$NON-NLS-1$
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
    public bool isPrimitiveTypeMatchedWithBoxed(TypeInfo sourceClass,
            TypeInfo toClass) {
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
