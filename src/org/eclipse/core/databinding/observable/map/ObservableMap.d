/*******************************************************************************
 * Copyright (c) 2006, 2007 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *     Brad Reynolds - bug 164653
 *******************************************************************************/

module org.eclipse.core.databinding.observable.map.ObservableMap;
import org.eclipse.core.databinding.observable.map.MapDiff;
import org.eclipse.core.databinding.observable.map.MapChangeEvent;
import org.eclipse.core.databinding.observable.map.IMapChangeListener;
import org.eclipse.core.databinding.observable.map.IObservableMap;

import java.lang.all;

import java.util.Collection;
import java.util.Map;
import java.util.Set;

import org.eclipse.core.databinding.observable.IChangeListener;
import org.eclipse.core.databinding.observable.IStaleListener;
import org.eclipse.core.databinding.observable.AbstractObservable;
import org.eclipse.core.databinding.observable.ObservableTracker;
import org.eclipse.core.databinding.observable.Realm;

/**
 * 
 * <p>
 * This class is thread safe. All state accessing methods must be invoked from
 * the {@link Realm#isCurrent() current realm}. Methods for adding and removing
 * listeners may be invoked from any thread.
 * </p>
 * @since 1.0
 */
public class ObservableMap : AbstractObservable , IObservableMap {
    // DWT start: java.util.Map additional methods
    public bool containsKey(String key) {
        return containsKey(stringcast(key));
    }
    public Object get(String key){
        return get(stringcast(key));
    }
    public Object put(String key, Object value){
        return put(stringcast(key), value);
    }
    public Object put(Object key, String value){
        return put(key, stringcast(value));
    }
    public Object put(String key, String value){
        return put(stringcast(key), stringcast(value));
    }
    public Object remove(String key){
        return remove(stringcast(key));
    }
    public int opApply (int delegate(ref Object value) dg){
        foreach( entry; entrySet() ){
            auto me = cast(Map.Entry)entry;
            auto v = me.getValue();
            int res = dg( v );
            if( res ) return res;
        }
        return 0;
    }
    public int opApply (int delegate(ref Object key, ref Object value) dg){
        foreach( entry; entrySet() ){
            auto me = cast(Map.Entry)entry;
            auto k = me.getKey();
            auto v = me.getValue();
            int res = dg( k, v );
            if( res ) return res;
        }
        return 0;
    }
    // DWT end: java.util.Map additional methods
    // DWT start reimpl super meths
    public override Realm getRealm() {
        return super.getRealm();
    }
    public override void addChangeListener(IChangeListener listener) {
        super.addChangeListener(listener);
    }
    public override void addStaleListener(IStaleListener listener) {
        super.addStaleListener(listener);
    }
    public override void removeChangeListener(IChangeListener listener) {
        super.removeChangeListener(listener);
    }
    public override void removeStaleListener(IStaleListener listener) {
        super.removeStaleListener(listener);
    }
    public override hash_t toHash(){
        return super.toHash();
    }
    public equals_t opEquals( Object o){
        if( ObservableMap other = cast(ObservableMap)o){
            return cast(equals_t)entrySet().opEquals( cast(Object) other.entrySet() );
        }
        return false;
    }
    // DWT end reimpl super meths

    protected Map wrappedMap;

    private bool stale = false;
    
    /**
     * @param wrappedMap
     */
    public this(Map wrappedMap) {
        this(Realm.getDefault(), wrappedMap);
    }

    /**
     * @param realm 
     * @param wrappedMap
     */
    public this(Realm realm, Map wrappedMap) {
        super(realm);
        this.wrappedMap = wrappedMap;
    }
    
    public synchronized void addMapChangeListener(IMapChangeListener listener) {
        addListener(MapChangeEvent.TYPE, listener);
    }

    public synchronized void removeMapChangeListener(IMapChangeListener listener) {
        removeListener(MapChangeEvent.TYPE, listener);
    }

    protected void getterCalled() {
        ObservableTracker.getterCalled(this);
    }

    protected void fireMapChange(MapDiff diff) {
        checkRealm();
        
        // fire general change event first
        super.fireChange();

        fireEvent(new MapChangeEvent(this, diff));
    }

    public bool containsKey(Object key) {
        getterCalled();
        return wrappedMap.containsKey(key);
    }

    public bool containsValue(Object value) {
        getterCalled();
        return wrappedMap.containsValue(value);
    }

    public Set entrySet() {
        getterCalled();
        return wrappedMap.entrySet();
    }

    public Object get(Object key) {
        getterCalled();
        return wrappedMap.get(key);
    }

    public bool isEmpty() {
        getterCalled();
        return wrappedMap.isEmpty();
    }

    public Set keySet() {
        getterCalled();
        return wrappedMap.keySet();
    }

    public int size() {
        getterCalled();
        return wrappedMap.size();
    }

    public Collection values() {
        getterCalled();
        return wrappedMap.values();
    }

    /**
     * Returns the stale state.  Must be invoked from the current realm.
     * 
     * @return stale state
     */
    public bool isStale() {
        checkRealm();
        return stale;
    }

    /**
     * Sets the stale state.  Must be invoked from the current realm.
     * 
     * @param stale
     *            The stale state to set. This will fire a stale event if the
     *            given bool is true and this observable set was not already
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

    public Object put(Object key, Object value) {
        throw new UnsupportedOperationException();
    }

    public Object remove(Object key) {
        throw new UnsupportedOperationException();
    }

    public void clear() {
        throw new UnsupportedOperationException();
    }

    public void putAll(Map arg0) {
        throw new UnsupportedOperationException();
    }

    public synchronized void dispose() {
        super.dispose();
    }
}
