/*******************************************************************************
 * Copyright (c) 2007 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 ******************************************************************************/

module org.eclipse.core.databinding.ListBinding;
import org.eclipse.core.databinding.UpdateListStrategy;
import org.eclipse.core.databinding.UpdateValueStrategy;
import org.eclipse.core.databinding.Binding;

import java.lang.all;

import java.util.Collections;

import org.eclipse.core.databinding.observable.Diffs;
import org.eclipse.core.databinding.observable.list.IListChangeListener;
import org.eclipse.core.databinding.observable.list.IObservableList;
import org.eclipse.core.databinding.observable.list.ListChangeEvent;
import org.eclipse.core.databinding.observable.list.ListDiff;
import org.eclipse.core.databinding.observable.list.ListDiffEntry;
import org.eclipse.core.databinding.observable.value.IObservableValue;
import org.eclipse.core.databinding.observable.value.WritableValue;
import org.eclipse.core.internal.databinding.BindingStatus;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.MultiStatus;
import org.eclipse.core.runtime.Status;

/**
 * @since 1.0
 * 
 */
public class ListBinding : Binding {

    private UpdateListStrategy targetToModel;
    private UpdateListStrategy modelToTarget;
    private IObservableValue validationStatusObservable;
    private bool updatingTarget;
    private bool updatingModel;

    private IListChangeListener targetChangeListener;
    private class TargetChangeListener : IListChangeListener {
        public void handleListChange(ListChangeEvent event) {
            if (!updatingTarget) {
                doUpdate(cast(IObservableList) getTarget(),
                        cast(IObservableList) getModel(), event.diff,
                        targetToModel, false, false);
            }
        }
    }
    private IListChangeListener modelChangeListener;
    class ModelChangeListener : IListChangeListener {
        public void handleListChange(ListChangeEvent event) {
            if (!updatingModel) {
                doUpdate(cast(IObservableList) getModel(),
                        cast(IObservableList) getTarget(), event.diff,
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
    public this(IObservableList target, IObservableList model,
            UpdateListStrategy targetToModelStrategy,
            UpdateListStrategy modelToTargetStrategy) {
targetChangeListener = new TargetChangeListener();
modelChangeListener = new ModelChangeListener();
        super(target, model);
        this.targetToModel = targetToModelStrategy;
        this.modelToTarget = modelToTargetStrategy;
        if ((targetToModel.getUpdatePolicy() & UpdateValueStrategy.POLICY_UPDATE) !is 0) {
            target.addListChangeListener(targetChangeListener);
        } else {
            targetChangeListener = null;
        }
        if ((modelToTarget.getUpdatePolicy() & UpdateValueStrategy.POLICY_UPDATE) !is 0) {
            model.addListChangeListener(modelChangeListener);
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
        if (modelToTarget.getUpdatePolicy() is UpdateListStrategy.POLICY_UPDATE) {
            updateModelToTarget();
        }
        if (targetToModel.getUpdatePolicy() !is UpdateListStrategy.POLICY_NEVER) {
            validateTargetToModel();
        }
    }

    public void updateModelToTarget() {
        final IObservableList modelList = cast(IObservableList) getModel();
        modelList.getRealm().exec(new class() Runnable {
            public void run() {
                ListDiff diff = Diffs.computeListDiff(Collections.EMPTY_LIST,
                        modelList);
                doUpdate(modelList, cast(IObservableList) getTarget(), diff,
                        modelToTarget, true, true);
            }
        });
    }

    public void updateTargetToModel() {
        final IObservableList targetList = cast(IObservableList) getTarget();
        targetList.getRealm().exec(new class() Runnable {
            public void run() {
                ListDiff diff = Diffs.computeListDiff(Collections.EMPTY_LIST,
                        targetList);
                doUpdate(targetList, cast(IObservableList) getModel(), diff,
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
     * This method may be moved to UpdateListStrategy in the future if clients
     * need more control over how the two lists are kept in sync.
     */
    private void doUpdate(IObservableList source,
            IObservableList destination, ListDiff diff,
            UpdateListStrategy updateListStrategy,
            bool explicit, bool clearDestination) {
        final int policy = updateListStrategy.getUpdatePolicy();
        if (policy !is UpdateListStrategy.POLICY_NEVER) {
            if (policy !is UpdateListStrategy.POLICY_ON_REQUEST || explicit) {
                destination.getRealm().exec(dgRunnable((
                                IObservableList destination_,
                                ListDiff diff_,
                                UpdateListStrategy updateListStrategy_,
                                bool clearDestination_) {
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
                        ListDiffEntry[] diffEntries = diff_.getDifferences();
                        for (int i = 0; i < diffEntries.length; i++) {
                            ListDiffEntry listDiffEntry = diffEntries[i];
                            if (listDiffEntry.isAddition()) {
                                IStatus setterStatus = updateListStrategy_
                                        .doAdd_package(
                                                destination_,
                                                updateListStrategy_
                                                        .convert(listDiffEntry
                                                                .getElement()),
                                                listDiffEntry.getPosition());

                                mergeStatus(multiStatus, setterStatus);
                                // TODO - at this point, the two lists
                                // will be out of sync if an error occurred...
                            } else {
                                IStatus setterStatus = updateListStrategy_
                                        .doRemove_package(destination_,
                                                listDiffEntry.getPosition());
                                
                                mergeStatus(multiStatus, setterStatus);
                                // TODO - at this point, the two lists
                                // will be out of sync if an error occurred...
                            }
                        }
                    } finally {
                        validationStatusObservable.setValue(multiStatus);

                        if (destination_ is getTarget()) {
                            updatingTarget = false;
                        } else {
                            updatingModel = false;
                        }
                    }
                }, destination, diff, updateListStrategy, clearDestination));
            }
        }
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
            (cast(IObservableList)getTarget()).removeListChangeListener(targetChangeListener);
            targetChangeListener = null;
        }
        if (modelChangeListener !is null) {
            (cast(IObservableList)getModel()).removeListChangeListener(modelChangeListener);
            modelChangeListener = null;
        }
        super.dispose();
    }
}
