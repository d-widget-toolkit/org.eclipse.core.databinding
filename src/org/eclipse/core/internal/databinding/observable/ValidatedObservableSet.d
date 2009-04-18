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

module org.eclipse.core.internal.databinding.observable.ValidatedObservableSet;

import java.lang.all;

import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

import org.eclipse.core.databinding.observable.Diffs;
import org.eclipse.core.databinding.observable.IStaleListener;
import org.eclipse.core.databinding.observable.StaleEvent;
import org.eclipse.core.databinding.observable.set.IObservableSet;
import org.eclipse.core.databinding.observable.set.ISetChangeListener;
import org.eclipse.core.databinding.observable.set.ObservableSet;
import org.eclipse.core.databinding.observable.set.SetChangeEvent;
import org.eclipse.core.databinding.observable.set.SetDiff;
import org.eclipse.core.databinding.observable.value.IObservableValue;
import org.eclipse.core.databinding.observable.value.IValueChangeListener;
import org.eclipse.core.databinding.observable.value.ValueChangeEvent;
import org.eclipse.core.runtime.Assert;
import org.eclipse.core.runtime.IStatus;

/**
 * @since 3.3
 * 
 */
public class ValidatedObservableSet : ObservableSet {
    private IObservableSet target;
    private IObservableValue validationStatus;

    // Only true when out of sync with target due to validation status
    private bool stale;

    // True when validation status changes from invalid to valid.
    private bool computeNextDiff = false;

    private bool updatingTarget = false;

    private ISetChangeListener targetChangeListener;
    class TargetChangeListener : ISetChangeListener {
        public void handleSetChange(SetChangeEvent event) {
            if (updatingTarget)
                return;
            IStatus status = cast(IStatus) validationStatus.getValue();
            if (isValid(status)) {
                if (stale) {
                    // this.stale means we are out of sync with target,
                    // so reset wrapped list to exactly mirror target
                    stale = false;
                    updateWrappedSet(new HashSet(target));
                } else {
                    SetDiff diff = event.diff;
                    if (computeNextDiff) {
                        diff = Diffs.computeSetDiff(wrappedSet, target);
                        computeNextDiff = false;
                    }
                    applyDiff(diff, wrappedSet);
                    fireSetChange(diff);
                }
            } else {
                makeStale();
            }
        }
    };

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
                // this.stale means we are out of sync with target,
                // reset wrapped set to exactly mirror target
                stale = false;
                updateWrappedSet(new HashSet(target));

                // If the validation status becomes valid because of a change in
                // target observable
                computeNextDiff = true;
            }
        }
    };

    /**
     * @param target
     * @param validationStatus
     */
    public this(IObservableSet target,
            IObservableValue validationStatus) {
targetStaleListener = new TargetStaleListener();
targetChangeListener = new TargetChangeListener();
validationStatusChangeListener = new ValidationStatusChangeListener();
        super(target.getRealm(), new HashSet(target), target.getElementType());
        Assert.isNotNull(cast(Object)validationStatus,
                "Validation status observable cannot be null"); //$NON-NLS-1$
        Assert
                .isTrue(cast(bool)target.getRealm().opEquals(validationStatus.getRealm()),
                        "Target and validation status observables must be on the same realm"); //$NON-NLS-1$
        this.target = target;
        this.validationStatus = validationStatus;
        target.addSetChangeListener(targetChangeListener);
        target.addStaleListener(targetStaleListener);
        validationStatus.addValueChangeListener(validationStatusChangeListener);
    }

    private void updateWrappedSet(Set newSet) {
        Set oldSet = wrappedSet;
        SetDiff diff = Diffs.computeSetDiff(oldSet, newSet);
        wrappedSet = newSet;
        fireSetChange(diff);
    }

    private static bool isValid(IStatus status) {
        return status.isOK() || status.matches(IStatus.INFO | IStatus.WARNING);
    }

    private void applyDiff(SetDiff diff, Set set) {
        for (Iterator iterator = diff.getRemovals().iterator(); iterator
                .hasNext();) {
            set.remove(iterator.next());
        }
        for (Iterator iterator = diff.getAdditions().iterator(); iterator
                .hasNext();) {
            set.add(iterator.next());
        }
    }

    private void makeStale() {
        if (!stale) {
            stale = true;
            fireStale();
        }
    }

    private void updateTargetSet(SetDiff diff) {
        updatingTarget = true;
        try {
            if (stale) {
                stale = false;
                applyDiff(Diffs.computeSetDiff(target, wrappedSet), target);
            } else {
                applyDiff(diff, target);
            }
        } finally {
            updatingTarget = false;
        }
    }

    public bool isStale() {
        getterCalled();
        return stale || target.isStale();
    }

    public bool add(Object o) {
        getterCalled();
        bool changed = wrappedSet.add(o);
        if (changed) {
            SetDiff diff = Diffs.createSetDiff(Collections.singleton(o),
                    Collections.EMPTY_SET);
            updateTargetSet(diff);
            fireSetChange(diff);
        }
        return changed;
    }

    public bool addAll(Collection c) {
        getterCalled();
        HashSet set = new HashSet(wrappedSet);
        bool changed = set.addAll(c);
        if (changed) {
            SetDiff diff = Diffs.computeSetDiff(wrappedSet, set);
            wrappedSet = set;
            updateTargetSet(diff);
            fireSetChange(diff);
        }
        return changed;
    }

    public void clear() {
        getterCalled();
        if (isEmpty())
            return;
        SetDiff diff = Diffs.createSetDiff(Collections.EMPTY_SET, wrappedSet);
        wrappedSet = new HashSet();
        updateTargetSet(diff);
        fireSetChange(diff);
    }

    public Iterator iterator() {
        getterCalled();
        final Iterator wrappedIterator = wrappedSet.iterator();
        return new class() Iterator {
            Object last = null;

            public bool hasNext() {
                return wrappedIterator.hasNext();
            }

            public Object next() {
                return last = wrappedIterator.next();
            }

            public void remove() {
                wrappedIterator.remove();
                SetDiff diff = Diffs.createSetDiff(Collections.EMPTY_SET,
                        Collections.singleton(last));
                updateTargetSet(diff);
                fireSetChange(diff);
            }
        };
    }

    public bool remove(Object o) {
        getterCalled();
        bool changed = wrappedSet.remove(o);
        if (changed) {
            SetDiff diff = Diffs.createSetDiff(Collections.EMPTY_SET,
                    Collections.singleton(o));
            updateTargetSet(diff);
            fireSetChange(diff);
        }
        return changed;
    }

    public bool removeAll(Collection c) {
        getterCalled();
        Set set = new HashSet(wrappedSet);
        bool changed = set.removeAll(c);
        if (changed) {
            SetDiff diff = Diffs.computeSetDiff(wrappedSet, set);
            wrappedSet = set;
            updateTargetSet(diff);
            fireSetChange(diff);
        }
        return changed;
    }

    public bool retainAll(Collection c) {
        getterCalled();
        Set set = new HashSet(wrappedSet);
        bool changed = set.retainAll(c);
        if (changed) {
            SetDiff diff = Diffs.computeSetDiff(wrappedSet, set);
            wrappedSet = set;
            updateTargetSet(diff);
            fireSetChange(diff);
        }
        return changed;
    }

    public synchronized void dispose() {
        target.removeSetChangeListener(targetChangeListener);
        target.removeStaleListener(targetStaleListener);
        validationStatus
                .removeValueChangeListener(validationStatusChangeListener);
        super.dispose();
    }
}
