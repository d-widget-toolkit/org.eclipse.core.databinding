/*******************************************************************************
 * Copyright (c) 2006, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *     Matthew Hall - bug 226216
 *******************************************************************************/

module org.eclipse.core.databinding.observable.Diffs;

import java.lang.all;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.eclipse.core.databinding.observable.list.ListDiff;
import org.eclipse.core.databinding.observable.list.ListDiffEntry;
import org.eclipse.core.databinding.observable.map.MapDiff;
import org.eclipse.core.databinding.observable.set.SetDiff;
import org.eclipse.core.databinding.observable.value.ValueDiff;
import org.eclipse.core.internal.databinding.Util;

/**
 * @since 1.0
 * 
 */
public class Diffs {

    /**
     * @param oldList
     * @param newList
     * @return the differences between oldList and newList
     */
    public static ListDiff computeListDiff(List oldList, List newList) {
        List diffEntries = new ArrayList();
        createListDiffs(new ArrayList(oldList), newList, diffEntries);
        ListDiff listDiff = createListDiff(cast(ListDiffEntry[]) diffEntries
                .toArray(new ListDiffEntry[diffEntries.size()]));
        return listDiff;
    }
    
    /**
     * adapted from EMF's ListDifferenceAnalyzer
     */
    private static void createListDiffs(List oldList, List newList,
            List listDiffs) {
        int index = 0;
        for (Iterator it = newList.iterator(); it.hasNext();) {
            Object newValue = it.next();
            if (oldList.size() <= index) {
                // append newValue to newList 
                listDiffs.add(createListDiffEntry(index, true, newValue));
            } else {
                bool done;
                do {
                    done = true;
                    Object oldValue = oldList.get(index);
                    if (oldValue is null ? newValue !is null : !oldValue.opEquals(newValue)) {
                        int oldIndexOfNewValue = listIndexOf(oldList, newValue, index);
                        if (oldIndexOfNewValue !is -1) {
                            int newIndexOfOldValue = listIndexOf(newList, oldValue, index);
                            if (newIndexOfOldValue is -1) {
                                // removing oldValue from list[index]
                                listDiffs.add(createListDiffEntry(index, false, oldValue));
                                oldList.remove(index);
                                done = false;
                            } else if (newIndexOfOldValue > oldIndexOfNewValue) {
                                // moving oldValue from list[index] to [newIndexOfOldValue] 
                                if (oldList.size() <= newIndexOfOldValue) {
                                    // The element cannot be moved to the correct index
                                    // now, however later iterations will insert elements
                                    // in front of it, eventually moving it into the
                                    // correct spot.
                                    newIndexOfOldValue = oldList.size() - 1;
                                }
                                listDiffs.add(createListDiffEntry(index, false, oldValue));
                                oldList.remove(index);
                                listDiffs.add(createListDiffEntry(newIndexOfOldValue, true, oldValue));
                                oldList.add(newIndexOfOldValue, oldValue);
                                done = false;
                            } else {
                                // move newValue from list[oldIndexOfNewValue] to [index]
                                listDiffs.add(createListDiffEntry(oldIndexOfNewValue, false, newValue));
                                oldList.remove(oldIndexOfNewValue);
                                listDiffs.add(createListDiffEntry(index, true, newValue));
                                oldList.add(index, newValue);
                            }
                        } else {
                            // add newValue at list[index]
                            oldList.add(index, newValue);
                            listDiffs.add(createListDiffEntry(index, true, newValue));
                        }
                    }
                } while (!done);
            }
            ++index;
        }
        for (int i = oldList.size(); i > index;) {
            // remove excess trailing elements not present in newList
            listDiffs.add(createListDiffEntry(--i, false, oldList.get(i)));
        }
    }

    /**
     * @param list
     * @param object
     * @param index
     * @return the index, or -1 if not found
     */
    private static int listIndexOf(List list, Object object, int index) {
        int size = list.size();
        for (int i=index; i<size;i++) {
            Object candidate = list.get(i);
            if (candidate is null ? object is null : candidate.opEquals(object)) {
                return i;
            }
        }
        return -1;
    }

    /**
     * Checks whether the two objects are <code>null</code> -- allowing for
     * <code>null</code>.
     * 
     * @param left
     *            The left object to compare; may be <code>null</code>.
     * @param right
     *            The right object to compare; may be <code>null</code>.
     * @return <code>true</code> if the two objects are equivalent;
     *         <code>false</code> otherwise.
     */
    public static final bool equals(Object left, Object right) {
        return left is null ? right is null : ((right !is null) && left
                .opEquals(right));
    }

