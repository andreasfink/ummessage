//
//  UMMessage_macroHelper.h
//  ummessage
//
//  Created by Andreas Fink on 05.03.2025.
//

#import <ulib/ulib.h>

void addFieldDefBoolean(id o,int len,const char *dbname,const char *options);
void addFieldDefDouble(id o,int len,const char *dbname,const char *options);
void addFieldDefInteger(id o,int len,const char *dbname,const char *options);
void addFieldDefString(id o,int len,const char *dbname,const char *options);
void addFieldDefText(id o,int len,const char *dbname,const char *options);
void addFieldDefDate(id o,int len,const char *dbname,const char *options);
void addFieldDefData(id o,int len,const char *dbname,const char *options);
