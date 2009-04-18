/*******************************************************************************
 * Copyright (c) 2007 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 ******************************************************************************/

module org.eclipse.core.internal.databinding.conversion.StatusToStringConverter;

import java.lang.all;

import org.eclipse.core.databinding.conversion.Converter;
import org.eclipse.core.databinding.conversion.IConverter;
import org.eclipse.core.runtime.IStatus;

/**
 * Converts an IStatus into a String.  The message of the status is the returned value.
 * 
 * @since 1.0
 */
public class StatusToStringConverter : Converter , IConverter {
    public override Object getFromType() {
        return super.getFromType();
    }
    public override Object getToType() {
        return super.getToType();
    }
    /**
     * Constructs a new instance.
     */
    public this() {
        super(typeid(IStatus), typeid(StringCls));
    }
    
    /* (non-Javadoc)
     * @see org.eclipse.core.databinding.conversion.IConverter#convert(java.lang.Object)
     */
    public Object convert(Object fromObject) {
        if (fromObject is null) {
            throw new IllegalArgumentException("Parameter 'fromObject' was null."); //$NON-NLS-1$
        }
        
        IStatus status = cast(IStatus) fromObject;
        return stringcast(status.getMessage());
    }
}
