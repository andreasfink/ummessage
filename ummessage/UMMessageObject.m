//
//  UMMessage.m
//  ummessage
//
//  Created by Andreas Fink on 03.03.2025.
//  Copyright 2025 Andreas Fink, Paradieshofstrasse 101, 4054 Basel andreas@fink.org
//

#import "UMMessageObject.h"
#import <ulib/ulib.h>
#import <ummessage/UMMessageObjectFields.h>
#import <ummessage/UMMessageUdh.h>
#import <ummessage/UMMessageUdhConcatenated.h>
#import <ummessage/UMMessageUdhConcatenated16BitRef.h>
#import "UMMessage_macroHelper.h"

#define     MAXADDRLEN      18

static      struct tm    last_msgid_time_trec;
static      int          last_msgid_serial = 0;
static      UMMutex      *g_messageIdLock = NULL;

@implementation UMMessageObject

- (UMMessageObject *)init
{
    self = [super init];
    if(self)
    {
#include <ummessage/UMMessage_macroInit.h>
#include <ummessage/UMMessageObject.def.h>
#include <ummessage/UMMessage_macroClear.h>
    }
    return self;
}


- (UMMessageObject *)initWithNewIdAndInstance:(NSString *)instance
{
    self = [self init];
    if(self)
    {
        _instance.stringValue = instance;
        _messageId.stringValue = [UMMessageObject uniqueMessageIdWithPrefix:@""];
        _messageHistory = [[UMMessageHistory alloc]init];
    }
    return self;
}

+ (NSString *)uniqueMessageId
{
    return [UMMessageObject uniqueMessageIdWithPrefix:@""];
}

+ (NSString *)uniqueMessageIdWithPrefix:(NSString *)prefix
{
    int           this_msgid_serial;
    time_t        this_msgid_time_t;
    struct tm     this_msgid_time_trec;
    
    if(g_messageIdLock==NULL)
    {
        g_messageIdLock = [[UMMutex alloc]initWithName:@"messageIdLock"];
    }
    ummutex_lock(g_messageIdLock);
    time(&this_msgid_time_t);
    gmtime_r(&this_msgid_time_t, &this_msgid_time_trec);
    
    this_msgid_time_trec.tm_mon++;
    if(      (this_msgid_time_trec.tm_year  == last_msgid_time_trec.tm_year)
       &&    (this_msgid_time_trec.tm_mon   == last_msgid_time_trec.tm_mon)
       &&    (this_msgid_time_trec.tm_mday  == last_msgid_time_trec.tm_mday)
       &&    (this_msgid_time_trec.tm_hour  == last_msgid_time_trec.tm_hour)
       &&    (this_msgid_time_trec.tm_min   == last_msgid_time_trec.tm_min)
       &&    (this_msgid_time_trec.tm_sec   == last_msgid_time_trec.tm_sec))
    {
        last_msgid_serial = last_msgid_serial + 1;
        if(last_msgid_serial > 9990)
        {
            usleep(1100000);
        }
        this_msgid_serial = last_msgid_serial;
    }
    else
    {
        this_msgid_serial = last_msgid_serial = 1;
    }
    NSString *s = [NSString stringWithFormat:@"%@%04d%02d%02d%02d%02d%02d%04d",
                   prefix,
                   this_msgid_time_trec.tm_year+1900 - 2000,
                   this_msgid_time_trec.tm_mon,
                   this_msgid_time_trec.tm_mday,
                   this_msgid_time_trec.tm_hour,
                   this_msgid_time_trec.tm_min,
                   this_msgid_time_trec.tm_sec,
                   this_msgid_serial];
    last_msgid_time_trec    = this_msgid_time_trec;
    last_msgid_serial       = this_msgid_serial;
    ummutex_unlock(g_messageIdLock);
    return s;
}



+(NSString *)sqlTableDefForTableName:(NSString *)tableName
{
    UMSynchronizedSortedDictionary *o = [[UMSynchronizedSortedDictionary alloc]init];
    
#include "UMMessage_macroDbTableDef.h"
#include <ummessage/UMMessageObject.def.h>
#include <ummessage/UMMessage_macroClear.h>
    return ummessage_fieldDefsToSql(o,tableName);
}

+(NSArray<NSString *>*)dbFieldNames
{
    NSMutableArray *o = [[NSMutableArray alloc]init];
#include "UMMessage_macroDbFieldNames.h"
#include <ummessage/UMMessageObject.def.h>
#include <ummessage/UMMessage_macroClear.h>
    return o;
}

