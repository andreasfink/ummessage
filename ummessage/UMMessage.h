//
//  UMMessage.h
//  ummessage
//
//  Created by Andreas Fink on 03.03.2025.
//  Copyright 2025 Andreas Fink, Paradieshofstrasse 101, 4054 Basel andreas@fink.org
//


#import <Foundation/Foundation.h>
#import <ulib/ulib.h>
#import <ulibdb/ulibdb.h>
#import <ulibasn1/ulibasn1.h>

@interface UMMessage : UMASN1Sequence
{
    
#include "Config_macroVariables.h"
#include "UMMessage.def.h"
#include "Config_macroClear.h"

	time_t			lastUsed;
	time_t			lastDbUpdated;
	time_t			delayedUpdateTime;
	time_t			cacheExpirationTime;
    time_t          createdTime;
    time_t          timer1time;
    time_t          timer2time;
    time_t          timer3time;
    time_t          timer4time;
    time_t          timer5time;
    long long       startTime;
    time_t          timeout;

    /* timer1 is started when SRI-SM is sent */
    /* timer2 is started when Forward-SM is sent */
    /* timer3 is started after SRISM is received before SRI-SM2 is sent */
    /* timer4 is started when SRI-SM2 is sent */
    /* timer5 is started when waiting for retry */
    /* timer2b is started when Forward-SM is sent and no ack is expected */
    /* values are copied from sms layer during message state new */
    
    long timer1min;
    long timer2min;
    long timer2bmin;
    long timer3min;
    long timer4min;
    long timer5min;
    
    long timer1max;
    long timer2max;
    long timer2bmax;
    long timer3max;
    long timer4max;
    long timer5max;
    int _failedSRISM;
    int _failedFSM;

	NSString                *cacheExpiryKey;
	NSString                *dbExpiryKey;
    UMMessageState          *messageState;
    UMHistoryLog            *_messageHistory;
	id				smsLayer;
	SubmissionStatisticStatus   submitStatStatus;
    int             traceLevel;
    UMTraceFile    *traceFile;
    BOOL            hasBeenBilled;
    BOOL            _hasBeenInserted;
    BOOL            _hasBeenUpdated;
    BOOL            _hasBeenQueuedForInsert;
    BOOL            _hasBeenQueuedForUpdate;
    BOOL            _historyHasBeenInserted;
    BOOL            _finalDlrSent;
    
    id  _originalSendingObject;
#ifdef DEALLOC_TRACE
    char            btbuffer[10240];
#endif
	/*--------------------*/
	
