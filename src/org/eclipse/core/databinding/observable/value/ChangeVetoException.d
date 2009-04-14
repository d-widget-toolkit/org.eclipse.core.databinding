/*******************************************************************************
 * Copyright (c) 2005, 2006 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *******************************************************************************/
module org.eclipse.core.databinding.observable.value.ChangeVetoException;

import java.lang.all;

/**
 * @since 1.0
 *
 */
public class ChangeVetoException : RuntimeException {
    
    /**
     * @param string
     */
    public this(String string) {
        super(string);
    }

    private static final long serialVersionUID = 1L;

}