- (NSString *)insert:(NSString *)tableName session:(UMDbSession *)session
{
    NSMutableString *o = [[NSMutableString alloc]init];
    [o appendFormat:@"INSERT INTO `%@` (",tableName];
    int i=0;
#include <ummessage/UMMessage_macroDbInsertName.h>
#include <ummessage/UMMessageObject.def.h>
#include <ummessage/UMMessage_macroClear.h>
#include <ummessage/UMMessage_macroClear.h>
    
    
    [o appendString:@") VALUES("];
    i=0;
#include <ummessage/UMMessage_macroDbInsertValues.h>
#include <ummessage/UMMessageObject.def.h>
#include <ummessage/UMMessage_macroClear.h>
    
    [o appendString:@")"];
    return o;
}

- (NSString *)update:(NSString *)tableName session:(UMDbSession *)session
{
    NSMutableString *o = [[NSMutableString alloc]init];
    [o appendFormat:@"UPDATE `%@` SET ",tableName];
    int i=0;
#include <ummessage/UMMessage_macroDbUpdate.h>
#include <ummessage/UMMessageObject.def.h>
#include <ummessage/UMMessage_macroClear.h>
    [o appendFormat:@"WHERE archive_id=`%@` ",[session sqlEscapeString:_archiveId.stringValue]];
    return o;
}

- (NSString *)updateIfDirty:(NSString *)tableName session:(UMDbSession *)session
{
    NSMutableString *o = [[NSMutableString alloc]init];
    [o appendFormat:@"UPDATE `%@` SET ",tableName];
    int i=0;
#include <ummessage/UMMessage_macroUpdateIfDirty.h>
#include <ummessage/UMMessageObject.def.h>
#include <ummessage/UMMessage_macroClear.h>
    [o appendFormat:@"WHERE archive_id=`%@` ",[session sqlEscapeString:_archiveId.stringValue]];
    return o;
}


- (NSString *)delete:(NSString *)tableName session:(UMDbSession *)session
{
    return [NSString stringWithFormat:@"DELETE FROM `%@` WHERE archive_id=`%@` ",tableName,[session sqlEscapeString:_archiveId.stringValue]];
}


- (NSString *)insertOrUpdate:(NSString *)tableName session:(UMDbSession *)session
{
    NSMutableString *o = [[NSMutableString alloc]init];
    [o appendFormat:@"INSERT INTO `%@` (",tableName];
    int i=0;
#include <ummessage/UMMessage_macroInsertOrUpdateNames.h>
#include <ummessage/UMMessageObject.def.h>
#include <ummessage/UMMessage_macroClear.h>
    
    
    [o appendString:@") VALUES("];
    i=0;
#include <ummessage/UMMessage_macroInsertOrUpdateValues.h>
#include <ummessage/UMMessageObject.def.h>
#include <ummessage/UMMessage_macroClear.h>
    
    
    [o appendString:@") ON DUPLICATE KEY UPDATE "];
    i=0;
#include <ummessage/UMMessage_macroOnDuplicateKeyUpdate.h>
#include <ummessage/UMMessageObject.def.h>
#include <ummessage/UMMessage_macroClear.h>
    return o;
}


+ (NSString *)asn1Def
{
    NSMutableString *o = [[NSMutableString alloc]init];
    [o appendFormat:@"UMMessageObject ::= SEQUENCE\n{\n"];
#include <ummessage/UMMessage_macroAsn1Def.h>
#include <ummessage/UMMessageObject.def.h>
#include <ummessage/UMMessage_macroClear.h>
    
    /* remove the last , before the \n */
    NSInteger n = [o length];
    o = [[o substringWithRange:NSMakeRange(0,n-2)] mutableCopy];
    [o appendString:@"\n}\n"];
    return o;
}



+ (UMMessageObject *)messageFromDbResult:(UMDbResult *)dbResult
{
    UMMessageObject *o = [[UMMessageObject alloc]init];
    [o loadFromDbResult:dbResult];
    return o;
}

