/*******************************************************************************
 * Copyright (c) 2006 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *     Daniel Kruegler - bug 137435
 ******************************************************************************/

module org.eclipse.core.internal.databinding.IdentityWrapper;

import java.lang.all;

/**
 * Used for wrapping objects that define their own implementations of equals()
 * and toHash() when putting them in sets or hashmaps to ensure identity
 * comparison.
 * 
 * @since 1.0
 * 
 */
public class IdentityWrapper {
    final Object o;

    /**
     * @param o
     */
    public this(Object o) {
        this.o = o;
    }
    
    /**
     * @return the unwrapped object
     */
    public Object unwrap() {
        return o;
    }

    public override equals_t opEquals(Object obj) {
        if (obj is null || obj.classinfo !is IdentityWrapper.classinfo) {
            return false;
        }
        return o is (cast(IdentityWrapper) obj).o;
    }

    public hash_t toHash() {
        return System.identityHashCode(o);
    }
}
