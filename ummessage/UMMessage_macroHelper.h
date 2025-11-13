//
//  UMMessage_macroHelper.h
//  ummessage
//
//  Created by Andreas Fink on 05.03.2025.
//

#import <ulib/ulib.h>

void addFieldDefBoolean(UMSynchronizedSortedDictionary *o,int len,const char *dbname,const char *options);
void addFieldDefDouble(UMSynchronizedSortedDictionary  *o,int len,const char *dbname,const char *options);
void addFieldDefInteger(UMSynchronizedSortedDictionary *o,int len,const char *dbname,const char *options);
void addFieldDefString(UMSynchronizedSortedDictionary  *o,int len,const char *dbname,const char *options);
void addFieldDefText(UMSynchronizedSortedDictionary    *o,int len,const char *dbname,const char *options); /* string stored as text field in db*/
void addFieldDefDate(UMSynchronizedSortedDictionary    *o,int len,const char *dbname,const char *options); /* date stored as string */
void addFieldDefData(UMSynchronizedSortedDictionary    *o,int len,const char *dbname,const char *options); /* bytes stored as hex text */
void addFieldDefBinary(UMSynchronizedSortedDictionary    *o,int len,const char *dbname,const char *options); /* bytes stored as blob */
NSString *fieldDefsToSql(UMSynchronizedSortedDictionary *o, NSString *dbTableName);
