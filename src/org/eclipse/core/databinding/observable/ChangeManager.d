/*******************************************************************************
 * Copyright (c) 2006, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *     Matthew Hall - bug 118516
 *******************************************************************************/

module org.eclipse.core.databinding.observable.ChangeManager;
import org.eclipse.core.databinding.observable.Realm;
import org.eclipse.core.databinding.observable.IObservablesListener;
import org.eclipse.core.databinding.observable.ObservableEvent;

import java.lang.all;

import org.eclipse.core.runtime.Assert;
import org.eclipse.core.runtime.ListenerList;

/**
 * Listener management implementation. Exposed to subclasses in form of
 * {@link AbstractObservable} and {@link ChangeSupport}.
 * 
 * @since 1.0
 * 
 */
/* package */ class ChangeManager {

    ListenerList[] listenerLists = null;
    Object listenerTypes[] = null;
    private Realm realm;

    /**
     * @param realm 
     * 
     */
    /* package */ this(Realm realm) {
        Assert.isNotNull(realm, "Realm cannot be null"); //$NON-NLS-1$
        this.realm = realm;
    }

    /**
     * @param listenerType
     * @param listener
     */
    protected void addListener(Object listenerType,
            IObservablesListener listener) {
        int listenerTypeIndex = findListenerTypeIndex(listenerType);
        if (listenerTypeIndex is -1) {
            int length;
            if (listenerTypes is null) {
                length = 0;
                listenerTypes = new Object[1];
                listenerLists = new ListenerList[1];
            } else {
                length = listenerTypes.length;
                System.arraycopy(listenerTypes, 0,
                        listenerTypes = new Object[length + 1], 0, length);
                System
                        .arraycopy(listenerLists, 0,
                                listenerLists = new ListenerList[length + 1],
                                0, length);
            }
            listenerTypes[length] = listenerType;
            listenerLists[length] = new ListenerList();
            bool hadListeners = hasListeners();
            listenerLists[length].add(cast(Object)listener);
            if (!hadListeners) {
                this.firstListenerAdded();
            }
            return;
        }
        ListenerList listenerList = listenerLists[listenerTypeIndex];
        bool hadListeners = true;
        if (listenerList.size() is 0) {
            hadListeners = hasListeners();
        }
        listenerList.add(cast(Object)listener);
        if (!hadListeners) {
            firstListenerAdded();
        }
    }

    /**
     * @param listenerType
     * @param listener
     */
    protected void removeListener(Object listenerType,
            IObservablesListener listener) {
        int listenerTypeIndex = findListenerTypeIndex(listenerType);
        if (listenerTypeIndex !is -1) {
            listenerLists[listenerTypeIndex].remove(cast(Object)listener);
            if (listenerLists[listenerTypeIndex].size() is 0) {
                if (!hasListeners()) {
                    this.lastListenerRemoved();
                }
            }
        }
    }

    protected bool hasListeners() {
        if (listenerTypes is null) {
            return false;
        }
        for (int i = 0; i < listenerTypes.length; i++) {
            if (listenerLists[i].size() > 0) {
                return true;
            }
        }
        return false;
    }

    private int findListenerTypeIndex(Object listenerType) {
        if (listenerTypes !is null) {
            for (int i = 0; i < listenerTypes.length; i++) {
                if (listenerTypes[i] is listenerType) {
                    return i;
                }
            }
        }
        return -1;
    }

    protected void fireEvent(ObservableEvent event) {
        Object listenerType = event.getListenerType_package();
        int listenerTypeIndex = findListenerTypeIndex(listenerType);
        if (listenerTypeIndex !is -1) {
            Object[] listeners = listenerLists[listenerTypeIndex]
                    .getListeners();
            for (int i = 0; i < listeners.length; i++) {
                event.dispatch_package(cast(IObservablesListener) listeners[i]);
            }
        }
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
    public void dispose() {
        listenerLists = null;
        listenerTypes = null;
        realm = null;
    }

    /**
     * @return Returns the realm.
     */
    public Realm getRealm() {
        return realm;
    }

}
