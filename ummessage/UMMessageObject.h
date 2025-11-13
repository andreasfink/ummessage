//
//  UMMessage.h
//  ummessage
//
//  Created by Andreas Fink on 03.03.2025.
//  Copyright 2025 Andreas Fink, Paradieshofstrasse 101, 4054 Basel andreas@fink.org
//


#import <ulib/ulib.h>
#import <ulibasn1/ulibasn1.h>
#import <ummessage/UMMessageStatusCode.h>
#import <ummessage/UMMessageHistory.h>
#import <ummessage/UMMessageObjectFields.h>

/// An object to hold a short message for use in SMS. This can be a long (multipart), concaenated message or a individual message part.
/// Can be used in SMPP or SS7

@class UMDbSession;
@class UMMessageReport;
@class UMDbResult;
@class UMMessageUser;




@interface UMMessageObject : UMASN1Sequence
{
    /* variables */
#include <ummessage/UMMessage_macroVariables.h>
#include <ummessage/UMMessageObject.def.h>
#include <ummessage/UMMessage_macroClear.h>
    
    UMSynchronizedArray *_udhs; /* Unpacked UDHs, not stored in DB */
    UMMessageReport     *_lastReport; /* helper */
    UMMessageUser       *_user;
    BOOL                _hasBeenInserted;
    BOOL                _hasBeenQueuedForInsert;
    id                  _originalSendingObject;
    id                  _routerTransaction;
    id                  _userTransaction;
    BOOL                _finalDlrSent;
    UMHTTPRequest       *_deliveryReportAddressHttp; /* a waiting web request */
    UMMessageHistory    *_messageHistory;
}


/* properties */
#include <ummessage/UMMessage_macroProperties.h>
#include <ummessage/UMMessageObject.def.h>
#include <ummessage/UMMessage_macroClear.h>


@property(readwrite,atomic,assign)      BOOL hasBeenInserted;
@property(readwrite,atomic,assign)      BOOL hasBeenQueuedForInsert;
@property(readwrite,atomic,assign)      BOOL isDirty;
@property(readwrite,atomic,strong)      UMSynchronizedArray *udhs; /* Unpacked UDHs, not stored in DB directly */
@property(readwrite,atomic,strong)      UMMessageReport            *lastReport; /* helper */
@property(readwrite,atomic,strong)      UMMessageUser       *user;
@property(readwrite,atomic,strong)      id                  originalSendingObject;
@property(readwrite,atomic,strong)      id                  routerTransaction;
@property(readwrite,atomic,strong)      id                  userTransaction;
@property(readwrite,strong)             NSMutableDictionary *tlvs;
@property(readwrite,strong,atomic)      UMMessageHistory    *messageHistory;
@property(readwrite,atomic,atomic)      BOOL                finalDlrSent;
@property(readwrite,atomic,atomic)      UMHTTPRequest       *deliveryReportAddressHttp; /* a waiting web request */

- (UMMessageObject *)initWithNewIdAndInstance:(NSString *)instance;
+ (NSString *)uniqueMessageId;
+ (NSString *)uniqueMessageIdWithPrefix:(NSString *)pfx;
+ (NSString *)asn1Def;
+ (NSString *)sqlTableDefForTableName:(NSString *)table;
- (NSString *)insertOrUpdate:(NSString *)tableName session:(UMDbSession *)session;
- (NSString *)insert:(NSString *)tableName session:(UMDbSession *)session;
- (NSString *)update:(NSString *)tableName session:(UMDbSession *)session;
- (NSString *)updateIfDirty:(NSString *)tableName session:(UMDbSession *)session;
- (NSString *)delete:(NSString *)tableName session:(UMDbSession *)session;


- (void) expandUdh;
- (void) packUdh;

+ (UMMessageObject *)messageFromDbResult:(UMDbResult *)dbResult;

/* glue code for legacy */
- (long)uid;
- (void)setUid:(long)uid;
- (long)gid;
- (void)setGid:(long)gid;


- (UMMessageStatusCode)internalStateCode;
- (void)setInternalStateCode:(UMMessageStatusCode)state;
- (UMMessageStatusCode)smppStateCode;
- (void)setSmppStateCode:(UMMessageStatusCode)state;
- (UMMessageStatusCode)deliveryReportStateCode;
- (void)setDeliveryReportStateCode:(UMMessageStatusCode)state;


- (void)enableHistoryLog;


- (void) setMessageStatus:(UMMessageStatusCode)mstat;
- (UMMessageStatusCode) messageStatus;

- (void)logToMessage:(NSString *)text;
- (void)logEvent:(NSString *)text inState:(NSString *)state;
- (void)logStateChange:(NSString *)oldstate newState:(NSString *)newState;
- (void)saveOldValues;

@end