    NSString        *triggerSet;
    NSDictionary    *triggers;
    NSString        *_dlrText;
	NSInteger	archiveStatus;
	NSString	*instanceName;
	NSString	*messageId;
	NSString	*userId;
	NSString	*groupId;
	DeliveryMethodType	deliveryMethodType;
	NSInteger	submissionType;
	NSString	*from;
    NSString    *receivedFromIp;
    NSString    *submissionIp;
	NSString	*to;
	NSString	*deliveryReportMsc;
	NSString	*deliveryReportImsi;
	NSString	*fromMsc;
	NSString	*fromImsi;
	NSString	*toMsc;
	NSString	*toImsi;
	NSString	*smsc;
	NSString	*smsc2;
	NSString	*smsc3;
	NSString	*smsc4;
    NSString	*hlr;
    NSString	*hlrOverride;
	NSString	*_created;
	NSString	*scts;
	NSInteger	scts_tz;
	NSInteger	qpriority;
	NSInteger	upriority;
	NSInteger	btype;
    int         _messageStateCode;
	NSInteger	messageStatus;
	NSInteger	messageError1;
	NSInteger	messageError2;
    NSString	*messageDelivered;
	NSString	*messageFailed;
    NSString	*messageAttempted;
    NSString    *_messageExpiry;
    NSString    *_deferredString;
	NSInteger	messageExpiryTz;
	NSString	*_messageNextAttempt;
	NSInteger	messageAttempts;
	NSInteger	_messageMaxAttempts;
	NSInteger	messageWaitingSet;
	NSInteger	sriAttempts;
	NSNumber	*_deliveryReportMask;
	NSString	*deliveryReportAddress;
    UMHTTPRequest	*deliveryReportAddressHttp; /* a waiting web request */
	NSInteger	deliveryReportStatus;
	NSInteger	deliveryReportError1;
	NSInteger	deliveryReportError2;
	NSString	*deliveryReportDelivered;
	NSString	*deliveryReportFailed;
	NSString	*deliveryReportAttempted;
	NSString	*deliveryReportExpiry;
	NSString	*deliveryReportNextAttempt;
	NSInteger	deliveryReportAttempts;
	NSInteger	deliveryReportMaxAttempts;
	NSInteger	deliveryReportWaitingSet;
    NSInteger   _msuCountSriSMTx;
    NSInteger   _msuCountSriSMRx;
    NSInteger   _msuCountSriSMHTx;
    NSInteger   _msuCountSriSMHRx;
    NSInteger   _msuCountSriSMCRx;
    NSInteger   _msuCountFsmTx;
    NSInteger   _msuCountFsmRx;
    NSInteger   _msuCountTcapHandshakeTx;
    NSInteger   _msuCountTcapHandshakeRx;
	NSInteger	testFlag;
	NSInteger	phoneRef;
	NSInteger	udhIndicator;
	NSString	*toCountry;
	NSString	*toOperatorCode;
	NSString	*toOperatorName;
	NSInteger	messagePriority;
	NSInteger	replyPath;
	NSInteger	pid;
	NSInteger	compress;
	NSInteger	dcs;
	NSInteger	mwi_pdu;
	NSData		*udh;
	NSData		*content;
	NSInteger	_messageClass;
	NSInteger	coding;
	NSString	*opc;
	NSString	*dpc;
	NSString	*opc2;
	NSString	*dpc2;
	NSInteger	tcapType;
	NSString	*_extensionData;
    NSDictionary *_extensionOptions;
	NSInteger	purgeFlag;
	NSString	*alertingAddress;
	NSString	*fromCountry;
	NSString	*fromOperatorCode;
	NSString	*fromOperatorName;
	NSString	*routeId;
	NSString	*subrouteId;
	NSString	*routedOnPrefix;
	NSInteger	autoRouted;
	NSInteger	_userFlags;
    NSInteger   retryPatternTable;
	NSString	*sccpSource;
    NSString    *interworkingTapCode;
    NSString	*_costTable;
    NSString	*destinationQuotaTableName;
    //NSString    *userMessageReference;
    
    double	     oldMsuCostTx;
    double	     oldMsuCostRx;
    double	     oldSmsCost;
    double	     oldInterworkingCost;
    double	     oldChargePrice1;
    double	     oldChargePrice2;

    double	     msuCostTx;
    double	     msuCostRx;
    double	     smsCost;
    double	     interworkingCost;
//  double	     totalCost;
    NSString	*_chargeTable1;
    double	     _chargePrice1;
//double profit1  // virtual variable
    NSString	*_chargeTable2;
    double	     _chargePrice2;
    //double profit2  // virtual variable
    int         submissionStatisticStatus;
//    struct sockaddr *originatingAddress;
//    socklen_t       originatingAddressLen;
    UMSMSEnvironment    *env;
    NSInteger   tt_sri;
    NSInteger   tt_fsm;
    NSString *_comment;
    NSString *_vas_esme;
    NSString *_vas_ip;

    BOOL    _isMultipart;
    int     _multipartCurrent;
    int     _multipartMax;
    int     _multipartRef;