- (void)loadFromDbResult:(UMDbResult *)dbResult
{
    if(dbResult==NULL)
    {
        return;
    }
    if(dbResult.resultArray.count < 1)
    {
        return;
    }
    NSArray *values = dbResult.resultArray[0];
    for(NSInteger i=0;i<dbResult.columNames.count;i++)
    {
        id field1 = values[i];
        if([field1 isKindOfClass:[NSNull class]])
        {
            continue;
        }
        if([field1 isKindOfClass:[NSString class]])
        {
            NSString *o = (NSString *)field1;
            NSString *fieldName = dbResult.columNames[i];
#include <ummessage/UMMessage_macroLoadFromDbString.h>
#include <ummessage/UMMessageObject.def.h>
#include <ummessage/UMMessage_macroClear.h>
            continue;
        }
#if 0 /* we have no Binary here*/
        if([field1 isKindOfClass:[NSData class]])
        {
            NSData *o = (NSData *)field1;
#include <ummessage/UMMessage_macroLoadFromDbBinary.h>
#include <ummessage/UMMessageObject.def.h>
#include <ummessage/UMMessage_macroClear.h>
            continue;
        }
#endif
    }
    return;
}

- (NSString *)description
{
    return [[self objectValue]jsonString];
}

- (UMSynchronizedSortedDictionary *) objectValue
{
    UMSynchronizedSortedDictionary *o = [[UMSynchronizedSortedDictionary alloc]init];
#include <ummessage/UMMessage_macroObjectValue.h>
#include <ummessage/UMMessageObject.def.h>
#include <ummessage/UMMessage_macroClear.h>
    return o;
}

- (void) processBeforeEncode
{
    [super processBeforeEncode];
#include <ummessage/UMMessage_macroProcessBeforeEncode.h>
#include <ummessage/UMMessageObject.def.h>
#include <ummessage/UMMessage_macroClear.h>
}


- (UMMessageObject *) processAfterDecodeWithContext:(id)context
{
    [super processAfterDecodeWithContext:context];
    int pos = 0;
    UMASN1Object *o = [self getObjectAtPosition:pos++];
    while(o)
    {
        if(o.asn1_tag.tagClass==UMASN1Class_ContextSpecific)
        {
            switch(o.asn1_tag.tagNumber)
            {
#include <ummessage/UMMessage_macroProcessAfterDecodeWithContext.h>
#include <ummessage/UMMessageObject.def.h>
#include <ummessage/UMMessage_macroClear.h>
                    break;
            }
        }
        o = [self getObjectAtPosition:pos++];
    }
    return self;
}

- (BOOL)isDirty
{
#include <ummessage/UMMessage_macroIsDirty.h>
#include <ummessage/UMMessageObject.def.h>
#include <ummessage/UMMessage_macroClear.h>
    return NO;
}
- (void)setIsDirty:(BOOL) dirt
{
    BOOL o = dirt;
#include <ummessage/UMMessage_macroSetIsDirty.h>
#include <ummessage/UMMessageObject.def.h>
#include <ummessage/UMMessage_macroClear.h>
}

- (void)clearDirty
{
#include <ummessage/UMMessage_macroClearDirty.h>
#include <ummessage/UMMessageObject.def.h>
#include <ummessage/UMMessage_macroClear.h>
}

- (void) expandUdh
{
    if(_pduUdh==NULL)
    {
        return;
    }
    /* position 0 is the length of the UDH data. */
    int pos = 1;
    _udhs = [[UMSynchronizedArray alloc]init];
    NSData *d = _pduUdh.currentValue;
    UMMessageUdh *u = [[UMMessageUdh alloc] initWithData:d atPosition:&pos];
    while(u)
    {
        if(u.iei==UdhIEI_concatenated)
        {
            u = [[UMMessageUdhConcatenated alloc]initWithUdh:u];
        }
        else if(u.iei==UdhIEI_concatenated16bitRef)
        {
            u = [[UMMessageUdhConcatenated16BitRef alloc]initWithUdh:u];
        }
        [_udhs addObject:u];
        u = [[UMMessageUdh alloc] initWithData:d atPosition:&pos];
    }
}

- (void) packUdh
{
    NSMutableData *d = [[NSMutableData alloc]init];
    
    for(UMMessageUdh *u in _udhs)
    {
        [d appendData:u.encode];
    }
    if(d.length == 0)
    {
        _pduUdh=NULL;
        [self setUdhIndicator:NO];
    }
    else
    {
        NSMutableData *udh = [[NSMutableData alloc]init];
        [udh appendByte:d.length];
        [udh appendData:d];
        _pduUdh = UMDIRTY_DATA(udh);
        [self setUdhIndicator:YES];
    }
}

