/*******************************************************************************
 * Copyright (c) 2006, 2007 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *     Brad Reynolds - bug 168153
 *******************************************************************************/

module org.eclipse.core.databinding.observable.Realm;

import java.lang.all;

import org.eclipse.core.databinding.Binding;
import org.eclipse.core.databinding.util.Policy;
import org.eclipse.core.internal.databinding.Queue;
import org.eclipse.core.runtime.ISafeRunnable;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.SafeRunner;
import org.eclipse.core.runtime.Status;

/**
 * A realm defines a context from which objects implementing {@link IObservable}
 * must be accessed, and on which these objects will notify their listeners. To
 * bridge between observables from different realms, subclasses of
 * {@link Binding} can be used.
 * <p>
 * A block of code is said to be executing within a realm if calling
 * {@link #isCurrent()} from that block returns true. Code reached by calling
 * methods from that block will execute within the same realm, with the
 * exception of methods on this class that can be used to execute code within a
 * specific realm. Clients can use {@link #syncExeccast(Runnable)},
 * {@link #asyncExeccast(Runnable)}, or {@link #execcast(Runnable)} to execute a
 * runnable within this realm. Note that using {@link #syncExeccast(Runnable)} can
 * lead to deadlocks and should be avoided if the current thread holds any
 * locks.
 * </p>
 * <p>
 * It is instructive to think about possible implementations of Realm: It can be
 * based on executing on a designated thread such as a UI thread, or based on
 * holding a lock. In the former case, calling syncExec on a realm that is not
 * the current realm will execute the given runnable on a different thread (the
 * designated thread). In the latter case, calling syncExec may execute the
 * given runnable on the calling thread, but calling
 * {@link #asyncExeccast(Runnable)} will execute the given runnable on a different
 * thread. Therefore, no assumptions can be made about the thread that will
 * execute arguments to {@link #asyncExeccast(Runnable)},
 * {@link #syncExeccast(Runnable)}, or {@link #execcast(Runnable)}.
 * </p>
 * <p>
 * It is possible that a block of code is executing within more than one realm.
 * This can happen for implementations of Realm that are based on holding a lock
 * but don't use a separate thread to run runnables given to
 * {@link #syncExeccast(Runnable)}. Realm implementations of this kind should be
 * appropriately documented because it increases the opportunity for deadlock.
 * </p>
 * <p>
 * Some implementations of {@link IObservable} provide constructors which do not
 * take a Realm argument and are specified to create the observable instance
 * with the current default realm. The default realm can be set for the
 * currently executing thread by using {@link #runWithDefault(Realm, Runnable)}.
 * Note that the default realm does not have to be the current realm.
 * </p>
 * <p>
 * Subclasses must override at least one of asyncExec()/syncExec(). For realms
 * based on a designated thread, it may be easier to implement asyncExec and
 * keep the default implementation of syncExec. For realms based on holding a
 * lock, it may be easier to implement syncExec and keep the default
 * implementation of asyncExec.
 * </p>
 * 
 * @since 1.0
 * 
 * @see IObservable
 */
public abstract class Realm {

    private static ThreadLocal defaultRealm;
    static this(){
        defaultRealm = new ThreadLocal();
    }
    this(){
        workQueue = new Queue();
    }

    /**
     * Returns the default realm for the calling thread, or <code>null</code>
     * if no default realm has been set.
     * 
     * @return the default realm, or <code>null</code>
     */
    public static Realm getDefault() {
        return cast(Realm) defaultRealm.get();
    }
    
    /**
     * Sets the default realm for the calling thread, returning the current
     * default thread. This method is inherently unsafe, it is recommended to
     * use {@link #runWithDefault(Realm, Runnable)} instead. This method is
     * exposed to subclasses to facilitate testing.
     * 
     * @param realm
     *            the new default realm, or <code>null</code>
     * @return the previous default realm, or <code>null</code>
     */
    protected static Realm setDefault(Realm realm) {
        Realm oldValue = getDefault();
        defaultRealm.set(realm);
        return oldValue;
    }

    /**
     * @return true if the caller is executing in this realm. This method must
     *         not have side-effects (such as, for example, implicitly placing
     *         the caller in this realm).
     */
    abstract public bool isCurrent();

    private Thread workerThread;

    Queue workQueue;
    
