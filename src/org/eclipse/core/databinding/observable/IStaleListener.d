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

module org.eclipse.core.databinding.observable.IStaleListener;
import org.eclipse.core.databinding.observable.IObservablesListener;
import org.eclipse.core.databinding.observable.StaleEvent;

import java.lang.all;

/**
 * Listener for staleness events. An observable object is stale if its state
 * will change eventually.
 * 
 * @since 1.0
 */
public interface IStaleListener : IObservablesListener {

    /**
     * Handle the event that the given observable object is now stale. The given
     * event object must only be used locally in this method because it may be
     * reused for other change notifications.
     * 
     * @param staleEvent
     */
    public void handleStale(StaleEvent staleEvent);

}
