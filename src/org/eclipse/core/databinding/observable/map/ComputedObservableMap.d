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

module org.eclipse.core.databinding.observable.map.ComputedObservableMap;
import org.eclipse.core.databinding.observable.map.AbstractObservableMap;

import java.lang.all;

import java.util.AbstractSet;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import org.eclipse.core.databinding.observable.Diffs;
import org.eclipse.core.databinding.observable.set.IObservableSet;
import org.eclipse.core.databinding.observable.set.ISetChangeListener;
import org.eclipse.core.databinding.observable.set.SetChangeEvent;

/**
 * Maps objects to one of their attributes. Tracks changes to the underlying
 * observable set of objects (keys), as well as changes to attribute values.
 */
public abstract class ComputedObservableMap : AbstractObservableMap {

    private final IObservableSet fkeySet;

    private ISetChangeListener setChangeListener;
    class SetChangeListener : ISetChangeListener {
        public void handleSetChange(SetChangeEvent event) {
            Set addedKeys = new HashSet(event.diff.getAdditions());
            Set removedKeys = new HashSet(event.diff.getRemovals());
            Map oldValues = new HashMap();
            Map newValues = new HashMap();
            for (Iterator it = removedKeys.iterator(); it.hasNext();) {
                Object removedKey = it.next();
                Object oldValue = doGet(removedKey);
                unhookListener(removedKey);
                if (oldValue !is null) {
                    oldValues.put(removedKey, oldValue);
                }
            }
            for (Iterator it = addedKeys.iterator(); it.hasNext();) {
                Object addedKey = it.next();
                hookListener(addedKey);
                Object newValue = doGet(addedKey);
                newValues.put(addedKey, newValue);
            }
            fireMapChange(Diffs.createMapDiff(addedKeys, removedKeys,
                    Collections.EMPTY_SET, oldValues, newValues));
        }
    };

    private Set fentrySet;

    private class EntrySet : AbstractSet {
        public override int opApply (int delegate(ref Object value) dg){
            return super.opApply(dg);
        }

        public Iterator iterator() {
            return new class() Iterator {

                final Iterator keyIterator;
                this(){
                    keyIterator = fkeySet.iterator();
                }

                public bool hasNext() {
                    return keyIterator.hasNext();
                }

                public Object next() {
                    return new class() Map.Entry {
                        Object key;
                        this(){
                            key = keyIterator.next();
                        }

                        public Object getKey() {
                            return key;
                        }

                        public Object getValue() {
                            return get(getKey());
                        }

                        public Object setValue(Object value) {
                            return put(getKey(), value);
                        }

                        public override equals_t    opEquals(Object o){
                            implMissing( __FILE__, __LINE__ );
                            return 0;
                        }
                        public override hash_t    toHash(){
                            implMissing( __FILE__, __LINE__ );
                            return 0;
                        }

                    };
                }

                public void remove() {
                    keyIterator.remove();
                }
            };
        }

        public int size() {
            return fkeySet.size();
        }

        public override String toString(){
            return super.toString();
        }
    }

    /**
     * @param keySet
     */
    public this(IObservableSet _keySet) {
setChangeListener = new SetChangeListener();
fentrySet = new EntrySet();
        super(_keySet.getRealm());
        this.fkeySet = _keySet;
        this.fkeySet.addSetChangeListener(setChangeListener);
    }

    protected void init() {
        for (Iterator it = this.fkeySet.iterator(); it.hasNext();) {
            Object key = it.next();
            hookListener(key);
        }
    }

    protected final void fireSingleChange(Object key, Object oldValue,
            Object newValue) {
        fireMapChange(Diffs.createMapDiffSingleChange(key, oldValue, newValue));
    }

    public Set entrySet() {
        return fentrySet;
    }
    
    public Set keySet() {
        return fkeySet;
    }

    final public Object get(Object key) {
        return doGet(key);
    }

    final public Object put(Object key, Object value) {
        return doPut(key, value);
    }

    /**
     * @param removedKey
     */
    protected abstract void unhookListener(Object removedKey);

    /**
     * @param addedKey
     */
    protected abstract void hookListener(Object addedKey);

    /**
     * @param key
     * @return the value for the given key
     */
    protected abstract Object doGet(Object key);

    /**
     * @param key
     * @param value
     * @return the old value for the given key
     */
    protected abstract Object doPut(Object key, Object value);
}
