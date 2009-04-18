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

module org.eclipse.core.databinding.observable.value.ValueChangeEvent;
import org.eclipse.core.databinding.observable.value.ValueDiff;
import org.eclipse.core.databinding.observable.value.IValueChangeListener;
import org.eclipse.core.databinding.observable.value.IObservableValue;

import java.lang.all;

import org.eclipse.core.databinding.observable.IObservablesListener;
import org.eclipse.core.databinding.observable.ObservableEvent;

/**
 * Value change event describing a change of an {@link IObservableValue}
 * object's current value.
 * 
 * @since 1.0
 * 
 */
public class ValueChangeEvent : ObservableEvent {

    /**
     * 
     */
    private static const long serialVersionUID = 2305345286999701156L;

    static const Object TYPE;
    static this(){
        TYPE = new Object();
    }

    /**
     * Description of the change to the source observable value. Listeners must
     * not change this field.
     */
    public ValueDiff diff;

    /**
     * Creates a new value change event.
     * 
     * @param source
     *            the source observable value
     * @param diff
     *            the value change
     */
    public this(IObservableValue source, ValueDiff diff) {
        super(source);
        this.diff = diff;
    }

    /**
     * Returns the observable value from which this event originated.
     * 
     * @return returns the observable value from which this event originated
     */
    public IObservableValue getObservableValue() {
        return cast(IObservableValue) source;
    }

    protected void dispatch(IObservablesListener listener) {
        (cast(IValueChangeListener) listener).handleValueChange(this);
    }

    protected Object getListenerType() {
        return TYPE;
    }

}
