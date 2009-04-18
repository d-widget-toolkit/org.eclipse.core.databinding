/*******************************************************************************
 * Copyright (c) 2007, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *     Matthew Hall - bug 220700
 *******************************************************************************/

module org.eclipse.core.databinding.ValueBinding;
import org.eclipse.core.databinding.UpdateValueStrategy;
import org.eclipse.core.databinding.Binding;

import java.lang.all;

import org.eclipse.core.databinding.observable.value.IObservableValue;
import org.eclipse.core.databinding.observable.value.IValueChangeListener;
import org.eclipse.core.databinding.observable.value.ValueChangeEvent;
import org.eclipse.core.databinding.observable.value.WritableValue;
import org.eclipse.core.databinding.util.Policy;
import org.eclipse.core.internal.databinding.BindingStatus;
import org.eclipse.core.internal.databinding.Util;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.MultiStatus;
import org.eclipse.core.runtime.Status;

/**
 * @since 1.0
 * 
 */
class ValueBinding : Binding {
    private final UpdateValueStrategy targetToModel;
    private final UpdateValueStrategy modelToTarget;
    private WritableValue validationStatusObservable;
    private IObservableValue target;
    private IObservableValue model;

    private bool updatingTarget;
    private bool updatingModel;
    private IValueChangeListener targetChangeListener;
    class TargetChangeListener : IValueChangeListener {
        public void handleValueChange(ValueChangeEvent event) {
            if (!updatingTarget && !Util.equals(event.diff.getOldValue(), event.diff.getNewValue())) {
                doUpdate(target, model, targetToModel, false, false);
            }
        }
    };
    private IValueChangeListener modelChangeListener;
    class ModelChangeListener : IValueChangeListener {
        public void handleValueChange(ValueChangeEvent event) {
            if (!updatingModel && !Util.equals(event.diff.getOldValue(), event.diff.getNewValue())) {
                doUpdate(model, target, modelToTarget, false, false);
            }
        }
    };

    /**
     * @param targetObservableValue
     * @param modelObservableValue
     * @param targetToModel
     * @param modelToTarget
     */
    public this(IObservableValue targetObservableValue,
            IObservableValue modelObservableValue,
            UpdateValueStrategy targetToModel, UpdateValueStrategy modelToTarget) {
targetChangeListener = new TargetChangeListener();
modelChangeListener = new ModelChangeListener();
        super(targetObservableValue, modelObservableValue);
        this.target = targetObservableValue;
        this.model = modelObservableValue;
        this.targetToModel = targetToModel;
        this.modelToTarget = modelToTarget;
        if ((targetToModel.getUpdatePolicy() & (UpdateValueStrategy.POLICY_CONVERT | UpdateValueStrategy.POLICY_UPDATE)) !is 0) {
            target.addValueChangeListener(targetChangeListener);
        } else {
            targetChangeListener = null;
        }
        if ((modelToTarget.getUpdatePolicy() & (UpdateValueStrategy.POLICY_CONVERT | UpdateValueStrategy.POLICY_UPDATE)) !is 0) {
            model.addValueChangeListener(modelChangeListener);
        } else {
            modelChangeListener = null;
        }
    }

    protected void preInit() {
        validationStatusObservable = new WritableValue(context
                .getValidationRealm(), cast(Object) Status.OK_STATUS, typeid(IStatus));
    }

    protected void postInit() {
        if (modelToTarget.getUpdatePolicy() is UpdateValueStrategy.POLICY_UPDATE) {
            updateModelToTarget();
        }
        if (targetToModel.getUpdatePolicy() !is UpdateValueStrategy.POLICY_NEVER) {
            validateTargetToModel();
        }
    }

    public IObservableValue getValidationStatus() {
        return validationStatusObservable;
    }

    public void updateTargetToModel() {
        doUpdate(target, model, targetToModel, true, false);
    }

    public void updateModelToTarget() {
        doUpdate(model, target, modelToTarget, true, false);
    }