    int _language_shift_table_number;
    int _language_lock_table_number;

@protected
	BOOL	newRecord;
	BOOL	finalStatusReached;
	BOOL	dirty;
	BOOL	dirtyTo;
	BOOL	dirtyFrom;
    BOOL    dirtyArchiveStatus;
    BOOL    dirtyPurgeFlag;
	BOOL	dirtyDoneFlag;
	BOOL	dirtyMessageStatus;
	BOOL	dirtyMessageAttempted;
	BOOL	dirtyMessageDelivered;
	BOOL	dirtyMessageFailed;
	BOOL	dirtyMessageError1;
	BOOL	dirtyMessageError2;
	BOOL	dirtyMessageWaitingSet;
	BOOL	dirtyToImsi;
	BOOL	dirtyFromImsi;
    BOOL    dirtyFromOperatorName;
    BOOL    dirtyFromOperatorCode;
    BOOL    dirtyToOperatorName;
    BOOL    dirtyToOperatorCode;
	BOOL	dirtyToMsc;
	BOOL	dirtyFromMsc;
	BOOL	dirtyHlr;
	BOOL	dirtySmsc;
	BOOL	dirtySmsc2;
	BOOL	dirtySmsc3;
	BOOL	dirtySmsc4;
	BOOL	dirtyScts;
    BOOL    dirtySctsTz;
	BOOL	dirtyDeliveryReportStatus;
	BOOL	dirtyDeliveryReportAttempted;
	BOOL	dirtyDeliveryReportDelivered;
	BOOL	dirtyDeliveryReportFailed;
	BOOL	dirtyDeliveryReportError1;
	BOOL	dirtyDeliveryReportError2;
	BOOL	dirtyDeliveryReportWaitingSet;
	BOOL	dirtyMessageAttempts;
	BOOL	dirtyDeliveryReportAttempts;
	BOOL	dirtyDeliveryReportImsi;
	BOOL	dirtyDeliveryReportMsc;
    BOOL    dirtyMsuCountSriSMTx;
    BOOL    dirtyMsuCountSriSMRx;
    BOOL    dirtyMsuCountSriSMHTx;
    BOOL    dirtyMsuCountSriSMHRx;
    BOOL    dirtyMsuCountSriSMCRx;
    BOOL    dirtyMsuCountFsmTx;
    BOOL    dirtyMsuCountFsmRx;
    BOOL    dirtyMsuCountTcapHandshakeTx;
    BOOL    dirtyMsuCountTcapHandshakeRx;
    BOOL    dirtyTT;
    BOOL    dirtyCosts;
    BOOL    dirtyDlrText;
    BOOL    dirtyComment;
    BOOL    _dirtyVAS_ESME;
    BOOL    _dirtyVAS_IP;
    BOOL    _dirtyDeferred;
    BOOL    _dirtyExtensionData;
    BOOL    _dirtyUserFlags;
    BOOL    _dirtyExpiryTime;
    BOOL    _dirtyMessageNextAttempt;

    NSDate *submitAckTime;
    NSString *providerReference;
    MMSMSMoAuthTransaction *_moAuthTransaction;
    
    NSArray     <NSString *>*   _mscs;
    NSInteger   _msc_index;
}

@property (readwrite,assign)    BOOL            hasBeenInserted;
@property (readwrite,assign)    BOOL            hasBeenQueuedForInsert;
@property (readwrite,assign)    BOOL            hasBeenUpdated;
@property (readwrite,assign)    BOOL            hasBeenQueuedForUpdate;
@property (readwrite,assign)    BOOL            finalDlrSent;
@property (readwrite,assign)    long long       startTime;
@property (readwrite,strong)    NSString        *dlrText;
@property (readwrite,assign) 	time_t			cacheExpirationTime;
@property (readwrite,strong)    UMSMSEnvironment    *env;
@property (readwrite,assign)    BOOL    historyHasBeenInserted;
@property (readwrite,assign)    time_t  timer1time;
@property (readwrite,assign)    time_t  timer2time;
@property (readwrite,assign)    time_t  timer3time;
@property (readwrite,assign)    time_t  timer4time;
@property (readwrite,assign)    time_t  timer5time;
@property (readwrite,assign)    time_t  timeout;

