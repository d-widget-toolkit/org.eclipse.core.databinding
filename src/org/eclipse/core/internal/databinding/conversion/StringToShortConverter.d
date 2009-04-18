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

module org.eclipse.core.internal.databinding.conversion.StringToShortConverter;
import org.eclipse.core.internal.databinding.conversion.StringToNumberParser;

import java.lang.all;
import java.nonstandard.RuntimeTraits;

import org.eclipse.core.internal.databinding.validation.NumberFormatConverter;

import com.ibm.icu.text.NumberFormat;

/**
 * @since 1.0
 */
public class StringToShortConverter : NumberFormatConverter {
    private final NumberFormat numberFormat;
    private final bool primitive;
    
    private String outOfRangeMessage;

    /**
     * Constructs a new instance.
     */
    private this(NumberFormat numberFormat, TypeInfo toType) {
        super(typeid(String), toType, numberFormat);
        this.numberFormat = numberFormat;
        primitive = isJavaPrimitive(toType);
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.eclipse.core.databinding.conversion.IConverter#convert(java.lang.Object)
     */
    public Object convert(Object fromObject) {
        StringToNumberParser.ParseResult result = StringToNumberParser.parse(fromObject,
                numberFormat, primitive);

        if (result.getPosition() !is null) {
            // this shouldn't happen in the pipeline as validation should catch
            // it but anyone can call convert so we should return a properly
            // formatted message in an exception
            throw new IllegalArgumentException(StringToNumberParser
                    .createParseErrorMessage(stringcast( fromObject), result
                            .getPosition()));
        } else if (result.getNumber() is null) {
            // if an error didn't occur and the number is null then it's a boxed
            // type and null should be returned
            return null;
        }

        if (StringToNumberParser.inShortRange(result.getNumber())) {
            return new Short(result.getNumber().shortValue());
        }
        
        synchronized (this) {
            if (outOfRangeMessage is null) {
                outOfRangeMessage = StringToNumberParser
                .createOutOfRangeMessage(new Short(Short.MIN_VALUE), new Short(Short.MAX_VALUE), numberFormat);
            }
                        
            throw new IllegalArgumentException(outOfRangeMessage);
        }
    }

    /**
     * @param primitive
     *            <code>true</code> if the convert to type is a short
     * @return to Short converter for the default locale
     */
    public static StringToShortConverter toShort(bool primitive) {
        return toShort(NumberFormat.getIntegerInstance(), primitive);
    }

    /**
     * @param numberFormat
     * @param primitive
     * @return to Short converter with the provided numberFormat
     */
    public static StringToShortConverter toShort(NumberFormat numberFormat,
            bool primitive) {
        return new StringToShortConverter(numberFormat,
                (primitive) ? Short.TYPE : typeid(Short));
    }
}