- (long)uid
{
    if(_userName)
    {
        return atol(_userName.stringValue.UTF8String);
    }
    return 0;
}

- (void)setUid:(long)uid
{
    NSString *s = [NSString stringWithFormat:@"%ld",uid];
    _userName = UMDIRTY_STRING(s);
}

- (long)gid
{
    if(_groupName)
    {
        return atol(_groupName.stringValue.UTF8String);
    }
    return 0L;
}

- (void)setGid:(long)gid
{
    NSString *s = [NSString stringWithFormat:@"%ld",gid];
    _groupName = UMDIRTY_STRING(s);
}


- (UMMessageStatusCode)internalStateCode
{
    return messageStateFromString(_internalState.stringValue);
}

- (void)setInternalStateCode:(UMMessageStatusCode)state
{
    _internalState = [[UMDirtyString alloc]initWithString:stringFromMessageState(state)];
}


- (UMMessageStatusCode)smppStateCode
{
    return messageStateFromString(_smppState.stringValue);
}

- (void)setSmppStateCode:(UMMessageStatusCode)state
{
    _smppState = [[UMDirtyString alloc]initWithString:stringFromMessageState(state)];
}

- (UMMessageStatusCode)deliveryReportStateCode
{
    return messageStateFromString(self.deliveryReportState.stringValue);
}

- (void)setDeliveryReportStateCode:(UMMessageStatusCode)state
{
    _deliveryReportState = [[UMDirtyString alloc]initWithString:stringFromMessageState(state)];
}


- (void)enableHistoryLog
{
    _messageHistory = [[UMMessageHistory alloc]init];
}

- (void) setMessageStatus:(UMMessageStatusCode)mstat
{
    self.internalStateCode = mstat;
}

- (UMMessageStatusCode) messageStatus
{
    return self.internalStateCode;
}

- (void)logToMessage:(NSString *)text
{
    NSDate *now = [NSDate date];
    NSTimeInterval delay = [now timeIntervalSinceDate:_created.dateValue];
    [_messageHistory addEntryWithArchiveId:_archiveId.stringValue
                                  instance:_instance.stringValue
                                 messageId:_messageId.stringValue
                                    msisdn:_toNumber.stringValue
                                        ts:[NSDate date]
                                     delay:delay
                                      text:[text printable]];
}

- (void)logEvent:(NSString *)event inState:(NSString *)state
{
    NSString *s = [NSString stringWithFormat:@"%@: %@",state,event];
    [self logToMessage:s];
}

- (void)logStateChange:(NSString *)oldstate newState:(NSString *)newState
{
    NSString *s = [NSString stringWithFormat:@"%@ -> %@",oldstate,newState];
    [self logToMessage:s];
}

- (void)saveOldValues
{
    
}

- (UMMessageObject *)copyWithZone:(NSZone *)zone
{
    UMMessageObject *o = [[UMMessageObject alloc]init];
    #include "UMMessage_macroCopy.h"
    #include <ummessage/UMMessageObject.def.h>
    #include <ummessage/UMMessage_macroClear.h>
    
    o->_user          = _user;
    o->_udhs          = [_udhs copy];
    o->_lastReport    = _lastReport;
    o->_hasBeenInserted = NO;
    o->_hasBeenQueuedForInsert = NO;
    o->_originalSendingObject = _originalSendingObject;
    o->_routerTransaction = _routerTransaction;
    o->_userTransaction = _userTransaction;
    o->_finalDlrSent = NO;
    o->_deliveryReportAddressHttp = _deliveryReportAddressHttp;
    o->_messageHistory = [[UMMessageHistory alloc]init];
    return o;
}

/* glue code */
- (BOOL)udhIndicator
{
    NSNumber *n = _pduUdhIndicator.currentValue;
    return (n.intValue ? YES : NO);
}
- (void)setUdhIndicator:(BOOL)val
{
    _pduUdhIndicator = UMDIRTY_INTEGER( val ? 1 : 0);
}

- (BOOL)replyPathIndicator
{
    NSNumber *n = _pduReplyPathIndicator.currentValue;
    return (n.intValue ? YES : NO);
}
- (void)setReplyPathIndicator:(BOOL)val
{
    _pduReplyPathIndicator = UMDIRTY_INTEGER( val ? 1 : 0);
}

@end

