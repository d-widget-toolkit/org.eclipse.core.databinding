/*******************************************************************************
 * Copyright (c) 2006, 2007 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *******************************************************************************/

module org.eclipse.core.internal.databinding.observable.tree.TreeDiff;
import org.eclipse.core.internal.databinding.observable.tree.TreeDiffVisitor;
import org.eclipse.core.internal.databinding.observable.tree.TreePath;
import org.eclipse.core.internal.databinding.observable.tree.TreeDiffNode;

import java.lang.all;

/**
 * Describes the difference between two trees as a tree of tree diff nodes.
 * 
 * @since 1.1
 * 
 */
public abstract class TreeDiff : TreeDiffNode {

    /**
     * Returns the tree path (possibly empty) of the parent, or
     * <code>null</code> if the underlying tree is not lazy and never contains
     * duplicate elements.
     * 
     * @return the tree path (possibly empty) of the unchanged parent, or
     *         <code>null</code>
     */
    public abstract TreePath getParentPath();

    /**
     * @param visitor
     */
    public void accept(TreeDiffVisitor visitor) {
        doAccept(visitor, getParentPath());
    }

}
