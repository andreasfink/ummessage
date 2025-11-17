//
//  UMMMessage_macroOnDuplicateKeyUpdate.h
//  ummessage
//
//  Created by Andreas Fink on 17.11.2025.
//

#define STRING(o,len,tag,dictname,field,accessor,dbname,options)  if(field) { if(i++) { [o appendString:@","]; }[o appendFormat:@"`%s`=\"%@\"",dbname,[session sqlEscapeString:field.stringValue]]; };
#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options) if(field) { if(i++) { [o appendString:@","]; }[o appendFormat:@"`%s`=\"%@\"",dbname,[session sqlEscapeString:field.stringValue]]; };
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; }[o appendFormat:@"`%s`=\"%@\"",dbname,[session sqlEscapeString:field.stringValue]]; };
#define DATA(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; }[o appendFormat:@"`%s`=\"%@\"",dbname,[session sqlEscapeString:field.stringValue]]; };
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; }[o appendFormat:@"`%s`=\"%@\"",dbname,[session sqlEscapeString:field.stringValue]]; };
#define REAL(o,len,tag,dictname,field,accessor,dbname,options)  if(field) { if(i++) { [o appendString:@","]; }[o appendFormat:@"`%s`=\"%@\"",dbname,[session sqlEscapeString:field.stringValue]]; };
