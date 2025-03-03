//
//  Config_macroDbInsertValues.h
//  smpp-multipart-join
//
//  Created by Andreas Fink on 30.01.2025.
//

// Prerequisites:   i & session

#define STRING(o,len,tag,dictname,field,accessor,dbname,options)  if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",[session sqlEscapeString:field.stringValue]];};
#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options) if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",[session sqlEscapeString:field.stringValue]]; };
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",[session sqlEscapeString:field.stringValue]]; };
#define DATA(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",[session sqlEscapeString:field.stringValue]]; };
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",[session sqlEscapeString:field.stringValue]]; };
#define DOUBLE(o,len,tag,dictname,field,accessor,dbname,options)  if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",[session sqlEscapeString:field.stringValue]]; };
