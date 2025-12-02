//
//  Config_macroProperties.h
//  umdbserver
//
//  Created by Andreas Fink on 20.03.2025.
//

#define BOOLEAN(o,len,tag,dictname,var,accessor,dbname,options)          @property(readwrite,strong,atomic) NSNumber *accessor;
#define REAL(o,len,tag,dictname,var,accessor,dbname,options)             @property(readwrite,strong,atomic) NSNumber *accessor;
#define INTEGER(o,len,tag,dictname,var,accessor,dbname,options)          @property(readwrite,strong,atomic) NSNumber *accessor;
#define STRING(o,len,tag,dictname,var,accessor,dbname,options)           @property(readwrite,strong,atomic) NSString *accessor;
#define TEXT(o,len,tag,dictname,var,accessor,dbname,options)             @property(readwrite,strong,atomic) NSString *accessor;
#define FILTERED_STRING(o,len,tag,dictname,var,accessor,dbname,options)  @property(readwrite,strong,atomic) NSString *accessor;
#define DATE(o,len,tag,dictname,var,accessor,dbname,options)             @property(readwrite,strong,atomic) NSDate *accessor;
#define DATA(o,len,tag,dictname,var,accessor,dbname,options)             @property(readwrite,strong,atomic) NSData *accessor;
#define ARRAY_COMPACT(o,len,tag,dictname,var,accessor,dbname,options)    @property(readwrite,strong,atomic) NSArray<NSString *> *accessor;
#define ARRAY_VERBOSE(o,len,tag,dictname,var,accessor,dbname,options)    @property(readwrite,strong,atomic) NSArray<NSString *> *accessor;
#define HEXDATA(o,len,tag,dictname,var,accessor,dbname,options)          @property(readwrite,strong,atomic) NSData *accessor;