    /**
     * Incorporates the provided <code>newStats</code> into the
     * <code>multieStatus</code>.
     * 
     * @param multiStatus
     * @param newStatus
     * @return <code>true</code> if the update should proceed
     */
    /* package */bool mergeStatus(MultiStatus multiStatus, IStatus newStatus) {
        if (!newStatus.isOK()) {
            multiStatus.add(newStatus);
            return multiStatus.getSeverity() < IStatus.ERROR;
        }
        return true;
    }

    /*
     * This method may be moved to UpdateValueStrategy in the future if clients
     * need more control over how the source value is copied to the destination
     * observable.
     */
    private void doUpdate(IObservableValue source,
            IObservableValue destination,
            UpdateValueStrategy updateValueStrategy,
            bool explicit, bool validateOnly) {

        final int policy = updateValueStrategy.getUpdatePolicy();
        if (policy is UpdateValueStrategy.POLICY_NEVER)
            return;
        if (policy is UpdateValueStrategy.POLICY_ON_REQUEST && !explicit)
            return;

        source.getRealm().exec(dgRunnable((
                        IObservableValue source_,
                        IObservableValue destination_,
                        UpdateValueStrategy updateValueStrategy_,
                        bool explicit_, bool validateOnly_) {
            bool destinationRealmReached = false;
            final MultiStatus multiStatus = BindingStatus.ok();
            try {
                // Get value
                Object value = source_.getValue();

                // Validate after get
                IStatus status = updateValueStrategy_
                        .validateAfterGet(value);
                if (!mergeStatus(multiStatus, status))
                    return;

                // Convert value
                final Object convertedValue = updateValueStrategy_
                        .convert(value);

                // Validate after convert
                status = updateValueStrategy_
                        .validateAfterConvert(convertedValue);
                if (!mergeStatus(multiStatus, status))
                    return;
                if (policy is UpdateValueStrategy.POLICY_CONVERT
                        && !explicit_)
                    return;

                // Validate before set
                status = updateValueStrategy_
                        .validateBeforeSet(convertedValue);
                if (!mergeStatus(multiStatus, status))
                    return;
                if (validateOnly_)
                    return;

                // Set value
                destinationRealmReached = true;
                destination_.getRealm().exec(dgRunnable((
                                IObservableValue destination__,
                                UpdateValueStrategy updateValueStrategy__) {
                    if (destination__ is target) {
                        updatingTarget = true;
                    } else {
                        updatingModel = true;
                    }
                    try {
                        IStatus setterStatus = updateValueStrategy__
                                .doSet_package(destination__, convertedValue);

                        mergeStatus(multiStatus, setterStatus);
                    } finally {
                        if (destination__ is target) {
                            updatingTarget = false;
                        } else {
                            updatingModel = false;
                        }
                        setValidationStatus(multiStatus);
                    }
                }, destination_, updateValueStrategy_ ));
            } catch (Exception ex) {
                // This check is necessary as in 3.2.2 Status
                // doesn't accept a null message (bug 177264).
                String message = (ex.msg !is null) ? ex
                        .msg : ""; //$NON-NLS-1$

                mergeStatus(multiStatus, new Status(IStatus.ERROR,
                        Policy.JFACE_DATABINDING, IStatus.ERROR, message,
                        ex));
            } finally {
                if (!destinationRealmReached) {
                    setValidationStatus(multiStatus);
                }

            }
        }, source, destination, updateValueStrategy, explicit, validateOnly));
    }

    public void validateModelToTarget() {
        doUpdate(model, target, modelToTarget, true, true);
    }

    public void validateTargetToModel() {
        doUpdate(target, model, targetToModel, true, true);
    }

    private void setValidationStatus( IStatus status) {
        validationStatusObservable.getRealm().exec(dgRunnable((IStatus status_) {
            validationStatusObservable.setValue(cast(Object)status_);
        }, status));
    }
    
    public void dispose() {
        if (targetChangeListener !is null) {
            target.removeValueChangeListener(targetChangeListener);
            targetChangeListener = null;
        }
        if (modelChangeListener !is null) {
            model.removeValueChangeListener(modelChangeListener);
            modelChangeListener = null;
        }
        target = null;
        model = null;
        super.dispose();
    }

}
