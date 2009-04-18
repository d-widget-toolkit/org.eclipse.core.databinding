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
 *     Matthew Hall - bug 118516
 *     Matthew Hall - bug 208858
 *     Matthew Hall - bug 208332
 *******************************************************************************/

module org.eclipse.core.databinding.observable.list.AbstractObservableList;
import org.eclipse.core.databinding.observable.list.IListChangeListener;
import org.eclipse.core.databinding.observable.list.ListChangeEvent;
import org.eclipse.core.databinding.observable.list.ListDiff;
import org.eclipse.core.databinding.observable.list.IObservableList;

import java.lang.all;

import java.util.AbstractList;
import java.util.Collection;
import java.util.Iterator;
import java.util.ListIterator;
import java.util.List;

import org.eclipse.core.databinding.observable.ChangeEvent;
import org.eclipse.core.databinding.observable.ChangeSupport;
import org.eclipse.core.databinding.observable.IChangeListener;
import org.eclipse.core.databinding.observable.IStaleListener;
import org.eclipse.core.databinding.observable.ObservableTracker;
import org.eclipse.core.databinding.observable.Realm;
import org.eclipse.core.databinding.observable.StaleEvent;
import org.eclipse.core.runtime.Assert;
import org.eclipse.core.runtime.AssertionFailedException;

/**
 * Subclasses should override at least get(int index) and size().
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
public abstract class AbstractObservableList : AbstractList ,
        IObservableList {
    public Object set(int index, Object element){
        return super.set( index, element );
    }
    public Object   remove(int index){
        return super.remove(index);
    }
    public bool     remove(Object o){
        return super.remove(o);
    }
    public bool     remove(String o){
        return super.remove(o);
    }
    public void     add(int index, Object element){
        return super.add(index, element);
    }
    public bool     add(Object o){
        return super.add(o);
    }
    public bool     add(String o){
        return super.add(o);
    }
    public ListIterator   listIterator(){
        return super.listIterator();
    }
    public ListIterator   listIterator(int index){
        return super.listIterator(index);
    }
    public void     clear(){
        super.clear();
    }
    public int opApply (int delegate(ref Object value) dg){
        return super.opApply(dg);
    }
    public List   subList(int fromIndex, int toIndex){
        return super.subList( fromIndex, toIndex );
    }
    private ChangeSupport changeSupport;

    /**
     * @param realm 
     * 
     */
    public this(Realm realm) {
        Assert.isNotNull(realm, "Realm cannot be null"); //$NON-NLS-1$
        changeSupport = new class(realm) ChangeSupport {
            this(Realm r){super(r);}
            protected void firstListenerAdded() {
                this.outer.firstListenerAdded();
            }
            protected void lastListenerRemoved() {
                this.outer.lastListenerRemoved();
            }
        };
    }

    /**
     * 
     */
    public this() {
        this(Realm.getDefault());
    }
    
    public bool isStale() {
        getterCalled();
        return false;
    }

    public synchronized void addListChangeListener(IListChangeListener listener) {
        changeSupport.addListener(ListChangeEvent.TYPE, listener);
    }

    public synchronized void removeListChangeListener(IListChangeListener listener) {
        changeSupport.removeListener(ListChangeEvent.TYPE, listener);
    }

    protected void fireListChange(ListDiff diff) {
        // fire general change event first
        fireChange();
        changeSupport.fireEvent(new ListChangeEvent(this, diff));
    }

    public synchronized void addChangeListener(IChangeListener listener) {
        changeSupport.addChangeListener(listener);
    }

    public synchronized void removeChangeListener(IChangeListener listener) {
        changeSupport.removeChangeListener(listener);
    }

    public synchronized void addStaleListener(IStaleListener listener) {
        changeSupport.addStaleListener(listener);
    }

    public synchronized void removeStaleListener(IStaleListener listener) {
        changeSupport.removeStaleListener(listener);
    }

    /**
     * Fires change event. Must be invoked from the current realm.
     */
    protected void fireChange() {
        checkRealm();
        changeSupport.fireEvent(new ChangeEvent(this));
    }

    /**
     * Fires stale event. Must be invoked from the current realm.
     */
    protected void fireStale() {
        checkRealm();
        changeSupport.fireEvent(new StaleEvent(this));
    }

    /**
     * 
     */
    protected void firstListenerAdded() {
    }

    /**
     * 
     */
    protected void lastListenerRemoved() {
    }

    /**
     * 
     */
    public synchronized void dispose() {
        changeSupport = null;
        lastListenerRemoved();
    }

    public final int size() {
        getterCalled();
        return doGetSize();
    }

    /**
     * @return the size
     */
    protected abstract int doGetSize();

    /**
     * 
     */
    private void getterCalled() {
        ObservableTracker.getterCalled(this);
    }

    public bool isEmpty() {
        getterCalled();
        return super.isEmpty();
    }

    public bool contains(Object o) {
        getterCalled();
        return super.contains(o);
    }

    public Iterator iterator() {
        getterCalled();
        final Iterator wrappedIterator = super.iterator();
        return new class() Iterator {
            public void remove() {
                wrappedIterator.remove();
            }

            public bool hasNext() {
                return wrappedIterator.hasNext();
            }

            public Object next() {
                return wrappedIterator.next();
            }
        };
    }


    public Object[] toArray() {
        getterCalled();
        return super.toArray();
    }

    public Object[] toArray(Object a[]) {
        getterCalled();
        return super.toArray(a);
    }

    public String[] toArray(String a[]) {
        getterCalled();
        return super.toArray(a);
    }

    // Modification Operations

    public alias AbstractList.add add;
    public override bool add(Object o) {
        getterCalled();
        return super.add(o);
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
        int size = doGetSize();
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

    public alias AbstractList.remove remove;
    public override bool remove(Object o) {
        getterCalled();
        return super.remove(o);
    }

    // Bulk Modification Operations

    public bool containsAll(Collection c) {
        getterCalled();
        return super.containsAll(c);
    }

    public bool addAll(Collection c) {
        getterCalled();
        return super.addAll(c);
    }

    public bool addAll(int index, Collection c) {
        getterCalled();
        return super.addAll(c);
    }

    public bool removeAll(Collection c) {
        getterCalled();
        return super.removeAll(c);
    }

    public bool retainAll(Collection c) {
        getterCalled();
        return super.retainAll(c);
    }

    // Comparison and hashing

    public override equals_t opEquals(Object o) {
        getterCalled();
        return super.opEquals(o);
    }

    public hash_t toHash() {
        getterCalled();
        return super.toHash();
    }

    public int indexOf(Object o) {
        getterCalled();
        return super.indexOf(o);
    }

    public int lastIndexOf(Object o) {
        getterCalled();
        return super.lastIndexOf(o);
    }

    public Realm getRealm() {
        return changeSupport.getRealm();
    }
    
    /**
     * Asserts that the realm is the current realm.
     * 
     * @see Realm#isCurrent()
     * @throws AssertionFailedException
     *             if the realm is not the current realm
     */
    protected void checkRealm() {
        Assert.isTrue(getRealm().isCurrent(),
                "This operation must be run within the observable's realm"); //$NON-NLS-1$
    }
}
