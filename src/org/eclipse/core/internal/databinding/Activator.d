/*******************************************************************************
 * Copyright (c) 2007 Tom Schindl and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Tom Schindl - initial API and implementation
 ******************************************************************************/

module org.eclipse.core.internal.databinding.Activator;

import java.lang.all;

import java.util.ArrayList;

import org.eclipse.core.databinding.util.ILogger;
import org.eclipse.core.databinding.util.Policy;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.osgi.framework.log.FrameworkLog;
import org.eclipse.osgi.framework.log.FrameworkLogEntry;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.osgi.util.tracker.ServiceTracker;

/**
 * @since 3.3
 * 
 */
public class Activator : BundleActivator {
    /**
     * The plug-in ID
     */
    public static final String PLUGIN_ID = "org.eclipse.core.databinding"; //$NON-NLS-1$

    private /+volatile+/ static ServiceTracker _frameworkLogTracker;

    /**
     * The constructor
     */
    public this() {
    }

    public void start(BundleContext context) {
        _frameworkLogTracker = new ServiceTracker(context, FrameworkLog.classinfo.name, null);
        _frameworkLogTracker.open();

        Policy.setLog(new class() ILogger {

            public void log(IStatus status) {
                ServiceTracker frameworkLogTracker = _frameworkLogTracker;
                FrameworkLog log = frameworkLogTracker is null ? null : cast(FrameworkLog) frameworkLogTracker.getService();
                if (log !is null) {
                    log.log(createLogEntry(status));
                } else {
                    // fall back to System.err
                    getDwtLogger().error(__FILE__, __LINE__, "{} - {} - {}", status.getPlugin(), status.getCode(), status.getMessage());  //$NON-NLS-1$//$NON-NLS-2$
                    if( status.getException() !is null ) {
                        ExceptionPrintStackTrace(status.getException());
                    }
                }
            }

        });
    }
    
    // Code copied from PlatformLogWriter.getLog(). Why is logging an IStatus so
    // hard?
    FrameworkLogEntry createLogEntry(IStatus status) {
        Throwable t = status.getException();
        ArrayList childlist = new ArrayList();

        int stackCode = null !is cast(CoreException )t ? 1 : 0;
        // ensure a substatus inside a CoreException is properly logged 
        if (stackCode is 1) {
            IStatus coreStatus = (cast(CoreException) t).getStatus();
            if (coreStatus !is null) {
                childlist.add(createLogEntry(coreStatus));
            }
        }

        if (status.isMultiStatus()) {
            IStatus[] children = status.getChildren();
            for (int i = 0; i < children.length; i++) {
                childlist.add(createLogEntry(children[i]));
            }
        }

        FrameworkLogEntry[] children = cast(FrameworkLogEntry[]) (childlist.size() is 0 ? null : childlist.toArray(new FrameworkLogEntry[childlist.size()]));

        return new FrameworkLogEntry(status.getPlugin(), status.getSeverity(), status.getCode(), status.getMessage(), stackCode, t, children);
    }

    
    public void stop(BundleContext context) {
        if (_frameworkLogTracker !is null) {
            _frameworkLogTracker.close();
            _frameworkLogTracker = null;
        }
    }

}
