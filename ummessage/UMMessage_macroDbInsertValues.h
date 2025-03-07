//
//  UMMessage_macroDbInsertValues.h
//  ummessage
//
//  Created by Andreas Fink on 05.03.2025.
//


// Prerequisites:   i & session

#define BOOLEAN(o,len,tag,dictname,field,accessor,dbname,options) { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",field ? [session sqlEscapeString:field.stringValue] : @""]; }
#define DOUBLE(o,len,tag,dictname,field,accessor,dbname,options)  { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",field ? [session sqlEscapeString:field.stringValue] : @""]; }
#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options) { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",field ? [session sqlEscapeString:field.stringValue] : @""]; }
#define STRING(o,len,tag,dictname,field,accessor,dbname,options)  { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",field ? [session sqlEscapeString:field.stringValue] : @""]; }
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)    { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",field ? [session sqlEscapeString:field.stringValue] : @""]; }
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)    { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",field ? [session sqlEscapeString:field.stringValue] : @""]; }
#define DATA(o,len,tag,dictname,field,accessor,dbname,options)    { if(i++) { [o appendString:@","]; } [o appendFormat:@"\"%@\"",field ? [session sqlEscapeString:field.stringValue] : @""]; }
