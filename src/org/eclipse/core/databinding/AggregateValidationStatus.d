/*******************************************************************************
 * Copyright (c) 2005, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *     Matt Carter - bug 182822
 *     Boris Bokowski - bug 218269
 *     Matthew Hall - bug 218269
 *******************************************************************************/
module org.eclipse.core.databinding.AggregateValidationStatus;
import org.eclipse.core.databinding.DataBindingContext;
import org.eclipse.core.databinding.ValidationStatusProvider;

import java.lang.all;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;

import org.eclipse.core.databinding.observable.IChangeListener;
import org.eclipse.core.databinding.observable.IObservableCollection;
import org.eclipse.core.databinding.observable.IStaleListener;
import org.eclipse.core.databinding.observable.Realm;
import org.eclipse.core.databinding.observable.value.ComputedValue;
import org.eclipse.core.databinding.observable.value.IObservableValue;
import org.eclipse.core.databinding.observable.value.IValueChangeListener;
import org.eclipse.core.databinding.util.Policy;
import org.eclipse.core.internal.databinding.BindingMessages;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.MultiStatus;
import org.eclipse.core.runtime.Status;

/**
 * This class can be used to aggregate status values from a data binding context
 * into a single status value. Instances of this class can be used as an
 * observable value with a value type of {@link IStatus}, or the static methods
 * can be called directly if an aggregated status result is only needed once.
 * 
 * @since 1.0
 * 
 */
public final class AggregateValidationStatus : IObservableValue {

    private IObservableValue implementation;

    /**
     * Constant denoting an aggregation strategy that merges multiple non-OK
     * status objects in a {@link MultiStatus}. Returns an OK status result if
     * all statuses from the given validation status providers are the an OK
     * status. Returns a single status if there is only one non-OK status.
     * 
     * @see #getStatusMergedcast(Collection)
     */
    public static final int MERGED = 1;

    /**
     * Constant denoting an aggregation strategy that always returns the most
     * severe status from the given validation status providers. If there is
     * more than one status at the same severity level, it picks the first one
     * it encounters.
     * 
     * @see #getStatusMaxSeveritycast(Collection)
     */
    public static final int MAX_SEVERITY = 2;

    /**
     * Creates a new aggregate validation status observable for the given data
     * binding context.
     * 
     * @param dbc
     *            a data binding context
     * @param strategy
     *            a strategy constant, one of {@link #MERGED} or
     *            {@link #MAX_SEVERITY}.
     * @since 1.1
     */
    public this(DataBindingContext dbc, int strategy) {
        this(dbc.getValidationRealm(), dbc.getValidationStatusProviders(),
                strategy);
    }

    /**
     * @param validationStatusProviders
     *            an observable collection containing elements of type
     *            {@link ValidationStatusProvider}
     * @param strategy
     *            a strategy constant, one of {@link #MERGED} or
     *            {@link #MAX_SEVERITY}.
     * @see DataBindingContext#getValidationStatusProviders()
     */
    public this(
            IObservableCollection validationStatusProviders, int strategy) {
        this(Realm.getDefault(), validationStatusProviders, strategy);
    }

    /**
     * @param realm
     *            Realm
     * @param validationStatusProviders
     *            an observable collection containing elements of type
     *            {@link ValidationStatusProvider}
     * @param strategy
     *            a strategy constant, one of {@link #MERGED} or
     *            {@link #MAX_SEVERITY}.
     * @see DataBindingContext#getValidationStatusProviders()
     * @since 1.1
     */
    public this(Realm realm,
            IObservableCollection validationStatusProviders, int strategy) {
        if (strategy is MERGED) {
            implementation = new class(realm, typeid(IStatus), validationStatusProviders) ComputedValue {
                IObservableCollection validationStatusProviders_;
                this(Realm r, TypeInfo c, IObservableCollection v){
                    super(r, c);
                    validationStatusProviders_=v;
                }
                protected Object calculate() {
                    return cast(Object)getStatusMerged(validationStatusProviders_);
                }
            };
        } else {
            implementation = new class(realm, typeid(IStatus), validationStatusProviders) ComputedValue {
                IObservableCollection validationStatusProviders_;
                this(Realm r, TypeInfo c, IObservableCollection v){
                    super(r, c);
                    validationStatusProviders_=v;
                }
                protected Object calculate() {
                    return cast(Object)getStatusMaxSeverity(validationStatusProviders_);
                }
            };
        }
    }

