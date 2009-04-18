/*******************************************************************************
 * Copyright (c) 2007 Matthew Hall and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 *     Matthew Hall - initial API and implementation (bug 208332)
 *     Brad Reynolds - initial API and implementation
 *         (through UnmodifiableObservableList.java)
 ******************************************************************************/

module org.eclipse.core.internal.databinding.observable.UnmodifiableObservableSet;

import java.lang.all;

import org.eclipse.core.databinding.observable.IStaleListener;
import org.eclipse.core.databinding.observable.StaleEvent;
import org.eclipse.core.databinding.observable.set.IObservableSet;
import org.eclipse.core.databinding.observable.set.ISetChangeListener;
import org.eclipse.core.databinding.observable.set.ObservableSet;
import org.eclipse.core.databinding.observable.set.SetChangeEvent;

/**
 * ObservableList implementation that prevents modification by consumers. Events
 * in the originating wrapped list are propagated and thrown from this instance
 * when appropriate. All mutators throw an UnsupportedOperationException.
 * 
 * @since 1.1
 */
public class UnmodifiableObservableSet : ObservableSet {
    private ISetChangeListener setChangeListener;
    class SetChangeListener : ISetChangeListener {
        public void handleSetChange(SetChangeEvent event) {
            fireSetChange(event.diff);
        }
    };

    private IStaleListener staleListener;
    class StaleListener : IStaleListener {
        public void handleStale(StaleEvent event) {
            fireStale();
        }
    };

    private IObservableSet wrappedSet;

    /**
     * @param wrappedSet
     */
    public this(IObservableSet wrappedSet) {
setChangeListener = new SetChangeListener();
staleListener = new StaleListener();
        super(wrappedSet.getRealm(), wrappedSet, wrappedSet.getElementType());

        this.wrappedSet = wrappedSet;

        wrappedSet.addSetChangeListener(setChangeListener);
        wrappedSet.addStaleListener(staleListener);
    }

    /**
     * Because this instance is immutable staleness cannot be changed.
     */
    public void setStale(bool stale) {
        throw new UnsupportedOperationException();
    }

    public bool isStale() {
        getterCalled();
        return wrappedSet is null ? false : wrappedSet.isStale();
    }

    public synchronized void dispose() {
        if (wrappedSet !is null) {
            wrappedSet.removeSetChangeListener(setChangeListener);
            wrappedSet.removeStaleListener(staleListener);
            wrappedSet = null;
        }
        setChangeListener = null;
        staleListener = null;
        super.dispose();
    }
}
