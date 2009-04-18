/*******************************************************************************
 * Copyright (c) 2006, 2007 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *     Brad Reynolds - bug 164134
 *******************************************************************************/
module org.eclipse.core.databinding.validation.ValidationStatus;

import java.lang.all;

import org.eclipse.core.databinding.util.Policy;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;

/**
 * Convenience class for creating status objects.
 * 
 * @since 3.3
 * 
 */
public class ValidationStatus : Status {

    /**
     * Creates a new validation status with the given severity, message, and
     * exception.
     * 
     * @param severity
     * @param message
     * @param exception
     */
    private this(int severity, String message, Throwable exception) {
        super(severity, Policy.JFACE_DATABINDING, IStatus.OK, message, exception);
    }

    /**
     * Creates a new validation status with the given severity and message.
     * 
     * @param severity
     * @param message
     */
    private this(int severity, String message) {
        super(severity, Policy.JFACE_DATABINDING,IStatus.OK, message, null);
    }

    /**
     * Creates a new validation error status with the given message.
     * 
     * @param message
     * @return a new error status with the given message
     */
    public static IStatus error(String message) {
        return new ValidationStatus(IStatus.ERROR, message);
    }

    /**
     * Creates a new validation cancel status with the given message.
     * 
     * @param message
     * @return a new cancel status with the given message
     */
    public static IStatus cancel(String message) {
        return new ValidationStatus(IStatus.CANCEL, message);
    }
    
    /**
     * Creates a new validation error status with the given message and
     * exception.
     * 
     * @param message
     * @param exception
     * @return a new error status with the given message and exception
     */
    public static IStatus error(String message, Throwable exception) {
        return new ValidationStatus(IStatus.ERROR, message, exception);
    }

    /**
     * Creates a new validation warning status with the given message.
     * 
     * @param message
     * @return a new warning status with the given message
     */
    public static IStatus warning(String message) {
        return new ValidationStatus(IStatus.WARNING, message);
    }
    
    /**
     * Creates a new validation info status with the given message.
     * 
     * @param message
     * @return a new info status with the given message
     */
    public static IStatus info(String message) {
        return new ValidationStatus(IStatus.INFO, message);
    }
    
    /**
     * Returns an OK status.
     * 
     * @return an ok status
     */
    public static IStatus ok() {
        return Status.OK_STATUS;
    }

    /*
     * (non-Javadoc)
     * 
     * @see java.lang.Object#toHash()
     */
    public hash_t toHash() {
        final int prime = 31;
        int result = 1;

        String message = getMessage();
        int severity = getSeverity();
        Throwable throwable = getException();

        result = prime * result + ((message is null) ? 0 : String_toHash(message));
        result = prime * result + severity;
        result = prime * result
                + ((throwable is null) ? 0 : throwable.toHash());
        return result;
    }

    /**
     * Equality is based upon instance equality rather than identity.
     * 
     * @see java.lang.Object#equals(java.lang.Object)
     */
    public override equals_t opEquals(Object obj) {
        if (this is obj)
            return true;
        if (obj is null)
            return false;
        if (this.classinfo !is obj.classinfo)
            return false;
        final ValidationStatus other = cast(ValidationStatus) obj;

        if (getSeverity() !is other.getSeverity())
            return false;
        if (getMessage() is null) {
            if (other.getMessage() !is null)
                return false;
        } else if (getMessage() != other.getMessage())
            return false;
        if (getException() is null) {
            if (other.getException() !is null)
                return false;
        } else if (!getException().opEquals(other.getException()))
            return false;
        return true;
    }
}