    /**
     * @param listener
     * @see org.eclipse.core.databinding.observable.IObservable#addChangeListener(org.eclipse.core.databinding.observable.IChangeListener)
     */
    public void addChangeListener(IChangeListener listener) {
        implementation.addChangeListener(listener);
    }

    /**
     * @param listener
     * @see org.eclipse.core.databinding.observable.IObservable#addStaleListener(org.eclipse.core.databinding.observable.IStaleListener)
     */
    public void addStaleListener(IStaleListener listener) {
        implementation.addStaleListener(listener);
    }

    /**
     * @param listener
     * @see org.eclipse.core.databinding.observable.value.IObservableValue#addValueChangeListener(org.eclipse.core.databinding.observable.value.IValueChangeListener)
     */
    public void addValueChangeListener(IValueChangeListener listener) {
        implementation.addValueChangeListener(listener);
    }

    public void dispose() {
        implementation.dispose();
    }

    public Realm getRealm() {
        return implementation.getRealm();
    }

    public Object getValue() {
        return implementation.getValue();
    }

    public Object getValueType() {
        return implementation.getValueType();
    }

    public bool isStale() {
        return implementation.isStale();
    }

    public void removeChangeListener(IChangeListener listener) {
        implementation.removeChangeListener(listener);
    }

    public void removeStaleListener(IStaleListener listener) {
        implementation.removeStaleListener(listener);
    }

    public void removeValueChangeListener(IValueChangeListener listener) {
        implementation.removeValueChangeListener(listener);
    }

    public void setValue(Object value) {
        implementation.setValue(value);
    }

    /**
     * Returns a status object that merges multiple non-OK status objects in a
     * {@link MultiStatus}. Returns an OK status result if all statuses from
     * the given validation status providers are the an OK status. Returns a
     * single status if there is only one non-OK status.
     * 
     * @param validationStatusProviders
     *            a collection of validation status providers
     * @return a merged status
     */
    public static IStatus getStatusMerged(Collection validationStatusProviders) {
        List statuses = new ArrayList();
        for (Iterator it = validationStatusProviders.iterator(); it.hasNext();) {
            ValidationStatusProvider validationStatusProvider = cast(ValidationStatusProvider) it
                    .next();
            IStatus status = cast(IStatus) validationStatusProvider
                    .getValidationStatus().getValue();
            if (!status.isOK()) {
                statuses.add(cast(Object)status);
            }
        }
        if (statuses.size() is 1) {
            return cast(IStatus) statuses.get(0);
        }
        if (!statuses.isEmpty()) {
            MultiStatus result = new MultiStatus(Policy.JFACE_DATABINDING, 0,
                    BindingMessages
                            .getString(BindingMessages.MULTIPLE_PROBLEMS), null);
            for (Iterator it = statuses.iterator(); it.hasNext();) {
                IStatus status = cast(IStatus) it.next();
                result.merge(status);
            }
            return result;
        }
        return Status.OK_STATUS;
    }

    /**
     * Returns a status that always returns the most severe status from the
     * given validation status providers. If there is more than one status at
     * the same severity level, it picks the first one it encounters.
     * 
     * @param validationStatusProviders
     *            a collection of validation status providers
     * @return a single status reflecting the most severe status from the given
     *         validation status providers
     */
    public static IStatus getStatusMaxSeverity(
            Collection validationStatusProviders) {
        int maxSeverity = IStatus.OK;
        IStatus maxStatus = Status.OK_STATUS;
        for (Iterator it = validationStatusProviders.iterator(); it.hasNext();) {
            ValidationStatusProvider validationStatusProvider = cast(ValidationStatusProvider) it
                    .next();
            IStatus status = cast(IStatus) validationStatusProvider
                    .getValidationStatus().getValue();
            if (status.getSeverity() > maxSeverity) {
                maxSeverity = status.getSeverity();
                maxStatus = status;
            }
        }
        return maxStatus;
    }

}
