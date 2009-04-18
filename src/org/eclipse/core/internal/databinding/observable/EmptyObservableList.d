/*******************************************************************************
 * Copyright (c) 2006, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *     Matthew Hall - bug 208858
 *     Matthew Hall - bug 208332
 *******************************************************************************/

module org.eclipse.core.internal.databinding.observable.EmptyObservableList;

import java.lang.all;

import java.util.Collection;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.ListIterator;

import org.eclipse.core.databinding.observable.IChangeListener;
import org.eclipse.core.databinding.observable.IStaleListener;
import org.eclipse.core.databinding.observable.Realm;
import org.eclipse.core.databinding.observable.list.IListChangeListener;
import org.eclipse.core.databinding.observable.list.IObservableList;
import org.eclipse.core.runtime.Assert;

/**
 * Singleton empty list
 */
public class EmptyObservableList : IObservableList {
// DWT start: additional methods in List
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
    public String[] toArray( String[] a ){
        auto d = toArray();
        if( a.length < d.length ){
            a.length = d.length;
        }
        for( int i = 0; i < d.length; i++ ){
            a[i] = stringcast(d[i]);
        }
        return a;
    }
// DWT end: additional methods in List

    private static List emptyList;
    static this(){
        emptyList = Collections.EMPTY_LIST;
    }

    private Realm realm;
    private Object elementType;

    /**
     * Creates an empty list. This list may be disposed multiple times
     * without any side-effects.
     * 
     * @param realm
     *            the realm of the constructed list
     */
    public this(Realm realm) {
        this(realm, null);
    }

    /**
     * Creates an empty list. This list may be disposed multiple times
     * without any side-effects.
     * 
     * @param realm
     *            the realm of the constructed list
     * @param elementType
     *            the element type of the constructed list
     * @since 1.1
     */
    public this(Realm realm, Object elementType) {
        this.realm = realm;
        this.elementType = elementType;
    }

    public void addListChangeListener(IListChangeListener listener) {
        // ignore
    }

    public void removeListChangeListener(IListChangeListener listener) {
        // ignore
    }

    public Object getElementType() {
        return elementType;
    }

    public int size() {
        checkRealm();
        return 0;
    }

    void checkRealm() {
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
        return emptyList.iterator();
    }

    public Object[] toArray() {
        checkRealm();
        return emptyList.toArray();
    }

    public Object[] toArray(Object[] a) {
        return emptyList.toArray(a);
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

    public bool addAll(int index, Collection c) {
        throw new UnsupportedOperationException();
    }

    public Object get(int index) {
        return emptyList.get(index);
    }

    public int indexOf(Object o) {
        return -1;
    }

    public int lastIndexOf(Object o) {
        return -1;
    }

    public ListIterator listIterator() {
        return emptyList.listIterator();
    }

    public ListIterator listIterator(int index) {
        return emptyList.listIterator(index);
    }

    public Object remove(int index) {
        throw new UnsupportedOperationException();
    }

    public Object set(int index, Object element) {
        throw new UnsupportedOperationException();
    }

    public Object move(int oldIndex, int newIndex) {
        throw new UnsupportedOperationException();
    }

    public List subList(int fromIndex, int toIndex) {
        return emptyList.subList(fromIndex, toIndex);
    }

    public void add(int index, Object o) {
        throw new UnsupportedOperationException();
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
        if (!( null !is cast(List)obj ))
            return false;

        return (cast(List) obj).isEmpty();
    }

    public hash_t toHash() {
        checkRealm();
        return 1;
    }
}
