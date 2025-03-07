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
void addFieldDefText(UMSynchronizedSortedDictionary    *o,int len,const char *dbname,const char *options);
void addFieldDefDate(UMSynchronizedSortedDictionary    *o,int len,const char *dbname,const char *options);
void addFieldDefData(UMSynchronizedSortedDictionary    *o,int len,const char *dbname,const char *options);