@property (readwrite,assign)    long timer1min;
@property (readwrite,assign)    long timer2min;
@property (readwrite,assign)    long timer2bmin;
@property (readwrite,assign)    long timer3min;
@property (readwrite,assign)    long timer4min;
@property (readwrite,assign)    long timer5min;

@property (readwrite,assign)    long timer1max;
@property (readwrite,assign)    long timer2max;
@property (readwrite,assign)    long timer2bmax;
@property (readwrite,assign)    long timer3max;
@property (readwrite,assign)    long timer4max;
@property (readwrite,assign)    long timer5max;
@property (readwrite,atomic)    int failedSRISM;
@property (readwrite,atomic)    int failedFSM;

@property (readwrite,assign)    SubmissionStatisticStatus   submitStatStatus;
@property (readwrite,strong)	NSString	*cacheExpiryKey;
@property (readwrite,strong)	NSString	*dbExpiryKey;
@property (readwrite,strong)	UMMessageState *messageState;
@property (readonly,strong)     UMHistoryLog   *messageHistory;
//@property (readwrite,retain)	UMStateMachine	*stateMachine;
//@property (readwrite,unsafe_unretained)	id          smsLayer;
@property (readwrite,assign)    time_t		delayedUpdateTime;
@property (readwrite,assign)    BOOL        hasBeenBilled;
@property (readwrite,assign)    int         traceLevel;
@property (readwrite,strong)    UMTraceFile *traceFile;

