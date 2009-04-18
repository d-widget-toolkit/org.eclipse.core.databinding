/*******************************************************************************
 * Copyright (c) 2008 Matthew Hall and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Matthew Hall - initial API and implementation (bug 124684)
 *     IBM Corporation - through ListBinding.java
 ******************************************************************************/

module org.eclipse.core.databinding.SetBinding;
import org.eclipse.core.databinding.UpdateSetStrategy;
import org.eclipse.core.databinding.Binding;

import java.lang.all;

import java.util.Collections;
import java.util.Iterator;

import org.eclipse.core.databinding.observable.Diffs;
import org.eclipse.core.databinding.observable.set.IObservableSet;
import org.eclipse.core.databinding.observable.set.ISetChangeListener;
import org.eclipse.core.databinding.observable.set.SetChangeEvent;
import org.eclipse.core.databinding.observable.set.SetDiff;
import org.eclipse.core.databinding.observable.value.IObservableValue;
import org.eclipse.core.databinding.observable.value.WritableValue;
import org.eclipse.core.internal.databinding.BindingStatus;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.MultiStatus;
import org.eclipse.core.runtime.Status;

/**
 * @since 1.1
 * 
 */
public class SetBinding : Binding {

    private UpdateSetStrategy targetToModel;
    private UpdateSetStrategy modelToTarget;
    private IObservableValue validationStatusObservable;
    private bool updatingTarget;
    private bool updatingModel;

    private ISetChangeListener targetChangeListener;
    class TargetChangeListener : ISetChangeListener {
        public void handleSetChange(SetChangeEvent event) {
            if (!updatingTarget) {
                doUpdate(cast(IObservableSet) getTarget(),
                        cast(IObservableSet) getModel(), event.diff, targetToModel,
                        false, false);
            }
        }
    };

    private ISetChangeListener modelChangeListener;
    class ModelChangeListener : ISetChangeListener {
        public void handleSetChange(SetChangeEvent event) {
            if (!updatingModel) {
                doUpdate(cast(IObservableSet) getModel(),
                        cast(IObservableSet) getTarget(), event.diff,
                        modelToTarget, false, false);
            }
        }
    };

    /**
     * @param target
     * @param model
     * @param modelToTargetStrategy
     * @param targetToModelStrategy
     */
    public this(IObservableSet target, IObservableSet model,
            UpdateSetStrategy targetToModelStrategy,
            UpdateSetStrategy modelToTargetStrategy) {
targetChangeListener = new TargetChangeListener();
modelChangeListener = new ModelChangeListener();
        super(target, model);
        this.targetToModel = targetToModelStrategy;
        this.modelToTarget = modelToTargetStrategy;
        if ((targetToModel.getUpdatePolicy() & UpdateSetStrategy.POLICY_UPDATE) !is 0) {
            target.addSetChangeListener(targetChangeListener);
        } else {
            targetChangeListener = null;
        }
        if ((modelToTarget.getUpdatePolicy() & UpdateSetStrategy.POLICY_UPDATE) !is 0) {
            model.addSetChangeListener(modelChangeListener);
        } else {
            modelChangeListener = null;
        }
    }

    public IObservableValue getValidationStatus() {
        return validationStatusObservable;
    }

    protected void preInit() {
        validationStatusObservable = new WritableValue(context
                .getValidationRealm(), cast(Object)Status.OK_STATUS, typeid(IStatus));
    }

    protected void postInit() {
        if (modelToTarget.getUpdatePolicy() is UpdateSetStrategy.POLICY_UPDATE) {
            updateModelToTarget();
        }
        if (targetToModel.getUpdatePolicy() !is UpdateSetStrategy.POLICY_NEVER) {
            validateTargetToModel();
        }
    }

    public void updateModelToTarget() {
        final IObservableSet modelSet = cast(IObservableSet) getModel();
        modelSet.getRealm().exec(new class() Runnable {
            public void run() {
                SetDiff diff = Diffs.computeSetDiff(Collections.EMPTY_SET,
                        modelSet);
                doUpdate(modelSet, cast(IObservableSet) getTarget(), diff,
                        modelToTarget, true, true);
            }
        });
    }

    public void updateTargetToModel() {
        final IObservableSet targetSet = cast(IObservableSet) getTarget();
        targetSet.getRealm().exec(new class() Runnable {
            public void run() {
                SetDiff diff = Diffs.computeSetDiff(Collections.EMPTY_SET,
                        targetSet);
                doUpdate(targetSet, cast(IObservableSet) getModel(), diff,
                        targetToModel, true, true);
            }
        });
    }

    public void validateModelToTarget() {
        // nothing for now
    }

    public void validateTargetToModel() {
        // nothing for now
    }

    /*
     * This method may be moved to UpdateSetStrategy in the future if clients
     * need more control over how the two sets are kept in sync.
     */
    private void doUpdate(IObservableSet source,
            IObservableSet destination, SetDiff diff,
            UpdateSetStrategy updateSetStrategy, bool explicit,
            bool clearDestination) {
        final int policy = updateSetStrategy.getUpdatePolicy();
        if (policy is UpdateSetStrategy.POLICY_NEVER)
            return;
        if (policy is UpdateSetStrategy.POLICY_ON_REQUEST && !explicit)
            return;
        destination.getRealm().exec(dgRunnable((IObservableSet destination_, SetDiff diff_, UpdateSetStrategy updateSetStrategy_, bool clearDestination_) {
            if (destination_ is getTarget()) {
                updatingTarget = true;
            } else {
                updatingModel = true;
            }
            MultiStatus multiStatus = BindingStatus.ok();

            try {
                if (clearDestination_) {
                    destination_.clear();
                }

                for (Iterator iterator = diff_.getRemovals().iterator(); iterator
                        .hasNext();) {
                    IStatus setterStatus = updateSetStrategy_.doRemove_package(
                            destination_, updateSetStrategy_.convert(iterator
                                    .next()));

                    mergeStatus(multiStatus, setterStatus);
                    // TODO - at this point, the two sets
                    // will be out of sync if an error
                    // occurred...
                }

                for (Iterator iterator = diff_.getAdditions().iterator(); iterator
                        .hasNext();) {
                    IStatus setterStatus = updateSetStrategy_.doAdd_package(
                            destination_, updateSetStrategy_.convert(iterator
                                    .next()));

                    mergeStatus(multiStatus, setterStatus);
                    // TODO - at this point, the two sets
                    // will be out of sync if an error
                    // occurred...
                }
            } finally {
                validationStatusObservable.setValue(multiStatus);

                if (destination_ is getTarget()) {
                    updatingTarget = false;
                } else {
                    updatingModel = false;
                }
            }
        }, destination, diff, updateSetStrategy, clearDestination));
    }

    /**
     * Merges the provided <code>newStatus</code> into the
     * <code>multiStatus</code>.
     * 
     * @param multiStatus
     * @param newStatus
     */
    /* package */void mergeStatus(MultiStatus multiStatus, IStatus newStatus) {
        if (!newStatus.isOK()) {
            multiStatus.add(newStatus);
        }
    }

    public void dispose() {
        if (targetChangeListener !is null) {
            (cast(IObservableSet) getTarget())
                    .removeSetChangeListener(targetChangeListener);
            targetChangeListener = null;
        }
        if (modelChangeListener !is null) {
            (cast(IObservableSet) getModel())
                    .removeSetChangeListener(modelChangeListener);
            modelChangeListener = null;
        }
        super.dispose();
    }
}
