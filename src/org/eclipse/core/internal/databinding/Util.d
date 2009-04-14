/*******************************************************************************
 * Copyright (c) 2006 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 ******************************************************************************/

module org.eclipse.core.internal.databinding.Util;

import java.lang.all;

/**
 * @since 3.3
 * 
 */
public class Util {

    /**
     * Checks whether the two objects are <code>null</code> -- allowing for
     * <code>null</code>.
     * 
     * @param left
     *            The left object to compare; may be <code>null</code>.
     * @param right
     *            The right object to compare; may be <code>null</code>.
     * @return <code>true</code> if the two objects are equivalent;
     *         <code>false</code> otherwise.
     */
    public static final bool equals(Object left, Object right) {
        return left is null ? right is null : ((right !is null) && left
                .opEquals(right));
    }
}
