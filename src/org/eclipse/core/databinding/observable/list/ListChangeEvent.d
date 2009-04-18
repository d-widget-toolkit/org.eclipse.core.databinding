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

module org.eclipse.core.databinding.observable.list.ListChangeEvent;
import org.eclipse.core.databinding.observable.list.IListChangeListener;
import org.eclipse.core.databinding.observable.list.ListDiff;
import org.eclipse.core.databinding.observable.list.IObservableList;

import java.lang.all;

import org.eclipse.core.databinding.observable.IObservablesListener;
import org.eclipse.core.databinding.observable.ObservableEvent;

/**
 * List change event describing an incremental change of an
 * {@link IObservableList} object.
 * 
 * @since 1.0
 */
public class ListChangeEvent : ObservableEvent {

    /**
     * 
     */
    private static const long serialVersionUID = -9154315534258776672L;

    static const Object TYPE;
    static this(){
        TYPE = new Object();
    }

    /**
     * Description of the change to the source observable list. Listeners must
     * not change this field.
     */
    public ListDiff diff;

    /**
     * Creates a new list change event.
     * 
     * @param source
     *            the source observable list
     * @param diff
     *            the list change
     */
    public this(IObservableList source, ListDiff diff) {
        super(source);
        this.diff = diff;
    }

    /**
     * Returns the observable list from which this event originated.
     * 
     * @return the observable list from which this event originated
     */
    public IObservableList getObservableList() {
        return cast(IObservableList) getSource();
    }

    protected void dispatch(IObservablesListener listener) {
        (cast(IListChangeListener) listener).handleListChange(this);
    }

    protected Object getListenerType() {
        return TYPE;
    }

}
