/*******************************************************************************
 * Copyright (c) 2006, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *     Matthew Hall - bug 208332
 *******************************************************************************/

module org.eclipse.core.internal.databinding.observable.EmptyObservableSet;

import java.lang.all;

import java.util.Collection;
import java.util.Collections;
import java.util.Iterator;
import java.util.Set;

import org.eclipse.core.databinding.observable.IChangeListener;
import org.eclipse.core.databinding.observable.IStaleListener;
import org.eclipse.core.databinding.observable.Realm;
import org.eclipse.core.databinding.observable.set.IObservableSet;
import org.eclipse.core.databinding.observable.set.ISetChangeListener;
import org.eclipse.core.runtime.Assert;

/**
 * Singleton empty set
 */
public class EmptyObservableSet : IObservableSet {
// DWT start: additional methods in Set
    public bool add(String o) {
        return add(stringcast(o));
    }
    public bool remove(String o) {
        return remove(stringcast(o));
    }
    public bool contains(String o) {
        return contains(stringcast(o));
    }
    public int opApply (int delegate(ref Object value) dg){
        auto it = iterator();
        while(it.hasNext()){
            auto v = it.next();
            int res = dg( v );
            if( res ) return res;
        }
        return 0;
    }
// DWT end: additional methods in Set

    private static Set emptySet;
    static this(){
        emptySet = Collections.EMPTY_SET;
    }

    private Realm realm;
    private Object elementType;

    /**
     * Creates a singleton empty set. This set may be disposed multiple times
     * without any side-effects.
     * 
     * @param realm
     *            the realm of the constructed set
     */
    public this(Realm realm) {
        this(realm, null);
    }

    /**
     * Creates a singleton empty set. This set may be disposed multiple times
     * without any side-effects.
     * 
     * @param realm
     *            the realm of the constructed set
     * @param elementType
     *            the element type of the constructed set
     * @since 1.1
     */
    public this(Realm realm, Object elementType) {
        this.realm = realm;
        this.elementType = elementType;
    }

    public void addSetChangeListener(ISetChangeListener listener) {
    }

    public void removeSetChangeListener(ISetChangeListener listener) {
    }

    public Object getElementType() {
        return elementType;
    }

    public int size() {
        checkRealm();
        return 0;
    }

    private void checkRealm() {
        Assert.isTrue(realm.isCurrent(),
                "Observable cannot be accessed outside its realm"); //$NON-NLS-1$
    }

    public bool isEmpty() {
        checkRealm();
        return true;
    }

    public bool contains(Object o) {
        checkRealm();
        return false;
    }

    public Iterator iterator() {
        checkRealm();
        return emptySet.iterator();
    }

    public Object[] toArray() {
        checkRealm();
        return emptySet.toArray();
    }

    public Object[] toArray(Object[] a) {
        return emptySet.toArray(a);
    }

    public bool add(Object o) {
        throw new UnsupportedOperationException();
    }

    public bool remove(Object o) {
        throw new UnsupportedOperationException();
    }

    public bool containsAll(Collection c) {
        checkRealm();
        return c.isEmpty();
    }

    public bool addAll(Collection c) {
        throw new UnsupportedOperationException();
    }

    public bool retainAll(Collection c) {
        throw new UnsupportedOperationException();
    }

    public bool removeAll(Collection c) {
        throw new UnsupportedOperationException();
    }

    public void clear() {
        throw new UnsupportedOperationException();
    }

    public void addChangeListener(IChangeListener listener) {
    }

    public void removeChangeListener(IChangeListener listener) {
    }

    public void addStaleListener(IStaleListener listener) {
    }

    public void removeStaleListener(IStaleListener listener) {
    }

    public bool isStale() {
        checkRealm();
        return false;
    }

    public void dispose() {
    }

    public Realm getRealm() {
        return realm;
    }

    public override equals_t opEquals(Object obj) {
        checkRealm();
        if (obj is this)
            return true;
        if (obj is null)
            return false;
        if (!( null !is cast(Set)obj ))
            return false;

        return (cast(Set) obj).isEmpty();
    }

    public hash_t toHash() {
        checkRealm();
        return 0;
    }
}
