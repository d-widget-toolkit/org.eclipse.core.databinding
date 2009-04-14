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

module org.eclipse.core.databinding.observable.ChangeEvent;

import java.lang.all;

/**
 * Generic change event denoting that the state of an {@link IObservable} object
 * has changed. This event does not carry information about the kind of change
 * that occurred.
 * 
 * @since 1.0
 * 
 */
public class ChangeEvent : ObservableEvent {

    /**
     * 
     */
    private static final long serialVersionUID = -3241193109844979384L;
    static final Object TYPE = new Object();

    /**
     * Creates a new change event object.
     * 
     * @param source
     *            the observable that changed state
     */
    public this(IObservable source) {
        super(source);
    }

    protected void dispatch(IObservablesListener listener) {
        (cast(IChangeListener) listener).handleChange(this);
    }

    protected Object getListenerType() {
        return TYPE;
    }

}