@property (readwrite,assign)	NSInteger	archiveStatus;
@property (readwrite,strong)	NSString	*instanceName;
@property (readwrite,strong)	NSString	*messageId;
@property (readwrite,strong)	NSString	*userId;
@property (readwrite,strong)	NSString	*groupId;
@property (readwrite,assign)	DeliveryMethodType	deliveryMethodType;
@property (readwrite,assign)	NSInteger	submissionType;
@property (readwrite,strong)	NSString	*from;
@property (readwrite,strong)    NSString    *receivedFromIp;
@property (readwrite,strong)    NSString    *submissionIp;
@property (readwrite,strong)	NSString	*to;
@property (readwrite,strong)	NSString	*deliveryReportMsc;
@property (readwrite,strong)	NSString	*deliveryReportImsi;
@property (readwrite,strong)	NSString	*fromMsc;
@property (readwrite,strong)	NSString	*fromImsi;
@property (readwrite,strong)	NSString	*toMsc;
@property (readwrite,strong)	NSString	*toImsi;
@property (readwrite,strong)	NSString	*smsc;
@property (readwrite,strong)	NSString	*smsc2;
@property (readwrite,strong)	NSString	*smsc3;
@property (readwrite,strong)	NSString	*smsc4;
@property (readwrite,strong)	NSString	*hlr;
@property (readwrite,strong)	NSString	*hlrOverride;
@property (readwrite,strong)	NSString	*created;
@property (readwrite,strong)	NSString	*scts;
@property (readwrite,assign)	NSInteger	scts_tz;
@property (readwrite,assign)	NSInteger	qpriority;
@property (readwrite,assign)	NSInteger	upriority;
@property (readwrite,assign)	NSInteger	btype;
@property (readwrite,assign)	NSInteger	messageStatus;
@property (readwrite,assign)	NSInteger	messageError1;
@property (readwrite,assign)	NSInteger	messageError2;
@property (readwrite,strong)	NSString	*messageDelivered;
@property (readwrite,strong)	NSString	*messageFailed;
@property (readwrite,strong)	NSString	*messageAttempted;
@property (readwrite,strong)	NSString	*messageExpiry;
@property (readwrite,assign)	NSInteger	messageExpiryTz;
@property (readwrite,strong)    NSString    *deferredString;
@property (readwrite,strong)	NSString	*messageNextAttempt;
@property (readwrite,assign)	NSInteger	messageAttempts;
@property (readwrite,assign)	NSInteger	messageMaxAttempts;
@property (readwrite,assign)	NSInteger	messageWaitingSet;
@property (readwrite,assign)	NSInteger	sriAttempts;
@property (readwrite,strong)	NSNumber    *deliveryReportMask;
@property (readwrite,strong)	NSString	*deliveryReportAddress;
@property (readwrite,strong)	UMHTTPRequest	*deliveryReportAddressHttp;
@property (readwrite,assign)	NSInteger	deliveryReportStatus;
@property (readwrite,assign)	NSInteger	deliveryReportError1;
@property (readwrite,assign)	NSInteger	deliveryReportError2;
@property (readwrite,strong)	NSString	*deliveryReportDelivered;
@property (readwrite,strong)	NSString	*deliveryReportFailed;
@property (readwrite,strong)	NSString	*deliveryReportAttempted;
@property (readwrite,strong)	NSString	*deliveryReportExpiry;
@property (readwrite,strong)	NSString	*deliveryReportNextAttempt;
@property (readwrite,assign)	NSInteger	deliveryReportAttempts;
@property (readwrite,assign)	NSInteger	deliveryReportMaxAttempts;
@property (readwrite,assign)	NSInteger	deliveryReportWaitingSet;
@property (readwrite,assign)	NSInteger	msuCountSriSMTx;
@property (readwrite,assign)	NSInteger	msuCountSriSMRx;
@property (readwrite,assign)	NSInteger	msuCountSriSMHTx;
@property (readwrite,assign)	NSInteger	msuCountSriSMHRx;
@property (readwrite,assign)	NSInteger	msuCountSriSMCRx;
@property (readwrite,assign)	NSInteger	msuCountFsmTx;
@property (readwrite,assign)	NSInteger	msuCountFsmRx;
@property (readwrite,assign)	NSInteger	msuCountTcapHandshakeTx;
@property (readwrite,assign)	NSInteger	msuCountTcapHandshakeRx;
@property (readwrite,assign)	NSInteger	testFlag;
@property (readwrite,assign)	NSInteger	phoneRef;
@property (readwrite,assign)	NSInteger	udhIndicator;
@property (readwrite,strong)	NSString	*toCountry;
@property (readwrite,strong)	NSString	*toOperatorCode;
@property (readwrite,strong)	NSString	*toOperatorName;
@property (readwrite,strong)	NSNumber	*messagePriority;
@property (readwrite,assign)	NSInteger	replyPath;
@property (readwrite,assign)	NSInteger	pid;
@property (readwrite,assign)	NSInteger	compress;
@property (readwrite,assign)	NSInteger	dcs;
@property (readwrite,assign)	NSInteger	mwi_pdu;
@property (readwrite,strong)	NSData		*udh;
@property (readwrite,strong)	NSData		*content;
@property (readwrite,strong)	NSString	*plaintextContent;
@property (readwrite,assign)	NSInteger	coding;
@property (readwrite,strong)	NSString	*opc;
@property (readwrite,strong)	NSString	*dpc;
@property (readwrite,strong)	NSString	*opc2;
@property (readwrite,strong)	NSString	*dpc2;
@property (readwrite,assign)	NSInteger	tcapType;
@property (readwrite,strong)	NSString	*extensionData;
@property (readwrite,strong)	NSDictionary *extensionOptions;
@property (readwrite,assign)	NSInteger	purgeFlag;
@property (readwrite,strong)	NSString	*alertingAddress;
@property (readwrite,strong)	NSString	*fromCountry;
@property (readwrite,strong)	NSString	*fromOperatorCode;
@property (readwrite,strong)	NSString	*fromOperatorName;
@property (readwrite,strong)	NSString	*routeId;
@property (readwrite,strong)	NSString	*subrouteId;
@property (readwrite,strong)	NSString	*routedOnPrefix;
@property (readwrite,assign)	NSInteger	autoRouted;
@property (readwrite,assign)	NSInteger	userFlags;
@property (readwrite,assign)	NSInteger	retryPatternTable;

