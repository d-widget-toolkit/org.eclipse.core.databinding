/*******************************************************************************
 * Copyright (c) 2008 Matthew Hall and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Matthew Hall - initial API and implementation (bug 221704)
 *     Matthew Hall - bug 223114
 ******************************************************************************/

module org.eclipse.core.internal.databinding.observable.masterdetail.DetailObservableMap;

import java.lang.all;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import org.eclipse.core.databinding.observable.Diffs;
import org.eclipse.core.databinding.observable.map.IMapChangeListener;
import org.eclipse.core.databinding.observable.map.IObservableMap;
import org.eclipse.core.databinding.observable.map.MapChangeEvent;
import org.eclipse.core.databinding.observable.map.ObservableMap;
import org.eclipse.core.databinding.observable.masterdetail.IObservableFactory;
import org.eclipse.core.databinding.observable.value.IObservableValue;
import org.eclipse.core.databinding.observable.value.IValueChangeListener;
import org.eclipse.core.databinding.observable.value.ValueChangeEvent;

/**
 * @since 1.1
 * 
 */
public class DetailObservableMap : ObservableMap {
    private bool updating = false;

    private IObservableValue master;
    private IObservableFactory detailFactory;

    private IObservableMap detailMap;

    private IValueChangeListener masterChangeListener;
    class MasterChangeListener : IValueChangeListener {
        public void handleValueChange(ValueChangeEvent event) {
            Map oldMap = new HashMap(wrappedMap);
            updateDetailMap();
            fireMapChange(Diffs.computeMapDiff(oldMap, wrappedMap));
        }
    };

    private IMapChangeListener detailChangeListener;
    class DetailChangeListener : IMapChangeListener {
        public void handleMapChange(MapChangeEvent event) {
            if (!updating) {
                fireMapChange(event.diff);
            }
        }
    };

    /**
     * Constructs a new DetailObservableMap
     * 
     * @param detailFactory
     *            observable factory that creates IObservableMap instances given
     *            the current value of master observable value
     * @param master
     * 
     */
    public this(IObservableFactory detailFactory,
            IObservableValue master) {
masterChangeListener = new MasterChangeListener();
detailChangeListener = new DetailChangeListener();
        super(master.getRealm(), Collections.EMPTY_MAP);
        this.master = master;
        this.detailFactory = detailFactory;

        updateDetailMap();
        master.addValueChangeListener(masterChangeListener);
    }

    private void updateDetailMap() {
        Object masterValue = master.getValue();
        if (detailMap !is null) {
            detailMap.removeMapChangeListener(detailChangeListener);
            detailMap.dispose();
        }

        if (masterValue is null) {
            detailMap = null;
            wrappedMap = Collections.EMPTY_MAP;
        } else {
            detailMap = cast(IObservableMap) detailFactory
                    .createObservable(masterValue);
            wrappedMap = detailMap;
            detailMap.addMapChangeListener(detailChangeListener);
        }
    }

    public Object put(Object key, Object value) {
        return detailMap.put(key, value);
    }

    public void putAll(Map map) {
        detailMap.putAll(map);
    }

    public Object remove(Object key) {
        return detailMap.remove(key);
    }

    public void clear() {
        detailMap.clear();
    }

    public synchronized void dispose() {
        if (master !is null) {
            master.removeValueChangeListener(masterChangeListener);
            master = null;
            masterChangeListener = null;
        }
        detailFactory = null;
        if (detailMap !is null) {
            detailMap.removeMapChangeListener(detailChangeListener);
            detailMap.dispose();
            detailMap = null;
        }
        detailChangeListener = null;
        super.dispose();
    }

}