    /**
     * @param oldSet
     * @param newSet
     * @return a set diff
     */
    public static SetDiff computeSetDiff(Set oldSet, Set newSet) {
        Set additions = new HashSet(newSet);
        additions.removeAll(oldSet);
        Set removals = new HashSet(oldSet);
        removals.removeAll(newSet);
        return createSetDiff(additions, removals);
    }

    /**
     * Computes the difference between two maps.
     * 
     * @param oldMap
     * @param newMap
     * @return a map diff representing the changes needed to turn oldMap into
     *         newMap
     */
    public static MapDiff computeMapDiff(Map oldMap, Map newMap) {
        // starts out with all keys from the new map, we will remove keys from
        // the old map as we go
        final Set addedKeys = new HashSet(newMap.keySet());
        final Set removedKeys = new HashSet();
        final Set changedKeys = new HashSet();
        final Map oldValues = new HashMap();
        final Map newValues = new HashMap();
        for (Iterator it = oldMap.entrySet().iterator(); it.hasNext();) {
            Map.Entry oldEntry = cast(Map.Entry) it.next();
            Object oldKey = oldEntry.getKey();
            if (addedKeys.remove(oldKey)) {
                // potentially changed key since it is in oldMap and newMap
                Object oldValue = oldEntry.getValue();
                Object newValue = newMap.get(oldKey);
                if (!Util.equals(oldValue, newValue)) {
                    changedKeys.add(oldKey);
                    oldValues.put(oldKey, oldValue);
                    newValues.put(oldKey, newValue);
                }
            } else {
                removedKeys.add(oldKey);
                oldValues.put(oldKey, oldEntry.getValue());
            }
        }
        for (Iterator it = addedKeys.iterator(); it.hasNext();) {
            Object newKey = it.next();
            newValues.put(newKey, newMap.get(newKey));
        }
        return new class() MapDiff {
            public Set getAddedKeys() {
                return addedKeys;
            }

            public Set getChangedKeys() {
                return changedKeys;
            }

            public Set getRemovedKeys() {
                return removedKeys;
            }

            public Object getNewValue(Object key) {
                return newValues.get(key);
            }

            public Object getOldValue(Object key) {
                return oldValues.get(key);
            }
        };
    }
    
    /**
     * @param oldValue
     * @param newValue
     * @return a value diff
     */
    public static ValueDiff createValueDiff(String oldValue,
            Object newValue) {
        return createValueDiff( stringcast(oldValue), newValue );
    }
    public static ValueDiff createValueDiff(Object oldValue,
            String newValue) {
        return createValueDiff( oldValue, stringcast(newValue) );
    }
    public static ValueDiff createValueDiff(String oldValue,
            String newValue) {
        return createValueDiff( stringcast(oldValue), stringcast(newValue) );
    }
    public static ValueDiff createValueDiff(Object oldValue,
            Object newValue) {
        return new class(oldValue, newValue) ValueDiff {
            Object oldValue_, newValue_;
            this(Object a, Object b){
                oldValue_=a;
                newValue_=b;
            }

            public Object getOldValue() {
                return oldValue_;
            }

            public Object getNewValue() {
                return newValue_;
            }
        };
    }

    /**
     * @param additions
     * @param removals
     * @return a set diff
     */
    public static SetDiff createSetDiff(Set additions, Set removals) {
        return new class() SetDiff {
            Set unmodifiableAdditions;
            Set unmodifiableRemovals;
            this(){
                unmodifiableAdditions = Collections
                    .unmodifiableSet(additions);
                unmodifiableRemovals = Collections.unmodifiableSet(removals);
            }

            public Set getAdditions() {
                return unmodifiableAdditions;
            }

            public Set getRemovals() {
                return unmodifiableRemovals;
            }
        };
    }

    /**
     * @param difference
     * @return a list diff with one differing entry
     */
    public static ListDiff createListDiff(ListDiffEntry difference) {
        return createListDiff([ difference ]);
    }

    /**
     * @param difference1
     * @param difference2
     * @return a list diff with two differing entries
     */
    public static ListDiff createListDiff(ListDiffEntry difference1,
            ListDiffEntry difference2) {
        return createListDiff([ difference1, difference2 ]);
    }

    /**
     * @param differences
     * @return a list diff with the given entries
     */
    public static ListDiff createListDiff(ListDiffEntry[] differences) {
        return new class() ListDiff {
            ListDiffEntry[] differences_;
            this(){
                differences_=differences;
            }
            public ListDiffEntry[] getDifferences() {
                return differences_;
            }
        };
    }

