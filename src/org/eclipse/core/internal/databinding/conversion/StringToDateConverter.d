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
module org.eclipse.core.internal.databinding.conversion.StringToDateConverter;
import org.eclipse.core.internal.databinding.conversion.DateConversionSupport;

import java.lang.all;

import java.util.Date;

import org.eclipse.core.databinding.conversion.IConverter;


/**
 * Convert a String to a java.util.Date, respecting the current locale
 * 
 * @since 1.0
 */
public class StringToDateConverter : DateConversionSupport , IConverter {
    public Object convert(Object source) {
        return parse(source.toString());
    }

    public Object getFromType() {
        return typeid(StringCls);
    }

    public Object getToType() {
        return typeid(Date);
    }   
}
