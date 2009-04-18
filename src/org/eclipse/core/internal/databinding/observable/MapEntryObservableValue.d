/*******************************************************************************
 * Copyright (c) 2008 Marko Topolnik and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Marko Topolnik - initial API and implementation (bug 184830)
 *     Matthew Hall - bug 184830
 ******************************************************************************/

module org.eclipse.core.internal.databinding.observable.MapEntryObservableValue;

import java.lang.all;

import org.eclipse.core.databinding.observable.Diffs;
import org.eclipse.core.databinding.observable.IStaleListener;
import org.eclipse.core.databinding.observable.ObservableTracker;
import org.eclipse.core.databinding.observable.StaleEvent;
import org.eclipse.core.databinding.observable.map.IMapChangeListener;
import org.eclipse.core.databinding.observable.map.IObservableMap;
import org.eclipse.core.databinding.observable.map.MapChangeEvent;
import org.eclipse.core.databinding.observable.value.AbstractObservableValue;
import org.eclipse.core.databinding.observable.value.IObservableValue;

/**
 * An {@link IObservableValue} that tracks the value of an entry in an
 * {@link IObservableMap}, identified by the entry's key.
 * 
 * @since 1.1
 */
public class MapEntryObservableValue : AbstractObservableValue {
    private IObservableMap map;
    private Object key;
    private Object valueType;

    private IMapChangeListener changeListener;
    class ChangeListener : IMapChangeListener {
        public void handleMapChange(MapChangeEvent event) {
            if (event.diff.getAddedKeys().contains(key)) {
                final Object newValue = event.diff.getNewValue(key);
                if (newValue !is null) {
                    fireValueChange(Diffs.createValueDiff(cast(Object)null, newValue));
                }
            } else if (event.diff.getChangedKeys().contains(key)) {
                fireValueChange(Diffs.createValueDiff(event.diff
                        .getOldValue(key), event.diff.getNewValue(key)));
            } else if (event.diff.getRemovedKeys().contains(key)) {
                final Object oldValue = event.diff.getOldValue(key);
                if (oldValue !is null) {
                    fireValueChange(Diffs.createValueDiff(oldValue, cast(Object)null));
                }
            }
        }
    };

    private IStaleListener staleListener;
    class StaleListener : IStaleListener {
        public void handleStale(StaleEvent staleEvent) {
            fireStale();
        }
    };

    /**
     * Creates a map entry observable.
     * 
     * @param map
     *            the observable map whose entry will be tracked
     * @param key
     *            the key identifying the entry whose value will be tracked
     * @param valueType
     *            the type of the value
     */
    public this(IObservableMap map, Object key,
            Object valueType) {
changeListener = new ChangeListener();
staleListener = new StaleListener();
        super(map.getRealm());
        this.map = map;
        this.key = key;
        this.valueType = valueType;

        map.addMapChangeListener(changeListener);
        map.addStaleListener(staleListener);
    }

    public Object getValueType() {
        return this.valueType;
    }

    public bool isStale() {
        ObservableTracker.getterCalled(this);
        return map.isStale();
    }

    public synchronized void dispose() {
        if (map !is null) {
            map.removeMapChangeListener(changeListener);
            map.removeStaleListener(staleListener);
            map = null;
            changeListener = null;
            staleListener = null;
        }
        super.dispose();
    }

    protected Object doGetValue() {
        return this.map.get(this.key);
    }

    protected void doSetValue(Object value) {
        this.map.put(this.key, value);
    }
}