@property (readwrite,strong)	NSString	*sccpSource;
@property (readwrite,strong)	NSString	*interworkingTapCode;

@property (readwrite,strong)	NSString	*costTable;
@property (readwrite,assign)	double	     msuCostTx;
@property (readwrite,assign)	double	     msuCostRx;
@property (readwrite,assign)	double	     smsCost;
@property (readwrite,assign)	double	     interworkingCost;
@property (readonly,assign)     double	     totalCost;
@property (readwrite,strong)	NSString	*chargeTable1;
@property (readwrite,assign)	double	     chargePrice1;
@property (readonly,assign)     double	     profit1;
@property (readwrite,strong)	NSString	*chargeTable2;
@property (readwrite,assign)	double	     chargePrice2;
@property (readonly,assign)     double	     profit2;
@property (readwrite,strong)	NSString	 *destinationQuotaTableName;

@property (readwrite,assign)	double	     oldMsuCostTx;
@property (readwrite,assign)	double	     oldMsuCostRx;
@property (readwrite,assign)	double	     oldSmsCost;
@property (readwrite,assign)	double	     oldInterworkingCost;
@property (readwrite,assign)	double	     oldChargePrice1;
@property (readwrite,assign)	double	     oldChargePrice2;

@property (readwrite,strong)    NSString        *triggerSet;
@property (readwrite,strong)    NSDictionary    *triggers;

@property (readwrite,assign)	NSInteger   tt_sri;
@property (readwrite,assign)	NSInteger   tt_fsm;
@property (readwrite,strong)    NSString *comment;
@property (readwrite,strong)    NSString *vas_esme;
@property (readwrite,strong)    NSString *vas_ip;
@property (readwrite,assign)    BOOL    isMultipart;
@property (readwrite,assign)    int     multipartCurrent;
@property (readwrite,assign)    int     multipartMax;
@property (readwrite,assign)    int     multipartRef;

@property (readwrite,assign)    NSInteger               msc_index;
@property (readwrite,strong)    NSArray <NSString *>    *mscs;

@property (readwrite,strong)    MMSMSMoAuthTransaction *moAuthTransaction;

- (NSString	*)  tableName;
- (NSString	*)  archiveTableName;
- (UMUser *)usr;

- (UMMessage *)initWithInstance:(NSString *)inst withNewMessageId:(BOOL)newid;

- (NSString *)countryOfTo;
- (NSString *)operatorOfTo;

- (NSString *) submissionTypeString;
- (void) setSubmissionTypeString:(NSString *)s;

- (NSString *)messageStatusString;
- (void) setMessageStatusString:(NSString *)s;

- (NSString *)deliveryReportStatusString;
- (void) setDeliveryReportStatusString:(NSString *)s;
	

- (void) setMessageStatus:(NSInteger)status;
- (void) setMessageAttempted:(NSString *)dt;
- (void) setMessageDelivered:(NSString *)dt;
- (void) setMessageFailed:(NSString *)dt;
- (void) setMessageError1:(NSInteger)err;
- (void) setMessageError2:(NSInteger)err;
- (void) setMessageWaitingSet:(NSInteger)mwi;
- (void) setToImsi:(NSString *)imsi;
- (void) setFromImsi:(NSString *)imsi;
- (void) setToMsc:(NSString *)msc;
- (void) setFromMsc:(NSString *)msc;
- (void) setHlr:(NSString *)hlr1;
- (void) setHlrOverride:(NSString *)hlr1;
- (void) setDeliveryReportStatus:(NSInteger)status;
- (void) setDeliveryReportAttempted:(NSString *)dt;
- (void) setDeliveryReportDelivered:(NSString *)dt;
- (void) setDeliveryReportFailed:(NSString *)dt;
- (void) setDeliveryReportError1:(NSInteger)err;
- (void) setDeliveryReportError2:(NSInteger)err;
- (void) setDeliveryReportWaitingSet:(NSInteger)mwi;
- (void) setDeliveryReportImsi:(NSString *)imsi;
- (void) setDeliveryReportMsc:(NSString *)msc;

