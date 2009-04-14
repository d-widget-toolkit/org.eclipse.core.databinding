/*******************************************************************************
 * Copyright (c) 2006, 2007 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *******************************************************************************/

module org.eclipse.core.databinding.observable.ChangeSupport;
import org.eclipse.core.databinding.observable.IChangeListener;
import org.eclipse.core.databinding.observable.ChangeEvent;
import org.eclipse.core.databinding.observable.Realm;
import org.eclipse.core.databinding.observable.IStaleListener;
import org.eclipse.core.databinding.observable.IObservablesListener;
import org.eclipse.core.databinding.observable.ObservableEvent;
import org.eclipse.core.databinding.observable.StaleEvent;
import org.eclipse.core.databinding.observable.ChangeManager;

import java.lang.all;

/**
 * @since 1.0
 *
 */
public abstract class ChangeSupport : ChangeManager {

    /**
     * @param realm 
     */
    public this(Realm realm) {
        super(realm);
    }
    
    public void addListener(Object listenerType,
            IObservablesListener listener) {
        super.addListener(listenerType, listener);
    }
    
    public void removeListener(Object listenerType,
            IObservablesListener listener) {
        super.removeListener(listenerType, listener);
    }
    
    public void fireEvent(ObservableEvent event) {
        super.fireEvent(event);
    }
    
    /**
     * 
     */
    protected abstract void firstListenerAdded();
    
    /**
     * 
     */
    protected abstract void lastListenerRemoved();

    /**
     * @param listener
     */
    public void addChangeListener(IChangeListener listener) {
        addListener(ChangeEvent.TYPE, listener);
    }
    
    /**
     * @param listener
     */
    public void removeChangeListener(IChangeListener listener) {
        removeListener(ChangeEvent.TYPE, listener);
    }

    /**
     * @param listener
     */
    public void addStaleListener(IStaleListener listener) {
        addListener(StaleEvent.TYPE, listener);
    }
    
    /**
     * @param listener
     */
    public void removeStaleListener(IStaleListener listener) {
        removeListener(StaleEvent.TYPE, listener);
    }
    
}
