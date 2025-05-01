//
//  Config_macroVariables.h
//  umdbserver
//
//  Created by Andreas Fink on 20.03.2025.
//

#define BOOLEAN(o,len,tag,dictname,var,accessor,dbname,options)           NSNumber *var;
#define REAL(o,len,tag,dictname,var,accessor,dbname,options)            NSNumber *var;
#define INTEGER(o,len,tag,dictname,var,accessor,dbname,options)           NSNumber *var;
#define STRING(o,len,tag,dictname,var,accessor,dbname,options)            NSString *var;
#define TEXT(o,len,tag,dictname,var,accessor,dbname,options)              NSString *var;
#define FILTERED_STRING(o,len,tag,dictname,var,accessor,dbname,options)   NSString *var;
#define DATE(o,len,tag,dictname,var,accessor,dbname,options)              NSDate   *var;
#define DATA(o,len,tag,dictname,var,accessor,dbname,options)              NSData   *var;
#define ARRAY_COMPACT(o,len,tag,dictname,var,accessor,dbname,options)     NSArray<NSString *> *var;
#define ARRAY_VERBOSE(o,len,tag,dictname,var,accessor,dbname,options)     NSArray<NSString *> *var;
#define HEXDATA(o,len,tag,dictname,var,accessor,dbname,options)           NSData *var;

