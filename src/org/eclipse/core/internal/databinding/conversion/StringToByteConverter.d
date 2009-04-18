/*
 * Copyright cast(C) 2005 db4objects Inc.  http://www.db4o.com
 * 
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     db4objects - Initial API and implementation
 */
module org.eclipse.core.internal.databinding.conversion.StringToByteConverter;
import org.eclipse.core.internal.databinding.conversion.StringToNumberParser;

import java.lang.all;
import java.nonstandard.RuntimeTraits;

import org.eclipse.core.internal.databinding.validation.NumberFormatConverter;

import com.ibm.icu.text.NumberFormat;

/**
 * @since 1.0
 */
public class StringToByteConverter : NumberFormatConverter {  
    private String outOfRangeMessage;
    private NumberFormat numberFormat;
    private bool primitive;
    
    /**
     * @param numberFormat
     * @param toType
     */
    private this(NumberFormat numberFormat, TypeInfo toType) {
        super(typeid(StringCls), toType, numberFormat);
        primitive = isJavaPrimitive(cast(TypeInfo)toType);
        this.numberFormat = numberFormat;
    }

    /**
     * @param numberFormat
     * @param primitive
     * @return converter
     */
    public static StringToByteConverter toByte(NumberFormat numberFormat,
            bool primitive) {
        return new StringToByteConverter(numberFormat, (primitive) ? Byte.TYPE : typeid(Byte));
    }

    /**
     * @param primitive
     * @return converter
     */
    public static StringToByteConverter toByte(bool primitive) {
        return toByte(NumberFormat.getIntegerInstance(), primitive);
    }

    /* (non-Javadoc)
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
                    .createParseErrorMessage(stringcast(fromObject), result
                            .getPosition()));
        } else if (result.getNumber() is null) {
            // if an error didn't occur and the number is null then it's a boxed
            // type and null should be returned
            return null;
        }

        if (StringToNumberParser.inByteRange(result.getNumber())) {
            return new Byte(result.getNumber().byteValue());
        }
        
        synchronized (this) {
            if (outOfRangeMessage is null) {
                outOfRangeMessage = StringToNumberParser
                .createOutOfRangeMessage(new Byte(Byte.MIN_VALUE), new Byte(Byte.MAX_VALUE), numberFormat);
            }
                        
            throw new IllegalArgumentException(outOfRangeMessage);
        }
    }
}
