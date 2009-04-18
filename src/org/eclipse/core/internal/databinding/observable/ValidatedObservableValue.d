/*******************************************************************************
 * Copyright (c) 2008 Matthew Hall and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Matthew Hall - initial API and implementation (bug 218269)
 ******************************************************************************/

module org.eclipse.core.internal.databinding.observable.ValidatedObservableValue;

import java.lang.all;

import org.eclipse.core.databinding.observable.Diffs;
import org.eclipse.core.databinding.observable.IStaleListener;
import org.eclipse.core.databinding.observable.ObservableTracker;
import org.eclipse.core.databinding.observable.StaleEvent;
import org.eclipse.core.databinding.observable.value.AbstractObservableValue;
import org.eclipse.core.databinding.observable.value.IObservableValue;
import org.eclipse.core.databinding.observable.value.IValueChangeListener;
import org.eclipse.core.databinding.observable.value.IVetoableValue;
import org.eclipse.core.databinding.observable.value.ValueChangeEvent;
import org.eclipse.core.databinding.observable.value.ValueChangingEvent;
import org.eclipse.core.internal.databinding.Util;
import org.eclipse.core.runtime.Assert;
import org.eclipse.core.runtime.IStatus;

/**
 * An {@link IObservableValue} wrapper that stays in sync with the target
 * observable as long as a given validation status is valid.
 * <ul>
 * <li>While status is valid, ValidatedObservableValue stays in sync with its
 * target.
 * <li>When status becomes invalid, ValidatedObservableValue will retain the
 * last valid value of its target.
 * <li>While status is invalid, changes in the target observable cause
 * ValidatedObservableValue to fire a stale event, to indicate that changes are
 * pending.
 * <li>When status becomes valid, pending value changes are performed (if any)
 * and synchronization resumes.
 * </ul>
 * <p>
 * Note:
 * <ul>
 * <li>By default, a status is valid if its
 * {@link IStatus#getSeverity() severity} is {@link IStatus#OK OK},
 * {@link IStatus#INFO INFO}, or {@link IStatus#WARNING WARNING}
 * <li>Calls to {@link #setValuecast(Object)} on the validated observable changes
 * the value regardless of the validation status.
 * <li>This class will not forward {@link ValueChangingEvent} events from a
 * wrapped {@link IVetoableValue}.
 * </ul>
 * 
 * @since 1.2
 */
public class ValidatedObservableValue : AbstractObservableValue {
    private IObservableValue target;
    private IObservableValue validationStatus;

    private Object cachedValue;
    private bool stale;
    private bool updatingTarget = false;

    private IValueChangeListener targetChangeListener;
    class TargetChangeListener : IValueChangeListener {
        public void handleValueChange(ValueChangeEvent event) {
            if (updatingTarget)
                return;
            IStatus status = cast(IStatus) validationStatus.getValue();
            if (isValid(status))
                internalSetValue(event.diff.getNewValue(), false);
            else
                makeStale();
        }
    };

    private static bool isValid(IStatus status) {
        return status.isOK() || status.matches(IStatus.INFO | IStatus.WARNING);
    }

    private IStaleListener targetStaleListener;
    class TargetStaleListener : IStaleListener {
        public void handleStale(StaleEvent staleEvent) {
            fireStale();
        }
    };

    private IValueChangeListener validationStatusChangeListener;
    class ValidationStatusChangeListener : IValueChangeListener {
        public void handleValueChange(ValueChangeEvent event) {
            IStatus oldStatus = cast(IStatus) event.diff.getOldValue();
            IStatus newStatus = cast(IStatus) event.diff.getNewValue();
            if (stale && !isValid(oldStatus) && isValid(newStatus)) {
                internalSetValue(target.getValue(), false);
            }
        }
    };

    /**
     * Constructs an observable value
     * 
     * @param target
     *            the observable value to be wrapped
     * @param validationStatus
     *            an observable value of type {@link IStatus}.classinfo which
     *            contains the current validation status
     */
    public this(IObservableValue target,
            IObservableValue validationStatus) {
targetChangeListener = new TargetChangeListener();
targetStaleListener = new TargetStaleListener();
validationStatusChangeListener = new ValidationStatusChangeListener();
        super(target.getRealm());
        Assert.isNotNull(cast(Object)validationStatus,
                "Validation status observable cannot be null"); //$NON-NLS-1$
        Assert
                .isTrue(cast(bool)target.getRealm().opEquals(validationStatus.getRealm()),
                        "Target and validation status observables must be on the same realm"); //$NON-NLS-1$
        this.target = target;
        this.validationStatus = validationStatus;
        this.cachedValue = target.getValue();

        target.addValueChangeListener(targetChangeListener);
        target.addStaleListener(targetStaleListener);
        validationStatus.addValueChangeListener(validationStatusChangeListener);
    }

    private void makeStale() {
        if (!stale) {
            stale = true;
            fireStale();
        }
    }

    public bool isStale() {
        ObservableTracker.getterCalled(this);
        return stale || target.isStale();
    }

    protected Object doGetValue() {
        return cachedValue;
    }

    private void internalSetValue(Object value, bool updateTarget) {
        Object oldValue = cachedValue;
        cachedValue = value;
        if (updateTarget) {
            updatingTarget = true;
            try {
                target.setValue(value);
                cachedValue = target.getValue();
            } finally {
                updatingTarget = false;
            }
        }
        stale = false;
        if (!Util.equals(oldValue, cachedValue))
            fireValueChange(Diffs.createValueDiff(oldValue, cachedValue));
    }

    protected void doSetValue(Object value) {
        internalSetValue(value, true);
    }

    public Object getValueType() {
        return target.getValueType();
    }

    public synchronized void dispose() {
        target.removeValueChangeListener(targetChangeListener);
        target.removeStaleListener(targetStaleListener);
        validationStatus
                .removeValueChangeListener(validationStatusChangeListener);
        super.dispose();
    }
}
