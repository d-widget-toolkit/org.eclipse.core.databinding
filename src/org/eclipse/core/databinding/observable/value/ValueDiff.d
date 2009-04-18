/*******************************************************************************
 * Copyright (c) 2006, 2007 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *******************************************************************************/

module org.eclipse.core.databinding.observable.value.ValueDiff;

import java.lang.all;
import java.nonstandard.RuntimeTraits;

import org.eclipse.core.databinding.observable.Diffs;

/**
 * @since 1.0
 * 
 */
public abstract class ValueDiff {
    /**
     * Creates a value diff.
     */
    public this() {
    }

    /**
     * @return the old value
     */
    public abstract Object getOldValue();

    /**
     * @return the new value
     */
    public abstract Object getNewValue();

    public override equals_t opEquals(Object obj) {
        if ( null !is cast(ValueDiff)obj ) {
            ValueDiff val = cast(ValueDiff) obj;

            return Diffs.equals(val.getNewValue(), getNewValue())
                    && Diffs.equals(val.getOldValue(), getOldValue());

        }
        return false;
    }
        
    public hash_t toHash() {
        final int prime = 31;
        int result = 1;
        Object nv = getNewValue();
        Object ov = getOldValue();
        result = prime * result + ((nv is null) ? 0 : nv.toHash());
        result = prime * result + ((ov is null) ? 0 : ov.toHash());
        return result;
    }

    /**
     * @see java.lang.Object#toString()
     */
    public String toString() {
        StringBuffer buffer = new StringBuffer();
        buffer
            .append(.getName(this.classinfo))
            .append("{oldValue [") //$NON-NLS-1$
            .append(getOldValue() !is null ? getOldValue().toString() : "null") //$NON-NLS-1$
            .append("], newValue [") //$NON-NLS-1$
            .append(getNewValue() !is null ? getNewValue().toString() : "null") //$NON-NLS-1$
            .append("]}"); //$NON-NLS-1$
        
        return buffer.toString();
    }
}
