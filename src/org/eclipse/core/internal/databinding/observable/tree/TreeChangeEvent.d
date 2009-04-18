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

module org.eclipse.core.internal.databinding.observable.tree.TreeChangeEvent;
import org.eclipse.core.internal.databinding.observable.tree.IObservableTree;
import org.eclipse.core.internal.databinding.observable.tree.TreeDiff;

import java.lang.all;

import java.util.EventObject;

/**
 * @since 3.3
 * 
 */
public class TreeChangeEvent : EventObject {

    /**
     * 
     */
    private static final long serialVersionUID = -3198503763995528027L;
    /**
     * 
     */
    public TreeDiff diff;

    /**
     * @param source
     * @param diff
     */
    public this(IObservableTree source, TreeDiff diff) {
        super(cast(Object)source);
        this.diff = diff;
    }

    /**
     * @return the observable tree from which this event originated
     */
    public IObservableTree getObservable() {
        return cast(IObservableTree) getSource();
    }

}
