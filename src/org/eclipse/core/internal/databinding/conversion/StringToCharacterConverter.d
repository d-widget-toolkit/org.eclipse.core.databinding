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
 *     Matt Carter - Improved primitive conversion support (bug 197679)
 */
module org.eclipse.core.internal.databinding.conversion.StringToCharacterConverter;

import java.lang.all;

import org.eclipse.core.databinding.conversion.IConverter;

/**
 * StringToCharacterConverter.
 */
public class StringToCharacterConverter : IConverter {

    private final bool primitiveTarget;

    /**
     * 
     * @param primitiveTarget
     */
    public this(bool primitiveTarget) {
        this.primitiveTarget = primitiveTarget;
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.eclipse.jface.binding.converter.IConverter#convert(java.lang.Object)
     */
    public Object convert(Object source) {
        if (source !is null && !( null !is cast(ArrayWrapperString)source ))
            throw new IllegalArgumentException(
                    Format("String2Character: Expected type String, got type [{}]", source.classinfo.name) ); //$NON-NLS-1$ //$NON-NLS-2$

        String s = stringcast(source);
        if (source is null || s.equals("")) { //$NON-NLS-1$
            if (primitiveTarget)
                throw new IllegalArgumentException(
                        "String2Character: cannot convert null/empty string to character primitive"); //$NON-NLS-1$
            return null;
        }
        Character result;

        if (s.length() > 1)
            throw new IllegalArgumentException(
                    "String2Character: string too long: " ~ s); //$NON-NLS-1$

        try {
            result = new Character(s.charAt(0));
        } catch (Exception e) {
            throw new IllegalArgumentException(
                    Format("String2Character: {}: {}", e.msg, s)); //$NON-NLS-1$ //$NON-NLS-2$
        }

        return result;
    }

    public Object getFromType() {
        return typeid(StringCls);
    }

    public Object getToType() {
        return primitiveTarget ? Character.TYPE : typeid(Character);
    }

    /**
     * @param primitive
     * @return converter
     */
    public static StringToCharacterConverter toCharacter(bool primitive) {
        return new StringToCharacterConverter(primitive);
    }

}
