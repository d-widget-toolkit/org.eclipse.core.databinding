/*******************************************************************************
 * Copyright (c) 2006 The Pampered Chef and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     The Pampered Chef - initial API and implementation
 ******************************************************************************/

module org.eclipse.core.internal.databinding.RandomAccessListIterator;

import java.lang.all;

import java.util.List;
import java.util.ListIterator;

/**
 * Class RandomAccessListIterator.  A ListIterator implementation that also
 * provides access to individual elements based on the element's index.
 * 
 * @since 3.3
 */
public class RandomAccessListIterator : ListIterator {
    private ListIterator delegate_ = null;

    /**
     * @param iterator
     */
    public this(ListIterator iterator) {
        this.delegate_ = iterator;
    }

    /**
     * @param list 
     */
    public this(List list) {
        if (list is null) {
            throw new IllegalArgumentException("list is null"); //$NON-NLS-1$
        }
        this.delegate_ = list.listIterator();
    }

    /* (non-Javadoc)
     * @see java.util.ListIterator#add(java.lang.Object)
     */
    public void add(Object arg0) {
        delegate_.add(arg0);
    }
    public void add(String arg0) {
        add(stringcast(arg0));
    }

    /* (non-Javadoc)
     * @see java.util.ListIterator#hasNext()
     */
    public bool hasNext() {
        return delegate_.hasNext();
    }

    /* (non-Javadoc)
     * @see java.util.ListIterator#hasPrevious()
     */
    public bool hasPrevious() {
        return delegate_.hasPrevious();
    }

    /* (non-Javadoc)
     * @see java.util.ListIterator#next()
     */
    public Object next() {
        return delegate_.next();
    }

    /* (non-Javadoc)
     * @see java.util.ListIterator#nextIndex()
     */
    public int nextIndex() {
        return delegate_.nextIndex();
    }

    /* (non-Javadoc)
     * @see java.util.ListIterator#previous()
     */
    public Object previous() {
        return delegate_.previous();
    }

    /* (non-Javadoc)
     * @see java.util.ListIterator#previousIndex()
     */
    public int previousIndex() {
        return delegate_.previousIndex();
    }

    /* (non-Javadoc)
     * @see java.util.ListIterator#remove()
     */
    public void remove() {
        delegate_.remove();
    }

    /* (non-Javadoc)
     * @see java.util.ListIterator#set(java.lang.Object)
     */
    public void set(Object arg0) {
        delegate_.set(arg0);
    }
    
    /**
     * Return the element at the specified position by moving the iterator
     * forward or backward in the list until it reaches the correct element.
     * The iterator's position after returning the element will be one after
     * the element returned.
     * 
     * @param index The (0-based) index of the element to return.
     * @return the Object at index
     */
    public Object get(int index) {
        if (delegate_.nextIndex() is 0 && !delegate_.hasNext()) {
            throw new IndexOutOfBoundsException("Request for element from empty list"); //$NON-NLS-1$
        }
        if (index < 0) {
            throw new IndexOutOfBoundsException("Request for negative element index"); //$NON-NLS-1$
        }
        
        while (nextIndex() < index && hasNext()) {
            next();
        }
        while (previousIndex() > index-1) {
            previous();
        }
        if (!hasNext()) {
            throw new IndexOutOfBoundsException("Request for element past end of list"); //$NON-NLS-1$
        }
        return next();
    }

}