    /**
     * @param position
     * @param isAddition
     * @param element
     * @return a list diff entry
     */
    public static ListDiffEntry createListDiffEntry(int position,
            bool isAddition, Object element) {
        return new class() ListDiffEntry {
            int position_;
            bool isAddition_;
            Object element_;
            this(){
                position_=position;
                isAddition_=isAddition;
                element_=element;
            }

            public int getPosition() {
                return position_;
            }

            public bool isAddition() {
                return isAddition_;
            }

            public Object getElement() {
                return element_;
            }
        };
    }

    /**
     * @param addedKey
     * @param newValue
     * @return a map diff
     */
    public static MapDiff createMapDiffSingleAdd(Object addedKey,
            Object newValue) {
        return new class() MapDiff {
            Object addedKey_, newValue_;
            this(){
                addedKey_=addedKey;
                newValue_=newValue;
            }

            public Set getAddedKeys() {
                return Collections.singleton(addedKey_);
            }

            public Set getChangedKeys() {
                return Collections.EMPTY_SET;
            }

            public Object getNewValue(Object key) {
                return newValue_;
            }

            public Object getOldValue(Object key) {
                return null;
            }

            public Set getRemovedKeys() {
                return Collections.EMPTY_SET;
            }
        };
    }

    /**
     * @param existingKey
     * @param oldValue
     * @param newValue
     * @return a map diff
     */
    public static MapDiff createMapDiffSingleChange(Object existingKey,
            Object oldValue, Object newValue) {
        return new class() MapDiff {
            Object existingKey_;
            Object oldValue_;
            Object newValue_;
            this(){
                existingKey_=existingKey;
                oldValue_=oldValue;
                newValue_=newValue;
            }
            public Set getAddedKeys() {
                return Collections.EMPTY_SET;
            }

            public Set getChangedKeys() {
                return Collections.singleton(existingKey_);
            }

            public Object getNewValue(Object key) {
                return newValue_;
            }

            public Object getOldValue(Object key) {
                return oldValue_;
            }

            public Set getRemovedKeys() {
                return Collections.EMPTY_SET;
            }
        };
    }

    /**
     * @param removedKey
     * @param oldValue
     * @return a map diff
     */
    public static MapDiff createMapDiffSingleRemove(Object removedKey,
            Object oldValue) {
        return new class() MapDiff {
            Object removedKey_;
            Object oldValue_;
            this(){
                removedKey_=removedKey;
                oldValue_=oldValue;
            }

            public Set getAddedKeys() {
                return Collections.EMPTY_SET;
            }

            public Set getChangedKeys() {
                return Collections.EMPTY_SET;
            }

            public Object getNewValue(Object key) {
                return null;
            }

            public Object getOldValue(Object key) {
                return oldValue_;
            }

            public Set getRemovedKeys() {
                return Collections.singleton(removedKey_);
            }
        };
    }

    /**
     * @param copyOfOldMap
     * @return a map diff
     */
    public static MapDiff createMapDiffRemoveAll(Map copyOfOldMap) {
        return new class() MapDiff {
            Map copyOfOldMap_;
            this(){
                copyOfOldMap_=copyOfOldMap;
            }

            public Set getAddedKeys() {
                return Collections.EMPTY_SET;
            }

            public Set getChangedKeys() {
                return Collections.EMPTY_SET;
            }

            public Object getNewValue(Object key) {
                return null;
            }

            public Object getOldValue(Object key) {
                return copyOfOldMap_.get(key);
            }

            public Set getRemovedKeys() {
                return copyOfOldMap_.keySet();
            }
        };
    }

    /**
     * @param addedKeys
     * @param removedKeys
     * @param changedKeys
     * @param oldValues
     * @param newValues
     * @return a map diff
     */
    public static MapDiff createMapDiff(Set addedKeys,
            Set removedKeys, Set changedKeys, Map oldValues,
            Map newValues) {
        return new class() MapDiff {
            Set addedKeys_;
            Set removedKeys_;
            Set changedKeys_;
            Map oldValues_;
            Map newValues_;
            this(){
                addedKeys_=addedKeys;
                removedKeys_=removedKeys;
                changedKeys_=changedKeys;
                oldValues_=oldValues;
                newValues_=newValues;
            }

            public Set getAddedKeys() {
                return addedKeys_;
            }

            public Set getChangedKeys() {
                return changedKeys_;
            }

            public Object getNewValue(Object key) {
                return newValues_.get(key);
            }

            public Object getOldValue(Object key) {
                return oldValues_.get(key);
            }

            public Set getRemovedKeys() {
                return removedKeys_;
            }
        };
    }
}
