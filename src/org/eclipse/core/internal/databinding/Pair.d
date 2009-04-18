/*******************************************************************************
 * Copyright (c) 2005, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *******************************************************************************/
module org.eclipse.core.internal.databinding.Pair;

import java.lang.all;

/**
 * Class Pair.  Represents a mathematical pair of objects (a, b).
 * @since 1.0
 */
public class Pair {

    /**
     * a in the pair (a, b)
     */
    public final Object a;

    /**
     * b in the pair (a, b)
     */
    public final Object b;

    /**
     * Construct a Pair(a, b)
     * 
     * @param a a in the pair (a, b)
     * @param b b in the pair (a, b)
     */
    public this(String a, String b) {
        this(stringcast(a), stringcast(b));
    }
    public this(Object a, String b) {
        this(a, stringcast(b));
    }
    public this(String a, Object b) {
        this(stringcast(a), b);
    }
    public this(Object a, Object b) {
        this.a = a;
        this.b = b;
    }

    public override hash_t toHash() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((a is null) ? 0 : a.toHash());
        result = prime * result + ((b is null) ? 0 : b.toHash());
        return result;
    }

    public override equals_t opEquals(Object obj) {
        if (this is obj)
            return true;
        if (obj is null)
            return false;
        if (this.classinfo !is obj.classinfo)
            return false;
        Pair other = cast(Pair) obj;
        if (a is null) {
            if (other.a !is null)
                return false;
        } else if (!a.opEquals(other.a))
            return false;
        if (b is null) {
            if (other.b !is null)
                return false;
        } else if (!b.opEquals(other.b))
            return false;
        return true;
    }

}
