//
//  UMMessage_dbInsertNameMacro.h
//  ummessage
//
//  Created by Andreas Fink on 17.11.2025.
//

#define STRING(o,len,tag,dictname,field,accessor,dbname,options)  if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"`%s`",dbname]; };
#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options) if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"`%s`",dbname]; };
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"`%s`",dbname]; };
#define DATA(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"`%s`",dbname]; };
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"`%s`",dbname]; };
#define REAL(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"`%s`",dbname]; };
