/*******************************************************************************
 * Copyright (c) 2006 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 ******************************************************************************/

module org.eclipse.core.internal.databinding.observable.StalenessTracker;
import org.eclipse.core.internal.databinding.observable.IStalenessConsumer;

import java.lang.all;

import java.util.HashMap;
import java.util.Map;

import org.eclipse.core.databinding.observable.ChangeEvent;
import org.eclipse.core.databinding.observable.IChangeListener;
import org.eclipse.core.databinding.observable.IObservable;
import org.eclipse.core.databinding.observable.IStaleListener;
import org.eclipse.core.databinding.observable.StaleEvent;
import org.eclipse.core.internal.databinding.IdentityWrapper;

/**
 * @since 1.0
 * 
 */
public class StalenessTracker {

    private Map staleMap;

    private int staleCount = 0;

    private final IStalenessConsumer stalenessConsumer;

    private class ChildListener : IStaleListener, IChangeListener {
        public void handleStale(StaleEvent event) {
            processStalenessChange(cast(IObservable) event.getSource(), true);
        }

        public void handleChange(ChangeEvent event) {
            processStalenessChange(cast(IObservable) event.getSource(), true);
        }
    }

    private ChildListener childListener;

    /**
     * @param observables
     * @param stalenessConsumer 
     */
    public this(IObservable[] observables,
            IStalenessConsumer stalenessConsumer) {
childListener = new ChildListener();
staleMap = new HashMap();
        this.stalenessConsumer = stalenessConsumer;
        for (int i = 0; i < observables.length; i++) {
            IObservable observable = observables[i];
            doAddObservable(observable, false);
        }
        stalenessConsumer.setStale(staleCount > 0);
    }

    /**
     * @param child
     * @param callback
     */
    public void processStalenessChange(IObservable child, bool callback) {
        bool oldStale = staleCount > 0;
        IdentityWrapper wrappedChild = new IdentityWrapper(cast(Object)child);
        bool oldChildStale = getOldChildStale(wrappedChild);
        bool newChildStale = child.isStale();
        if (oldChildStale !is newChildStale) {
            if (oldChildStale) {
                staleCount--;
            } else {
                staleCount++;
            }
            staleMap.put(wrappedChild, newChildStale ? Boolean.TRUE : Boolean.FALSE);
        }
        bool newStale = staleCount > 0;
        if (callback && (newStale !is oldStale)) {
            stalenessConsumer.setStale(newStale);
        }
    }

    /**
     * @param wrappedChild
     */
    private bool getOldChildStale(IdentityWrapper wrappedChild) {
        Object oldChildValue = staleMap.get(wrappedChild);
        bool oldChildStale = oldChildValue is null ? false
                : (cast(Boolean) oldChildValue).booleanValue();
        return oldChildStale;
    }

    /**
     * @param observable
     */
    public void addObservable(IObservable observable) {
        doAddObservable(observable, true);
    }

    private void doAddObservable(IObservable observable, bool callback) {
        processStalenessChange(observable, callback);
        observable.addChangeListener(childListener);
        observable.addStaleListener(childListener);
    }

    /**
     * @param observable
     */
    public void removeObservable(IObservable observable) {
        bool oldStale = staleCount > 0;
        IdentityWrapper wrappedChild = new IdentityWrapper(cast(Object)observable);
        bool oldChildStale = getOldChildStale(wrappedChild);
        if (oldChildStale) {
            staleCount--;
        }
        staleMap.remove(wrappedChild);
        observable.removeChangeListener(childListener);
        observable.removeStaleListener(childListener);
        bool newStale = staleCount > 0;
        if (newStale !is oldStale) {
            stalenessConsumer.setStale(newStale);
        }
    }

}
