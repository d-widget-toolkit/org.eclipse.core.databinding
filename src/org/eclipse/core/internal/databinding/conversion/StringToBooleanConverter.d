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
module org.eclipse.core.internal.databinding.conversion.StringToBooleanConverter;
import org.eclipse.core.internal.databinding.conversion.StringToBooleanPrimitiveConverter;

import java.lang.all;

/**
 * StringToBooleanConverter.
 */
public class StringToBooleanConverter : StringToBooleanPrimitiveConverter {

    /*
     * (non-Javadoc)
     * 
     * @see org.eclipse.jface.binding.converter.IConverter#convert(java.lang.Object)
     */
    public Object convert(Object source) {
        String sourceString = stringcast( source);
        if ("".equals(sourceString.trim())) { //$NON-NLS-1$
            return null;
        }
        return super.convert(source);
    }

    public Object getToType() {
        return typeid(Boolean);
    }

}
