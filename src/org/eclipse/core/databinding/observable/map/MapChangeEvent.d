/*******************************************************************************
 * Copyright (c) 2006, 2007 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 ******************************************************************************/

module org.eclipse.core.databinding.observable.map.MapChangeEvent;
import org.eclipse.core.databinding.observable.map.MapDiff;
import org.eclipse.core.databinding.observable.map.IMapChangeListener;
import org.eclipse.core.databinding.observable.map.IObservableMap;

import java.lang.all;

import org.eclipse.core.databinding.observable.IObservablesListener;
import org.eclipse.core.databinding.observable.ObservableEvent;

/**
 * Map change event describing an incremental change of an
 * {@link IObservableMap} object.
 * 
 * @since 1.0
 * 
 */
public class MapChangeEvent : ObservableEvent {

    /**
     * 
     */
    private static final long serialVersionUID = -8092347212410548463L;
    static final Object TYPE = new Object();

    /**
     * Description of the change to the source observable map. Listeners must
     * not change this field.
     */
    public MapDiff diff;

    /**
     * Creates a new map change event
     * 
     * @param source
     *            the source observable map
     * @param diff
     *            the map change
     */
    public this(IObservableMap source, MapDiff diff) {
        super(source);
        this.diff = diff;
    }

    /**
     * Returns the observable map from which this event originated.
     * 
     * @return the observable map from which this event originated
     */
    public IObservableMap getObservableMap() {
        return cast(IObservableMap) getSource();
    }

    protected void dispatch(IObservablesListener listener) {
        (cast(IMapChangeListener) listener).handleMapChange(this);
    }

    protected Object getListenerType() {
        return TYPE;
    }

}
