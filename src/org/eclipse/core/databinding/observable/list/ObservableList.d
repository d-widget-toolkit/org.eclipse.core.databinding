/*******************************************************************************
 * Copyright (c) 2006, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *     Brad Reynolds - bug 164653
 *     Brad Reynolds - bug 167204
 *     Matthew Hall - bug 208858
 *     Matthew Hall - bug 208332
 *******************************************************************************/

module org.eclipse.core.databinding.observable.list.ObservableList;
import org.eclipse.core.databinding.observable.list.IListChangeListener;
import org.eclipse.core.databinding.observable.list.AbstractObservableList;
import org.eclipse.core.databinding.observable.list.ListChangeEvent;
import org.eclipse.core.databinding.observable.list.ListDiff;
import org.eclipse.core.databinding.observable.list.IObservableList;

import java.lang.all;

import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.ListIterator;

import org.eclipse.core.databinding.observable.AbstractObservable;
import org.eclipse.core.databinding.observable.Diffs;
import org.eclipse.core.databinding.observable.ObservableTracker;
import org.eclipse.core.databinding.observable.Realm;

/**
 * 
 * Abstract implementation of {@link IObservableList}, based on an underlying regular list. 
 * <p>
 * This class is thread safe. All state accessing methods must be invoked from
 * the {@link Realm#isCurrent() current realm}. Methods for adding and removing
 * listeners may be invoked from any thread.
 * </p>
 * @since 1.0
 * 
 */
