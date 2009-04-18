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

module org.eclipse.core.databinding.observable.set.ObservableSet;
import org.eclipse.core.databinding.observable.set.ISetChangeListener;
import org.eclipse.core.databinding.observable.set.SetDiff;
import org.eclipse.core.databinding.observable.set.SetChangeEvent;
import org.eclipse.core.databinding.observable.set.IObservableSet;

import java.lang.all;

import java.util.Collection;
import java.util.Iterator;
import java.util.Set;

import org.eclipse.core.databinding.observable.AbstractObservable;
import org.eclipse.core.databinding.observable.ObservableTracker;
import org.eclipse.core.databinding.observable.Realm;

/**
 * 
 * Abstract implementation of {@link IObservableSet}. 
 * 
 * <p>
 * This class is thread safe. All state accessing methods must be invoked from
 * the {@link Realm#isCurrent() current realm}. Methods for adding and removing
 * listeners may be invoked from any thread.
 * </p>
 * 
 * @since 1.0
 * 
 */
public abstract class ObservableSet : AbstractObservable ,
        IObservableSet {
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
    protected Set wrappedSet;

    private bool stale = false;

    protected Object elementType;

    protected this(Set wrappedSet, Object elementType) {
        this(Realm.getDefault(), wrappedSet, elementType);
    }

    protected this(Realm realm, Set wrappedSet, Object elementType) {
        super(realm);
        this.wrappedSet = wrappedSet;
        this.elementType = elementType;
    }
    
    public synchronized void addSetChangeListener(ISetChangeListener listener) {
        addListener(SetChangeEvent.TYPE, listener);
    }

    public synchronized void removeSetChangeListener(ISetChangeListener listener) {
        removeListener(SetChangeEvent.TYPE, listener);
    }

    protected void fireSetChange(SetDiff diff) {
        // fire general change event first
        super.fireChange();

        fireEvent(new SetChangeEvent(this, diff));
    }
    
    public bool contains(Object o) {
        getterCalled();
        return wrappedSet.contains(o);
    }

    public bool containsAll(Collection c) {
        getterCalled();
        return wrappedSet.containsAll(c);
    }

    public override equals_t opEquals(Object o) {
        getterCalled();
        return wrappedSet.opEquals(o);
    }

    public hash_t toHash() {
        getterCalled();
        return wrappedSet.toHash();
    }

    public bool isEmpty() {
        getterCalled();
        return wrappedSet.isEmpty();
    }

    public Iterator iterator() {
        getterCalled();
        final Iterator wrappedIterator = wrappedSet.iterator();
        return new class() Iterator {

            public void remove() {
                throw new UnsupportedOperationException();
            }

            public bool hasNext() {
                ObservableTracker.getterCalled(this.outer);
                return wrappedIterator.hasNext();
            }

            public Object next() {
                ObservableTracker.getterCalled(this.outer);
                return wrappedIterator.next();
            }
        };
    }

    public int size() {
        getterCalled();
        return wrappedSet.size();
    }

    public Object[] toArray() {
        getterCalled();
        return wrappedSet.toArray();
    }

    public Object[] toArray(Object[] a) {
        getterCalled();
        return wrappedSet.toArray(a);
    }

    public String toString() {
        getterCalled();
        return wrappedSet.toString();
    }

    protected void getterCalled() {
        ObservableTracker.getterCalled(this);
    }

    public bool add(Object o) {
        throw new UnsupportedOperationException();
    }

    public bool addAll(Collection c) {
        throw new UnsupportedOperationException();
    }

    public bool remove(Object o) {
        throw new UnsupportedOperationException();
    }

    public bool removeAll(Collection c) {
        throw new UnsupportedOperationException();
    }

    public bool retainAll(Collection c) {
        throw new UnsupportedOperationException();
    }

    public void clear() {
        throw new UnsupportedOperationException();
    }

    /**
     * @return Returns the stale state.
     */
    public bool isStale() {
        getterCalled();
        return stale;
    }

    /**
     * @param stale
     *            The stale state to set. This will fire a stale event if the
     *            given bool is true and this observable set was not already
     *            stale.
     */
    public void setStale(bool stale) {
        checkRealm();
        bool wasStale = this.stale;
        this.stale = stale;
        if (!wasStale && stale) {
            fireStale();
        }
    }

    /**
     * @param wrappedSet The wrappedSet to set.
     */
    protected void setWrappedSet(Set wrappedSet) {
        this.wrappedSet = wrappedSet;
    }

    protected void fireChange() {
        throw new RuntimeException("fireChange should not be called, use fireSetChange() instead"); //$NON-NLS-1$
    }
    
    /* (non-Javadoc)
     * @see org.eclipse.jface.provisional.databinding.observable.AbstractObservable#dispose()
     */
    public synchronized void dispose() {
        super.dispose();
    }
    
    public Object getElementType() {
        return elementType;
    }
}
