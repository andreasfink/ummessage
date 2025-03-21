//
//  ConfigMacroHelper.h
//  smpp-multipart-join
//
//  Created by Andreas Fink on 23.01.2025.
//

#import <ulib/ulib.h>

void appendConfig_BOOLEAN(NSMutableString *str,const char *name,NSNumber *value,const char *dbname,int tag,const char *options);
void appendConfig_DOUBLE(NSMutableString *str,const char *name,NSNumber *value,const char *dbname,int tag,const char *options);
void appendConfig_INTEGER(NSMutableString *str,const char *name,NSNumber *value,const char *dbname,int tag,const char *options);
void appendConfig_STRING(NSMutableString *str,const char *name,NSString *value,const char *dbname,int tag,const char *options);
void appendConfig_TEXT(NSMutableString *str,const char *name,NSString *value,const char *dbname,int tag,const char *options);
void appendConfig_HEXDATA(NSMutableString *str,const char *name,NSData *value,const char *dbname,int tag,const char *options);
void appendConfig_FILTERED_STRING(NSMutableString *str,const char *name,NSString *value,const char *dbname,int tag,const char *options);
void appendConfig_DATE(NSMutableString *str,const char *name,NSDate *value,const char *dbname,int tag,const char *options);
void appendConfig_DATA(NSMutableString *str,const char *name,NSData *value,const char *dbname,int tag,const char *options);
void appendConfig_ARRAY_VERBOSE(NSMutableString *str,const char *name,NSArray *array,const char *dbname,int tag,const char *options);
void appendConfig_ARRAY_COMPACT(NSMutableString *str,const char *name,NSArray *array,const char *dbname,int tag,const char *options);

void appendDict_BOOLEAN(UMSynchronizedSortedDictionary *dict,const char *name,NSNumber *value,const char *dbname,int tag,const char *options);
void appendDict_DOUBLE(UMSynchronizedSortedDictionary *dict,const char *name,NSNumber *value,const char *dbname,int tag,const char *options);
void appendDict_INTEGER(UMSynchronizedSortedDictionary *dict,const char *name,NSNumber *value,const char *dbname,int tag,const char *options);
void appendDict_STRING(UMSynchronizedSortedDictionary *dict,const char *name,NSString *value,const char *dbname,int tag,const char *options);
void appendDict_TEXT(UMSynchronizedSortedDictionary *dict,const char *name,NSString *value,const char *dbname,int tag,const char *options);
void appendDict_HEXDATA(UMSynchronizedSortedDictionary *dict,const char *name,NSData *value,const char *dbname,int tag,const char *options);
void appendDict_FILTERED_STRING(UMSynchronizedSortedDictionary *dict,const char *name,NSString *value,const char *dbname,int tag,const char *options);
void appendDict_DATE(UMSynchronizedSortedDictionary *dict,const char *name,NSDate *value,const char *dbname,int tag,const char *options);
void appendDict_DATA(UMSynchronizedSortedDictionary *dict,const char *name,NSData *value,const char *dbname,int tag,const char *options);
void appendDict_ARRAY_VERBOSE(UMSynchronizedSortedDictionary *dict,const char *name,NSArray *array,const char *dbname,int tag,const char *options);
void appendDict_ARRAY_COMPACT(UMSynchronizedSortedDictionary *dict,const char *name,NSArray *array,const char *dbname,int tag,const char *options);



NSNumber * setConfigFromDict_BOOLEAN(NSDictionary *o,const char *name,const char *dbname,int tag,const char *options);
NSNumber * setConfigFromDict_DOUBLE(NSDictionary *o,const char *name,const char *dbname,int tag,const char *options);
NSNumber * setConfigFromDict_INTEGER(NSDictionary *o,const char *name,const char *dbname,int tag,const char *options);
NSString * setConfigFromDict_STRING(NSDictionary *o,const char *name,const char *dbname,int tag,const char *options);
NSString * setConfigFromDict_TEXT(NSDictionary *o,const char *name,const char *dbname,int tag,const char *options);
NSData   * setConfigFromDict_HEXDATA(NSDictionary *o,const char *name,const char *dbname,int tag,const char *options);
NSString * setConfigFromDict_FILTERED_STRING(NSDictionary *o,const char *name,const char *dbname,int tag,const char *options);
NSDate   * setConfigFromDict_DATE(NSDictionary *o,const char *name,const char *dbname,int tag,const char *options);
NSData   * setConfigFromDict_DATA(NSDictionary *o,const char *name,const char *dbname,int tag,const char *options);
NSArray  * setConfigFromDict_ARRAY_COMPACT(NSDictionary *o,const char *name,const char *dbname,int tag,const char *options);
NSArray  * setConfigFromDict_ARRAY_VERBOSE(NSDictionary *o,const char *name,const char *dbname,int tag,const char *options);
