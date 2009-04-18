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
 *     Matthew Hall - bug 118516
 *******************************************************************************/

module org.eclipse.core.databinding.observable.map.AbstractObservableMap;
import org.eclipse.core.databinding.observable.map.MapDiff;
import org.eclipse.core.databinding.observable.map.MapChangeEvent;
import org.eclipse.core.databinding.observable.map.IMapChangeListener;
import org.eclipse.core.databinding.observable.map.IObservableMap;

import java.lang.all;

import java.util.AbstractMap;
import java.util.Set;

import org.eclipse.core.databinding.observable.ChangeEvent;
import org.eclipse.core.databinding.observable.ChangeSupport;
import org.eclipse.core.databinding.observable.IChangeListener;
import org.eclipse.core.databinding.observable.IStaleListener;
import org.eclipse.core.databinding.observable.Realm;
import org.eclipse.core.databinding.observable.StaleEvent;
import org.eclipse.core.runtime.Assert;
import org.eclipse.core.runtime.AssertionFailedException;

/**
 * 
 * <p>
 * This class is thread safe. All state accessing methods must be invoked from
 * the {@link Realm#isCurrent() current realm}. Methods for adding and removing
 * listeners may be invoked from any thread.
 * </p>
 * @since 1.0
 */
public abstract class AbstractObservableMap : AbstractMap ,
        IObservableMap {

    // DWT start reimplement
    public override int size(){
        return super.size();
    }
    public override bool isEmpty(){
        return super.isEmpty();
    }
    public override bool containsKey(Object o){
        return super.containsKey(o);
    }
    public override bool containsValue(Object o){
        return super.containsValue(o);
    }
    public override Object get(Object o){
        return super.get(o);
    }
    public override Object put(Object key, Object value){
        return super.put(key, value);
    }
    public override equals_t opEquals(Object o){
        return super.opEquals(o);
    }
    public override hash_t toHash(){
        return super.toHash();
    }
    public override Object remove(Object o){
        return super.remove(o);
    }
    public override Set keySet(){
        return super.keySet();
    }
    public override Set values(){
        return super.values();
    }
    // DWT end reimplement
    private ChangeSupport changeSupport;

    private bool stale;

    /**
     */
    public this() {
        this(Realm.getDefault());
    }

    /**
     * 
     */
    protected void lastListenerRemoved() {
    }

    /**
     * 
     */
    protected void firstListenerAdded() {
    }

    /**
     * @param realm
     */
    public this(Realm realm) {
        Assert.isNotNull(realm, "Realm cannot be null"); //$NON-NLS-1$
        changeSupport = new class(realm) ChangeSupport {
            this(Realm r){ super(r);}
            protected void firstListenerAdded() {
                this.outer.firstListenerAdded();
            }
            protected void lastListenerRemoved() {
                this.outer.lastListenerRemoved();
            }
        };
    }

    public synchronized void addMapChangeListener(IMapChangeListener listener) {
        changeSupport.addListener(MapChangeEvent.TYPE, listener);
    }

    public synchronized void removeMapChangeListener(IMapChangeListener listener) {
        changeSupport.removeListener(MapChangeEvent.TYPE, listener);
    }

    public synchronized void addChangeListener(IChangeListener listener) {
        changeSupport.addChangeListener(listener);
    }

    public synchronized void addStaleListener(IStaleListener listener) {
        changeSupport.addStaleListener(listener);
    }

    public synchronized void dispose() {
        changeSupport.dispose();
        changeSupport = null;
    }

    public Realm getRealm() {
        return changeSupport.getRealm();
    }

    public bool isStale() {
        checkRealm();
        return stale;
    }

    public synchronized void removeChangeListener(IChangeListener listener) {
        changeSupport.removeChangeListener(listener);
    }

    public synchronized void removeStaleListener(IStaleListener listener) {
        changeSupport.removeStaleListener(listener);
    }

    /**
     * Sets the stale state.  Must be invoked from the current realm.
     * 
     * @param stale
     */
    public void setStale(bool stale) {
        checkRealm();
        this.stale = stale;
        if (stale) {
            fireStale();
        }
    }

    /**
     * Fires stale events.  Must be invoked from current realm.
     */
    protected void fireStale() {
        checkRealm();
        changeSupport.fireEvent(new StaleEvent(this));
    }

    /**
     * Fires change events.  Must be invoked from current realm.
     */
    protected void fireChange() {
        checkRealm();
        changeSupport.fireEvent(new ChangeEvent(this));
    }

    /**
     * Fires map change events.  Must be invoked from current realm.
     * 
     * @param diff
     */
    protected void fireMapChange(MapDiff diff) {
        checkRealm();
        changeSupport.fireEvent(new MapChangeEvent(this, diff));
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
