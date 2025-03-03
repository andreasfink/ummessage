//
//  Config_macroDbInsertNames.h
//  smpp-multipart-join
//
//  Created by Andreas Fink on 30.01.2025.
//

// Prerequisites:   i & session

#define STRING(o,len,tag,dictname,field,accessor,dbname,options)  if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"`%s`",dbname]; };
#define INTEGER(o,len,tag,dictname,field,accessor,dbname,options) if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"`%s`",dbname]; };
#define DATE(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"`%s`",dbname]; };
#define DATA(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"`%s`",dbname]; };
#define TEXT(o,len,tag,dictname,field,accessor,dbname,options)    if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"`%s`",dbname]; };
#define DOUBLE(o,len,tag,dictname,field,accessor,dbname,options)  if(field) { if(i++) { [o appendString:@","]; } [o appendFormat:@"`%s`",dbname]; };
