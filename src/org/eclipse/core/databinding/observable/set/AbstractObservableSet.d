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

module org.eclipse.core.databinding.observable.set.AbstractObservableSet;

import java.lang.all;

import java.util.Collection;
import java.util.Iterator;
import java.util.Set;

import org.eclipse.core.databinding.observable.AbstractObservable;
import org.eclipse.core.databinding.observable.ChangeSupport;
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
 */
public abstract class AbstractObservableSet : AbstractObservable ,
        IObservableSet {

    private ChangeSupport changeSupport;

    private bool stale = false;

    protected this() {
        this(Realm.getDefault());
    }
    
    protected void firstListenerAdded() {
        super.firstListenerAdded();
    }

    protected void lastListenerRemoved() {
        super.lastListenerRemoved();
    }
    
    protected this(Realm realm) {
        super(realm);
        changeSupport = new class(realm) ChangeSupport {
            protected void firstListenerAdded() {
                this.outer.firstListenerAdded();
            }
            protected void lastListenerRemoved() {
                this.outer.lastListenerRemoved();
            }
        };
    }
    
    public synchronized void addSetChangeListener(ISetChangeListener listener) {
        changeSupport.addListener(SetChangeEvent.TYPE, listener);
    }

    public synchronized void removeSetChangeListener(ISetChangeListener listener) {
        changeSupport.removeListener(SetChangeEvent.TYPE, listener);
    }

    protected abstract Set getWrappedSet();
    
    protected void fireSetChange(SetDiff diff) {
        // fire general change event first
        super.fireChange();

        changeSupport.fireEvent(new SetChangeEvent(this, diff));
    }
    
    public bool contains(Object o) {
        getterCalled();
        return getWrappedSet().contains(o);
    }

    public bool containsAll(Collection c) {
        getterCalled();
        return getWrappedSet().containsAll(c);
    }

    public override bool opEquals(Object o) {
        getterCalled();
        return getWrappedSet().equals(o);
    }

    public int hashCode() {
        getterCalled();
        return getWrappedSet().hashCode();
    }

    public bool isEmpty() {
        getterCalled();
        return getWrappedSet().isEmpty();
    }

    public Iterator iterator() {
        getterCalled();
        final Iterator wrappedIterator = getWrappedSet().iterator();
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
        return getWrappedSet().size();
    }

    public Object[] toArray() {
        getterCalled();
        return getWrappedSet().toArray();
    }

    public Object[] toArray(Object[] a) {
        getterCalled();
        return getWrappedSet().toArray(a);
    }

    public String toString() {
        getterCalled();
        return getWrappedSet().toString();
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


    protected void fireChange() {
        throw new RuntimeException("fireChange should not be called, use fireSetChange() instead"); //$NON-NLS-1$
    }
    
    /* (non-Javadoc)
     * @see org.eclipse.jface.provisional.databinding.observable.AbstractObservable#dispose()
     */
    public synchronized void dispose() {
        super.dispose();
        
        if (changeSupport !is null) {
            changeSupport.dispose();
            changeSupport = null;
        }
    }
    
}