    /**
     * Runs the given runnable. If an exception occurs within the runnable, it
     * is logged and not re-thrown. If the runnable implements
     * {@link ISafeRunnable}, the exception is passed to its
     * <code>handleException<code> method.
     * 
     * @param runnable
     */
    protected static void safeRun(Runnable runnable) {
        ISafeRunnable safeRunnable;
        if ( null !is cast(ISafeRunnable)runnable ) {
            safeRunnable = cast(ISafeRunnable) runnable;
        } else {
            safeRunnable = new class(runnable) ISafeRunnable {
                Runnable runnable_;
                this(Runnable r){runnable_=r;}
                public void handleException(Throwable exception) {
                    Policy
                            .getLog()
                            .log(
                                    new Status(
                                            IStatus.ERROR,
                                            Policy.JFACE_DATABINDING,
                                            IStatus.OK,
                                            "Unhandled exception: " ~ exception.msg, exception)); //$NON-NLS-1$
                }
                public void run() {
                    runnable_.run();
                }
            };
        }
        SafeRunner.run(safeRunnable);
    }

    /**
     * Causes the <code>run()</code> method of the runnable to be invoked from
     * within this realm. If the caller is executing in this realm, the
     * runnable's run method is invoked directly, otherwise it is run at the
     * next reasonable opportunity using asyncExec.
     * <p>
     * If the given runnable is an instance of {@link ISafeRunnable}, its
     * exception handler method will be called if any exceptions occur while
     * running it. Otherwise, the exception will be logged.
     * </p>
     * 
     * @param runnable
     */
    public void exec(Runnable runnable) {
        if (isCurrent()) {
            safeRun(runnable);
        } else {
            asyncExec(runnable);
        }
    }

    /**
     * Causes the <code>run()</code> method of the runnable to be invoked from
     * within this realm at the next reasonable opportunity. The caller of this
     * method continues to run in parallel, and is not notified when the
     * runnable has completed.
     * <p>
     * If the given runnable is an instance of {@link ISafeRunnable}, its
     * exception handler method will be called if any exceptions occur while
     * running it. Otherwise, the exception will be logged.
     * </p>
     * <p>
     * Subclasses should use {@link #safeRuncast(Runnable)} to run the runnable.
     * </p>
     * 
     * @param runnable
     */
    public void asyncExec(Runnable runnable) {
        synchronized (workQueue) {
            ensureWorkerThreadIsRunning();
            workQueue.enqueue(cast(Object)runnable);
            workQueue.notifyAll();
        }
    }

    /**
     * 
     */
    private void ensureWorkerThreadIsRunning() {
        if (workerThread is null) {
            workerThread = new class() Thread {
                public void run() {
                    try {
                        while (true) {
                            Runnable work = null;
                            synchronized (workQueue) {
                                while (workQueue.isEmpty()) {
                                    workQueue.wait();
                                }
                                work = cast(Runnable) workQueue.dequeue();
                            }
                            syncExec(work);
                        }
                    } catch (InterruptedException e) {
                        // exit
                    }
                }
            };
            workerThread.start();
        }
    }

    /**
     * Causes the <code>run()</code> method of the runnable to be invoked from
     * within this realm at the next reasonable opportunity. This method is
     * blocking the caller until the runnable completes.
     * <p>
     * If the given runnable is an instance of {@link ISafeRunnable}, its
     * exception handler method will be called if any exceptions occur while
     * running it. Otherwise, the exception will be logged.
     * </p>
     * <p>
     * Subclasses should use {@link #safeRuncast(Runnable)} to run the runnable.
     * </p>
     * <p>
     * Note: This class is not meant to be called by clients and therefore has
     * only protected access.
     * </p>
     * 
     * @param runnable
     */
    protected void syncExec(Runnable runnable) {
        SyncRunnable syncRunnable = new SyncRunnable(runnable);
        asyncExec(syncRunnable);
        synchronized (syncRunnable) {
            while (!syncRunnable.hasRun) {
                try {
                    syncRunnable.wait();
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
            }
        }
    }

    static class SyncRunnable : Runnable {
        bool hasRun = false;

        private Runnable runnable;

        this(Runnable runnable) {
            this.runnable = runnable;
        }

        public void run() {
            try {
                safeRun(runnable);
            } finally {
                synchronized (this) {
                    hasRun = true;
                    this.notifyAll();
                }
            }
        }
        void notifyAll(){
            implMissing( __FILE__, __LINE__ );
        }
        void wait(){
            implMissing( __FILE__, __LINE__ );
        }
    }

    /**
     * Sets the provided <code>realm</code> as the default for the duration of
     * {@link Runnable#run()} and resets the previous realm after completion.
     * Note that this will not set the given realm as the current realm.
     * 
     * @param realm
     * @param runnable
     */
    public static void runWithDefault(Realm realm, Runnable runnable) {
        Realm oldRealm = Realm.getDefault();
        try {
            defaultRealm.set(realm);
            runnable.run();
        } finally {
            defaultRealm.set(oldRealm);
        }
    }
}
