/*******************************************************************************
 * Copyright (c) 2006, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *******************************************************************************/

module org.eclipse.core.databinding.observable.set.IObservableSet;
import org.eclipse.core.databinding.observable.set.ISetChangeListener;

import java.lang.all;

import java.util.Collection;
import java.util.Iterator;
import java.util.Set;

import org.eclipse.core.databinding.observable.IObservableCollection;

/**
 * A set whose changes can be tracked by set change listeners.
 * 
 * @noextend This interface is not intended to be extended by clients.
 * @noimplement This interface is not intended to be implemented by clients.
 *              Clients should instead subclass one of the classes that
 *              implement this interface. Note that direct implementers of this
 *              interface outside of the framework will be broken in future
 *              releases when methods are added to this interface.
 * 
 * @see AbstractObservableSet
 * @see ObservableSet
 * 
 * @since 1.0
 * 
 */
public interface IObservableSet : Set, IObservableCollection {

    /**
     * @param listener
     */
    public void addSetChangeListener(ISetChangeListener listener);

    /**
     * @param listener
     */
    public void removeSetChangeListener(ISetChangeListener listener);

    /**
     * @return the element type or <code>null</code> if untyped
     */
    public Object getElementType();

    /**
     * @TrackedGetter
     */
    int size();

    /**
     * @TrackedGetter
     */
    bool isEmpty();

    /**
     * @TrackedGetter
     */
    bool contains(Object o);

    /**
     * @TrackedGetter
     */
    Iterator iterator();

    /**
     * @TrackedGetter
     */
    Object[] toArray();

    /**
     * @TrackedGetter
     */
    Object[] toArray(Object a[]);

    // Modification Operations

    /**
     * @TrackedGetter
     */
    bool add(Object o);

    /**
     * @TrackedGetter
     */
    bool remove(Object o);

    // Bulk Operations

    /**
     * @TrackedGetter
     */
    bool containsAll(Collection c);

    /**
     * @TrackedGetter
     */
    bool addAll(Collection c);

    /**
     * @TrackedGetter
     */
    bool retainAll(Collection c);

    /**
     * @TrackedGetter
     */
    bool removeAll(Collection c);

    // Comparison and hashing

    /**
     * @TrackedGetter
     */
    equals_t opEquals(Object o);

    /**
     * @TrackedGetter
     */
    hash_t toHash();

}
