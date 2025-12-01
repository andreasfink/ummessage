//
//  UMMessage_macroHelper.h
//  ummessage
//
//  Created by Andreas Fink on 05.03.2025.
//

#import <ulib/ulib.h>

void ummessage_addFieldDefBoolean(UMSynchronizedSortedDictionary *o,int len,const char *dbname,const char *options);
void ummessage_addFieldDefDouble(UMSynchronizedSortedDictionary  *o,int len,const char *dbname,const char *options);
void ummessage_addFieldDefInteger(UMSynchronizedSortedDictionary *o,int len,const char *dbname,const char *options);
void ummessage_addFieldDefString(UMSynchronizedSortedDictionary  *o,int len,const char *dbname,const char *options);
void ummessage_addFieldDefText(UMSynchronizedSortedDictionary    *o,int len,const char *dbname,const char *options); /* string stored as text field in db*/
void ummessage_addFieldDefDate(UMSynchronizedSortedDictionary    *o,int len,const char *dbname,const char *options); /* date stored as string */
void ummessage_addFieldDefData(UMSynchronizedSortedDictionary    *o,int len,const char *dbname,const char *options); /* bytes stored as hex text */
void ummessage_addFieldDefBinary(UMSynchronizedSortedDictionary    *o,int len,const char *dbname,const char *options); /* bytes stored as blob */
NSString *ummessage_fieldDefsToSql(UMSynchronizedSortedDictionary *o, NSString *dbTableName);

void ummessage_addTableDefBoolean(NSMutableString *o,int len, const char *dbname, const char *options);
void ummessage_addTableDefDouble(NSMutableString *o,int len, const char *dbname, const char *options);
void ummessage_addTableDefInteger(NSMutableString *o,int len, const char *dbname, const char *options);
void ummessage_addTableDefString(NSMutableString *o,int len, const char *dbname, const char *options);
void ummessage_addTableDefText(NSMutableString *o,int len, const char *dbname, const char *options);
void ummessage_addTableDefDate(NSMutableString *o,int len, const char *dbname, const char *options);
void ummessage_addTableDefData(NSMutableString *o,int len, const char *dbname, const char *options);
void ummessage_addTableDefArray(NSMutableString *o,int len, const char *dbname, const char *options);
