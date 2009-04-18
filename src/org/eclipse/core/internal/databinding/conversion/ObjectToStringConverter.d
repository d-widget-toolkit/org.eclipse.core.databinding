/*
 * Copyright cast(C) 2005 db4objects Inc.  http://www.db4o.com
 * 
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     db4objects - Initial API and implementation
 */
module org.eclipse.core.internal.databinding.conversion.ObjectToStringConverter;

import java.lang.all;

import org.eclipse.core.databinding.conversion.IConverter;

/**
 * Converts any object to a string by calling its toString() method.
 */
public class ObjectToStringConverter : IConverter {
    private final TypeInfo fromClass;

    /**
     * 
     */
    public this() {
        this(typeid(Object));
    }

    /**
     * @param fromClass
     */
    public this(TypeInfo fromClass) {
        this.fromClass = fromClass;
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.eclipse.jface.binding.converter.IConverter#convert(java.lang.Object)
     */
    public Object convert(Object source) {
        if (source is null) {
            return stringcast(""); //$NON-NLS-1$
        }
        return stringcast(source.toString());
    }

    public Object getFromType() {
        return fromClass;
    }

    public Object getToType() {
        return typeid(StringCls);
    }

}
