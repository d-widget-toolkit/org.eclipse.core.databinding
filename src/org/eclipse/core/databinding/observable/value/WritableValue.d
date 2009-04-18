/*******************************************************************************
 * Copyright (c) 2006, 2007 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *     Brad Reynolds - bug 158687
 *     Brad Reynolds - bug 164653, 147515
 *******************************************************************************/

module org.eclipse.core.databinding.observable.value.WritableValue;
import org.eclipse.core.databinding.observable.value.AbstractObservableValue;

import java.lang.all;

import org.eclipse.core.databinding.observable.Diffs;
import org.eclipse.core.databinding.observable.Realm;

/**
 * Mutable (writable) implementation of {@link IObservableValue} that will maintain a value and fire
 * change events when the value changes.
 * <p>
 * This class is thread safe. All state accessing methods must be invoked from
 * the {@link Realm#isCurrent() current realm}. Methods for adding and removing
 * listeners may be invoked from any thread.
 * </p>
 * @since 1.0
 */
public class WritableValue : AbstractObservableValue {

    private final Object valueType;

    /**
     * Constructs a new instance with the default realm, a <code>null</code>
     * value type, and a <code>null</code> value.
     */
    public this() {
        this(null, null);
    }

    /**
     * Constructs a new instance with the default realm.
     * 
     * @param initialValue
     *            can be <code>null</code>
     * @param valueType
     *            can be <code>null</code>
     */
    public this(Object initialValue, Object valueType) {
        this(Realm.getDefault(), initialValue, valueType);
    }

    /**
     * Constructs a new instance with the provided <code>realm</code>, a
     * <code>null</code> value type, and a <code>null</code> initial value.
     * 
     * @param realm
     */
    public this(Realm realm) {
        this(realm, null, null);
    }

    /**
     * Constructs a new instance.
     * 
     * @param realm
     * @param initialValue
     *            can be <code>null</code>
     * @param valueType
     *            can be <code>null</code>
     */
    public this(Realm realm, Object initialValue, Object valueType) {
        super(realm);
        this.valueType = valueType;
        this.value = initialValue;
    }

    private Object value = null;

    public Object doGetValue() {
        return value;
    }

    /**
     * @param value
     *            The value to set.
     */
    public void doSetValue(Object value) {
        bool changed = false;

        if (this.value is null && value !is null) {
            changed = true;
        } else if (this.value !is null && !this.value.opEquals(value)) {
            changed = true;
        }

        if (changed) {
            fireValueChange(Diffs.createValueDiff(this.value, this.value = value));
        }
    }

    public Object getValueType() {
        return valueType;
    }

    /**
     * @param elementType can be <code>null</code>
     * @return new instance with the default realm and a value of <code>null</code>
     */
    public static WritableValue withValueType(Object elementType) {
        return new WritableValue(Realm.getDefault(), null, elementType);
    }
}
