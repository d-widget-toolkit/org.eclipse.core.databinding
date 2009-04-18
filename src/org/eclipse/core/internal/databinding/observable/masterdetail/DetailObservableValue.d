/*******************************************************************************
 * Copyright (c) 2005, 2007 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *     Brad Reynolds - bug 164653
 *     Brad Reynolds - bug 147515
 *******************************************************************************/
module org.eclipse.core.internal.databinding.observable.masterdetail.DetailObservableValue;

import java.lang.all;

import org.eclipse.core.databinding.observable.Diffs;
import org.eclipse.core.databinding.observable.IObserving;
import org.eclipse.core.databinding.observable.masterdetail.IObservableFactory;
import org.eclipse.core.databinding.observable.value.AbstractObservableValue;
import org.eclipse.core.databinding.observable.value.IObservableValue;
import org.eclipse.core.databinding.observable.value.IValueChangeListener;
import org.eclipse.core.databinding.observable.value.ValueChangeEvent;
import org.eclipse.core.runtime.Assert;

/**
 * @since 1.0
 * 
 */
public class DetailObservableValue : AbstractObservableValue , IObserving {

    private bool updating = false;

    private IValueChangeListener innerChangeListener;
    class InnerChangeListener : IValueChangeListener {
        public void handleValueChange(ValueChangeEvent event) {
            if (!updating) {
                fireValueChange(event.diff);
            }
        }
    };

    private Object currentOuterValue;

    private IObservableValue innerObservableValue;

    private Object detailType;

    private IObservableValue outerObservableValue;

    private IObservableFactory factory;

    /**
     * @param outerObservableValue
     * @param factory
     * @param detailType
     */
    public this(IObservableValue outerObservableValue,
            IObservableFactory factory, Object detailType) {
innerChangeListener = new InnerChangeListener();
outerChangeListener = new OuterChangeListener();
        super(outerObservableValue.getRealm());
        this.factory = factory;
        this.detailType = detailType;
        this.outerObservableValue = outerObservableValue;
        updateInnerObservableValue(outerObservableValue);

        outerObservableValue.addValueChangeListener(outerChangeListener);
    }

    IValueChangeListener outerChangeListener;
    class OuterChangeListener : IValueChangeListener {
        public void handleValueChange(ValueChangeEvent event) {
            Object oldValue = doGetValue();
            updateInnerObservableValue(outerObservableValue);
            fireValueChange(Diffs.createValueDiff(oldValue, doGetValue()));
        }
    };

    private void updateInnerObservableValue(
            IObservableValue outerObservableValue) {
        currentOuterValue = outerObservableValue.getValue();
        if (innerObservableValue !is null) {
            innerObservableValue.removeValueChangeListener(innerChangeListener);
            innerObservableValue.dispose();
        }
        if (currentOuterValue is null) {
            innerObservableValue = null;
        } else {
            this.innerObservableValue = cast(IObservableValue) factory
                    .createObservable(currentOuterValue);
            Object innerValueType = innerObservableValue.getValueType();

            if (detailType !is null) {
                Assert
                        .isTrue(
                                cast(bool)detailType.opEquals(innerValueType),
                                Format("Cannot change value type in a nested observable value, from {} to {}", innerValueType, detailType)); //$NON-NLS-1$ //$NON-NLS-2$
            }
            innerObservableValue.addValueChangeListener(innerChangeListener);
        }
    }

    public void doSetValue(Object value) {
        if (innerObservableValue !is null)
            innerObservableValue.setValue(value);
    }

    public Object doGetValue() {
        return innerObservableValue is null ? null : innerObservableValue
                .getValue();
    }

    public Object getValueType() {
        return detailType;
    }

    public void dispose() {
        super.dispose();

        if (outerObservableValue !is null) {
            outerObservableValue.removeValueChangeListener(outerChangeListener);
            outerObservableValue.dispose();
        }
        if (innerObservableValue !is null) {
            innerObservableValue.removeValueChangeListener(innerChangeListener);
            innerObservableValue.dispose();
        }
        currentOuterValue = null;
        factory = null;
        innerObservableValue = null;
        innerChangeListener = null;
    }

    public Object getObserved() {
        if ( null !is cast(IObserving)innerObservableValue ) {
            return (cast(IObserving)innerObservableValue).getObserved();
        }
        return null;
    }

}
