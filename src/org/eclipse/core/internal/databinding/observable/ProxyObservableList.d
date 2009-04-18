/*******************************************************************************
 * Copyright (c) 2007 Matthew Hall and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 *     Matthew Hall - initial API and implementation (bug 208332)
 *     IBM Corporation - initial API and implementation
 *         (through ProxyObservableSet.java)
 ******************************************************************************/

module org.eclipse.core.internal.databinding.observable.ProxyObservableList;

import java.lang.all;

import org.eclipse.core.databinding.observable.IStaleListener;
import org.eclipse.core.databinding.observable.StaleEvent;
import org.eclipse.core.databinding.observable.list.IListChangeListener;
import org.eclipse.core.databinding.observable.list.IObservableList;
import org.eclipse.core.databinding.observable.list.ListChangeEvent;
import org.eclipse.core.databinding.observable.list.ObservableList;

/**
 * Wraps an observable list. This object acts like an exact copy of the original
 * list, and tracks all the changes in the original. The only difference is that
 * disposing the wrapper will not dispose the original. You can use this
 * whenever you need to return an IObservableList from a method that expects the
 * caller to dispose the list, but you have an IObservableList that you don't
 * want disposed.
 * 
 * @since 1.1
 */
public class ProxyObservableList : ObservableList {
    private IListChangeListener listChangelistener;
    class ListChangeListener : IListChangeListener {
        public void handleListChange(ListChangeEvent event) {
            fireListChange(event.diff);
        }
    };

    private IStaleListener staleListener;
    class StaleListener : IStaleListener {
        public void handleStale(StaleEvent event) {
            fireStale();
        }
    };

    private IObservableList wrappedList;

    /**
     * Constructs a ProxyObservableList that tracks the state of the given list.
     * 
     * @param wrappedList
     *            the list being wrapped
     */
    public this(IObservableList wrappedList) {
listChangelistener = new ListChangeListener();
staleListener = new StaleListener();
        super(wrappedList.getRealm(), wrappedList, wrappedList.getElementType());
        this.wrappedList = wrappedList;
        wrappedList.addListChangeListener(listChangelistener);
        wrappedList.addStaleListener(staleListener);
    }

    public bool isStale() {
        getterCalled();
        return wrappedList is null ? false : wrappedList.isStale();
    }

    public void dispose() {
        if (wrappedList !is null) {
            wrappedList.removeListChangeListener(listChangelistener);
            listChangelistener = null;
            wrappedList.removeStaleListener(staleListener);
            staleListener = null;
            wrappedList = null;
        }
        super.dispose();
    }
}