public abstract class ObservableList : AbstractObservable ,
        IObservableList {

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
// DWT start: reimpl
// DWT end: reimpl
    protected List wrappedList;

    /**
     * Stale state of the list.  Access must occur in the current realm.
     */
    private bool stale = false;

    private Object elementType;

    protected this(List wrappedList, Object elementType) {
        this(Realm.getDefault(), wrappedList, elementType);
    }

    protected this(Realm realm, List wrappedList, Object elementType) {
        super(realm);
        this.wrappedList = wrappedList;
        this.elementType = elementType;
    }

    public synchronized void addListChangeListener(IListChangeListener listener) {
        addListener(ListChangeEvent.TYPE, listener);
    }

    public synchronized void removeListChangeListener(IListChangeListener listener) {
        removeListener(ListChangeEvent.TYPE, listener);
    }

    protected void fireListChange(ListDiff diff) {
        // fire general change event first
        super.fireChange();
        fireEvent(new ListChangeEvent(this, diff));
    }
    
    public bool contains(Object o) {
        getterCalled();
        return wrappedList.contains(o);
    }

    public bool containsAll(Collection c) {
        getterCalled();
        return wrappedList.containsAll(c);
    }

    public override equals_t opEquals(Object o) {
        getterCalled();
        return wrappedList.opEquals(o);
    }

    public hash_t toHash() {
        getterCalled();
        return wrappedList.toHash();
    }

    public bool isEmpty() {
        getterCalled();
        return wrappedList.isEmpty();
    }

    public Iterator iterator() {
        getterCalled();
        final Iterator wrappedIterator = wrappedList.iterator();
        return new class() Iterator {

            public void remove() {
                throw new UnsupportedOperationException();
            }

            public bool hasNext() {
                return wrappedIterator.hasNext();
            }

            public Object next() {
                return wrappedIterator.next();
            }
        };
    }

    public int size() {
        getterCalled();
        return wrappedList.size();
    }

    public Object[] toArray() {
        getterCalled();
        return wrappedList.toArray();
    }

    public Object[] toArray(Object[] a) {
        getterCalled();
        return wrappedList.toArray(a);
    }

    public String toString() {
        getterCalled();
        return wrappedList.toString();
    }
    
    /**
     * @TrackedGetter
     */
    public Object get(int index) {
        getterCalled();
        return wrappedList.get(index);
    }

    /**
     * @TrackedGetter
     */
    public int indexOf(Object o) {
        getterCalled();
        return wrappedList.indexOf(o);
    }

    /**
     * @TrackedGetter
     */
    public int lastIndexOf(Object o) {
        getterCalled();
        return wrappedList.lastIndexOf(o);
    }

    // List Iterators

    /**
     * @TrackedGetter
     */
    public ListIterator listIterator() {
        return listIterator(0);
    }

    /**
     * @TrackedGetter
     */
    public ListIterator listIterator(int index) {
        getterCalled();
        final ListIterator wrappedIterator = wrappedList.listIterator(index);
        return new class() ListIterator {

            public int nextIndex() {
                return wrappedIterator.nextIndex();
            }

            public int previousIndex() {
                return wrappedIterator.previousIndex();
            }

            public void remove() {
                throw new UnsupportedOperationException();
            }

            public bool hasNext() {
                return wrappedIterator.hasNext();
            }

            public bool hasPrevious() {
                return wrappedIterator.hasPrevious();
            }

            public Object next() {
                return wrappedIterator.next();
            }

            public Object previous() {
                return wrappedIterator.previous();
            }

            public void add(String o) {
                throw new UnsupportedOperationException();
            }
            public void add(Object o) {
                throw new UnsupportedOperationException();
            }

            public void set(Object o) {
                throw new UnsupportedOperationException();
            }
        };
    }


    public List subList(int fromIndex, int toIndex) {
        getterCalled();
        if (fromIndex < 0 || fromIndex > toIndex || toIndex > size()) {
            throw new IndexOutOfBoundsException();
        }
        return new class(getRealm(), fromIndex, toIndex ) AbstractObservableList {
            int fromIndex_; int toIndex_;
            this( Realm r, int f, int t){
                super(r);
                fromIndex_ = f;
                toIndex_ = t;
            }
        
            public Object getElementType() {
                return this.outer.getElementType();
            }
        
            public Object get(int location) {
                return this.outer.get(fromIndex_ + location);
            }
        
            protected int doGetSize() {
                return toIndex_ - fromIndex_;
            }
        };
    }

    protected void getterCalled() {
        ObservableTracker.getterCalled(this);
    }

    public Object set(int index, Object element) {
        throw new UnsupportedOperationException();
    }

    /**
     * Moves the element located at <code>oldIndex</code> to
     * <code>newIndex</code>. This method is equivalent to calling
     * <code>add(newIndex, remove(oldIndex))</code>.
     * <p>
     * Subclasses should override this method to deliver list change
     * notification for the remove and add operations in the same
     * ListChangeEvent, as this allows {@link ListDiff#acceptcast(ListDiffVisitor)}
     * to recognize the operation as a move.
     * 
     * @param oldIndex
     *            the element's position before the move. Must be within the
     *            range <code>0 &lt;= oldIndex &lt; size()</code>.
     * @param newIndex
     *            the element's position after the move. Must be within the
     *            range <code>0 &lt;= newIndex &lt; size()</code>.
     * @return the element that was moved.
     * @throws IndexOutOfBoundsException
     *             if either argument is out of range (<code>0 &lt;= index &lt; size()</code>).
     * @see ListDiffVisitor#handleMove(int, int, Object)
     * @see ListDiff#acceptcast(ListDiffVisitor)
     * @since 1.1
     */
    public Object move(int oldIndex, int newIndex) {
        checkRealm();
        int size = wrappedList.size();
        if (oldIndex < 0 || oldIndex >= size)
            throw new IndexOutOfBoundsException(
                    Format("oldIndex: {}, size:{}", oldIndex, size)); //$NON-NLS-1$ //$NON-NLS-2$
        if (newIndex < 0 || newIndex >= size)
            throw new IndexOutOfBoundsException(
                    Format("newIndex: {}, size:{}", newIndex, size)); //$NON-NLS-1$ //$NON-NLS-2$
        Object element = remove(oldIndex);
        add(newIndex, element);
        return element;
    }

    public Object remove(int index) {
        throw new UnsupportedOperationException();
    }

    public bool add(Object o) {
        throw new UnsupportedOperationException();
    }

    public void add(int index, Object element) {
        throw new UnsupportedOperationException();
    }
    
    public bool addAll(Collection c) {
        throw new UnsupportedOperationException();
    }

    public bool addAll(int index, Collection c) {
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
     * Returns the stale state.  Must be invoked from the current realm.
     * 
     * @return stale state
     */
    public bool isStale() {
        getterCalled();
        return stale;
    }

    /**
     * Sets the stale state.  Must be invoked from the current realm.
     * 
     * @param stale
     *            The stale state to list. This will fire a stale event if the
     *            given bool is true and this observable list was not already
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
        throw new RuntimeException("fireChange should not be called, use fireListChange() instead"); //$NON-NLS-1$
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

    protected void updateWrappedList(List newList) {
        List oldList = wrappedList;
        ListDiff listDiff = Diffs.computeListDiff(oldList, newList);
        wrappedList = newList;
        fireListChange(listDiff);
    }

}