- (void) increaseMessageAttempts;
- (void) increaseSriAttempts;
- (void) increaseDeliveryReportAttempts;
- (void) updateDB:(BOOL)forced;
- (void) updateDBCallback:(UMDbSession *)session historySession:(UMDbSession *)session2;
- (void) updateDBCallbackMessage:(UMDbSession *)session;
- (void) updateDBCallbackHistory:(UMDbSession *)session;


//+ (NSString *)fieldNames;


- (BOOL)insertToDatabase;
- (BOOL)insertToDatabase:(BOOL)canFail;
- (BOOL)insertToDatabase:(BOOL)canFail withSession:(UMDbSession *)session withHistorySession:(UMDbSession *)session2;


- (void)archive;
- (BOOL)archiveToDatabaseCallback:(BOOL)canFail withSession:(UMDbSession *)session;
- (BOOL)removeFromArchive;


//- (NSString *)updateSql;
//- (NSString *)updateSqlForDbType:(UMDbDriverType)dbtype;
//- (NSString *)updateHistorySqlForDbType:(UMDbDriverType)dbtype;

- (void)clearDirtyStatus;
- (NSInteger)uid;
- (NSInteger)gid;
- (void)setUid:(NSInteger)i;
- (void) setGid:(NSInteger)i;
- (void) setOpcLong:(long)pc;
- (void) setDpcLong:(long)pc;
- (long) opcLong;
- (long) dpcLong;
- (void) setOpc2Long:(long)pc;
- (void) setDpc2Long:(long)pc;
- (long) opc2Long;
- (long) dpc2Long;
- (NSString *)archiveId;
- (void) setArchiveId:(NSString *)a;

+ (NSArray *)createSql:(NSString *) tn withDb:(UMDbDriverType)dbType;
+ (NSArray *)createArchiveSql:(NSString *) tn withDb:(UMDbDriverType)dbType;
+ (NSArray *)createHistorySql:(NSString *) tn withDb:(UMDbDriverType)dbType;

+ (NSString *)imsiToOperatorCode:(NSString *)imsi;
+ (NSString *)operatorCodeToOperatorName:(NSString *)code;
+ (void)imsiToOperatorCodeAndName:(NSString *)imsi_in name:(NSString **)opName operatorCode:(NSString **)opCode;

- (void)increaseMsuCountSriSMTx:(int)i;
- (void)increaseMsuCountSriSMRx:(int)i;
- (void)increaseMsuCountSriSMHTx:(int)i;
- (void)increaseMsuCountSriSMHRx:(int)i;
- (void)increaseMsuCountSriSMCRx:(int)i;
- (void)increaseMsuCountFsmTx:(int)i;
- (void)increaseMsuCountFsmRx:(int)i;
- (void)increaseMsuCountTcapHandshakeTx:(int)i;
- (void)increaseMsuCountTcapHandshakeRx:(int)i;
- (NSInteger)msuCountRx;
- (NSInteger)msuCountTx;
- (NSString *)getSmsc2;
- (NSString *)getSmsc3;
- (NSString *)getSmsc4;
- (int) updateBilling;
- (NSString *)toMcc;
- (NSString *)toMnc;
- (NSString *)fromMcc;
- (NSString *)fromMnc;
- (int)networkErrorCode;
- (void)setHistoryText:(NSString *)text;
//+ (UMMessage *)msgLoadReal:(const char *)mid file:(const char *)file line:(long)line  func:(const char *)func;
+(UMMessage *)messageLoad:(NSString *)messageId forInstance:(NSString *)instance file:(const char *)file line:(long)line  func:(const char *)func;

