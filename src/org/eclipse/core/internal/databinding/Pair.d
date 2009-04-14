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
    public this(Object a, Object b) {
        this.a = a;
        this.b = b;
    }

    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((a is null) ? 0 : a.hashCode());
        result = prime * result + ((b is null) ? 0 : b.hashCode());
        return result;
    }

    public override bool opEquals(Object obj) {
        if (this is obj)
            return true;
        if (obj is null)
            return false;
        if (getClass() !is obj.getClass())
            return false;
        Pair other = cast(Pair) obj;
        if (a is null) {
            if (other.a !is null)
                return false;
        } else if (!a.equals(other.a))
            return false;
        if (b is null) {
            if (other.b !is null)
                return false;
        } else if (!b.equals(other.b))
            return false;
        return true;
    }

}