//- (void)addToCache;
//- (void)removeFromCache;
//+ (UMMessage *)loadFromCache:(NSString *)messagId;
- (UMMessage *)initWithRow:(NSArray *)row;
- (void)saveOldValues;

- (int)m2type;
+ (int)m2type;

- (NSString *)valueForKey:(NSString *)key;
- (void)setValue:(NSString *)value forKey:(NSString *)key;

//- (void)setOriginatingAddress:(struct sockaddr *)originatingAddress length:(socklen_t)originatingAddressLen;
//- (void)getOriginatingAddress:(struct sockaddr *)originatingAddress length:(socklen_t *)originatingAddressLen;

- (void)startTimer1;
- (void)stopTimer1;

- (void)startTimer2;
- (void)startTimer2b;
- (void)stopTimer2;

- (void)startTimer3;
- (void)stopTimer3;

- (void)startTimer4;
- (void)stopTimer4;

- (void)startTimer5;
- (void)stopTimer5;

- (long) randomRangeMin:(long)min max:(long)max;
- (void)enableHistoryLog;
- (void)enableHistoryLogOverride; /* switch on history if something goes totally wrong, even if globally disabled */

- (BOOL)mustSendReport;

- (void)logToMessage:(NSString *)text;
- (void)logEvent:(NSString *)text inState:(NSString *)state;
- (void)logStateChange:(NSString *)oldstate newState:(NSString *)newState;
+ (NSString *)archiveIdWithInstance:(NSString *)instanceName messageId:(NSString *)messageId;

#ifdef UNUSED
- (BOOL)updateToDatabaseNew:(BOOL)canFail;
#endif

- (NSString *)plaintextContent32;
- (void)copyUserDefaults:(UMUser *)usr;
+ (int)statusCodeFromString:(NSString *)s;
+ (NSString *)statusString:(NSInteger)mstat;


/* glue code */
- (void) setPduUdhi:(NSInteger)i;
- (NSInteger) pduUdhi;
- (NSData *)pduContentIncludingUdh;
- (NSDate *)attemptedDate;
- (NSDate *)submitDate;
- (NSDate *)submitAckTime;
- (void) setSubmitAckTime:(NSDate *)d;
- (void) setValidity:(NSDate *)d;
- (NSDate *)validity;
- (void) setDeferred:(NSDate *)d;
- (NSDate *)deferred;
- (void) setSubmitString: (NSString *)s;
- (NSString *)submitString;
- (NSDate *)submitErrTime;
- (void) setSubmitErrTime:(NSDate *)d;
- (NSInteger)submitErrCode;
- (void) setSubmitErrCode:(NSInteger)err;
- (void)setNetworkErrorCode:(int)c;
- (void) setUserTransaction:(id)transaction;
- (id) userTransaction;
- (void) setRouterTransaction:(id)transaction;
- (id) routerTransaction;
- (int) priority;
- (void) setPriority:(int)prio;
- (int) replaceIfPresentFlag;
- (void) setReplaceIfPresentFlag:(int)i;
- (id)originalSendingObject;
- (void)setOriginalSendingObject:(id)obj;
- (NSString *)instance;
- (void)setInstance:(NSString *)instance;

- (BOOL)scriptDebugging;
- (void)expandExtensionData;
- (void)packExtensionData;
- (int)phase;
- (void)setPhase:(int)p;

- (void)setApplicationContextSriSM:(NSString *)ac;
- (void)setApplicationContextForwardSM:(NSString *)ac;
- (void)setApplicationContext:(NSString *)ac;

- (void) setUserMessageReference:(NSString *)msgid;
- (NSString *)userMessageReference;
- (void) setUserReference:(NSString *)msgid;
- (NSString *)userReference;

- (void)specialAction:(NSString *)action data:(NSString *)data;

- (NSInteger)messageClass;
- (void)setMessageClass:(NSInteger)messageClass;
+ (NSArray *)loadStatusNew;
- (NSString *)userFlagsDescription;

@end
