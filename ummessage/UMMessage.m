//
//  UMMessage.m
//  ummessage
//
//  Created by Andreas Fink on 03.03.2025.
//  Copyright 2025 Andreas Fink, Paradieshofstrasse 101, 4054 Basel andreas@fink.org
//

#import "UMMessage.h"
#import <ulib/ulib.h>
#import <ulibdb/ulibdb.h>

#import <ulibsmpp/ulibsmpp.h> /* for NSString+HexFunctions.h */

#include "db.h"				/* for database access */
#import "globals.h"
#import "mm_mtp3.h"
#import "UMDestinationQuota.h"
#import "UMDestinationQuotaEntry.h"

#import "license.h"
#include <unistd.h>
#import "UMSMSEnvironment.h"
#import "MMSMSMoAuthTransaction.h"

extern UMGlobalMessageCache *g_global_message_cache;
//static NSMutableDictionary *globalMessagesTable = NULL;

/* if you modify this, you must modify insert and archive as well in same order and also modify copyWithZone and msg_row2msg_array  */
BOOL    selectorsUpdated = NO;

extern UMQueueSingle *archive_message_list;

static dbFieldDef db_message_fields[] =
{
	{"archiveId",                   NULL,                           NO,     DB_PRIMARY_INDEX,   DB_FIELD_TYPE_VARCHAR,              64,   0,NULL,NULL,1},
	{"archiveStatus",               NULL,                           NO,     DB_INDEXED,         DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,2},
	{"instanceName",                NULL,                           NO,     DB_INDEXED,         DB_FIELD_TYPE_VARCHAR,              32,   0,NULL,NULL,3},
	{"messageId",                   NULL,                           NO,     DB_INDEXED,         DB_FIELD_TYPE_VARCHAR,              20,   0,NULL,NULL,4},
	{"userId",                      NULL,                           NO,     DB_INDEXED,         DB_FIELD_TYPE_VARCHAR,              20,   0,NULL,NULL,5},
	{"groupId",                     NULL,                           NO,     DB_INDEXED,         DB_FIELD_TYPE_VARCHAR,              20,   0,NULL,NULL,6},
	{"deliveryMethod",              NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_VARCHAR,              16,    0,NULL,NULL,7},
	{"submissionType",              NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_VARCHAR,              16,    0,NULL,NULL,8},
	{"fromNumber",                  NULL,                           NO,     DB_INDEXED,         DB_FIELD_TYPE_VARCHAR,              MAXADDRLEN,   0,NULL,NULL,9},
	{"receivedFromIp",              NULL,                           NO,     DB_INDEXED,         DB_FIELD_TYPE_VARCHAR,              32,   0,NULL,NULL,10},
    {"submissionIp",                NULL,                           NO,     DB_INDEXED,         DB_FIELD_TYPE_VARCHAR,              32,   0,NULL,NULL,119},
	{"toNumber",                    NULL,                           NO,     DB_INDEXED,         DB_FIELD_TYPE_VARCHAR,              MAXADDRLEN,   0,NULL,NULL,11},
	{"deliveryReportMsc",           NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_VARCHAR,              MAXADDRLEN,   0,NULL,NULL,12},
	{"deliveryReportImsi",          NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_VARCHAR,              MAXIMSILEN,   0,NULL,NULL,13},
	{"fromMsc",                     NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_VARCHAR,              MAXADDRLEN,   0,NULL,NULL,14},
	{"fromImsi",                    NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_VARCHAR,              MAXIMSILEN,   0,NULL,NULL,15},
	{"toMsc",                       NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_VARCHAR,              MAXADDRLEN,   0,NULL,NULL,16},
	{"toImsi",                      NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_VARCHAR,              MAXIMSILEN,   0,NULL,NULL,17},
	{"smsc",                        NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_VARCHAR,              MAXADDRLEN,   0,NULL,NULL,18},
	{"smsc2",                       NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_VARCHAR,              MAXADDRLEN,   0,NULL,NULL,19},
	{"smsc3",                       NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_VARCHAR,              MAXADDRLEN,   0,NULL,NULL,20},
	{"smsc4",                       NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_VARCHAR,              MAXADDRLEN,   0,NULL,NULL,21},
	{"hlr",                         NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_VARCHAR,              MAXADDRLEN,   0,NULL,NULL,22},
	{"created",                     "0000-00-00 00:00:00.000000",   NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_TIMESTAMP_AS_STRING,  0,    0,NULL,NULL,23},
	{"scts",                        "0000-00-00 00:00:00.000000",   NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_TIMESTAMP_AS_STRING,  0,    0,NULL,NULL,24},
	{"scts_tz",                     NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,25},
	{"qpriority",                   "3",                            NO,     DB_INDEXED_BUT_NOT_FOR_ARCHIVE, DB_FIELD_TYPE_SMALL_INTEGER,0,0,NULL,NULL,26},
	{"upriority",                   "4",                            NO,     DB_INDEXED_BUT_NOT_FOR_ARCHIVE, DB_FIELD_TYPE_SMALL_INTEGER,0,0,NULL,NULL,27},
	{"messagePriority",             NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,28},
	{"btype",                       NULL,                           NO,     DB_INDEXED_BUT_NOT_FOR_ARCHIVE, DB_FIELD_TYPE_SMALL_INTEGER,0,0,NULL,NULL,29},
	{"messageStatus",               NULL,                           NO,     DB_INDEXED,         DB_FIELD_TYPE_VARCHAR,               16,   0,NULL,NULL,30},
	{"messageError1",               NULL,                           NO,     DB_INDEXED,         DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,31},
	{"messageError2",               NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,32},
	{"messageDelivered",            "0000-00-00 00:00:00.000000",   NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_TIMESTAMP_AS_STRING,  0,    0,NULL,NULL,33},
	{"messageFailed",               "0000-00-00 00:00:00.000000",   NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_TIMESTAMP_AS_STRING,  0,    0,NULL,NULL,34},
	{"messageAttempted",            "0000-00-00 00:00:00.000000",   NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_TIMESTAMP_AS_STRING,  0,    0,NULL,NULL,35},
	{"messageExpiry",               "0000-00-00 00:00:00.000000",   NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_TIMESTAMP_AS_STRING,  0,    0,NULL,NULL,36},
	{"messageExpiryTz",             NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,37},
	{"messageNextAttempt",          "0000-00-00 00:00:00.000000",   NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_TIMESTAMP_AS_STRING,  0,    0,NULL,NULL,38},
	{"messageAttempts",             NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,39},
	{"messageMaxAttempts",          NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,40},
	{"messageWaitingSet",           NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,41},
	{"deliveryReportMask",          NULL,                           NO,     DB_INDEXED_BUT_NOT_FOR_ARCHIVE, DB_FIELD_TYPE_SMALL_INTEGER, 0, 0,NULL,NULL,42},
	{"deliveryReportAddress",       NULL,                           NO,     DB_INDEXED_BUT_NOT_FOR_ARCHIVE, DB_FIELD_TYPE_VARCHAR,  32,   0,NULL,NULL,43},
	{"deliveryReportStatus",        NULL,                           NO,     DB_INDEXED_BUT_NOT_FOR_ARCHIVE, DB_FIELD_TYPE_VARCHAR,  16,   0,NULL,NULL,44},
	{"deliveryReportError1",        NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,45},
	{"deliveryReportError2",        NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,46},
	{"deliveryReportDelivered",     "0000-00-00 00:00:00.000000",   NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_TIMESTAMP_AS_STRING,  0,    0,NULL,NULL,47},
	{"deliveryReportFailed",        "0000-00-00 00:00:00.000000",   NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_TIMESTAMP_AS_STRING,  0,    0,NULL,NULL,48},
	{"deliveryReportAttempted",     "0000-00-00 00:00:00.000000",   NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_TIMESTAMP_AS_STRING,  0,    0,NULL,NULL,49},
	{"deliveryReportExpiry",        "0000-00-00 00:00:00.000000",   NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_TIMESTAMP_AS_STRING,  0,    0,NULL,NULL,50},
	{"deliveryReportNextAttempt",   "0000-00-00 00:00:00.000000",   NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_TIMESTAMP_AS_STRING,  0,    0,NULL,NULL,51},
	{"deliveryReportAttempts",      NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,52},
	{"deliveryReportMaxAttempts",   NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,53},
	{"deliveryReportWaitingSet",    NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,54},
	{"msuCountSriSMTx",             NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,55},
	{"msuCountSriSMRx",             NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,56},
	{"msuCountSriSMHTx",            NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,57},
	{"msuCountSriSMHRx",            NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,58},
	{"msuCountSriSMCRx",            NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,59},
	{"msuCountFsmTx",               NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,60},
	{"msuCountFsmRx",               NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,61},
	{"msuCountTcapHandshakeTx",     NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,62},
	{"msuCountTcapHandshakeRx",     NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,63},
	{"testFlag",                    NULL,                           NO,     DB_INDEXED,         DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,64},
	{"phoneRef",                    NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,65},
	{"udhIndicator",                NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,66},
	{"toCountry",                   NULL,                           NO,     DB_INDEXED,         DB_FIELD_TYPE_VARCHAR,              255,   0,NULL,NULL,67},
	{"toOperatorCode",              NULL,                           NO,     DB_INDEXED,         DB_FIELD_TYPE_VARCHAR,              8,    0,NULL,NULL,68},
	{"toOperatorName",              NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_VARCHAR,              255,   0,NULL,NULL,69},
	{"replyPath",                   NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,70},
	{"pid",                         NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,71},
	{"compress",                    NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,72},
	{"dcs",                         NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,73},
	{"mwi_pdu",                     NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,74},
	{"udh",                         NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_TEXT,                 0,    0,NULL,NULL,75},
	{"content",                     NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_TEXT,                 0,    0,NULL,NULL,76},
	{"plaintextContent",            NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_VARCHAR,              32,   0,NULL,NULL,77},
	{"messageClass",                NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,78},
	{"coding",                      NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,79},
	{"opc",                         NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_VARCHAR,              16,   0,NULL,NULL,80},
	{"dpc",                         NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_VARCHAR,              16,   0,NULL,NULL,81},
	{"opc2",                        NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_VARCHAR,              16,   0,NULL,NULL,82},
	{"dpc2",                        NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_VARCHAR,              16,   0,NULL,NULL,83},
	{"tcapType",                    NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,84},
	{"extensionData",               NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_TEXT,                 0,  0,NULL,NULL,85},
	{"purgeFlag",                   NULL,                           NO,     DB_INDEXED_BUT_NOT_FOR_ARCHIVE, DB_FIELD_TYPE_SMALL_INTEGER, 0, 0,NULL,NULL,86},
	{"alertingAddress",             NULL,                           NO,     DB_INDEXED_BUT_NOT_FOR_ARCHIVE, DB_FIELD_TYPE_VARCHAR, MAXADDRLEN, 0,NULL,NULL,87},
	{"fromCountry",                 NULL,                           NO,     DB_INDEXED,         DB_FIELD_TYPE_VARCHAR,              255,   0,NULL,NULL,88},
	{"fromOperatorCode",            NULL,                           NO,     DB_INDEXED,         DB_FIELD_TYPE_VARCHAR,              8,    0,NULL,NULL,89},
	{"fromOperatorName",            NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_VARCHAR,              255,   0,NULL,NULL,90},
	{"routeId",                     NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_VARCHAR,              32,   0,NULL,NULL,91},
	{"subrouteId",                  NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_VARCHAR,              32,   0,NULL,NULL,92},
	{"routedOnPrefix",              NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_VARCHAR,              32,   0,NULL,NULL,93},
	{"autoRouted",                  NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,94},
	{"userFlags",                   NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_INTEGER,              0,    0,NULL,NULL,95},
	{"retryPatternTable",           NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,96},
    {"interworkingTapCode",         NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_VARCHAR,              7,    0,NULL,NULL,97},
    {"costTable",                   "default",                      NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_VARCHAR,              32,   0,NULL,NULL,98},
    {"msuCostTx"  ,                 NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_NUMERIC,              24,   6,NULL,NULL,99},
    {"msuCostRx"  ,                 NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_NUMERIC,              24,   6,NULL,NULL,100},
    {"smsCost"  ,                   NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_NUMERIC,              24,   6,NULL,NULL,101},
    {"interworkingCost",            NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_NUMERIC,              24,   6,NULL,NULL,102},
    {"totalCost",                   NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_NUMERIC,              24,   6,NULL,NULL,103},
    {"chargeTable1",                "default",                      NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_VARCHAR,               32,   6,NULL,NULL,104},
    {"chargePrice1",                NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_NUMERIC,              24,   6,NULL,NULL,105},
    {"profit1",                     NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_NUMERIC,              24,   6,NULL,NULL,106},
    {"chargeTable2",                "default",                      NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_VARCHAR,              32,   6,NULL,NULL,107},
    {"chargePrice2",                NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_NUMERIC,              24,   6,NULL,NULL,108},
    {"profit2",                     NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_NUMERIC,              24,   6,NULL,NULL,109},
    {"destinationQuotaTable",       "default",                      NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_VARCHAR,              32,   6,NULL,NULL,110},
    {"tt_sri",                      "0",                            NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_SMALL_INTEGER,        32,   6,NULL,NULL,111},
    {"tt_fsm",                      "0",                            NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_SMALL_INTEGER,        32,   6,NULL,NULL,112},
    {"dlr_text",                    NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_TEXT,                 0,    0,NULL,NULL,113},
    {"comment",                     NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_VARCHAR,              127,  0,NULL,NULL,114},
    {"hlr_override",                NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_VARCHAR,              32,   0,NULL,NULL,115},
    {"vas_esme",                    NULL,                           NO,     DB_INDEXED_BUT_NOT_FOR_ARCHIVE, DB_FIELD_TYPE_VARCHAR,   255,  0,NULL,NULL,116},
    {"vas_ip",                      NULL,                           NO,     DB_INDEXED_BUT_NOT_FOR_ARCHIVE, DB_FIELD_TYPE_VARCHAR,   255,  0,NULL,NULL,117},
    {"deferred",                    NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_VARCHAR,        32,    0,NULL,NULL,119},
    {"exported",                    NULL,                           NO,     DB_INDEXED,         DB_FIELD_TYPE_SMALL_INTEGER,        0,    0,NULL,NULL,118},
    {"",                            NULL,                           NO,     DB_NOT_INDEXED,     DB_FIELD_TYPE_END,                  0,    0,NULL,NULL,0},
};

static dbFieldDef db_message_history_fields[] =
{
	{"archiveId",    NULL,NO,DB_PRIMARY_INDEX, DB_FIELD_TYPE_VARCHAR,  64,           0,NULL,NULL,1},
	{"instanceName", NULL,NO,DB_INDEXED,       DB_FIELD_TYPE_VARCHAR,  32,           0,NULL,NULL,2},
	{"messageId",    NULL,NO,DB_INDEXED,       DB_FIELD_TYPE_VARCHAR,  20,           0,NULL,NULL,3},
	{"toNumber",     NULL,NO,DB_INDEXED,       DB_FIELD_TYPE_VARCHAR,  MAXADDRLEN,   0,NULL,NULL,4},
	{"history",      NULL,NO,DB_NOT_INDEXED,   DB_FIELD_TYPE_TEXT,    0,            0,NULL,NULL,5},
    {"",             NULL,NO,DB_NOT_INDEXED,   DB_FIELD_TYPE_END,     0,            0,NULL,NULL,0},
};

#define LIMIT_TO_16BIT(i) \
    if(i>0x7FFF) \
    {\
        i = 0x7FFF; \
    } \
    else if(i<-0x7FFF) \
    { \
        i = - 0x7FFF; \
    }

extern NSString *UMTimeStampDT(void);

@implementation UMMessage
@synthesize startTime;
//@synthesize dlrText;
@synthesize cacheExpirationTime;
@synthesize timer1time;
@synthesize timer2time;
@synthesize timer3time;
@synthesize timer4time;
@synthesize timer5time;

@synthesize timer1min;
@synthesize timer2min;
@synthesize timer2bmin;
@synthesize timer3min;
@synthesize timer4min;
@synthesize timer5min;

@synthesize timer1max;
@synthesize timer2max;
@synthesize timer2bmax;
@synthesize timer3max;
@synthesize timer4max;
@synthesize timer5max;
@synthesize timeout;

@synthesize submitStatStatus;
@synthesize cacheExpiryKey;
@synthesize dbExpiryKey;
@synthesize delayedUpdateTime;
@synthesize hasBeenBilled;
@synthesize	archiveStatus;
@synthesize	instanceName;
@synthesize	messageId;
@synthesize	userId;
@synthesize	groupId;
@synthesize	submissionType;
@synthesize	from;
@synthesize    receivedFromIp;
@synthesize    submissionIp;
//@synthesize	to;
@synthesize	deliveryReportMsc;
//@synthesize	deliveryReportImsi;
@synthesize	fromMsc;
@synthesize	fromImsi;
//@synthesize	toMsc;
//@synthesize	toImsi;
//@synthesize	smsc;
//@synthesize	smsc2;
//@synthesize	smsc3;
//@synthesize	hlr;
//@synthesize	created;
//@synthesize	scts;
//@synthesize	scts_tz;
@synthesize	qpriority;
@synthesize	upriority;
@synthesize	btype;
@synthesize	messageStatus;
@synthesize	messageError1;
@synthesize	messageError2;
@synthesize	messageDelivered;
@synthesize	messageFailed;
@synthesize	messageAttempted;
//@synthesize	messageExpiry;
@synthesize messageExpiryTz;
@synthesize	messageAttempts;
@synthesize	messageWaitingSet;
@synthesize	sriAttempts;
@synthesize	deliveryReportMask;
@synthesize	deliveryReportAddress;
@synthesize	deliveryReportAddressHttp;
@synthesize	deliveryReportStatus;
@synthesize	deliveryReportError1;
@synthesize	deliveryReportError2;
@synthesize	deliveryReportDelivered;
@synthesize	deliveryReportFailed;
@synthesize	deliveryReportAttempted;
@synthesize	deliveryReportExpiry;
@synthesize	deliveryReportNextAttempt;
@synthesize	deliveryReportAttempts;
@synthesize	deliveryReportMaxAttempts;
@synthesize	deliveryReportWaitingSet;
@synthesize	testFlag;
@synthesize	phoneRef;
@synthesize	udhIndicator;
@synthesize	toCountry;
//@synthesize	toOperatorCode;
@synthesize	toOperatorName;
@synthesize	messagePriority;
@synthesize	replyPath;
@synthesize	pid;
@synthesize	compress;
@synthesize	dcs;
@synthesize	mwi_pdu;
//@synthesize	udh;
@synthesize	content;
//@synthesize	plaintextContent;
@synthesize	coding;
@synthesize	opc;
@synthesize	dpc;
@synthesize	opc2;
@synthesize	dpc2;
@synthesize	tcapType;
@synthesize	purgeFlag;
@synthesize	alertingAddress;
@synthesize	fromCountry;
@synthesize	fromOperatorCode;
@synthesize	fromOperatorName;
@synthesize	routeId;
@synthesize	subrouteId;
@synthesize	routedOnPrefix;
@synthesize	autoRouted;
@synthesize retryPatternTable;
@synthesize sccpSource;
//@synthesize stateMachine;
@synthesize messageState;
@synthesize interworkingTapCode;
@synthesize destinationQuotaTableName;

@synthesize oldMsuCostTx;
@synthesize oldMsuCostRx;
@synthesize oldSmsCost;
@synthesize oldInterworkingCost;
@synthesize oldChargePrice1;
@synthesize oldChargePrice2;
@synthesize traceLevel;
@synthesize traceFile;
@synthesize env;
@synthesize triggerSet;
@synthesize triggers;
@synthesize tt_sri;
@synthesize tt_fsm;
//@synthesize costTable;
//@synthesize msuCost;
//@synthesize smsCost;
//@synthesize interworkingCost;
//@synthesize totalCost;
//@synthesize profit;

- (void) setUserMessageReference:(NSString *)msgid
{
    messageId =  msgid;
}

- (NSString *)userMessageReference
{
    return messageId;
}


- (void) setUserReference:(NSString *)msgid
{
    messageId =  msgid;
}

- (NSString *)userReference
{
    return messageId;
}

- (UMMessage *)init
{
	return [self initWithInstance:NULL withNewMessageId:YES];
}

+(dbFieldDef *)tableDefinition
{
    return db_message_fields;
}

+(dbFieldDef *)tableDefinitionHistory
{
    return db_message_history_fields;
}

#if 0
- (void)addToCache
{
    if(globalMessagesTable==NULL)
    {
        globalMessagesTable = [[NSMutableDictionary alloc]init];
    }
    @synchronized(globalMessagesTable)
    {
        NSString *archiveId = [self archiveId];
        assert(archiveId!=NULL);
        [globalMessagesTable setObject:self forKey:archiveId];
        time_t now;
        time(&now);
        cacheExpirationTime = now + 600; /* we expire in 10 minutes */
    }
}

- (void)removeFromCache
{
    if(globalMessagesTable==NULL)
    {
        globalMessagesTable = [[NSMutableDictionary alloc]init];
    }
    @synchronized(globalMessagesTable)
    {
        [globalMessagesTable removeObjectForKey:[self archiveId]];
    }
}

+(void)expireCache
{
    NSMutableArray *removeKeys = [[NSMutableArray alloc]init];
    @synchronized(globalMessagesTable)
    {
        time_t now;
        time(&now);

        for(NSString *key in globalMessagesTable)
        {
            UMMessage *msg = [globalMessagesTable objectForKey:key];
            if(msg.cacheExpirationTime < now)
            {
                [removeKeys addObject:key];
            }
        }
    }
    for(NSString *key in removeKeys)
    {
        @synchronized(globalMessagesTable)
        {
            [globalMessagesTable removeObjectForKey:key];
        }
    }
}
#endif

- (void)expireMessage
{
    time_t now;
    time(&now);
    cacheExpirationTime = now;
}



- (UMMessage *)initWithInstance:(NSString *)inst
               withNewMessageId:(BOOL)newid
{
    self=[super init];
	if(self)
	{
        time_t current;
        time(&current);

        startTime = mm_milisecond_clock();
        _historyHasBeenInserted = NO;
        _messageHistory = [[UMHistoryLog alloc]initWithMaxLines:1000];
        if(g_force_enable_history)
        {
            self.userFlags |= USERFLAG_ENABLE_HISTORY;
        }
        newRecord = YES;
		qpriority= -1;	/* -1 means not set */
		messagePriority= -1;	/* -1 means not set */
		messageStatus = M_STATUS_NEW;
		deliveryReportStatus = M_STATUS_IGNORED;
		_messageMaxAttempts = 15;
		deliveryReportMaxAttempts = 7;
		compress =COMPRESS_UNDEF;
		mwi_pdu = MWI_UNDEF;
		_messageClass = MC_UNDEF;
		coding = DC_UNDEF;
        NSDate *now = [NSDate date];
        _created = [now stringValue];
        _messageExpiry = @"";
        _deferredString = @"";
        _costTable = @"default";
        _chargeTable1 = @"default";
        _chargeTable2 = @"default";
		_deliveryMethod = METHOD_MT;
		if(inst==NULL)
        {
			instanceName = [NSString stringWithUTF8String:(char *)&global_default_smsc_instance];
        }
		else
        {
			instanceName = inst;
        }
        if(newid==YES)
        {
            MsgIdType	this_msgid;
            globals_set_next_id(&this_msgid);
            messageId = [NSString stringWithUTF8String:&this_msgid[0]];
        }
        _msc_index = -1;
        _mscs = @[];
	}
	return self;
}

-(NSString *) messageExpiry
{
    return _messageExpiry;
}

- (void)setMessageExpiry:(NSString *)exp
{
    _messageExpiry = exp;
    _dirtyExpiryTime = YES;
    dirty = YES;
}

-(NSString *) messageNextAttempt
{
    return _messageNextAttempt;
}

- (void)setMessageNextAttempt:(NSString *)exp
{
    _messageNextAttempt = exp;
    _dirtyMessageNextAttempt = YES;
    dirty = YES;
}

- (void)dealloc
{
    //    NSLog(@"dealloc %s",magic);
#ifdef DEALLOC_TRACE
    UMAssert(archiveStatus<99,@"message in the process of being deallocated by: %s",btbuffer);
    NSString *bt = UMBacktrace(NULL,0);
    memset(btbuffer,0x00,sizeof(btbuffer));
    strncpy(btbuffer,bt.UTF8String,sizeof(btbuffer)-1);
    archiveStatus=99;
    usleep(10000);  /* we sleep here on purpose to provoke a double dealloc failure */
    archiveStatus=100;
#endif
}


- (void)enableHistoryLog
{
    if(_messageHistory==NULL)
    {
        _messageHistory = [[UMHistoryLog alloc]initWithMaxLines:1000];
    }
    if(!g_force_disable_history)
    {
        self.userFlags  = self.userFlags | USERFLAG_ENABLE_HISTORY;
    }
}

- (void)disableHistoryLog
{
    if(!g_force_enable_history)
    {
        self.userFlags  = self.userFlags &  ~USERFLAG_ENABLE_HISTORY;
    }
}

- (void)enableHistoryLogOverride
{
    if(_messageHistory==NULL)
    {
        _messageHistory = [[UMHistoryLog alloc]initWithMaxLines:1000];
    }
    self.userFlags |=  USERFLAG_ENABLE_HISTORY;
}


- (UMMessage *)copyWithZone:(NSZone *)zone
{
	UMMessage *newObject = [UMMessage allocWithZone:zone]; /* we don't call init on purpose */
	newObject->instanceName=instanceName;
	newObject->messageId=messageId;
	newObject->userId=userId;
	newObject->groupId=groupId;
	newObject->from=from;
    newObject->receivedFromIp=receivedFromIp;
    newObject->submissionIp=submissionIp;
	newObject->to=to;
	newObject->deliveryReportMsc=deliveryReportMsc;
	newObject->deliveryReportImsi=deliveryReportImsi;
	newObject->fromMsc=fromMsc;
	newObject->fromImsi=fromImsi;
	newObject->toMsc=toMsc;
	newObject->toImsi=toImsi;
	newObject->smsc=smsc;
	newObject->smsc2=smsc2;
	newObject->smsc3=smsc3;
	newObject->smsc4=smsc4;
	newObject->hlr=hlr;
	newObject->_created=_created;
	newObject->scts=scts;
	newObject->messageDelivered=messageDelivered;
	newObject->messageFailed=messageFailed;
	newObject->messageAttempted=messageAttempted;
	newObject->_messageExpiry=_messageExpiry;
	newObject->_messageNextAttempt=_messageNextAttempt;
	newObject->deliveryReportAddress=deliveryReportAddress;
	newObject->deliveryReportDelivered=deliveryReportDelivered;
	newObject->deliveryReportFailed=deliveryReportFailed;
	newObject->deliveryReportAttempted=deliveryReportAttempted;
	newObject->deliveryReportExpiry=deliveryReportExpiry;
	newObject->deliveryReportNextAttempt=deliveryReportNextAttempt;
	newObject->toCountry=toCountry;
	newObject->toOperatorCode=toOperatorCode;
	newObject->toOperatorName=toOperatorName;
	newObject->udh=udh;
    newObject->_isMultipart = _isMultipart;
    newObject->_multipartMax = _multipartMax;
    newObject->_multipartCurrent = _multipartCurrent;
    newObject->_multipartRef = _multipartRef;
	newObject->content=content;
	//newObject->plaintextContent=plaintextContent;
	newObject->opc=opc;
	newObject->dpc=dpc;
	newObject->opc2=opc2;
	newObject->dpc2=dpc2;
	newObject->_extensionData=_extensionData;
	newObject->alertingAddress=alertingAddress;
	newObject->fromCountry=fromCountry;
	newObject->fromOperatorCode=fromOperatorCode;
	newObject->fromOperatorName=fromOperatorName;
	newObject->routeId=routeId;
	newObject->subrouteId=subrouteId;
	newObject->routedOnPrefix=routedOnPrefix;
	newObject->sccpSource=sccpSource;
    newObject->interworkingTapCode=interworkingTapCode;

    newObject->_costTable=_costTable;
    newObject->_chargeTable1=_chargeTable1;
    newObject->_chargeTable2=_chargeTable2;

    newObject->destinationQuotaTableName = destinationQuotaTableName;

	/* integer values */
	newObject->archiveStatus=archiveStatus;
	newObject->_deliveryMethod=_deliveryMethod;
	newObject->submissionType=submissionType;
	newObject->scts_tz=scts_tz;
	newObject->qpriority=qpriority;
	newObject->upriority=upriority;
	newObject->btype=btype;
	newObject->messageStatus=messageStatus;
	newObject->messageError1=messageError1;
	newObject->messageError2=messageError2;
	newObject->messageExpiryTz=messageExpiryTz;
	newObject->messageAttempts=messageAttempts;
	newObject->_messageMaxAttempts=_messageMaxAttempts;
	newObject->messageWaitingSet=messageWaitingSet;
	newObject->_deliveryReportMask=_deliveryReportMask;
	newObject->deliveryReportStatus=deliveryReportStatus;
	newObject->deliveryReportError1=deliveryReportError1;
	newObject->deliveryReportError2=deliveryReportError2;
	newObject->deliveryReportAttempts=deliveryReportAttempts;
	newObject->deliveryReportMaxAttempts=deliveryReportMaxAttempts;
	newObject->deliveryReportWaitingSet=deliveryReportWaitingSet;
	newObject.msuCountSriSMTx=_msuCountSriSMTx;
	newObject.msuCountSriSMRx=_msuCountSriSMRx;
	newObject.msuCountSriSMHTx =_msuCountSriSMHTx;
	newObject.msuCountSriSMHRx=_msuCountSriSMHRx;
	newObject.msuCountSriSMHRx=_msuCountSriSMCRx;
	newObject.msuCountFsmTx=_msuCountFsmTx;
	newObject.msuCountFsmRx=_msuCountFsmRx;
    newObject.msuCountTcapHandshakeRx=_msuCountTcapHandshakeRx;
    newObject.msuCountTcapHandshakeRx=_msuCountTcapHandshakeTx;
	newObject->testFlag=testFlag;
	newObject->phoneRef=phoneRef;
	newObject->udhIndicator=udhIndicator;
	newObject->messagePriority=messagePriority;
	newObject->replyPath=replyPath;
	newObject->pid=pid;
	newObject->compress=compress;
	newObject->dcs=dcs;
	newObject->mwi_pdu=mwi_pdu;
	newObject->_messageClass=_messageClass;
	newObject->coding=coding;
	newObject->tcapType=tcapType;
	newObject->purgeFlag=purgeFlag;
	newObject->autoRouted=autoRouted;
	newObject->_userFlags=_userFlags;
	newObject->retryPatternTable=retryPatternTable;

	/* double values */
    
    newObject->msuCostTx=msuCostTx;
    newObject->msuCostRx=msuCostRx;
    newObject->smsCost=smsCost;
    newObject->interworkingCost=interworkingCost;
 //   newObject->totalCost=totalCost;
    newObject->_chargePrice1=_chargePrice1;
    newObject->_chargePrice2=_chargePrice2;
    newObject->_chargeTable1=_chargeTable1;
    newObject->_chargeTable2=_chargeTable2;

//    newObject->profit=profit;

	/* BOOL flags */
	newObject->newRecord=newRecord;
	newObject->finalStatusReached=finalStatusReached;
	newObject->dirty=dirty;
    newObject->dirtyPurgeFlag=dirtyPurgeFlag;
    newObject->dirtyArchiveStatus=dirtyArchiveStatus;
	newObject->dirtyDoneFlag=dirtyDoneFlag;
	newObject->dirtyMessageStatus=dirtyMessageStatus;
	newObject->dirtyMessageAttempted=dirtyMessageAttempted;
	newObject->dirtyMessageDelivered=dirtyMessageDelivered;
	newObject->dirtyMessageFailed=dirtyMessageFailed;
	newObject->dirtyMessageError1=dirtyMessageError1;
	newObject->dirtyMessageError2=dirtyMessageError2;
	newObject->dirtyMessageWaitingSet=dirtyMessageWaitingSet;
	newObject->dirtyToImsi=dirtyToImsi;
	newObject->dirtyFromImsi=dirtyFromImsi;
	newObject->dirtyTo=dirtyTo;
	newObject->dirtyFrom=dirtyFrom;
	newObject->dirtyToMsc=dirtyToMsc;
	newObject->dirtyFromMsc=dirtyFromMsc;
	newObject->dirtyHlr=dirtyHlr;
	newObject->dirtyDeliveryReportStatus=dirtyDeliveryReportStatus;
	newObject->dirtyDeliveryReportAttempted=dirtyDeliveryReportAttempted;
	newObject->dirtyDeliveryReportDelivered=dirtyDeliveryReportDelivered;
	newObject->dirtyDeliveryReportFailed=dirtyDeliveryReportFailed;
	newObject->dirtyDeliveryReportError1=dirtyDeliveryReportError1;
	newObject->dirtyDeliveryReportError2=dirtyDeliveryReportError2;
	newObject->dirtyDeliveryReportWaitingSet=dirtyDeliveryReportWaitingSet;
	newObject->dirtyMessageAttempts=dirtyMessageAttempts;
	newObject->dirtyDeliveryReportAttempts=dirtyDeliveryReportAttempts;
	newObject->dirtyDeliveryReportImsi=dirtyDeliveryReportImsi;
	newObject->dirtyDeliveryReportMsc=dirtyDeliveryReportMsc;
    newObject->dirtyTT=dirtyTT;
    newObject->dirtyCosts=dirtyCosts;
    newObject->dirtyDlrText=dirtyDlrText;
    newObject->dirtyComment=dirtyComment;
    newObject->_dirtyVAS_ESME=_dirtyVAS_ESME;
    newObject->_dirtyVAS_IP=_dirtyVAS_IP;
    newObject->_dirtyDeferred=_dirtyDeferred;
    newObject->_dirtyExtensionData=_dirtyExtensionData;
    newObject->_dirtyUserFlags=_dirtyUserFlags;
    newObject->_dirtyExpiryTime=_dirtyExpiryTime;
    newObject->_dirtyMessageNextAttempt=_dirtyMessageNextAttempt;
    newObject->tt_sri=tt_sri;
    newObject->tt_fsm=tt_fsm;
    newObject->_dlrText=_dlrText;
    newObject->_comment=_comment;
    newObject->_vas_ip=_vas_ip;
    newObject->_vas_esme=_vas_esme;
    newObject->_deferredString=_deferredString;
    newObject->hlrOverride=hlrOverride;

	return newObject;
}

- (NSString *)countryOfTo
{
	return @"";
}

- (NSString *)operatorOfTo;
{
	return @"";
}

- (NSString *)deliveryMethodString
{
	switch (deliveryMethod)
	{
        case METHOD_MT:
            return @"mt";
        case METHOD_MO:
            return @"mo";
        case METHOD_HLR:
            return @"hlr";
        case METHOD_MT2:
            return @"mt2";
        case METHOD_MO2:
            return @"mo2";
        case METHOD_HLR2:
            return @"hlr2";
        case METHOD_AUX1:
            return @"aux1";
        case METHOD_AUX2:
            return @"aux2";
        case METHOD_AUX3:
            return @"aux3";
        case METHOD_AUX4:
            return @"aux4";
        case METHOD_ATI:
            return @"ati";
        case METHOD_SRI:
            return @"sri";
        case METHOD_PSI:
            return @"psi";
        case METHOD_PSL:
            return @"psl";
        case METHOD_SI:
            return @"si";
        case METHOD_SRILCS:
            return @"srilcs";
        case METHOD_SAI:
            return @"sai";
        case METHOD_ISS:
            return @"iss";
        case METHOD_SID:
            return @"sid";
        case METHOD_UL:
            return @"ul";
        case METHOD_UNDEF:
            return @"";
	}
	return @"";
}

- (void) setDeliveryMethodString:(NSString *)s
{
	if([s isEqual: @"mt"])
    {
		deliveryMethod=METHOD_MT;
    }
	else if([s isEqual: @"mo"])
    {
		deliveryMethod=METHOD_MO;
    }
	else if([s isEqual: @"hlr"])
    {
		deliveryMethod=METHOD_HLR;
    }
	else if([s isEqual: @"mt2"])
    {
		deliveryMethod=METHOD_MT2;
    }
	else if([s isEqual: @"mo2"])
    {
		deliveryMethod=METHOD_MO2;
    }
	else if([s isEqual: @"hlr2"])
    {
		deliveryMethod=METHOD_HLR2;
    }
	else if([s isEqual: @"aux1"])
    {
		deliveryMethod=METHOD_AUX1;
    }
	else if([s isEqual: @"aux2"])
    {
		deliveryMethod=METHOD_AUX2;
    }
	else if([s isEqual: @"aux3"])
    {
		deliveryMethod=METHOD_AUX3;
    }
	else if([s isEqual: @"aux4"])
    {
		deliveryMethod=METHOD_AUX4;
    }
	else if([s isEqual: @"ati"])
    {
		deliveryMethod=METHOD_ATI;
    }
	else if([s isEqual: @"sri"])
    {
		deliveryMethod=METHOD_SRI;
    }
	else if([s isEqual: @"psi"])
    {
		deliveryMethod=METHOD_PSI;
    }
	else if([s isEqual: @"psl"])
    {
		deliveryMethod=METHOD_PSL;
    }
	else
    {
		deliveryMethod=METHOD_UNDEF;
	}
}

- (NSInteger)userFlags
{
    return _userFlags;
}

- (void)setUserFlags:(NSInteger)i
{
    _userFlags = i;
    _dirtyUserFlags=YES;
    dirty = YES;
}


- (NSString *)extensionData
{
    return _extensionData;
}

- (void)setExtensionData:(NSString *)e
{
    _extensionData = e;
    _dirtyExtensionData=YES;
    dirty = YES;
    [self expandExtensionData];
}

- (NSString *)submissionTypeString
{
	switch(submissionType)
	{
        case SUBM_UDP:
            return @"udp";
		case SUBM_SS7_MO:
			return @"ss7-mo";
		case SUBM_SS7_MT_SINK:
			return @"ss7-mtsink";
		case SUBM_HTTP:
			return @"http";
		case SUBM_EMI:
			return @"emi";
		case SUBM_SMPP:
			return @"smpp";
		case SUBM_CIMD:
			return @"cimd";
		case SUBM_INTERNALLY:
			return @"internally";
		case SUBM_SIP_MO:
			return @"sip-mo";
		case SUBM_SIP_MT_SINK:
			return @"sip-mtsink";
		case SUBM_AUTOTEST:
			return @"autotest";
		case SUBM_UNKNOWN:
			return @"";
	}
	return @"";
}

- (void)setSubmissionTypeString:(NSString *)s
{
	if([s isEqual: @"udp"])
    {
		submissionType = SUBM_UDP;
    }
	if([s isEqual: @"ss7-mo"])
    {
		submissionType = SUBM_SS7_MO;
    }
	else if([s isEqual: @"ss7-mtsink"])
    {
		submissionType = SUBM_SS7_MT_SINK;
    }
	else if([s isEqual: @"http"])
    {
		submissionType = SUBM_HTTP;
    }
	else if([s isEqual: @"emi"])
    {
		submissionType = SUBM_EMI;
    }
	else if([s isEqual: @"smpp"])
    {
		submissionType = SUBM_SMPP;
    }
	else if([s isEqual: @"cimd"])
    {
		submissionType = SUBM_CIMD;
    }
	else if([s isEqual: @"internally"])
    {
		submissionType = SUBM_INTERNALLY;
    }
	else if([s isEqual: @"sip-mo"])
    {
		submissionType = SUBM_SIP_MO;
    }
	else if([s isEqual: @"sip-mtsink"])
    {
		submissionType = SUBM_SIP_MT_SINK;
    }
	else if([s isEqual: @"autotest"])
    {
		submissionType = SUBM_AUTOTEST;
    }
	else
    {
		submissionType = SUBM_UNKNOWN;
    }
}


+ (NSString *)statusString:(NSInteger)mstat
{
	switch(mstat)
	{
		case M_STATUS_NEW:
			return @"new";
		case M_STATUS_BUFFERED:
			return @"buffered";
		case M_STATUS_DELIVERED:
			return @"delivered";
		case M_STATUS_FAILED:
			return @"failed";
		case M_STATUS_IGNORED:
			return @"ignored";
		case M_STATUS_APIBUF:
			return @"apibuf";
		case M_STATUS_HLRSENT:
			return @"hlrsent";
		case M_STATUS_HLRRECEIVED:
			return @"hlrreceived";
        case M_STATUS_HLR2SENT:
            return @"hlr2sent";
        case M_STATUS_ATISENT:
            return @"atisent";
		case M_STATUS_ATIRECEIVED:
			return @"atireceived";
		case M_STATUS_MSGSENT:
			return @"msgsent";
        case M_STATUS_SRISENT:
            return @"srisent";
        case M_STATUS_SRIRECEIVED:
            return @"srireceived";
        case M_STATUS_PSISENT:
            return @"psisent";
        case M_STATUS_PSIRECEIVED:
            return @"psireceived";
        case M_STATUS_PSLSENT:
            return @"pslsent";
        case M_STATUS_PSLRECEIVED:
            return @"pslreceived";
        case M_STATUS_SISENT:
            return @"sisent";
        case M_STATUS_SIRECEIVED:
            return @"sireceived";
        case M_STATUS_MOAUTH_FAILED:
            return @"auth-failed";
        default:
			return @"";
	}
}

+ (int)statusCodeFromString:(NSString *)s
{
    int ms = M_STATUS_NOT_USED;
    
    if([s isEqual:@"new"])
    {
		ms = M_STATUS_NEW;
    }
	else if([s isEqual:@"buffered"])
    {
		ms = M_STATUS_BUFFERED;
    }
	else if([s isEqual:@"buffered"])
    {
		ms = M_STATUS_DELIVERED;
    }
	else if([s isEqual:@"failed"])
    {
		ms = M_STATUS_FAILED;
    }
	else if([s isEqual:@"ignored"])
    {
		ms = M_STATUS_IGNORED;
    }
	else if([s isEqual:@"apibuf"])
    {
		ms = M_STATUS_APIBUF;
    }
	else if([s isEqual:@"hlrsent"])
    {
		ms = M_STATUS_HLRSENT;
    }
	else if([s isEqual:@"hlrreceived"])
    {
		ms = M_STATUS_HLRRECEIVED;
    }
	else if([s isEqual:@"msgsent"])
    {
		ms = M_STATUS_MSGSENT;
    }
	else if([s isEqual:@"hlr2sent"])
    {
		ms = M_STATUS_HLR2SENT;
    }
	else if([s isEqual:@"atisent"])
    {
		ms = M_STATUS_ATISENT;
    }
	else if([s isEqual:@"atireceived"])
    {
		ms = M_STATUS_ATIRECEIVED;
    }
	else if([s isEqual:@"delivered"])
    {
		ms = M_STATUS_DELIVERED;
    }
    
    else if([s isEqual:@"srisent"])
    {
		ms = M_STATUS_SRISENT;
    }
    else if([s isEqual:@"srireceived"])
    {
		ms = M_STATUS_SRIRECEIVED;
    }
    
    else if([s isEqual:@"psisent"])
    {
		ms = M_STATUS_PSISENT;
    }
    else if([s isEqual:@"psireceived"])
    {
		ms = M_STATUS_PSIRECEIVED;
    }
    
    else if([s isEqual:@"pslsent"])
    {
		ms = M_STATUS_PSLSENT;
    }
    else if([s isEqual:@"pslreceived"])
    {
		ms = M_STATUS_PSLRECEIVED;
    }
    else if([s isEqual:@"sisent"])
    {
		ms = M_STATUS_SISENT;
    }
    else if([s isEqual:@"sireceived"])
    {
		ms = M_STATUS_SIRECEIVED;
    }
    else if([s isEqual:@"auth-failed"])
    {
        ms = M_STATUS_MOAUTH_FAILED;
    }
    return ms;
}

- (NSString *)messageStatusString
{
    return [UMMessage statusString:messageStatus];
}

- (void)setMessageStatusString:(NSString *)s
{
    messageStatus = [UMMessage statusCodeFromString:s];
}

- (NSString *)deliveryReportStatusString
{
	switch(deliveryReportStatus)
	{
		case M_STATUS_NEW:
			return @"new";
		case M_STATUS_BUFFERED:
			return @"buffered";
		case M_STATUS_DELIVERED:
			return @"delivered";
		case M_STATUS_FAILED:
			return @"failed";
		case M_STATUS_IGNORED:
			return @"ignored";
		case M_STATUS_APIBUF:
			return @"apibuf";
		case M_STATUS_HLRSENT:
			return @"hlrsent";
        case M_STATUS_HLR2SENT:
             return @"hlr2sent";
        case M_STATUS_ATISENT:
            return @"atisent";
		case M_STATUS_HLRRECEIVED:
			return @"hlrreceived";
		case M_STATUS_ATIRECEIVED:
			return @"atireceived";
		case M_STATUS_MSGSENT:
			return @"msgsent";
		case M_STATUS_NOT_USED:
			return @"";
	}
	return @"";
}


- (void)setDeliveryReportStatusString:(NSString *)s
{
	if([s isEqual:@"new"])
    {
		deliveryReportStatus = M_STATUS_NEW;
    }
	else if([s isEqual:@"buffered"])
    {
		deliveryReportStatus = M_STATUS_BUFFERED;
    }
	else if([s isEqual:@"buffered"])
    {
		deliveryReportStatus = M_STATUS_DELIVERED;
    }
	else if([s isEqual:@"failed"])
    {
		deliveryReportStatus = M_STATUS_FAILED;
    }
	else if([s isEqual:@"ignored"])
    {
		deliveryReportStatus = M_STATUS_IGNORED;
    }
	else if([s isEqual:@"apibuf"])
    {
		deliveryReportStatus = M_STATUS_APIBUF;
    }
	else if([s isEqual:@"hlrsent"])
    {
		deliveryReportStatus = M_STATUS_HLRSENT;
    }
	else if([s isEqual:@"hlrreceived"])
    {
		deliveryReportStatus = M_STATUS_HLRRECEIVED;
    }
	else if([s isEqual:@"msgsent"])
    {
		deliveryReportStatus = M_STATUS_MSGSENT;
    }
	else
    {
		deliveryReportStatus = M_STATUS_NOT_USED;
    }
}


- (NSInteger) messageStatus
{
	return messageStatus;
}

- (void) setMessageStatus:(NSInteger)status
{
    @synchronized(self)
	{
		if(messageStatus != status)
		{
			messageStatus = status;
			dirty = YES;
			dirtyMessageStatus = YES;
		}
	}
}

- (void) setTt_sri:(NSInteger)n
{
    @synchronized(self)
	{
		if(tt_sri != n)
		{
			tt_sri = n;
			dirty = YES;
			dirtyTT = YES;
		}
	}
}

- (void) setDlrText:(NSString *)t
{
    _dlrText = t;
    dirtyDlrText = YES;
}

- (NSString *)dlrText
{
    return _dlrText;
}

- (void) setComment:(NSString *)t
{
    _comment = t;
    dirtyComment = YES;
}

- (NSString *)comment
{
    return _comment;
}

- (void) setVas_ip:(NSString *)t
{
    if([t isEqualToString:@"(null))"])
    {
        t = NULL;
    }
    _vas_ip = t;
    _dirtyVAS_IP = YES;
}

- (NSString *)vas_ip
{
    return _vas_ip;
}

- (void) setDeferredString:(NSString *)s
{
    _deferredString = s;
    _dirtyDeferred = YES;
    dirty = YES;
}

- (NSString *)deferredString
{
    return _deferredString;
}

- (void) setVas_esme:(NSString *)t
{
    if([t isEqualToString:@"(null))"])
    {
        t = NULL;
    }
    _vas_esme = t;
    _dirtyVAS_ESME = YES;
}

- (NSString *)vas_esme
{
    return _vas_esme;
}

- (void) setTt_fsm:(NSInteger)n
{
    @synchronized(self)
	{
		if(tt_fsm != n)
		{
			tt_fsm = n;
			dirty = YES;
			dirtyTT = YES;
		}
	}
}

- (NSInteger)tt_sri
{
    return tt_sri;
}

- (NSInteger)tt_fsm
{
    return tt_fsm;
}

- (NSString *)messageAttempted
{
	return messageAttempted;
}

- (void) setMessageAttempted:(NSString *)dt
{
    @synchronized(self)
	{
		if(messageAttempted != dt)
		{
			if(![messageAttempted isEqual:dt])
			{
                if(dt.length > 26)
                {
                    dt = [dt substringToIndex:26]; /* 0000-00-00 00:00:00.000000 maximum length = 26*/
                }
                messageAttempted = dt;
				dirty = YES;
				dirtyMessageAttempted = YES;
			}
		}
	}
}

- (NSString *)messageDelivered
{
	return messageDelivered;
}

- (void) setMessageDelivered:(NSString *)dt
{
	@synchronized(self)
	{
		if(messageDelivered != dt)
		{
			if(![messageDelivered isEqual:dt])
			{
                if(dt.length > 26)
                {
                    dt = [dt substringToIndex:26]; /* 0000-00-00 00:00:00.000000 maximum length = 26*/
                }
				messageDelivered = dt;
				dirty = YES;
				dirtyMessageDelivered = YES;
			}
		}
	}
    
}

- (NSString *)messageFailed
{
	return messageFailed;
}

- (void) setMessageFailed:(NSString *)dt
{
	@synchronized(self)
	{
		if(messageFailed != dt)
		{
			if(![messageFailed isEqual:dt])
			{
                if(dt.length > 26)
                {
                    dt = [dt substringToIndex:26]; /* 0000-00-00 00:00:00.000000 maximum length = 26*/
                }
				messageFailed = dt;
				dirty = YES;
				dirtyMessageFailed = YES;
			}
		}
	}
    
}



- (NSInteger)messageError1
{
	return messageError1;
}

- (void) setMessageError1:(NSInteger)err
{
    gw_assert(err>=0);
//    NSAssert(err>=0,@"Message Error 1 must be positive");
	@synchronized(self)
	{
		if(messageError1 != err)
		{
			messageError1 = err;
			dirty = YES;
			dirtyMessageError1 = YES;
		}
	}
    
}

- (NSInteger)messageError2
{
	return messageError2;
}

- (void) setMessageError2:(NSInteger)err
{
	@synchronized(self)
	{
		if(messageError2 != err)
		{
			messageError2 = err;
			dirty = YES;
			dirtyMessageError2 = YES;
		}
	}
    
}

- (NSInteger)messageWaitingSet
{
	return messageWaitingSet;
}

- (void) setMessageWaitingSet:(NSInteger)mwi
{
	@synchronized(self)
	{
		if(messageWaitingSet != mwi)
		{
			messageWaitingSet = mwi;
			dirty = YES;
			dirtyMessageWaitingSet = YES;
		}
	}
    
}

- (NSString *)toImsi
{
	return toImsi;
}

- (void) setToImsi:(NSString *)imsi
{
	@synchronized(self)
	{
        if(imsi.length > MAXIMSILEN)
        {
            imsi = [imsi substringToIndex:MAXIMSILEN];
        }
		if(toImsi != imsi)
		{
			if(![toImsi isEqual:imsi])
			{
				toImsi = imsi;
				dirty = YES;
				dirtyToImsi = YES;
                
                if(toImsi.length > 0)
                {
                    NSString *code = [UMMessage imsiToOperatorCode:toImsi];
                    if(toOperatorCode != code)
                    {
                        if(![toOperatorCode isEqual:code])
                        {
                            toOperatorCode = code;
                            
                            dirty = YES;
                            dirtyToOperatorCode = YES;
                        }
                    }
                    NSString *name = [UMMessage operatorCodeToOperatorName:toOperatorCode];
                    if(toOperatorCode != name)
                    {
                        if(![toOperatorName isEqual:name])
                        {
                            toOperatorName = name;
                            dirty = YES;
                            dirtyToOperatorName = YES;
                        }
                    }
                }
            }
		}
	}
    
}

- (void) setFromImsi:(NSString *)imsi
{
	@synchronized(self)
	{
        if(imsi.length > MAXIMSILEN)
        {
            imsi = [imsi substringToIndex:MAXIMSILEN];
        }
		if(fromImsi != imsi)
		{
			if(![fromImsi isEqual:imsi])
			{
				fromImsi = imsi;
				dirty = YES;
				dirtyFromImsi = YES;
                
                NSString *code = [UMMessage imsiToOperatorCode:fromImsi];
                if(fromOperatorCode != code)
                {
                    if(![fromOperatorCode isEqual:code])
                    {
                        fromOperatorCode = code;
                        dirty = YES;
                        dirtyFromOperatorCode = YES;
                    }
                }
                NSString *name = [UMMessage operatorCodeToOperatorName:fromOperatorCode];
                if(fromOperatorName != name)
                {
                    if(![fromOperatorName isEqual:name])
                    {
                        fromOperatorName = name;
                        dirty = YES;
                        dirtyFromOperatorName = YES;
                    }
                }
			}
		}
	}
}

- (NSString *)fromImsi
{
	return fromImsi;
}


- (NSString *)toOperatorCode
{
    if(toOperatorCode == NULL)
    {
        return @"";
    }
    return toOperatorCode;
}


- (void) setToOperatorCode:(NSString *)code
{
	@synchronized(self)
	{
        if(toOperatorCode != code)
        {            
            if(![toOperatorCode isEqual:code])
            {
                toOperatorCode = code;
                
                dirty = YES;
                dirtyToOperatorCode = YES;
            }
        }
    }
    
}

- (NSString *)fromOperatorCode
{
    return fromOperatorCode;
}

- (void) setFromOperatorCode:(NSString *)code
{
	@synchronized(self)
	{
        if(fromOperatorCode != code)
        {            
            if(![fromOperatorCode isEqual:code])
            {
                fromOperatorCode = code;
                dirty = YES;
                dirtyFromOperatorCode = YES;
            }
        }
    }
    
}

- (NSString *)toOperatorName
{
    return toOperatorName;
}

- (void) setToOperatorName:(NSString *)name
{
	@synchronized(self)
	{
        if(toOperatorCode != name)
        {            
            if(![toOperatorName isEqual:name])
            {
                toOperatorName = name;
                dirty = YES;
                dirtyToOperatorName = YES;
            }
        }
    }
    
}

- (NSString *)fromOperatorName
{
    return fromOperatorName;
}

- (void) setFromOperatorName:(NSString *)name
{
	@synchronized(self)
	{
        if(fromOperatorName != name)
        {            
            if(![fromOperatorName isEqual:name])
            {
                fromOperatorName = name;
                dirty = YES;
                dirtyFromOperatorName = YES;
            }
        }
    }
    
}

- (NSString *)to;
{
	return to;
}

- (void) setTo:(NSString *)nto
{
	@synchronized(self)
	{
		if(to != nto)
		{
			if(![to isEqual:nto])
			{
				to = nto;
				dirty = YES;
				dirtyTo = YES;
                if([nto length] > 0)
                {
                    self.toCountry = countryCodeFromDigits(nto);
                }
			}
		}
	}
    
}

- (NSString *)from;
{
	return from;
}

- (void) setFrom:(NSString *)nfrom
{
	@synchronized(self)
	{
		if(from != nfrom)
		{
			if(![from isEqual:nfrom])
			{
				from = nfrom;
				dirty = YES;
				dirtyFrom = YES;
                self.fromCountry = countryCodeFromDigits(nfrom);
			}
		}
	}
    
}

- (NSString *)toMsc
{
	return toMsc;
}

- (void) setToMsc:(NSString *)msc
{
	@synchronized(self)
	{
        if(msc.length > MAXADDRLEN)
        {
            msc = [msc substringToIndex:MAXADDRLEN];
        }
        if(toMsc != msc)
		{
			if(![toMsc isEqual:msc])
			{
				toMsc = msc;
				dirty = YES;
				dirtyToMsc = YES;
			}
		}
	}
    
}

- (NSString *) fromMsc
{
	return fromMsc;
}

- (void) setFromMsc:(NSString *)msc
{
	@synchronized(self)
	{
        if(msc.length >MAXADDRLEN)
        {
            msc = [msc substringToIndex:MAXADDRLEN];
        }
        if(fromMsc != msc)
		{
			if(![fromMsc isEqual:msc])
			{
				fromMsc = msc;
				dirty = YES;
				dirtyFromMsc = YES;
			}
		}
	}
    
}

- (NSString *)hlr
{
	return hlr;
}

- (void) setHlr:(NSString *)hlr1
{
	@synchronized(self)
	{
        if(hlr1.length >MAXADDRLEN)
        {
            hlr1 = [hlr1 substringToIndex:MAXADDRLEN];
        }
		if(hlr != hlr1)
		{
			if(![hlr isEqual:hlr1])
			{
				hlr = hlr1;
				dirty = YES;
				dirtyHlr = YES;
			}
		}
	}
}

- (void) setHlrOverride:(NSString *)hlr1
{
    @synchronized(self)
    {
        if(hlr != hlr1)
        {
            if(![hlr isEqual:hlr1])
            {
                hlrOverride = hlr1;
                dirty = YES;
                dirtyHlr = YES;
            }
        }
    }
    
}

- (NSString *)hlrOverride
{
    return hlrOverride;
}


- (NSString *)smsc
{
    return smsc;
}

- (void) setSmsc:(NSString *)smsc1
{
	@synchronized(self)
	{
        if(smsc1.length >MAXADDRLEN)
        {
            smsc1 = [smsc1 substringToIndex:MAXADDRLEN];
        }
		if(smsc != smsc1)
		{
			if(![smsc isEqual:smsc1])
			{
				smsc = smsc1;
				dirty = YES;
				dirtySmsc = YES;
			}
		}
	}
    
}

- (NSString *)smsc2
{
    return smsc2;
}

- (void) setSmsc2:(NSString *)smsc1
{
	@synchronized(self)
	{
        if(smsc1.length >MAXADDRLEN)
        {
            smsc1 = [smsc1 substringToIndex:MAXADDRLEN];
        }
		if(smsc2 != smsc1)
		{
			if(![smsc2 isEqual:smsc1])
			{
				smsc2 = smsc1;
				dirty = YES;
				dirtySmsc2 = YES;
			}
		}
	}
    
}

- (NSString *)smsc3
{
    return smsc3;
}

- (void) setSmsc3:(NSString *)smsc1
{
    @synchronized(self)
    {
        if(smsc1.length >MAXADDRLEN)
        {
            smsc1 = [smsc1 substringToIndex:MAXADDRLEN];
        }
        if(smsc3 != smsc1)
		{
			if(![smsc3 isEqual:smsc1])
			{
				smsc3 = smsc1;
				dirty = YES;
				dirtySmsc3 = YES;
			}
		}
	}
}

- (NSString *)smsc4
{
    return smsc4;
}

- (void) setSmsc4:(NSString *)smsc1
{
	@synchronized(self)
	{
        if(smsc1.length >MAXADDRLEN)
        {
            smsc1 = [smsc1 substringToIndex:MAXADDRLEN];
        }
		if(smsc4 != smsc1)
		{
			if(![smsc4 isEqual:smsc1])
			{
				smsc4 = smsc1;
				dirty = YES;
				dirtySmsc4 = YES;
			}
		}
	}
    
}

- (NSString *)scts
{
    return scts;
}

- (void) setScts:(NSString *)s
{
	@synchronized(self)
	{
        if(s.length >MAXTIMESTAMPLEN)
        {
            s = [s substringToIndex:MAXTIMESTAMPLEN];
        }
		if(scts != s)
		{
			if(![scts isEqual:s])
			{
				scts = s;
				dirty = YES;
				dirtyScts = YES;
			}
		}
	}
    
}


- (NSInteger)scts_tz
{
    return scts_tz;
}

- (void) setScts_tz:(NSInteger)s
{
	@synchronized(self)
	{
		if(scts_tz != s)
		{
			scts_tz = s;
            dirty = YES;
            dirtySctsTz = YES;
		}
	}
    
}

- (NSInteger) deliveryReportStatus
{
	return deliveryReportStatus;
}

- (void) setDeliveryReportStatus:(NSInteger)status
{
	@synchronized(self)
	{
		if(deliveryReportStatus != status)
		{
			deliveryReportStatus = status;
			dirty = YES;
			dirtyDeliveryReportStatus = YES;
		}
	}
    
}

- (NSString *) deliveryReportAttempted
{
	return deliveryReportAttempted;
}

- (void) setDeliveryReportAttempted:(NSString *)dt
{
    if(dt.length >26)
    {
        NSLog(@"setDeliveryReportAttempted receives string with length > 26: %@",dt);
        NSLog(@"Backtrace: %@",UMBacktrace(NULL,0));
    }
	@synchronized(self)
	{
		if(deliveryReportAttempted != dt)
		{
			if(![deliveryReportAttempted isEqual:dt])
			{
                if(dt.length > 26)
                {
                    dt = [dt substringToIndex:26]; /* 0000-00-00 00:00:00.000000 maximum length = 26*/
                }
				deliveryReportAttempted = dt;
				dirty = YES;
				dirtyMessageAttempted = YES;
			}
		}
	}
    
}

- (NSString *) deliveryReportDelivered
{
	return deliveryReportDelivered;
}

- (void) setDeliveryReportDelivered:(NSString *)dt
{
	@synchronized(self)
	{
		if(deliveryReportDelivered != dt)
		{
			if(![deliveryReportDelivered isEqual:dt])
			{
                if(dt.length > 26)
                {
                    dt = [dt substringToIndex:26]; /* 0000-00-00 00:00:00.000000 maximum length = 26*/
                }
				deliveryReportDelivered = dt;
				dirty = YES;
				dirtyDeliveryReportDelivered = YES;
			}
		}
	}
    
}

- (NSString *) deliveryReportFailed
{
	return deliveryReportFailed;
}


- (void) setDeliveryReportFailed:(NSString *)dt
{
	@synchronized(self)
	{
		if(deliveryReportFailed != dt)
		{
			if(![deliveryReportFailed isEqual:dt])
			{
                if(dt.length > 26)
                {
                    dt = [dt substringToIndex:26]; /* 0000-00-00 00:00:00.000000 maximum length = 26*/
                }
				deliveryReportFailed = dt;
				dirty = YES;
				dirtyDeliveryReportFailed = YES;
			}
		}
	}
    
}



- (NSInteger) deliveryReportError1
{
	return deliveryReportError1;
}

- (void) setDeliveryReportError1:(NSInteger)err
{
	@synchronized(self)
	{
		if(deliveryReportError1 != err)
		{
			deliveryReportError1 = err;
			dirty = YES;
			dirtyDeliveryReportError1 = YES;
		}
	}
    
}

- (NSInteger) deliveryReportError2
{
	return deliveryReportError2;
}

- (void) setDeliveryReportError2:(NSInteger)err
{
	@synchronized(self)
	{
		if(deliveryReportError2 != err)
		{
			deliveryReportError2 = err;
			dirty = YES;
			dirtyDeliveryReportError2 = YES;
		}
	}
    
}

- (NSInteger) deliveryReportWaitingSet
{
	return deliveryReportWaitingSet;
}

- (void) setDeliveryReportWaitingSet:(NSInteger)mwi
{
	@synchronized(self)
	{
		if(deliveryReportWaitingSet != mwi)
		{
			deliveryReportWaitingSet = mwi;
			dirty = YES;
			dirtyDeliveryReportWaitingSet = YES;
		}
	}
    
}

- (void) increaseMessageAttempts
{
	@synchronized(self)
	{
		messageAttempts++;
		dirty = YES;
		dirtyMessageAttempts = YES;
	}
    
}

- (void) increaseSriAttempts
{
	@synchronized(self)
	{
		sriAttempts++;
//		dirty = YES;
//		dirtyMessageAttempts = YES;
	}
    
}
- (void) increaseDeliveryReportAttempts
{
	@synchronized(self)
	{
		deliveryReportAttempts++;
		dirty = YES;
		dirtyDeliveryReportAttempts = YES;
	}
    
}

- (NSString *)deliveryReportImsi
{
	return deliveryReportImsi;
}

- (void) setDeliveryReportImsi:(NSString *)imsi
{
	@synchronized(self)
	{
		if(deliveryReportImsi != imsi)
		{
			if(![deliveryReportImsi isEqual:imsi])
			{
				deliveryReportImsi = imsi;
				dirty = YES;
				dirtyDeliveryReportImsi = YES;
			}
		}
	}
    
	
}

- (NSString *) deliveryReportMsc
{
	return deliveryReportMsc;
}

- (void) setDeliveryReportMsc:(NSString *)msc
{
	@synchronized(self)
	{
		if(deliveryReportMsc != msc)
		{
			if(![deliveryReportMsc isEqual:msc])
			{
				deliveryReportMsc = msc;
				dirty = YES;
				dirtyDeliveryReportMsc = YES;
			}
		}
	}
    
}


- (NSInteger)purgeFlag
{
	return purgeFlag;
}

- (void) setPurgeFlag:(NSInteger)pf
{
	@synchronized(self)
	{
		if(purgeFlag != pf)
		{
            purgeFlag = pf;
            dirty = YES;
            dirtyPurgeFlag = YES;
		}
	}
    
}

- (NSInteger)archiveStatus
{
	return archiveStatus;
}

- (void) setArchiveStatus:(NSInteger)as
{
	@synchronized(self)
	{
		if(archiveStatus != as)
		{
            archiveStatus = as;
            dirty = YES;
            dirtyArchiveStatus = YES;
		}
	}
    
}

- (NSString *)tableName
{
    return UMDB_MESSAGE.tableName;
}

- (NSString *)archiveTableName
{
    return UMDB_MESSAGE_ARCHIVE.tableName;
}

- (NSString *)historyTableName
{
    return UMDB_MESSAGE_HISTORY.tableName;
}




/*
+ (NSString *)fieldNamesFromFieldsDefinition:(dbFieldDef *)fieldDef withQuoteChar:(char)quoteChar;
{
    return [UMDbQuery fieldNamesFromFieldsDefinition:[UMMessage tableDefinition] quoteChar:'`' tableName:NULL];
}
*/

+ (NSArray *)createSql:(NSString *) tn withDb:(UMDbDriverType)dbType
{
    return [UMDbQuery createSql:tn withDbType:dbType session:NULL fieldsDefinition:[UMMessage tableDefinition]];
}

+ (NSArray *)createArchiveSql:(NSString *) tn withDb:(UMDbDriverType)dbType
{
    return [UMDbQuery createArchiveSql:tn withDbType:dbType session:NULL fieldsDefinition:[UMMessage tableDefinition]];
}

+ (NSArray *)createHistorySql:(NSString *) tn withDb:(UMDbDriverType)dbType
{
    return [UMDbQuery createSql:tn withDbType:dbType session:NULL fieldsDefinition:[UMMessage tableDefinitionHistory]];
}

- (BOOL)insertToDatabase
{
    BOOL result = [self insertToDatabase:NO];
    return result;
}

- (BOOL)removeFromArchive
{
    UMDbQuery *query = [UMDbQuery queryForFile:__FILE__ line: __LINE__];
    if(![query isInCache])
    {
        [query setType:UMDBQUERYTYPE_DELETE];
        [query setTable:UMDB_MESSAGE_ARCHIVE];
        UMDbQueryCondition *condition =  [UMDbQueryCondition queryConditionLeft:[UMDbQueryPlaceholder placeholderField:@"archiveId"]
                                                                             op:UMDBQUERY_OPERATOR_EQUAL
                                                                          right:[UMDbQueryPlaceholder placeholderParameterIndex:0]];
        [query setWhereCondition:condition];
        [query addToCache];
    }    
    NSArray *params  = [NSArray arrayWithObject:STRING_NONEMPTY([self archiveId])];
    UMDbSession *session;
    session= [UMDB_MESSAGE_ARCHIVE.pool grabSession:FLF];
    BOOL result =  [session cachedQueryWithNoResult:query parameters:params  allowFail:YES];
    [session.pool returnSession:session file:FLF];
    return result;
}


- (BOOL)insertToDatabase:(BOOL)canFail
{
    if(_userFlags & USERFLAG_DONOT_STORE_IN_DB)
    {
        return YES;
    }
    BOOL result = NO;
    UMDbSession *session = [UMDB_MESSAGE.pool grabSession:FLF];
    UMDbSession *session2 = [UMDB_MESSAGE_HISTORY.pool grabSession:FLF];
    @try
    {
        result = [self insertToDatabase:canFail withSession:session withHistorySession:session2];
        _hasBeenInserted = YES;
    }
    @catch(NSException *e)
    {
        @throw(e);
    }
    @finally
    {
        [session.pool returnSession:session file:FLF];
        [session2.pool returnSession:session2 file:FLF];
    }
    return result;
}

- (BOOL)insertToDatabase:(BOOL)canFail withSession:(UMDbSession *)session withHistorySession:(UMDbSession *)session2
{
    if(_userFlags & USERFLAG_DONOT_STORE_IN_DB)
    {
        _hasBeenInserted = YES;
        return YES;
    }

    UMDbQuery *query = NULL;
    query = [UMDbQuery queryForFile:__FILE__ line: __LINE__];
    BOOL result;
    @try
    {
        if(![query isInCache])
        {
            NSArray *fields = [UMDbQuery fieldNamesArrayFromFieldsDefinition:[UMMessage tableDefinition]];
            [query setType:UMDBQUERYTYPE_INSERT_BY_KEY];
            [query setTable:UMDB_MESSAGE];
            [query setFields:fields];
            [query setPrimaryKeyName:@"archiveId"];
            [query addToCache];
        }

        NSArray *params  = [NSArray arrayWithObjects:
                            STRING_NONEMPTY([self archiveId]),
                            STRING_FROM_INT([self archiveStatus]),
                            STRING_NONEMPTY([self instanceName]),
                            STRING_NONEMPTY([self messageId]),
                            STRING_NONEMPTY([self userId]),
                            STRING_NONEMPTY([self groupId]),
                            STRING_NONEMPTY([self deliveryMethodString]),
                            STRING_NONEMPTY([self submissionTypeString]),
                            STRING_NONEMPTY([self from]),
                            STRING_NONEMPTY([self receivedFromIp]),
                            STRING_NONEMPTY([self submissionIp]),
                            STRING_NONEMPTY([self to]),
                            STRING_NONEMPTY([self deliveryReportMsc]),
                            STRING_NONEMPTY([self deliveryReportImsi]),
                            STRING_NONEMPTY([self fromMsc]),
                            STRING_NONEMPTY([self fromImsi]),
                            STRING_NONEMPTY([self toMsc]),
                            STRING_NONEMPTY([self toImsi]),
                            STRING_NONEMPTY([self smsc]),
                            STRING_NONEMPTY([self smsc2]),
                            STRING_NONEMPTY([self smsc3]),
                            STRING_NONEMPTY([self smsc4]),
                            STRING_NONEMPTY([self hlr]),
                            STRING_NONEMPTY([self created]),
                            STRING_NONEMPTY([self scts]),
                            STRING_FROM_INT([self scts_tz]),
                            STRING_FROM_INT([self qpriority]),
                            STRING_FROM_INT([self upriority]),
                            STRING_FROM_INT([self messagePriority]),
                            STRING_FROM_INT([self btype]),
                            STRING_NONEMPTY([self messageStatusString]),
                            STRING_FROM_INT([self messageError1]),
                            STRING_FROM_INT([self messageError2]),
                            STRING_NONEMPTY([self messageDelivered]),
                            STRING_NONEMPTY([self messageFailed]),
                            STRING_NONEMPTY([self messageAttempted]),
                            STRING_NONEMPTY([self messageExpiry]),
                            STRING_FROM_INT([self messageExpiryTz]),
                            STRING_NONEMPTY([self messageNextAttempt]),
                            STRING_FROM_INT([self messageAttempts]),
                            STRING_FROM_INT([self messageMaxAttempts]),
                            STRING_FROM_INT([self messageWaitingSet]),
                            STRING_FROM_NUMBER([self deliveryReportMask]),
                            STRING_NONEMPTY([self deliveryReportAddress]),
                            STRING_NONEMPTY([self deliveryReportStatusString]),
                            STRING_FROM_INT([self deliveryReportError1]),
                            STRING_FROM_INT([self deliveryReportError2]),
                            STRING_NONEMPTY([self deliveryReportDelivered]),
                            STRING_NONEMPTY([self deliveryReportFailed]),
                            STRING_NONEMPTY([self deliveryReportAttempted]),
                            STRING_NONEMPTY([self deliveryReportExpiry]),
                            STRING_NONEMPTY([self deliveryReportNextAttempt]),
                            STRING_FROM_INT([self deliveryReportAttempts]),
                            STRING_FROM_INT([self deliveryReportMaxAttempts]),
                            STRING_FROM_INT([self deliveryReportWaitingSet]),
                            STRING_FROM_INT([self msuCountSriSMTx]),
                            STRING_FROM_INT([self msuCountSriSMRx]),
                            STRING_FROM_INT([self msuCountSriSMHTx]),
                            STRING_FROM_INT([self msuCountSriSMHRx]),
                            STRING_FROM_INT([self msuCountSriSMCRx]),
                            STRING_FROM_INT([self msuCountFsmTx]),
                            STRING_FROM_INT([self msuCountFsmRx]),
                            STRING_FROM_INT([self msuCountTcapHandshakeTx]),
                            STRING_FROM_INT([self msuCountTcapHandshakeRx]),
                            STRING_FROM_INT([self testFlag]),
                            STRING_FROM_INT([self phoneRef]),
                            STRING_FROM_INT([self udhIndicator]),
                            STRING_NONEMPTY([self toCountry]),
                            STRING_NONEMPTY([self toOperatorCode]),
                            STRING_NONEMPTY([self toOperatorName]),
                            STRING_FROM_INT([self replyPath]),
                            STRING_FROM_INT([self pid]),
                            STRING_FROM_INT([self compress]),
                            STRING_FROM_INT([self dcs]),
                            STRING_FROM_INT([self mwi_pdu]),
                            STRING_FROM_DATA([self udh]),
                            STRING_FROM_DATA([self content]),
                            STRING_NONEMPTY([self plaintextContent32]),
                            STRING_FROM_INT([self messageClass]),
                            STRING_FROM_INT([self coding]),
                            STRING_NONEMPTY([self opc]),
                            STRING_NONEMPTY([self dpc]),
                            STRING_NONEMPTY([self opc2]),
                            STRING_NONEMPTY([self dpc2]),
                            STRING_FROM_INT([self tcapType]),
                            STRING_NONEMPTY([self extensionData]),
                            STRING_FROM_INT([self purgeFlag]),
                            STRING_NONEMPTY([self alertingAddress]),
                            STRING_NONEMPTY([self fromCountry]),
                            STRING_NONEMPTY([self fromOperatorCode]),
                            STRING_NONEMPTY([self fromOperatorName]),
                            STRING_NONEMPTY([self routeId]),
                            STRING_NONEMPTY([self subrouteId]),
                            STRING_NONEMPTY([self routedOnPrefix]),
                            STRING_FROM_INT([self autoRouted]),
                            STRING_FROM_INT([self userFlags]),
                            STRING_FROM_INT([self retryPatternTable]),
                            STRING_NONEMPTY([self interworkingTapCode ]),
                            STRING_NONEMPTY([self costTable ]),
                            STRING_FROM_DOUBLE([self msuCostTx]),
                            STRING_FROM_DOUBLE([self msuCostRx]),
                            STRING_FROM_DOUBLE([self smsCost]),
                            STRING_FROM_DOUBLE([self interworkingCost]),
                            STRING_FROM_DOUBLE([self totalCost]),
                            STRING_NONEMPTY([self chargeTable1 ]),
                            STRING_FROM_DOUBLE([self chargePrice1]),
                            STRING_FROM_DOUBLE([self profit1]),
                            STRING_NONEMPTY([self chargeTable2 ]),
                            STRING_FROM_DOUBLE([self chargePrice2]),
                            STRING_FROM_DOUBLE([self profit2]),
                            STRING_NONEMPTY([self destinationQuotaTableName]),
                            STRING_FROM_INT([self tt_sri]),
                            STRING_FROM_INT([self tt_fsm]),
                            STRING_NONEMPTY([self dlrText]),
                            STRING_NONEMPTY([self comment]),
                            STRING_NONEMPTY([self hlrOverride]),
                            STRING_NONEMPTY([self vas_esme]),
                            STRING_NONEMPTY([self vas_ip]),
                            STRING_NONEMPTY([self deferredString]),
                            @"0", /* exported */
                            NULL];
        result =  [session cachedQueryWithNoResult:query parameters:params  allowFail:canFail primaryKeyValue:self.archiveId];
    }
    @catch (NSException *e)
    {
        NSLog(@"Exception: %@",e);
        @throw(e);
    }
    BOOL result2 = YES;
    _hasBeenInserted = YES;

    /*** INSERTING INTO HISTORY ***/
    if(_messageHistory !=NULL)
    {
        query = [UMDbQuery queryForFile:__FILE__ line: __LINE__];
        if(session2.pool.dbDriverType == UMDBDRIVER_REDIS)
        {
            /* for now we only save history if its redis */
            NSArray *fields = [UMDbQuery fieldNamesArrayFromFieldsDefinition:[UMMessage tableDefinitionHistory]];
            [query setType:UMDBQUERYTYPE_INSERT_BY_KEY];
            [query setTable:UMDB_MESSAGE_HISTORY];
            [query setFields:fields];
            [query setPrimaryKeyName:@"archiveId"];
            NSArray *params  = [NSArray arrayWithObjects:
                                 STRING_NONEMPTY([self archiveId]),
                                 STRING_NONEMPTY([self instanceName]),
                                 STRING_NONEMPTY([self messageId]),
                                 STRING_NONEMPTY([self to]),
                                 STRING_NONEMPTY([_messageHistory stringLines]),
                                 NULL];

            result2 =  [session2 cachedQueryWithNoResult:query parameters:params  allowFail:canFail primaryKeyValue:self.archiveId];
            _historyHasBeenInserted = YES;
        }
    }
    return result | result2;
}


- (BOOL)archiveToDatabaseCallback:(BOOL)canFail withSession:(UMDbSession *)session
{
    if(license_verify_feature(LICENSE_FEATURE_IGNORE_NOLOGGING_TLV)!=LICENSE_STATUS_OK)
    {
        if(self.traceLevel & TRACELEVEL_DO_NOT_LOG)
        {
            return YES;
        }
    }
    UMDbQuery *query = NULL;
    query = [UMDbQuery queryForFile:__FILE__ line: __LINE__];
    if(![query isInCache])
    {
        NSArray *fields = [UMDbQuery fieldNamesArrayFromFieldsDefinition:[UMMessage tableDefinition]];
        [query setType:UMDBQUERYTYPE_INSERT];
        [query setTable:UMDB_MESSAGE_ARCHIVE];
        [query setFields:fields];
        [query addToCache];
    }

    NSArray *params  = [NSArray arrayWithObjects:
                        STRING_NONEMPTY([self archiveId]),
                        STRING_FROM_INT([self archiveStatus]),
                        STRING_NONEMPTY([self instanceName]),
                        STRING_NONEMPTY([self messageId]),
                        STRING_NONEMPTY([self userId]),
                        STRING_NONEMPTY([self groupId]),
                        STRING_NONEMPTY([self deliveryMethodString]),
                        STRING_NONEMPTY([self submissionTypeString]),
                        STRING_NONEMPTY([self from]),
                        STRING_NONEMPTY([self receivedFromIp]),
                        STRING_NONEMPTY([self submissionIp]),
                        STRING_NONEMPTY([self to]),
                        STRING_NONEMPTY([self deliveryReportMsc]),
                        STRING_NONEMPTY([self deliveryReportImsi]),
                        STRING_NONEMPTY([self fromMsc]),
                        STRING_NONEMPTY([self fromImsi]),
                        STRING_NONEMPTY([self toMsc]),
                        STRING_NONEMPTY([self toImsi]),
                        STRING_NONEMPTY([self smsc]),
                        STRING_NONEMPTY([self smsc2]),
                        STRING_NONEMPTY([self smsc3]),
                        STRING_NONEMPTY([self smsc4]),
                        STRING_NONEMPTY([self hlr]),
                        STRING_NONEMPTY([self created]),
                        STRING_NONEMPTY([self scts]),
                        STRING_FROM_INT([self scts_tz]),
                        STRING_FROM_INT([self qpriority]),
                        STRING_FROM_INT([self upriority]),
                        STRING_FROM_INT([self messagePriority]),
                        STRING_FROM_INT([self btype]),
                        STRING_NONEMPTY([self messageStatusString]),
                        STRING_FROM_INT([self messageError1]),
                        STRING_FROM_INT([self messageError2]),
                        STRING_NONEMPTY([self messageDelivered]),
                        STRING_NONEMPTY([self messageFailed]),
                        STRING_NONEMPTY([self messageAttempted]),
                        STRING_NONEMPTY([self messageExpiry]),
                        STRING_FROM_INT([self messageExpiryTz]),
                        STRING_NONEMPTY([self messageNextAttempt]),
                        STRING_FROM_INT([self messageAttempts]),
                        STRING_FROM_INT([self messageMaxAttempts]),
                        STRING_FROM_INT([self messageWaitingSet]),
                        STRING_FROM_NUMBER([self deliveryReportMask]),
                        STRING_NONEMPTY([self deliveryReportAddress]),
                        STRING_NONEMPTY([self deliveryReportStatusString]),
                        STRING_FROM_INT([self deliveryReportError1]),
                        STRING_FROM_INT([self deliveryReportError2]),
                        STRING_NONEMPTY([self deliveryReportDelivered]),
                        STRING_NONEMPTY([self deliveryReportFailed]),
                        STRING_NONEMPTY([self deliveryReportAttempted]),
                        STRING_NONEMPTY([self deliveryReportExpiry]),
                        STRING_NONEMPTY([self deliveryReportNextAttempt]),
                        STRING_FROM_INT([self deliveryReportAttempts]),
                        STRING_FROM_INT([self deliveryReportMaxAttempts]),
                        STRING_FROM_INT([self deliveryReportWaitingSet]),
                        STRING_FROM_INT([self msuCountSriSMTx]),
                        STRING_FROM_INT([self msuCountSriSMRx]),
                        STRING_FROM_INT([self msuCountSriSMHTx]),
                        STRING_FROM_INT([self msuCountSriSMHRx]),
                        STRING_FROM_INT([self msuCountSriSMCRx]),
                        STRING_FROM_INT([self msuCountFsmTx]),
                        STRING_FROM_INT([self msuCountFsmRx]),
                        STRING_FROM_INT([self msuCountTcapHandshakeTx]),
                        STRING_FROM_INT([self msuCountTcapHandshakeRx]),
                        STRING_FROM_INT([self testFlag]),
                        STRING_FROM_INT([self phoneRef]),
                        STRING_FROM_INT([self udhIndicator]),
                        STRING_NONEMPTY([self toCountry]),
                        STRING_NONEMPTY([self toOperatorCode]),
                        STRING_NONEMPTY([self toOperatorName]),
                        STRING_FROM_INT([self replyPath]),
                        STRING_FROM_INT([self pid]),
                        STRING_FROM_INT([self compress]),
                        STRING_FROM_INT([self dcs]),
                        STRING_FROM_INT([self mwi_pdu]),
                        STRING_FROM_DATA([self udh]),
                        STRING_FROM_DATA([self content]),
                        STRING_NONEMPTY([self plaintextContent32]),
                        STRING_FROM_INT([self messageClass]),
                        STRING_FROM_INT([self coding]),
                        STRING_NONEMPTY([self opc]),
                        STRING_NONEMPTY([self dpc]),
                        STRING_NONEMPTY([self opc2]),
                        STRING_NONEMPTY([self dpc2]),
                        STRING_FROM_INT([self tcapType]),
                        STRING_NONEMPTY([self extensionData]),
                        STRING_FROM_INT([self purgeFlag]),
                        STRING_NONEMPTY([self alertingAddress]),
                        STRING_NONEMPTY([self fromCountry]),
                        STRING_NONEMPTY([self fromOperatorCode]),
                        STRING_NONEMPTY([self fromOperatorName]),
                        STRING_NONEMPTY([self routeId]),
                        STRING_NONEMPTY([self subrouteId]),
                        STRING_NONEMPTY([self routedOnPrefix]),
                        STRING_FROM_INT([self autoRouted]),
                        STRING_FROM_INT([self userFlags]),
                        STRING_FROM_INT([self retryPatternTable]),
                        STRING_NONEMPTY([self interworkingTapCode ]),
                        STRING_NONEMPTY([self costTable ]),
                        STRING_FROM_DOUBLE([self msuCostTx]),
                        STRING_FROM_DOUBLE([self msuCostRx]),
                        STRING_FROM_DOUBLE([self smsCost]),
                        STRING_FROM_DOUBLE([self interworkingCost]),
                        STRING_FROM_DOUBLE([self totalCost]),
                        STRING_NONEMPTY([self chargeTable1 ]),
                        STRING_FROM_DOUBLE([self chargePrice1]),
                        STRING_FROM_DOUBLE([self profit1]),
                        STRING_NONEMPTY([self chargeTable2 ]),
                        STRING_FROM_DOUBLE([self chargePrice2]),
                        STRING_FROM_DOUBLE([self profit2]),
                        STRING_NONEMPTY([self destinationQuotaTableName]),
                        STRING_FROM_INT([self tt_sri]),
                        STRING_FROM_INT([self tt_fsm]),
                        STRING_NONEMPTY([self dlrText]),
                        STRING_NONEMPTY([self comment]),
                        STRING_NONEMPTY([self hlrOverride]),
                        STRING_NONEMPTY([self vas_esme]),
                        STRING_NONEMPTY([self vas_ip]),
                        STRING_NONEMPTY([self deferredString]),
                        @"0", /* exported */
                        NULL];
    BOOL result =  [session cachedQueryWithNoResult:query parameters:params  allowFail:canFail ];
    return result;
}


-(void)updateFields:(NSArray **)f values:(NSArray **)v
{
	NSMutableArray *fields = [[NSMutableArray alloc]init];
	NSMutableArray *values = [[NSMutableArray alloc]init];
	
   
    *f = fields;
    *v = values;
    
	if(!dirty)
    {
		return;
    }
	
    if(dirtyPurgeFlag)
    {
        [fields addObject:@"purgeFlag"];
		[values addObject:[NSString stringWithFormat:@"%d",(int)[self purgeFlag]]];
    }
    if(dirtyArchiveStatus)
    {
		[fields addObject:@"archiveStatus"];
		[values addObject:[NSString stringWithFormat:@"%d",(int)[self archiveStatus]]];
    }
    
	if(dirtyMessageStatus)
	{
		[fields addObject:@"messageStatus"];
		[values addObject:[NSString stringWithFormat:@"%@",[self messageStatusString]]];
	}
	
	if(dirtyMessageDelivered)
	{
		[fields addObject:@"messageDelivered"];
		[values addObject:[NSString stringWithFormat:@"%@",[messageDelivered sqlEscaped]]];
	}
	
	if(dirtyMessageFailed)
	{
		[fields addObject:@"messageFailed"];
		[values addObject:[NSString stringWithFormat:@"%@",[messageFailed sqlEscaped]]];
	}
	
	if(dirtyMessageAttempted)
	{
		[fields addObject:@"messageAttempted"];
		[values addObject:[NSString stringWithFormat:@"%@",[messageAttempted sqlEscaped]]];
	}
	
	if(dirtyMessageError1)
	{
		[fields addObject:@"messageError1"];
		[values addObject:[NSString stringWithFormat:@"%d",(int)messageError1]];
	}
	
	if(dirtyMessageError2)
	{
		[fields addObject:@"messageError2"];
		[values addObject:[NSString stringWithFormat:@"%d",(int)messageError2]];
	}
    
	if(dirtyMessageAttempts)
	{
		[fields addObject:@"messageAttempts"];
		[values addObject:[NSString stringWithFormat:@"%d",(int)messageAttempts]];
	}
    
	if(dirtyMessageWaitingSet)
	{
		[fields addObject:@"messageWaitingSet"];
		[values addObject:[NSString stringWithFormat:@"%d",(int)messageWaitingSet]];
	}
	
	if(dirtyToImsi)
	{
		[fields addObject:@"toImsi"];
		[values addObject:[NSString stringWithFormat:@"%@",[toImsi sqlEscaped]]];
	}
    
    if(dirtyFromImsi)
	{
		[fields addObject:@"fromImsi"];
		[values addObject:[NSString stringWithFormat:@"%@",[fromImsi sqlEscaped]]];
	}
    
	if(dirtyToOperatorCode)
	{
		[fields addObject:@"toOperatorCode"];
		[values addObject:[NSString stringWithFormat:@"%@",[toOperatorCode sqlEscaped]]];
	}
    
    if(dirtyFromOperatorCode)
	{
		[fields addObject:@"fromOperatorCode"];
		[values addObject:[NSString stringWithFormat:@"%@",[fromOperatorCode sqlEscaped]]];
	}
    
    
    if(dirtyToOperatorName)
	{
		[fields addObject:@"toOperatorName"];
		[values addObject:[NSString stringWithFormat:@"%@",[toOperatorName sqlEscaped]]];
	}
    
	
    if(dirtyFromOperatorName)
	{
		[fields addObject:@"fromOperatorName"];
		[values addObject:[NSString stringWithFormat:@"%@",[fromOperatorName sqlEscaped]]];
	}
    
	if(dirtyToMsc)
	{
		[fields addObject:@"toMsc"];
		[values addObject:[NSString stringWithFormat:@"%@",[toMsc sqlEscaped]]];
	}
	
	if(dirtyFromMsc)
	{
		[fields addObject:@"fromMsc"];
		[values addObject:[NSString stringWithFormat:@"%@",[fromMsc sqlEscaped]]];
	}
    
    if(dirtyTo)
	{
		[fields addObject:@"toNumber"];
		[values addObject:[NSString stringWithFormat:@"%@",[to sqlEscaped]]];
	}
	
	if(dirtyFrom)
	{
		[fields addObject:@"fromNumber"];
		[values addObject:[NSString stringWithFormat:@"%@",[from sqlEscaped]]];
	}
    
	if(dirtyHlr)
	{
		[fields addObject:@"hlr"];
		[values addObject:[NSString stringWithFormat:@"%@",[hlr sqlEscaped]]];
        [fields addObject:@"hlr_override"];
        [values addObject:[NSString stringWithFormat:@"%@",[hlrOverride sqlEscaped]]];
	}
    
    if(dirtySmsc)
	{
		[fields addObject:@"smsc"];
		[values addObject:[NSString stringWithFormat:@"%@",[smsc sqlEscaped]]];
	}
    if(dirtySmsc2)
	{
		[fields addObject:@"smsc2"];
		[values addObject:[NSString stringWithFormat:@"%@",[smsc2 sqlEscaped]]];
	}
    if(dirtySmsc3)
	{
		[fields addObject:@"smsc3"];
		[values addObject:[NSString stringWithFormat:@"%@",[smsc3 sqlEscaped]]];
	}
    if(dirtySmsc4)
	{
		[fields addObject:@"smsc4"];
		[values addObject:[NSString stringWithFormat:@"%@",[smsc4 sqlEscaped]]];
	}
    if(dirtyScts)
	{
		[fields addObject:@"scts"];
		[values addObject:[NSString stringWithFormat:@"%@",[scts sqlEscaped]]];
	}
    
    if(dirtySctsTz)
	{
		[fields addObject:@"scts_tz"];
		[values addObject:[NSString stringWithFormat:@"%d",(int)scts_tz]];
	}
	if(dirtyDeliveryReportStatus)
	{
		[fields addObject:@"deliveryReportStatus"];
		[values addObject:[NSString stringWithFormat:@"%@",[self deliveryReportStatusString]]];
	}
	
	if(dirtyDeliveryReportDelivered)
	{
		[fields addObject:@"deliveryReportDelivered"];
		[values addObject:[NSString stringWithFormat:@"%@",[deliveryReportDelivered sqlEscaped]]];
	}
	
	if(dirtyDeliveryReportFailed)
	{
		[fields addObject:@"deliveryReportFailed"];
		[values addObject:[NSString stringWithFormat:@"%@",[deliveryReportFailed sqlEscaped]]];
	}
	
	if(dirtyDeliveryReportAttempted)
	{
		[fields addObject:@"deliveryReporteAttempted"];
		[values addObject:[NSString stringWithFormat:@"%@",[deliveryReportAttempted sqlEscaped]]];
	}
	
	if(dirtyDeliveryReportError1)
	{
		[fields addObject:@"deliveryReportError1"];
		[values addObject:[NSString stringWithFormat:@"%d",(int)deliveryReportError1]];
	}
	
	if(dirtyDeliveryReportError2)
	{
		[fields addObject:@"deliveryReportError2"];
		[values addObject:[NSString stringWithFormat:@"%d",(int)deliveryReportError2]];
	}
    
	if(dirtyDeliveryReportAttempts)
	{
		[fields addObject:@"deliveryReportAttempts"];
		[values addObject:[NSString stringWithFormat:@"%d",(int)deliveryReportAttempts]];
	}
	
	if(dirtyDeliveryReportWaitingSet)
	{
		[fields addObject:@"deliveryReportWaitingSet"];
		[values addObject:[NSString stringWithFormat:@"%d",(int)deliveryReportWaitingSet]];
	}
	
    
	if(dirtyDeliveryReportMsc)
	{
		[fields addObject:@"deliveryReportMsc"];
		[values addObject:[NSString stringWithFormat:@"%@",[deliveryReportMsc sqlEscaped]]];
	}
    
	if(dirtyDeliveryReportImsi)
	{
		[fields addObject:@"deliveryReportImsi"];
		[values addObject:[NSString stringWithFormat:@"%@",[deliveryReportImsi sqlEscaped]]];
	}
	
    if(dirtyMsuCountSriSMTx)
    {
		[fields addObject:@"msuCountSriSMTx"];
		[values addObject:[NSString stringWithFormat:@"%d",(int)_msuCountSriSMTx]];
    }
    
    if(dirtyMsuCountSriSMRx)
    {
		[fields addObject:@"msuCountSriSMRx"];
		[values addObject:[NSString stringWithFormat:@"%d",(int)_msuCountSriSMRx]];
    }
    
    if(dirtyMsuCountSriSMHTx)
    {
		[fields addObject:@"msuCountSriSMHTx"];
		[values addObject:[NSString stringWithFormat:@"%d",(int)_msuCountSriSMHTx]];
    }
    
    if(dirtyMsuCountSriSMHRx)
    {
		[fields addObject:@"msuCountSriSMHRx"];
		[values addObject:[NSString stringWithFormat:@"%d",(int)_msuCountSriSMHRx]];
    }
    
    if(dirtyMsuCountSriSMCRx)
    {
		[fields addObject:@"msuCountSriSMCRx"];
		[values addObject:[NSString stringWithFormat:@"%d",(int)_msuCountSriSMCRx]];
    }
    
    if(dirtyMsuCountFsmTx)
    {
		[fields addObject:@"msuCountFsmTx"];
		[values addObject:[NSString stringWithFormat:@"%d",(int)_msuCountFsmTx]];
    }
    
    if(dirtyMsuCountFsmRx)
    {
		[fields addObject:@"msuCountFsmRx"];
		[values addObject:[NSString stringWithFormat:@"%d",(int)_msuCountFsmRx]];
    }
    
    if(dirtyMsuCountTcapHandshakeTx)
    {
		[fields addObject:@"msuCountTcapHandshakeTx"];
		[values addObject:[NSString stringWithFormat:@"%d",(int)_msuCountTcapHandshakeTx]];
    }
    
    if(dirtyMsuCountTcapHandshakeRx)
    {
		[fields addObject:@"msuCountTcapHandshakeRx"];
		[values addObject:[NSString stringWithFormat:@"%d",(int)_msuCountTcapHandshakeRx]];
    }

    if(dirtyCosts)
    {
		[fields addObject:@"costTable"];
		[values addObject:[NSString stringWithFormat:@"%@",[_costTable sqlEscaped]]];
		[fields addObject:@"msuCostTx"];
		[values addObject:[NSString stringWithFormat:@"%lf",[self msuCostTx]]];
		[fields addObject:@"msuCostRx"];
		[values addObject:[NSString stringWithFormat:@"%lf",[self msuCostRx]]];
		[fields addObject:@"smsCost"];
		[values addObject:[NSString stringWithFormat:@"%lf",[self smsCost]]];
		[fields addObject:@"interworkingCost"];
		[values addObject:[NSString stringWithFormat:@"%lf",[self interworkingCost]]];
		[fields addObject:@"totalCost"];
		[values addObject:[NSString stringWithFormat:@"%lf",[self totalCost]]];
        [fields addObject:@"chargeTable1"];
		[values addObject:[NSString stringWithFormat:@"%@",[_chargeTable1 sqlEscaped]]];
		[fields addObject:@"chargePrice1"];
		[values addObject:[NSString stringWithFormat:@"%lf",[self chargePrice1]]];
		[fields addObject:@"profit1"];
		[values addObject:[NSString stringWithFormat:@"%lf",[self profit1]]];
        [fields addObject:@"chargeTable2"];
		[values addObject:[NSString stringWithFormat:@"%@",[_chargeTable2 sqlEscaped]]];
		[fields addObject:@"chargePrice2"];
		[values addObject:[NSString stringWithFormat:@"%lf",[self chargePrice2]]];
		[fields addObject:@"profit2"];
		[values addObject:[NSString stringWithFormat:@"%lf",[self profit2]]];
    }
    if(dirtyTT)
    {
		[fields addObject:@"tt_sri"];
		[values addObject:[NSString stringWithFormat:@"%d",(int)tt_sri]];
		[fields addObject:@"tt_fsm"];
		[values addObject:[NSString stringWithFormat:@"%d",(int)tt_fsm]];
    }
    if(dirtyDlrText)
    {
        [fields addObject:@"dlr_text"];
        [values addObject:[NSString stringWithFormat:@"%@",[self.dlrText sqlEscaped]]];
    }
    if(dirtyComment)
    {
        [fields addObject:@"comment"];
        [values addObject:[NSString stringWithFormat:@"%@",[self.comment sqlEscaped]]];
    }
    if(_dirtyExtensionData)
    {
        [fields addObject:@"extensionData"];
        [values addObject:[NSString stringWithFormat:@"%@",[self.extensionData sqlEscaped]]];
    }
    if(_dirtyUserFlags)
    {
        [fields addObject:@"userFlags"];
        [values addObject:[NSString stringWithFormat:@"%ld",[self userFlags]]];
    }
    if(_dirtyExpiryTime)
    {
        [fields addObject:@"messageExpiry"];
        [values addObject:[NSString stringWithFormat:@"%@",[[self messageExpiry] sqlEscaped]]];
    }
    if(_dirtyDeferred)
    {
        [fields addObject:@"deferred"];
        [values addObject:[NSString stringWithFormat:@"%@",[[self deferredString] sqlEscaped]]];
    }
    if(_dirtyMessageNextAttempt)
    {
        [fields addObject:@"messageNextAttempt"];
        [values addObject:[NSString stringWithFormat:@"%@",[[self messageNextAttempt] sqlEscaped]]];
    }
    if(_dirtyVAS_ESME)
    {
        [fields addObject:@"vas_esme"];
        [values addObject:[NSString stringWithFormat:@"%@",[[self vas_esme] sqlEscaped]]];
    }
    if(_dirtyVAS_IP)
    {
        [fields addObject:@"vas_ip"];
        [values addObject:[NSString stringWithFormat:@"%@",[self.vas_ip sqlEscaped]]];
    }
}


- (void)clearDirtyStatus
{
	dirty = NO;
	dirtyArchiveStatus = NO;
	dirtyPurgeFlag = NO;
	dirtyDoneFlag = NO;
	dirtyMessageStatus = NO;
    dirtyTo = NO;
    dirtyFrom = NO;
	dirtyMessageAttempted = NO;
	dirtyMessageDelivered = NO;
	dirtyMessageFailed = NO;
	dirtyMessageError1 = NO;
	dirtyMessageError2 = NO;
	dirtyMessageWaitingSet = NO;
	dirtyToImsi = NO;
	dirtyFromImsi = NO;
	dirtyToMsc = NO;
	dirtyFromMsc = NO;
	dirtyHlr = NO;
    dirtySmsc=NO;
	dirtySmsc2=NO;
	dirtySmsc3=NO;
	dirtySmsc4=NO;
	dirtyScts=NO;
    dirtySctsTz=NO;
	dirtyDeliveryReportStatus = NO;
	dirtyDeliveryReportAttempted = NO;
	dirtyDeliveryReportDelivered = NO;
	dirtyDeliveryReportFailed = NO;
	dirtyDeliveryReportError1 = NO;
	dirtyDeliveryReportError2 = NO;
	dirtyDeliveryReportWaitingSet = NO;
	dirtyMessageAttempts = NO;
	dirtyDeliveryReportAttempts = NO;
	dirtyDeliveryReportImsi = NO;
	dirtyDeliveryReportMsc = NO;
    dirtyFromOperatorCode = NO;
    dirtyFromOperatorName = NO;
    dirtyToOperatorCode = NO;
    dirtyToOperatorName = NO;
    dirtyCosts = NO;
    dirtyTT = NO;
    dirtyDlrText = NO;
    dirtyComment = NO;
    _dirtyExtensionData = NO;
    _dirtyUserFlags = NO;
    _dirtyDeferred = NO;
    _dirtyExpiryTime = NO;
    _dirtyMessageNextAttempt = NO;
    _dirtyVAS_IP = NO;
    _dirtyVAS_ESME = NO;
}


- (void) updateDB:(BOOL)forced
{
    if(forced)
    {
        msg_immediate_udpate(self);
    }
    else
    {
        msg_delayed_udpate(self);
    }
}


- (void)updateDBCallback:(UMDbSession *)session1 historySession:(UMDbSession *)session2
{
    [self updateDBCallbackMessage:session1];
    if(_messageHistory != NULL)
    {
        [self updateDBCallbackHistory:session2];
    }
}

- (void)updateDBCallbackMessage:(UMDbSession *)session
{
    @autoreleasepool
    {
        UMAssert(session != NULL,@"ouch, no session");
        NSMutableArray *fields = NULL;
        NSMutableArray *params = NULL;
        [self updateFields:&fields values:&params];
        if(fields.count > 0)
        {
            UMAssert(fields.count == params.count,@"number of fields does not match number of parameters");
            UMDbQuery *query = [UMDbQuery queryForFile:__FILE__ line: __LINE__];
            [query setType:UMDBQUERYTYPE_UPDATE_BY_KEY];
            [query setTable:UMDB_MESSAGE];
            [query setFields:fields];
            [query setPrimaryKeyName:@"archiveId"];
            unsigned long long rows;
            [session cachedQueryWithNoResult:query parameters:params  allowFail:NO primaryKeyValue:self.archiveId affectedRows:&rows];
        }
    }
}


- (void)setExpiry
{
    UMDbTable *dbt = UMDB_MESSAGE;
    UMDbPool *pool = dbt.pool;
    if(pool.dbDriverType!=UMDBDRIVER_REDIS)
    {
        return;
    }

    time_t created_t = UMTimeFromTimestampDT(self.created);
    time_t now;
    time(&now);
    time_t  expiry_time = created_t + global_keep_absolute_delay;
    if(purgeFlag)
    {
        expiry_time = now + global_keep_data_delay;
    }
    time_t remaining_time = expiry_time - now;
    UMDbSession *session = [pool grabSession:FLF];
    UMDbQuery *query = [UMDbQuery queryForFile:__FILE__ line: __LINE__];
    [query setType:UMDBQUERYTYPE_EXPIRE_KEY];
    [query setTable:UMDB_MESSAGE];
    [query setPrimaryKeyName:@"archiveId"];
    NSNumber *exp = [NSNumber numberWithInteger:remaining_time];
    [session cachedQueryWithNoResult:query parameters:@[exp]  allowFail:NO primaryKeyValue:self.archiveId];
    [session.pool returnSession:session file:FLF];
}

- (void)updateDBCallbackHistory:(UMDbSession *)session
{
    @autoreleasepool
    {
        if(_messageHistory == NULL)
        {
            return;
        }
        if(!(_userFlags & USERFLAG_ENABLE_HISTORY))
        {
            return;
        }
        @try
        {
            UMDbQuery *query = NULL;
            /* for now we only save history if its redis */
            NSArray *fields = [UMDbQuery fieldNamesArrayFromFieldsDefinition:[UMMessage tableDefinitionHistory]];
            if(self.historyHasBeenInserted==NO)
            {
                query = [UMDbQuery queryForFile:__FILE__ line: __LINE__];
                if(![query isInCache])
                {
                    [query setType:UMDBQUERYTYPE_INSERT_BY_KEY];
                    [query setTable:UMDB_MESSAGE_HISTORY];
                    [query setFields:fields];
                    [query setPrimaryKeyName:@"archiveId"];
                    [query addToCache];
                }
            }
            else
            {
                query = [UMDbQuery queryForFile:__FILE__ line: __LINE__];
                if(![query isInCache])
                {
                    [query setType:UMDBQUERYTYPE_UPDATE_BY_KEY];
                    [query setTable:UMDB_MESSAGE_HISTORY];
                    [query setFields:fields];
                    [query setPrimaryKeyName:@"archiveId"];
                    [query addToCache];
                }
                
            }
            NSString *historyLogString = [_messageHistory stringLines];
            NSArray *params  = @[
                                 STRING_NONEMPTY(self.archiveId),
                                 STRING_NONEMPTY(self.instanceName),
                                 STRING_NONEMPTY(self.messageId),
                                 STRING_NONEMPTY(self.to),
                                 STRING_NONEMPTY(historyLogString)
                                 ];
            unsigned long long affectedRows = 0;
            BOOL success = [session cachedQueryWithNoResult:query parameters:params  allowFail:YES primaryKeyValue:self.archiveId affectedRows:&affectedRows];
            if(success)
            {
                _historyHasBeenInserted = YES;
            }
        }
        @catch (NSException *exception)
        {
            NSString *reason = exception.reason;
            NSLog(@"UMMessage\n%@",reason);
            error(1,"%s",reason.UTF8String);
        }
    }
}

- (void) archive
{
    BOOL doArchive = YES;
    
    if(g_force_disable_archive)
    {
        doArchive = NO;
    }
    else
    {
        if(g_force_enable_archive)
        {
            doArchive=YES;
        }
        else
        {
            if(_userFlags & USERFLAG_DISABLE_ARCHIVE)
            {
                doArchive = NO;
            }
            else
            {
                doArchive=YES;
            }
        }
    }
    if(doArchive)
    {
        self.archiveStatus=1;
        [archive_message_list append:self];
        self.purgeFlag=1;
        msg_immediate_udpate(self);
        [self setExpiry]; // sets expiry time in redis
    }
}

- (NSInteger)uid
{
	return [userId integerValue];
}

- (NSInteger)gid
{
	return [groupId integerValue];
}

- (void)setUid:(NSInteger)i
{
	[self setUserId:[NSString stringWithFormat:@"%ld",i]];
}

- (void) setGid:(NSInteger)i;
{
	[self setGroupId:[NSString stringWithFormat:@"%ld",i]];
}

- (void) setOpcLong:(long)pc
{
	char pcstr[32];
	pc2str(pc, &pcstr[0], UMMTP3Variant_Undefined);
	[self setOpc:[NSString stringWithUTF8String:pcstr]];
}

- (void) setDpcLong:(long)pc
{
	char pcstr[32];
	pc2str(pc, &pcstr[0], UMMTP3Variant_Undefined);
	[self setDpc:[NSString stringWithUTF8String:pcstr]];
}

- (void) setOpc2Long:(long)pc
{
	char pcstr[32];
	pc2str(pc, &pcstr[0], UMMTP3Variant_Undefined);
	[self setOpc:[NSString stringWithUTF8String:pcstr]];
}

- (void) setDpc2Long:(long)pc
{
	char pcstr[32];
	pc2str(pc, &pcstr[0], UMMTP3Variant_Undefined);
	[self setDpc:[NSString stringWithUTF8String:pcstr]];
}


- (long) opcLong
{
    if(opc.length==0)
    {
        return 0;
    }
    unsigned long pc;
	pc = cstr2pc(opc.UTF8String,UMMTP3Variant_Undefined);
	return pc;
}

- (long) dpcLong
{
    if(dpc.length==0)
    {
        return 0;
    }
    Pointcode pc = cstr2pc(dpc.UTF8String,UMMTP3Variant_Undefined);
	return pc;
}

- (long) opc2Long
{
    if(opc2.length == 0)
    {
        return 0;
    }
	unsigned long pc = cstr2pc(opc2.UTF8String,UMMTP3Variant_Undefined);
	return pc;
}

- (long) dpc2Long
{
    if(dpc2 == NULL)
    {
        return 0;
    }
    if([dpc2 length]==0)
    {
        return 0;
    }
    Pointcode pc;
	pc = cstr2pc(dpc2.UTF8String,UMMTP3Variant_Undefined);
	return pc;
}


+ (NSString *)archiveIdWithInstance:(NSString *)instanceName messageId:(NSString *)messageId
{
    return [NSString stringWithFormat:@"%@:%@",
            (instanceName ? instanceName :@"") ,
            (messageId ? messageId : @"")];
}

- (NSString *)archiveId
{
    return [UMMessage archiveIdWithInstance:instanceName messageId:messageId];
}

- (void) setArchiveId:(NSString *)a
{
	/* we dont do anything here as the values instanceName and messageId are already set */
}

- (NSString *)description
{
	NSString *ns = @"(not set)";
	NSMutableString *t = [[NSMutableString alloc]init];
	[t appendFormat:@"archiveId:       '%@'\n",[[self archiveId] sqlEscaped]];
	[t appendFormat:@"archiveStatus:   '%d'\n",(int)[self archiveStatus]];
	[t appendFormat:@"instanceName:    '%@'\n",(instanceName ?  [[self instanceName] sqlEscaped] :ns )];
	[t appendFormat:@"messageId:       '%@'\n",(messageId ?  [[self messageId] sqlEscaped] : ns)];
	[t appendFormat:@"userId:          '%@'\n",(userId ?  [[self userId] sqlEscaped] : ns)];
	[t appendFormat:@"groupId:         '%@'\n",(groupId ?  [[self groupId] sqlEscaped] : ns)];
	[t appendFormat:@"deliveryMethod:  '%@'\n",[self deliveryMethodString]];
	[t appendFormat:@"submissionType:  '%@'\n",[self submissionTypeString]];
	[t appendFormat:@"from:            '%@'\n",(from ?  [[self from] sqlEscaped] : ns)];
    [t appendFormat:@"receivedFromIp:  '%@'\n",(receivedFromIp ?  [[self receivedFromIp] sqlEscaped] : ns)];
    [t appendFormat:@"submissionIp:  '%@'\n",(submissionIp ?  [[self submissionIp] sqlEscaped] : ns)];
	[t appendFormat:@"to:              '%@'\n",(to ?  [[self to] sqlEscaped] : ns)];
	[t appendFormat:@"deliveryReportMsc: '%@'\n",(deliveryReportMsc ?  [[self deliveryReportMsc] sqlEscaped] : ns)];
	[t appendFormat:@"deliveryReportImsi:'%@'\n",(deliveryReportImsi ?  [[self deliveryReportImsi] sqlEscaped] : ns)];
	[t appendFormat:@"fromMsc:         '%@'\n",(fromMsc ?  [[self fromMsc] sqlEscaped] : ns)];
	[t appendFormat:@"fromImsi:        '%@'\n",(fromImsi ?  [[self fromImsi] sqlEscaped] : ns)];
	[t appendFormat:@"toMsc:           '%@'\n",(toMsc ?  [[self toMsc] sqlEscaped] : ns)];
	[t appendFormat:@"toImsi:          '%@'\n",(toImsi ?  [[self toImsi] sqlEscaped] : ns)];
	[t appendFormat:@"smsc:            '%@'\n",(smsc ?  [[self smsc] sqlEscaped] : ns)];
	[t appendFormat:@"smsc2:           '%@'\n",(smsc2 ?  [[self smsc2] sqlEscaped] : ns)];
	[t appendFormat:@"smsc3:           '%@'\n",(smsc3 ?  [[self smsc3] sqlEscaped] : ns)];
	[t appendFormat:@"smsc4:           '%@'\n",(smsc4 ?  [[self smsc4] sqlEscaped] : ns)];
	[t appendFormat:@"hlr:             '%@'\n",(hlr ?  [[self hlr] sqlEscaped] : ns)];
	[t appendFormat:@"created:         '%@'\n",(_created ?  [[self created] sqlEscaped] : ns)];
	[t appendFormat:@"scts:            '%@'\n",(scts ?  [[self scts] sqlEscaped] : ns)];
	[t appendFormat:@"scts_tz:         '%d'\n",(int)[self scts_tz]];
	[t appendFormat:@"qpriority:       '%d'\n",(int)[self qpriority]];
	[t appendFormat:@"upriority:       '%d'\n",(int)[self upriority]];
	[t appendFormat:@"btype:                     '%d'\n",(int)[self btype]];
	[t appendFormat:@"messageStatus:             '%@'\n",[self messageStatusString]];
	[t appendFormat:@"messageError1:             '%d'\n",(int)[self messageError1]];
	[t appendFormat:@"messageError2:             '%d'\n",(int)[self messageError2]];
	[t appendFormat:@"messageDelivered:          '%@'\n",(messageDelivered ?  [[self messageDelivered] sqlEscaped] : ns)];
	[t appendFormat:@"messageFailed:             '%@'\n",(messageFailed ?  [[self messageFailed] sqlEscaped] : ns)];
	[t appendFormat:@"messageAttempted:          '%@'\n",(messageAttempted ?  [[self messageAttempted] sqlEscaped] : ns)];
	[t appendFormat:@"messageExpiry:             '%@'\n",(self.messageExpiry ?  [self.messageExpiry sqlEscaped] : ns)];
	[t appendFormat:@"messageExpiryTz:           '%d'\n",(int)[self messageExpiryTz]];
	[t appendFormat:@"messageNextAttempt:        '%@'\n",(_messageNextAttempt ?  [self.messageNextAttempt sqlEscaped] : ns)];
	[t appendFormat:@"messageAttempts:           '%d'\n",(int)[self messageAttempts]];
	[t appendFormat:@"messageMaxAttempts:        '%d'\n",(int)[self messageMaxAttempts]];
	[t appendFormat:@"messageWaitingSet:         '%d'\n",(int)[self messageWaitingSet]];
	[t appendFormat:@"deliveryReportMask:        '%@'\n",[self deliveryReportMask]];
	[t appendFormat:@"deliveryReportAddress:     '%@'\n",(deliveryReportAddress ?  [[self deliveryReportAddress] sqlEscaped] : ns)];
	[t appendFormat:@"deliveryReportStatus:      '%@'\n",[self deliveryReportStatusString]];
	[t appendFormat:@"deliveryReportError1:      '%d'\n",(int)[self deliveryReportError1]];
	[t appendFormat:@"deliveryReportError2:      '%d'\n",(int)[self deliveryReportError2]];
	[t appendFormat:@"deliveryReportDelivered:   '%@'\n",(deliveryReportDelivered ?  [[self deliveryReportDelivered] sqlEscaped] : ns)];
	[t appendFormat:@"deliveryReportFailed:      '%@'\n",(deliveryReportFailed ?  [[self deliveryReportFailed] sqlEscaped] : ns)];
	[t appendFormat:@"deliveryReportAttempted:   '%@'\n",(deliveryReportAttempted ?  [[self deliveryReportAttempted] sqlEscaped] : ns)];
	[t appendFormat:@"deliveryReportExpiry:      '%@'\n",(deliveryReportExpiry ?  [[self deliveryReportExpiry] sqlEscaped] : ns)];
	[t appendFormat:@"deliveryReportNextAttempt: '%@'\n",(deliveryReportNextAttempt ?  [[self deliveryReportNextAttempt] sqlEscaped] : ns)];
	[t appendFormat:@"deliveryReportAttempts:    '%d'\n",(int)[self deliveryReportAttempts]];
	[t appendFormat:@"deliveryReportMaxAttempts: '%d'\n",(int)[self deliveryReportMaxAttempts]];
	[t appendFormat:@"deliveryReportWaitingSet:  '%d'\n",(int)[self deliveryReportWaitingSet]];
	[t appendFormat:@"msuCountSriSMTx:           '%d'\n",(int)[self msuCountSriSMTx]];
	[t appendFormat:@"msuCountSriSMRx:           '%d'\n",(int)[self msuCountSriSMRx]];
	[t appendFormat:@"msuCountSriSMHTx:          '%d'\n",(int)[self msuCountSriSMHTx]];
	[t appendFormat:@"msuCountSriSMHRx:          '%d'\n",(int)[self msuCountSriSMHRx]];
	[t appendFormat:@"msuCountFsmTx:          '%d'\n",(int)[self msuCountFsmTx]];
	[t appendFormat:@"msuCountFsmRx:          '%d'\n",(int)[self msuCountFsmRx]];
	[t appendFormat:@"testFlag:        '%d'\n",(int)[self testFlag]];
	[t appendFormat:@"phoneRef:        '%d'\n",(int)[self phoneRef]];
	[t appendFormat:@"udhIndicator:    '%d'\n",(int)[self udhIndicator]];
	[t appendFormat:@"toCountry:       '%@'\n",(toCountry ?  [[self toCountry] sqlEscaped] : ns)];
	[t appendFormat:@"toOperatorCode:  '%@'\n",(toOperatorCode ?  [[self toOperatorCode] sqlEscaped] : ns)];
	[t appendFormat:@"toOperatorName:  '%@'\n",(toOperatorName ?  [[self toOperatorName] sqlEscaped] : ns)];
	[t appendFormat:@"messagePriority: '%d'\n",(int)[self messagePriority]];
	[t appendFormat:@"replyPath:       '%d'\n",(int)[self replyPath]];
	[t appendFormat:@"pid:             '%d'\n",(int)[self pid]];
	[t appendFormat:@"compress:        '%d'\n",(int)[self compress]];
	[t appendFormat:@"dcs:             '%d'\n",(int)[self dcs]];
	[t appendFormat:@"mwi_pdu:         '%d'\n",(int)[self mwi_pdu]];
	[t appendFormat:@"udh:             '%@'\n",[[self udh]hexString]];
	[t appendFormat:@"content:         '%@'\n",[[self content]hexString]];
	[t appendFormat:@"plaintextContent:'%@'\n",(self.plaintextContent ?  [[self plaintextContent] sqlEscaped] : ns)];
	[t appendFormat:@"messageClass:    '%d'\n",(int)[self messageClass]];
	[t appendFormat:@"coding:          '%d'\n",(int)[self coding]];
	[t appendFormat:@"opc:             '%@'\n",(opc ?  [[self opc] sqlEscaped] : ns)];
	[t appendFormat:@"dpc:             '%@'\n",(dpc ?  [[self dpc] sqlEscaped] : ns)];
	[t appendFormat:@"opc2:            '%@'\n",(opc ?  [[self opc2] sqlEscaped] : ns)];
	[t appendFormat:@"dpc2:            '%@'\n",(dpc ?  [[self dpc2] sqlEscaped] : ns)];
	[t appendFormat:@"tcapType:        '%d'\n",(int)[self tcapType]];
	[t appendFormat:@"extensionData:   '%@'\n",(_extensionData ?  [[self extensionData] sqlEscaped] : ns)];
	[t appendFormat:@"purgeFlag:       '%d'\n",(int)[self purgeFlag]];
	[t appendFormat:@"alertingAddress: '%@'\n",(alertingAddress ?  [[self alertingAddress] sqlEscaped] : ns)];
	[t appendFormat:@"fromCountry:     '%@'\n",(fromCountry ?  [[self fromCountry] sqlEscaped] : ns)];
	[t appendFormat:@"fromOperatorCode:'%@'\n",(fromOperatorCode ?  [[self fromOperatorCode] sqlEscaped] : ns)];
	[t appendFormat:@"fromOperatorName:'%@'\n",(fromOperatorName ?  [[self fromOperatorName] sqlEscaped] : ns)];
	[t appendFormat:@"routeId:         '%@'\n",(routeId ?  [[self routeId] sqlEscaped] : ns)];
	[t appendFormat:@"subrouteId:      '%@'\n",(subrouteId ?  [[self subrouteId] sqlEscaped] : ns)];
	[t appendFormat:@"routedOnPrefix:  '%@'\n",(routedOnPrefix ?  [[self routedOnPrefix] sqlEscaped] : ns)];
	[t appendFormat:@"autorouted:      '%d'\n",(int)[self autoRouted]];
	[t appendFormat:@"userFlags:       '%d'\n",(int)[self userFlags]];
    [t appendFormat:@"retryPatternTable:'%d'\n",(int)[self retryPatternTable]];
    [t appendFormat:@"costTable:       '%@'\n",[self costTable]];
    [t appendFormat:@"msuCostTx:         '%10.6lf'\n",[self msuCostTx]];
    [t appendFormat:@"msuCostRx:         '%10.6lf'\n",[self msuCostRx]];
    [t appendFormat:@"smsCost:         '%10.6lf'\n",[self smsCost]];
    [t appendFormat:@"interworkingCost:'%10.6lf'\n",[self interworkingCost]];
    [t appendFormat:@"totalCost:       '%10.6lf'\n",[self totalCost]];
    [t appendFormat:@"chargeTable1:     '%@'\n",[self chargeTable1]];
    [t appendFormat:@"chargePrice1:     '%10.6lf'\n",[self chargePrice1]];
    [t appendFormat:@"profit1:          '%10.6lf'\n",[self profit1]];
    [t appendFormat:@"chargeTable2:     '%@'\n",[self chargeTable2]];
    [t appendFormat:@"chargePrice2:     '%10.6lf'\n",[self chargePrice2]];
    [t appendFormat:@"profit2:          '%10.6lf'\n",[self profit2]];
    [t appendFormat:@"destinationQuotaTableName: '%@'\n",[self destinationQuotaTableName]];

	return t;
}


- (DeliveryMethodType)deliveryMethod
{
	return deliveryMethod;
}

- (void) setDeliveryMethod:(DeliveryMethodType)method
{
	if(deliveryMethod == method)
    {
		return;
    }
    deliveryMethod = method;
	
}

- (id)smsLayer
{
	return smsLayer;
}

- (void)setSmsLayer:newLayer
{
	@synchronized(self)
	{
		if(smsLayer == newLayer)
        {
			return;
        }
        smsLayer=newLayer;
		//[stateMachine setDelegate:smsLayer];
	}	
    
}

- (void)increaseMsuCountSriSMTx:(int)i
{
    _msuCountSriSMTx +=i;
    dirtyMsuCountSriSMTx=YES;
    dirtyCosts=YES;
    dirty = YES;
}

- (void)increaseMsuCountSriSMRx:(int)i;
{
    _msuCountSriSMRx +=i;
    dirtyMsuCountSriSMRx=YES;
    dirtyCosts=YES;
    dirty = YES;
}

- (void)increaseMsuCountSriSMHTx:(int)i;
{
    _msuCountSriSMHTx +=i;
    dirtyMsuCountSriSMHTx=YES;
    dirtyCosts=YES;
    dirty = YES;
}

- (void)increaseMsuCountSriSMHRx:(int)i;
{
    _msuCountSriSMHRx +=i;
    dirtyMsuCountSriSMHRx=YES;
    dirtyCosts=YES;
    dirty = YES;
}

- (void)increaseMsuCountSriSMCRx:(int)i;
{
    _msuCountSriSMCRx +=i;
    LIMIT_TO_16BIT(_msuCountSriSMCRx);
    dirtyMsuCountSriSMCRx=YES;
    dirtyCosts=YES;
    dirty = YES;
}

- (void)increaseMsuCountFsmTx:(int)i;
{
    _msuCountFsmTx +=i;
    LIMIT_TO_16BIT(_msuCountFsmTx);
    dirtyMsuCountFsmTx=YES;
    dirtyCosts=YES;
    dirty = YES;
}

- (void)increaseMsuCountFsmRx:(int)i;
{
    _msuCountFsmRx +=i;
    LIMIT_TO_16BIT(_msuCountFsmRx);
    dirtyMsuCountFsmRx=YES;
    dirtyCosts=YES;
}

- (void)increaseMsuCountTcapHandshakeTx:(int)i;
{
    _msuCountTcapHandshakeTx +=i;
    LIMIT_TO_16BIT(_msuCountTcapHandshakeTx);
    dirtyMsuCountTcapHandshakeTx=YES;
    dirtyCosts=YES;
    dirty = YES;
}

- (void)increaseMsuCountTcapHandshakeRx:(int)i;
{
    _msuCountTcapHandshakeRx +=i;
    LIMIT_TO_16BIT(_msuCountTcapHandshakeRx);
    dirtyMsuCountTcapHandshakeRx=YES;
    dirtyCosts=YES;
    dirty = YES;
}

- (NSInteger)msuCountRx
{
    return _msuCountFsmRx + _msuCountSriSMRx + _msuCountTcapHandshakeRx;
}

- (NSInteger)msuCountTx;
{
    return _msuCountFsmTx + _msuCountSriSMTx + _msuCountTcapHandshakeTx;
}

- (int)msuCount
{
    return [self msuCountTx] + [self msuCountRx];
}

- (double)msuCostRx
{
    return msuCostRx;
}

- (void)setMsuCostRx:(double)m
{
    msuCostRx = m;
    dirtyCosts=YES;
    dirty = YES;
}

- (double)msuCostTx
{
    return msuCostTx;
}

- (void)setMsuCostTx:(double)m
{
    msuCostTx = m;
    dirtyCosts=YES;
    dirty = YES;
}



- (double)smsCost
{
    return smsCost;
}

- (void)setSmsCost:(double)m
{
    if(m==smsCost)
        return;
    smsCost = m;
    dirtyCosts=YES;
    dirty = YES;
}

- (double)interworkingCost
{
    return interworkingCost;
}

- (void)setInterworkingCost:(double)m
{
    if(m==interworkingCost)
        return;
    interworkingCost = m;
    dirtyCosts=YES;
    dirty = YES;

}

- (double)totalCost
{
    return (msuCostTx * [self msuCountTx]) + (msuCostRx * [self msuCountRx]) + smsCost + interworkingCost;
}

- (double)profit1
{
    return [self chargePrice1] - [self totalCost];
}

- (double)profit2
{
    return [self chargePrice2] - [self totalCost];
}

- (NSString *)costTable
{
    if(_costTable==NULL)
    {
        return @"default";
    }
    return _costTable;
}

-(void) setCostTable:(NSString *)ct 
{
    if(ct==NULL)
    {
        ct = @"default";
    }
    @synchronized(self)
    {
        if([ct isEqualToString:_costTable])
        {
            return;
        }
        _costTable = ct;
        dirtyCosts = YES;
        dirty = YES;
   }
    
}

- (NSString *)chargeTable1
{
    if(_chargeTable1==NULL)
    {
        return @"default";
    }
    return _chargeTable1;
}

- (NSString *)chargeTable2
{
    if(_chargeTable2==NULL)
    {
        return @"default";
    }
    return _chargeTable2;
}

-(void) setChargeTable1:(NSString *)ct 
{
    if(ct==NULL)
    {
        ct = @"default";
    }
    @synchronized(self)
    {
        if([ct isEqualToString:_chargeTable1])
        {
            return;
        }
        _chargeTable1 = ct;
        dirtyCosts = YES;
        dirty = YES;
    }
    
}

-(void) setChargeTable2:(NSString *)ct 
{
    if(ct==NULL)
    {
        ct = @"default";
    }
    @synchronized(self)
    {
        if([ct isEqualToString:_chargeTable2])
        {
            return;
        }
        _chargeTable2 = ct;
        dirtyCosts = YES;
        dirty = YES;
    }
    
}

- (double)chargePrice1
{
    return _chargePrice1;
}

- (void)setChargePrice1:(double)m
{
    _chargePrice1 = m;
    dirtyCosts=YES;
    dirty = YES;
}

- (double)chargePrice2
{
    return _chargePrice2;
}

- (void)setChargePrice2:(double)m
{
    _chargePrice2 = m;
    dirtyCosts=YES;
    dirty = YES;
}




+(UMMessage *)messageLoad:(NSString *)messageId
              forInstance:(NSString *)instance
                     file:(const char *)file
                     line:(long)line
                     func:(const char *)func
{
    UMMessage *msg = NULL;
    if(instance == NULL)
    {
        instance = [NSString stringWithUTF8String:&global_default_smsc_instance[0]];
    }
    if(messageId==NULL)
    {
		return NULL;
    }
    if(messageId.length==0)
    {
        return NULL;
    }
    NSString *archiveId = [UMMessage archiveIdWithInstance:instance messageId:messageId];
  
    msg = [g_global_message_cache findMessage:messageId];
    if(msg)
    {
        LOG_TO_MESSAGE(msg,@"loadedFromCache");
        return msg;
    }
    
    UMDbQuery *query = [UMDbQuery queryForFile:__FILE__ line: __LINE__];
    if(![query isInCache])
    {
        NSArray *fields = [UMDbQuery fieldNamesArrayFromFieldsDefinition:[UMMessage tableDefinition]];
        [query setType:UMDBQUERYTYPE_SELECT_BY_KEY];
        [query setTable:UMDB_MESSAGE];
        [query setFields:fields];
        [query setPrimaryKeyName:@"archiveId"];
        [query addToCache];
    }
    
    UMDbSession *session = [UMDB_MESSAGE.pool grabSession:FLF];
    UMDbResult *result = [session cachedQueryWithMultipleRowsResult:query parameters:@[] allowFail:NO primaryKeyValue:archiveId];
    [session.pool returnSession:session file:FLF];
    UMAssert(result.rowsCount<=1,@"more than one row found");
    NSArray *row = [result fetchRow];
    if(row==NULL)
    {
        return NULL;
    }
    msg = [[UMMessage alloc]initWithRow:row];

    time_t startT = UMTimeFromTimestampDT(msg.created);
    msg.startTime = (long long)startT * 1000LL; /* its in miliseconds */
    if(msg.messageState == nil)
    {
        switch(msg.messageStatus)
        {
            case M_STATUS_NEW:
                msg.messageState = [[UMMessageState_new alloc]init];
                break;
            case M_STATUS_BUFFERED:
            case M_STATUS_HLRSENT:
            case M_STATUS_HLRRECEIVED:
            case M_STATUS_MSGSENT:
                msg.messageState = [[UMMessageState_waitingForRetryTimer alloc]init];
                break;
        }
    }
    
    UMDbQuery *query2 = [UMDbQuery queryForFile:__FILE__ line: __LINE__];
    if(![query2 isInCache])
    {
        [query2 setType:UMDBQUERYTYPE_SELECT_BY_KEY];
        [query2 setTable:UMDB_MESSAGE_HISTORY];
        [query2 setFields:@[@"history"]];
        [query2 setPrimaryKeyName:@"archiveId"];
        [query2 addToCache];
    }
    
    session = [UMDB_MESSAGE_HISTORY.pool grabSession:FLF];
    UMDbResult *result2 = [session cachedQueryWithMultipleRowsResult:query2 parameters:@[] allowFail:NO primaryKeyValue:archiveId];
    [session.pool returnSession:session file:FLF];

    UMAssert(result2.rowsCount<=1,@"more than one row found");
    NSArray *row2 = [result2 fetchRow];
    if(row2!=NULL)
    {
        NSString *historyText = row2[0];
        [msg setHistoryText: historyText];
    }
    if(msg.env==NULL)
    {
        msg.env = [[UMSMSEnvironment alloc]initWithMessage:msg];
    }
    LOG_TO_MESSAGE(msg,@"loadedFromDb");
    msg.hasBeenInserted = YES;
    return msg;
}

- (NSString *)getSmsc2
{
    if ((smsc2) && ([smsc2 length] > 0))
        return smsc2;
    return smsc;
}

- (NSString *)getSmsc3
{
    if ((smsc3) && ([smsc3 length] > 0))
        return smsc3;
    if ((smsc2) && ([smsc2 length] > 0))
        return smsc2;
    return smsc;
}

- (NSString *)getSmsc4
{
    if ((smsc4) && ([smsc4 length] > 0))
        return smsc4;
    return smsc;
}


+(void)imsiToOperatorCodeAndName:(NSString *)imsi_in name:(NSString **)opName operatorCode:(NSString **)opCode;
{
    const char *name = "";
    const char *operator_code = NULL;
    const char *cc2 = NULL;
    const char *cc3 = NULL;
    const char *country = NULL;
    const char *mcc = NULL;
    const char *mnc = NULL;
    get_operator_from_imsi2(imsi_in.UTF8String,
                            &operator_code,
                            &cc2,
                            &cc3,
                            &country,
                            &mcc,
                            &mnc,
                            &name);
    if(opName)
    {
        *opName = @(name);
    }
    if(opCode)
    {
        *opCode = @(operator_code);
    }
}

+ (NSString *)imsiToOperatorCode:(NSString *)imsi_in
{
    if(imsi_in.length == 0)
    {
        return @"";
    }
#ifdef HAS_OPERATOR_FROM_IMSI2
    const char *operator_code = NULL;
    const char *name = "";
    const char *cc2 = NULL;
    const char *cc3 = NULL;
    const char *country = NULL;
    const char *mcc = NULL;
    const char *mnc = NULL;

    get_operator_from_imsi2(imsi_in.UTF8String,
                            &operator_code,
                            &cc2,
                            &cc3,
                            &country,
                            &mcc,
                            &mnc,
                            &name);

#else
    const char *country = NULL;
    const char *organisation = NULL;
    const char *network = NULL;
    const char *abbreviated_name = NULL;
    const char *mcc = NULL;
    const char *mnc = NULL;
    const char *sim = NULL;
    const char *last_update = NULL;
    const char *operator_code = NULL;
    get_operator_from_imsi(imsi_in.UTF8String,
                           &country, /* this is a 3 character ISO code */
                           &organisation,
                           &network,
                           &abbreviated_name,
                           &mcc,
                           &mnc,
                           &sim,
                           &last_update,
                           &operator_code);
#endif
    if(operator_code)
    {
        return @(operator_code);
    }
    return @"";
}


+ (NSString *)operatorCodeToOperatorName:(NSString *)code
{
    if(code.length ==0)
    {
        return @"";
    }
    NSString *x = [code stringByReplacingOccurrencesOfString:@"." withString:@""];
#ifdef HAS_OPERATOR_FROM_IMSI2
    const char *network = "";
    const char *operator_code = NULL;
    const char *name = NULL;
    const char *cc2 = NULL;
    const char *cc3 = NULL;
    const char *country = NULL;
    const char *mcc = NULL;
    const char *mnc = NULL;

    get_operator_from_imsi2(x.UTF8String,
                            &operator_code,
                            &cc2,
                            &cc3,
                            &country,
                            &mcc,
                            &mnc,
                            &name);

#else
    const char *country = "";
    const char *organisation = "";
    const char *network = "";
    const char *abbreviated_name = "";
    const char *mcc = "";
    const char *mnc = "";
    const char *sim = "";
    const char *last_update = "";
    const char *operator_code = "";
    get_operator_from_imsi(x.UTF8String,
                           &country, /* this is a 3 character ISO code */
                           &organisation,
                           &network,
                           &abbreviated_name,
                           &mcc,
                           &mnc,
                           &sim,
                           &last_update,
                           &operator_code);
#endif
    if(network)
    {
        return @(network);
    }
    return @"";
}

- (int) updateBilling
{
    double price = [self chargePrice1];

    UMCustomerPricing   *cp1 = [UMCustomerPricing getTable:_chargeTable1];
    double customerPrice1 = [cp1 getEnduserPriceForOperator:toOperatorCode];
    [self setChargePrice1:customerPrice1];

    UMCustomerPricing   *cp2 = [UMCustomerPricing getTable:_chargeTable2];
    double customerPrice2 = [cp2 getEnduserPriceForOperator:toOperatorCode];
    [self setChargePrice2:customerPrice2];

    UMInterworking      *iw = [UMInterworking getTable:_costTable];
    NSDictionary *dict = [iw getPricingDetailsForOperator:toOperatorCode];
    
    double iwCst = [[dict objectForKey:@"iw"]doubleValue];
    double msuCstTx = [[dict objectForKey:@"msutx"]doubleValue];
    double msuCstRx = [[dict objectForKey:@"msurx"]doubleValue];
    double smsCst = [[dict objectForKey:@"sms"]doubleValue];
    

    [self setInterworkingCost:iwCst];
    [self setMsuCostTx:msuCstTx];
    [self setMsuCostRx:msuCstRx];
    [self setSmsCost:smsCst];
    
    price = customerPrice1 - price;
    if((price > 0.00000001) || (price < -0.00000001))
    {
        UMUser *u = proto_api_user_find_by_uid([[self userId]intValue]);
        if(u)
        {
            [u useMoney:price];
        }
    } 
 
    int blocked = NO;
    
    if([[dict objectForKey:@"blk"]boolValue]==YES)
    {
        blocked = MB_ERR_CHARGING_BLOCKED;
    }
    if(blocked == MB_ERR_NONE)
    {
        UMDestinationQuota *dq = [UMDestinationQuota getTable:[self destinationQuotaTableName]];
        if([dq quotaPermissionByOperator:[self toOperatorCode]]==NO)
        {
            blocked = MB_ERR_QUOTA_REACHED;
        }
    }
    return blocked;
}

- (UMMessage *)initWithRow:(NSArray *)row 
{   
    self=[super init];
    if(self)
    {
        int	i=0;
        if(row == NULL)
            return NULL; 
        i = 0;
        [self setArchiveId:[row objectAtIndex:i++]];
        [self setArchiveStatus:[[row objectAtIndex:i++]intValue]];
        [self setInstanceName:[row objectAtIndex:i++]];
        [self setMessageId:[row objectAtIndex:i++]];
        [self setUserId:[row objectAtIndex:i++]];
        [self setGroupId:[row objectAtIndex:i++]];
        [self setDeliveryMethodString:[row objectAtIndex:i++]];
        [self setSubmissionTypeString:[row objectAtIndex:i++]];
        [self setFrom:[row objectAtIndex:i++]];
        [self setReceivedFromIp:[row objectAtIndex:i++]];
        [self setSubmissionIp:[row objectAtIndex:i++]];
        [self setTo:[row objectAtIndex:i++]];
        [self setDeliveryReportMsc:[row objectAtIndex:i++]];
        [self setDeliveryReportImsi:[row objectAtIndex:i++]];
        [self setFromMsc:[row objectAtIndex:i++]];
        [self setFromImsi:[row objectAtIndex:i++]];
        [self setToMsc:[row objectAtIndex:i++]];
        [self setToImsi:[row objectAtIndex:i++]];
        [self setSmsc:[row objectAtIndex:i++]];
        [self setSmsc2:[row objectAtIndex:i++]];
        [self setSmsc3:[row objectAtIndex:i++]];
        [self setSmsc4:[row objectAtIndex:i++]];
        [self setHlr:[row objectAtIndex:i++]];
        [self setCreated:[row objectAtIndex:i++]];
        [self setScts:[row objectAtIndex:i++]];
        [self setScts_tz:[[row objectAtIndex:i++]intValue]];
        [self setQpriority:[[row objectAtIndex:i++]intValue]];
        [self setUpriority:[[row objectAtIndex:i++]intValue]];
        [self setMessagePriority:[[row objectAtIndex:i++]intValue]];
        [self setBtype:[[row objectAtIndex:i++]intValue]];
        [self setMessageStatusString:[row objectAtIndex:i++]];
        [self setMessageError1:[[row objectAtIndex:i++]intValue]];
        [self setMessageError2:[[row objectAtIndex:i++]intValue]];
        [self setMessageDelivered:[row objectAtIndex:i++]];
        [self setMessageFailed:[row objectAtIndex:i++]];
        [self setMessageAttempted:[row objectAtIndex:i++]];
        [self setMessageExpiry:[row objectAtIndex:i++]];
        [self setMessageExpiryTz:[[row objectAtIndex:i++]intValue]];
        [self setMessageNextAttempt:[row objectAtIndex:i++]];
        [self setMessageAttempts:[[row objectAtIndex:i++]intValue]];
        [self setMessageMaxAttempts:[[row objectAtIndex:i++]intValue]];
        [self setMessageWaitingSet:[[row objectAtIndex:i++]intValue]];
        [self setDeliveryReportMask:[[row objectAtIndex:i++]intValue]];
        [self setDeliveryReportAddress:[row objectAtIndex:i++]];
        [self setDeliveryReportStatusString:[row objectAtIndex:i++]];
        [self setDeliveryReportError1:[[row objectAtIndex:i++]intValue]];
        [self setDeliveryReportError2:[[row objectAtIndex:i++]intValue]];
        [self setDeliveryReportDelivered:[row objectAtIndex:i++]];
        [self setDeliveryReportFailed:[row objectAtIndex:i++]];
        [self setDeliveryReportAttempted:[row objectAtIndex:i++]];
        [self setDeliveryReportExpiry:[row objectAtIndex:i++]];
        [self setDeliveryReportNextAttempt:[row objectAtIndex:i++]];
        [self setDeliveryReportAttempts:[[row objectAtIndex:i++]intValue]];
        [self setDeliveryReportMaxAttempts:[[row objectAtIndex:i++]intValue]];
        [self setDeliveryReportWaitingSet:[[row objectAtIndex:i++]intValue]];
        [self setMsuCountSriSMRx:[[row objectAtIndex:i++]intValue]];
        [self setMsuCountSriSMTx:[[row objectAtIndex:i++]intValue]];
        [self setMsuCountSriSMHRx:[[row objectAtIndex:i++]intValue]];
        [self setMsuCountSriSMHTx:[[row objectAtIndex:i++]intValue]];
        [self setMsuCountSriSMCRx:[[row objectAtIndex:i++]intValue]];
        [self setMsuCountFsmTx:[[row objectAtIndex:i++]intValue]];
        [self setMsuCountFsmRx:[[row objectAtIndex:i++]intValue]];
        [self setMsuCountTcapHandshakeTx:[[row objectAtIndex:i++]intValue]];
        [self setMsuCountTcapHandshakeRx:[[row objectAtIndex:i++]intValue]];
        [self setTestFlag:[[row objectAtIndex:i++]intValue]];
        [self setPhoneRef:[[row objectAtIndex:i++]intValue]];
        [self setUdhIndicator:[[row objectAtIndex:i++]intValue]];
        [self setToCountry:[row objectAtIndex:i++]];
        [self setToOperatorCode:[row objectAtIndex:i++]];
        [self setToOperatorName:[row objectAtIndex:i++]];
        [self setReplyPath:[[row objectAtIndex:i++]intValue]];
        [self setPid:[[row objectAtIndex:i++]intValue]];
        [self setCompress:[[row objectAtIndex:i++]intValue]];
        [self setDcs:[[row objectAtIndex:i++]intValue]];
        [self setMwi_pdu:[[row objectAtIndex:i++]intValue]];
        [self setUdh:[[row objectAtIndex:i++]unhexedData]];
        [self setContent:[[row objectAtIndex:i++]unhexedData]];
        i++; //[self setPlaintextContent:[row objectAtIndex:i++]];
        [self setMessageClass:[[row objectAtIndex:i++]intValue]];
        [self setCoding:[[row objectAtIndex:i++]intValue]];
        [self setOpc:[row objectAtIndex:i++]];
        [self setDpc:[row objectAtIndex:i++]];
        [self setOpc2:[row objectAtIndex:i++]];
        [self setDpc2:[row objectAtIndex:i++]];
        [self setTcapType:[[row objectAtIndex:i++]intValue]];
        [self setExtensionData:[row objectAtIndex:i++]];
        [self setPurgeFlag:[[row objectAtIndex:i++]intValue]];
        [self setAlertingAddress:[row objectAtIndex:i++]];
        [self setFromCountry:[row objectAtIndex:i++]];
        [self setFromOperatorCode:[row objectAtIndex:i++]];
        [self setFromOperatorName:[row objectAtIndex:i++]];
        [self setRouteId:[row objectAtIndex:i++]];
        [self setSubrouteId:[row objectAtIndex:i++]];
        [self setRoutedOnPrefix:[row objectAtIndex:i++]];
        [self setAutoRouted:[[row objectAtIndex:i++]intValue]];
        [self setUserFlags:[[row objectAtIndex:i++]intValue]];
        [self setRetryPatternTable:[[row objectAtIndex:i++]intValue]];
        [self setInterworkingTapCode:[row objectAtIndex:i++]];
        [self setCostTable:[row objectAtIndex:i++]];
        [self setMsuCostTx:[[row objectAtIndex:i++]doubleValue]];    
        [self setMsuCostRx:[[row objectAtIndex:i++]doubleValue]];    
        [self setSmsCost:[[row objectAtIndex:i++]doubleValue]];    
        [self setInterworkingCost:[[row objectAtIndex:i++]doubleValue]];   
        i++;    //	[self setTotalCost:[[row objectAtIndex:i++]doubleValue]]; 
        [self setChargeTable1:[row objectAtIndex:i++]];
        [self setChargePrice1:[[row objectAtIndex:i++]doubleValue]];   
        i++;    //	[self setProfit1:[[row objectAtIndex:i++]doubleValue]];    
        [self setChargeTable2:[row objectAtIndex:i++]];
        [self setChargePrice2:[[row objectAtIndex:i++]doubleValue]];   
        i++;    //	[self setProfit2:[[row objectAtIndex:i++]doubleValue]];   
        [self setDestinationQuotaTableName:[row objectAtIndex:i++]];
        [self setTt_sri:[[row objectAtIndex:i++]intValue]];
        [self setTt_fsm:[[row objectAtIndex:i++]intValue]];
        [self setDlrText:[row objectAtIndex:i++]];
        [self setComment:[row objectAtIndex:i++]];
        [self setVas_esme:[row objectAtIndex:i++]];
        [self setVas_ip:[row objectAtIndex:i++]];
        i++; /* exported */
        [self setDeferredString:[row objectAtIndex:i++]];
        [self clearDirtyStatus];
    }
    return self;
}

- (void)saveOldValues
{
    oldMsuCostTx = msuCostTx;;
    oldMsuCostRx = msuCostRx;
    oldSmsCost = smsCost;
    oldInterworkingCost = interworkingCost;
    oldChargePrice1 = _chargePrice1;
    oldChargePrice2 = _chargePrice2;

}


- (int)m2type
{
    return [UMMessage m2type];
}

+ (int)m2type
{
    return 500;
}

#if 0
- (void)setOriginatingAddress:(struct sockaddr *)addr length:(socklen_t)len
{
    if(originatingAddress)
    {
        free(originatingAddress);
        originatingAddress = NULL;
        originatingAddressLen = 0;
    }
    originatingAddress = malloc(len);
    if(originatingAddress)
    {
        memcpy(originatingAddress,addr,len);
        originatingAddressLen = len;
    }
}

- (void)getOriginatingAddress:(struct sockaddr *)addr length:(socklen_t *)len
{
    memset(addr,0x00,*len);
    if(*len < originatingAddressLen)
    {
        *len = 0;
        return;
    }
    memcpy(addr,originatingAddress,originatingAddressLen);
    *len = originatingAddressLen;
}
#endif

- (NSString *)toMcc
{
    if([toOperatorCode length]>3)
    {
        return [toOperatorCode substringToIndex:3];
    }
    return @"";
}
- (NSString *)toMnc
{
    if([toOperatorCode length]>4)
    {
        return [toOperatorCode substringFromIndex:4];
    }
    return @"";
}

- (NSString *)fromMcc
{
    if([fromOperatorCode length]>3)
    {
        return [fromOperatorCode substringToIndex:3];
    }
    return @"";
}
- (NSString *)fromMnc
{
    if([fromOperatorCode length]>4)
    {
        return [fromOperatorCode substringFromIndex:4];
    }
    return @"";
}

- (int)networkErrorCode
{
    return messageError1;
}

- (NSString *)valueForKey:(NSString *)key
{
    return @"undefined";
    /* TODO: */
}

- (void)setValue:(NSString *)value forKey:(NSString *)key
{
/* TODO: */
}


- (void)startTimer1
{
    time_t now;
    time(&now);
    NSInteger diff = 90;
    NSString *toption = self.extensionOptions[@"srism-timeout"];
    if(toption.length > 0)
    {
        diff = [toption intValue];
        if(diff < 6)
        {
            diff = 6;
        }
        else if(diff > 90)
        {
            diff = 90;
        }
    }
    else
    {
        diff = [self randomRangeMin:timer1min max:timer1max hardMin:6 hardMax:90];
    }
    timer1time = now + diff;
    NSString *s = [NSString stringWithFormat:@"start timer1: %lds",(long)diff];
    LOG_TO_MESSAGE(self,s);
}

- (void)stopTimer1
{
    timer1time = 0;
    LOG_TO_MESSAGE(self,@"stop timer1");
}

- (void)startTimer2
{

    time_t now;
    time(&now);

    NSInteger diff = 90;
    NSString *s;
    NSString *toption = self.extensionOptions[@"fsm-timeout"];
    if(toption.length > 0)
    {
        diff = [toption intValue];
        if(diff < 6)
        {
            diff = 6;
        }
        else if(diff > 90)
        {
            diff = 90;
        }
    }
    else
    {
        diff = [self randomRangeMin:timer2bmin max:timer2bmax hardMin:6 hardMax:90];
    }
    timer2time = now + diff;
    s = [NSString stringWithFormat:@"start timer2b: %lds",(long)diff];
    LOG_TO_MESSAGE(self,s);
}

- (void)startTimer2b
{
    
    time_t now;
    time(&now);
    NSInteger diff = [self randomRangeMin:timer2bmin max:timer2bmax];
    timer2time = now + diff;
    NSString *s = [NSString stringWithFormat:@"start timer2b: %lds",(long)diff];
    LOG_TO_MESSAGE(self,s);
}

- (void)stopTimer2
{
    timer2time = 0;
    LOG_TO_MESSAGE(self,@"stop timer2");
}

- (void)startTimer3
{
    
    time_t now;
    time(&now);
    NSInteger diff = [self randomRangeMin:timer3min max:timer3max];
    timer3time = now + diff;
    NSString *s = [NSString stringWithFormat:@"start timer3: %lds",(long)diff];
    LOG_TO_MESSAGE(self,s);
}

- (void)stopTimer3
{
    timer3time = 0;
    LOG_TO_MESSAGE(self,@"stop timer3");
}

- (void)startTimer4
{
    
    time_t now;
    time(&now);
    NSInteger diff = [self randomRangeMin:timer4min max:timer4max];
    timer4time = now + diff;
    NSString *s = [NSString stringWithFormat:@"start timer4: %lds",(long)diff];
    LOG_TO_MESSAGE(self,s);
}

- (void)stopTimer4
{
    timer4time = 0;
    LOG_TO_MESSAGE(self,@"stop timer4");
}

- (void)startTimer5
{
    
    time_t now;
    time(&now);
    NSInteger diff = [self randomRangeMin:timer5min max:timer5max];
    timer5time = now + diff;
    NSString *s = [NSString stringWithFormat:@"start timer5: %lds",(long)diff];
    LOG_TO_MESSAGE(self,s);
}

- (void)stopTimer5
{
    timer5time = 0;
    LOG_TO_MESSAGE(self,@"stop timer5");
}

- (long) randomRangeMin:(long)min max:(long)max
{
    return [self randomRangeMin:min max:max hardMin:0 hardMax:max];
}

- (long) randomRangeMin:(long)min max:(long)max hardMin:(long)hmin hardMax:(long)hmax
{
    if(min < hmin)
    {
        min = hmin;
    }
    if(max > hmax)
    {
        max = hmax;
    }
    if(min==max)
    {
        return max;
    }
    double    diff = (double)abs((int)(max - min));
    if(diff <=0)
    {
        return min;
    }
    else
    {
        double r = diff * random() / 2147483647.0;
        return min + (long)r;
    }
}

- (BOOL)mustSendReport
{
    NSInteger status = messageStatus;
    NSInteger mask = deliveryReportMask.intValue;
	if
        (	((status == M_STATUS_FAILED)			&& (mask & DLR_MASK_FAIL))
         ||	((status == M_STATUS_BUFFERED)			&& (mask & DLR_MASK_BUFFERED))
         ||	((status == M_STATUS_HLRSENT)			&& (mask & DLR_MASK_HLRSENT))
         ||	((status == M_STATUS_ATISENT)			&& (mask & DLR_MASK_ATISENT))
         ||	((status == M_STATUS_HLR2SENT)			&& (mask & DLR_MASK_HLR2SENT))
         ||	((status == M_STATUS_HLRRECEIVED)		&& (mask & DLR_MASK_HLRRECEIVED))
         ||	((status == M_STATUS_DELIVERED)			&& (mask & DLR_MASK_SUCCESS))
         ||	((status == M_STATUS_MSGSENT)			&& (mask & DLR_MASK_FSM_SENT))
         )
	{
        LOG_TO_MESSAGE(self,([NSString stringWithFormat:@"mustSendReport=YES messageStatus=%@ mask=%ld",[self messageStatusString],mask]));
		return YES;
	}
	else
	{
        LOG_TO_MESSAGE(self,([NSString stringWithFormat:@"mustSendReport=NO messageStatus=%@ mask=%ld",[self messageStatusString],mask]));
		return NO;
	}
}	

- (void)logToMessage:(NSString *)text
{
    long long now=mm_milisecond_clock();
    double delay = ((double)(now - startTime)) / 1000.0;
    NSString *s = [NSString stringWithFormat:@"%04.3lfs:  %@",delay,[text printable]];
    [_messageHistory addObject:[s printable]];
}


- (void)logEvent:(NSString *)event inState:(NSString *)state
{
    long long now=mm_milisecond_clock();
    double delay = ((double)(now - startTime)) / 1000.0;
    NSString *s = [NSString stringWithFormat:@"%04.3lfs: %@: %@",delay,state,event];
    [_messageHistory addObject:[s printable]];
}

- (void)logStateChange:(NSString *)oldstate newState:(NSString *)newState
{
    long long now = mm_milisecond_clock();
    double delay = ((double)(now - startTime)) / 1000.0;
    NSString *s = [NSString stringWithFormat:@"%04.3lfs: %@ -> %@",delay,oldstate,newState];
    [_messageHistory addObject:[s printable]];
}

- (NSDictionary *) messageAsDictionary
{
    NSDictionary *dict =
    @{
      @"archiveId"                  :   STRING_NONEMPTY([self archiveId]),
      @"archiveStatus"              :   STRING_FROM_INT([self archiveStatus]),
      @"instanceName"               :   STRING_NONEMPTY([self instanceName]),
      @"messageId"                  :   STRING_NONEMPTY([self messageId]),
      @"userId"                     :   STRING_NONEMPTY([self userId]),
      @"groupId"					:   STRING_NONEMPTY([self groupId]),
      @"deliveryMethod"             :   STRING_NONEMPTY([self deliveryMethodString]),
      @"submissionType"             :   STRING_NONEMPTY([self submissionTypeString]),
      @"fromNumber"                 :   STRING_NONEMPTY([self from]),
      @"receivedFromIp"             :   STRING_NONEMPTY([self receivedFromIp]),
      @"submissionIp"             :   STRING_NONEMPTY([self submissionIp]),
      @"toNumber"					:   STRING_NONEMPTY([self to]),
      @"deliveryReportMsc"          :   STRING_NONEMPTY([self deliveryReportMsc]),
      @"deliveryReportImsi"         :   STRING_NONEMPTY([self deliveryReportImsi]),
      @"fromMsc"					:   STRING_NONEMPTY([self fromMsc]),
      @"fromImsi"					:   STRING_NONEMPTY([self fromImsi]),
      @"toMsc"                      :   STRING_NONEMPTY([self toMsc]),
      @"toImsi"                     :   STRING_NONEMPTY([self toImsi]),
      @"smsc"                       :   STRING_NONEMPTY([self smsc]),
      @"smsc2"                      :   STRING_NONEMPTY([self smsc2]),
      @"smsc3"                      :   STRING_NONEMPTY([self smsc3]),
      @"smsc4"                      :   STRING_NONEMPTY([self smsc4]),
      @"hlr"						:   STRING_NONEMPTY([self hlr]),
      @"created"					:   STRING_NONEMPTY([self created]),
      @"scts"						:   STRING_NONEMPTY([self scts]),
      @"scts_tz"					:   STRING_FROM_INT([self scts_tz]),
      @"qpriority"                  :   STRING_FROM_INT([self qpriority]),
      @"upriority"                  :   STRING_FROM_INT([self upriority]),
      @"messagePriority"			:   STRING_FROM_INT([self messagePriority]),
      @"btype"                      :   STRING_FROM_INT([self btype]),
      @"messageStatus"              :   STRING_NONEMPTY([self messageStatusString]),
      @"messageError1"              :   STRING_FROM_INT([self messageError1]),
      @"messageError2"              :   STRING_FROM_INT([self messageError2]),
      @"messageDelivered"			:   STRING_NONEMPTY([self messageDelivered]),
      @"messageFailed"              :   STRING_NONEMPTY([self messageFailed]),
      @"messageAttempted"			:   STRING_NONEMPTY([self messageAttempted]),
      @"messageExpiry"              :   STRING_NONEMPTY([self messageExpiry]),
      @"messageExpiryTz"			:   STRING_FROM_INT([self messageExpiryTz]),
      @"messageNextAttempt"         :   STRING_NONEMPTY([self messageNextAttempt]),
      @"messageAttempts"			:   STRING_FROM_INT([self messageAttempts]),
      @"messageMaxAttempts"         :   STRING_FROM_INT([self messageMaxAttempts]),
      @"messageWaitingSet"          :   STRING_FROM_INT([self messageWaitingSet]),
      @"deliveryReportMask"         :   STRING_FROM_NUMBER([self deliveryReportMask]),
      @"deliveryReportAddress"      :   STRING_NONEMPTY([self deliveryReportAddress]),
      @"deliveryReportStatus"		:   STRING_NONEMPTY([self deliveryReportStatusString]),
      @"deliveryReportError1"		:   STRING_FROM_INT([self deliveryReportError1]),
      @"deliveryReportError2"		:   STRING_FROM_INT([self deliveryReportError2]),
      @"deliveryReportDelivered"	:   STRING_NONEMPTY([self deliveryReportDelivered]),
      @"deliveryReportFailed"		:   STRING_NONEMPTY([self deliveryReportFailed]),
      @"deliveryReportAttempted"	:   STRING_NONEMPTY([self deliveryReportAttempted]),
      @"deliveryReportExpiry"		:   STRING_NONEMPTY([self deliveryReportExpiry]),
      @"deliveryReportNextAttempt"  :   STRING_NONEMPTY([self deliveryReportNextAttempt]),
      @"deliveryReportAttempts"     :   STRING_FROM_INT([self deliveryReportAttempts]),
      @"deliveryReportMaxAttempts"  :   STRING_FROM_INT([self deliveryReportMaxAttempts]),
      @"deliveryReportWaitingSet"	:   STRING_FROM_INT([self deliveryReportWaitingSet]),
      @"msuCountSriSMTx"			:   STRING_FROM_INT([self msuCountSriSMTx]),
      @"msuCountSriSMRx"			:   STRING_FROM_INT([self msuCountSriSMRx]),
      @"msuCountSriSMHTx"			:   STRING_FROM_INT([self msuCountSriSMHTx]),
      @"msuCountSriSMHRx"			:   STRING_FROM_INT([self msuCountSriSMHRx]),
      @"msuCountSriSMCRx"			:   STRING_FROM_INT([self msuCountSriSMCRx]),
      @"msuCountFsmTx"              :   STRING_FROM_INT([self msuCountFsmTx]),
      @"msuCountFsmRx"              :   STRING_FROM_INT([self msuCountFsmRx]),
      @"msuCountTcapHandshakeTx"	:   STRING_FROM_INT([self msuCountTcapHandshakeTx]),
      @"msuCountTcapHandshakeRx"	:   STRING_FROM_INT([self msuCountTcapHandshakeRx]),
      @"testFlag"					:   STRING_FROM_INT([self testFlag]),
      @"phoneRef"					:   STRING_FROM_INT([self phoneRef]),
      @"udhIndicator"				:   STRING_FROM_INT([self udhIndicator]),
      @"toCountry"                  :   STRING_NONEMPTY([self toCountry]),
      @"toOperatorCode"             :   STRING_NONEMPTY([self toOperatorCode]),
      @"toOperatorName"             :   STRING_NONEMPTY([self toOperatorName]),
      @"replyPath"                  :   STRING_FROM_INT([self replyPath]),
      @"pid"						:   STRING_FROM_INT([self pid]),
      @"compress"					:   STRING_FROM_INT([self compress]),
      @"dcs"						:   STRING_FROM_INT([self dcs]),
      @"mwi_pdu"					:   STRING_FROM_INT([self mwi_pdu]),
      @"udh"						:   STRING_FROM_DATA([self udh]),
      @"content"					:   STRING_FROM_DATA([self content]),
      @"plaintextContent"			:   STRING_NONEMPTY([self plaintextContent32]),
      @"messageClass"				:   STRING_FROM_INT([self messageClass]),
      @"coding"                     :   STRING_FROM_INT([self coding]),
      @"opc"						:   STRING_NONEMPTY([self opc]),
      @"dpc"						:   STRING_NONEMPTY([self dpc]),
      @"opc2"						:   STRING_NONEMPTY([self opc2]),
      @"dpc2"						:   STRING_NONEMPTY([self dpc2]),
      @"tcapType"					:   STRING_FROM_INT([self tcapType]),
      @"extensionData"              :   STRING_NONEMPTY([self extensionData]),
      @"purgeFlag"                  :   STRING_FROM_INT([self purgeFlag]),
      @"alertingAddress"			:   STRING_NONEMPTY([self alertingAddress]),
      @"fromCountry"				:   STRING_NONEMPTY([self fromCountry]),
      @"fromOperatorCode"			:   STRING_NONEMPTY([self fromOperatorCode]),
      @"fromOperatorName"			:   STRING_NONEMPTY([self fromOperatorName]),
      @"routeId"					:   STRING_NONEMPTY([self routeId]),
      @"subrouteId"                 :   STRING_NONEMPTY([self subrouteId]),
      @"routedOnPrefix"             :   STRING_NONEMPTY([self routedOnPrefix]),
      @"autoRouted"                 :   STRING_FROM_INT([self autoRouted]),
      @"userFlags"                  :   STRING_FROM_INT([self userFlags]),
      @"retryPatternTable"          :   STRING_FROM_INT([self retryPatternTable]),
      @"interworkingTapCode"		:   STRING_NONEMPTY([self interworkingTapCode ]),
      @"costTable"                  :   STRING_NONEMPTY([self costTable ]),
      @"msuCostTx"  				:   STRING_FROM_DOUBLE([self msuCostTx]),
      @"msuCostRx"  				:   STRING_FROM_DOUBLE([self msuCostRx]),
      @"smsCost"                    :   STRING_FROM_DOUBLE([self smsCost]),
      @"interworkingCost"			:   STRING_FROM_DOUBLE([self interworkingCost]),
      @"totalCost"                  :   STRING_FROM_DOUBLE([self totalCost]),
      @"chargeTable1"				:   STRING_NONEMPTY([self chargeTable1 ]),
      @"chargePrice1"				:   STRING_FROM_DOUBLE([self chargePrice1]),
      @"profit1"					:   STRING_FROM_DOUBLE([self profit1]),
      @"chargeTable2"				:   STRING_NONEMPTY([self chargeTable2 ]),
      @"chargePrice2"				:   STRING_FROM_DOUBLE([self chargePrice2]),
      @"profit2"					:   STRING_FROM_DOUBLE([self profit2]),
      @"destinationQuotaTable"      :   STRING_NONEMPTY([self destinationQuotaTableName]),
      @"tt_sri"                     :   STRING_FROM_INT([self tt_sri]),
      @"tt_fsm"                     :   STRING_FROM_INT([self tt_fsm]),
      @"dlr_text"                   :   STRING_NONEMPTY([self dlrText]),
      @"comment"                    :   STRING_NONEMPTY([self comment]),
      @"vas_esme"                   :   STRING_NONEMPTY([self vas_esme]),
      @"vas_ip"                     :   STRING_NONEMPTY([self vas_ip]),
      @"deferred"                   :   STRING_NONEMPTY([self deferredString]),
      };
    return dict;
}


- (UMMessage *)initWithDict:(NSDictionary *)d
{
    self=[super init];
    if(self)
    {
        [self setArchiveId:d[@"archiveId"]];
        [self setArchiveStatus:[d[@"archiveStatus"]intValue]];
        [self setInstanceName:d[@"instanceName"]];
        [self setMessageId:d[@"messageId"]];
        [self setUserId:d[@"userId"]];
        [self setGroupId:d[@"groupId"]];
        [self setDeliveryMethodString:d[@"deliveryMethod"]];
        [self setSubmissionTypeString:d[@"submissionType"]];
        [self setFrom:d[@"fromNumber"]];
        [self setReceivedFromIp:d[@"receivedFromIp"]];
        [self setSubmissionIp:d[@"submissionIp"]];
        [self setTo:d[@"toNumber"]];
        [self setDeliveryReportMsc:d[@"deliveryReportMsc"]];
        [self setDeliveryReportImsi:d[@"deliveryReportImsi"]];
        [self setFromMsc:d[@"fromMsc"]];
        [self setFromImsi:d[@"fromImsi"]];
        [self setToMsc:d[@"toMsc"]];
        [self setToImsi:d[@"toImsi"]];
        [self setSmsc:d[@"smsc"]];
        [self setSmsc2:d[@"smsc2"]];
        [self setSmsc3:d[@"smsc3"]];
        [self setSmsc4:d[@"smsc4"]];
        [self setHlr:d[@"hlr"]];
        [self setCreated:d[@"created"]];
        [self setScts:d[@"scts"]];
        [self setScts_tz:[d[@"scts_tz"]intValue]];
        [self setQpriority:[d[@"qpriority"]intValue]];
        [self setUpriority:[d[@"upriority"]intValue]];
        [self setMessagePriority:[d[@"messagePriority"]intValue]];
        [self setBtype:[d[@"btype"]intValue]];
        [self setMessageStatusString:d[@"messageStatus"]];
        [self setMessageError1:[d[@"messageError1"]intValue]];
        [self setMessageError2:[d[@"messageError2"]intValue]];
        [self setMessageDelivered:d[@"messageDelivered"]];
        [self setMessageFailed:d[@"messageFailed"]];
        [self setMessageAttempted:d[@"messageAttempted"]];
        [self setMessageExpiry:d[@"messageExpiry"]];
        [self setMessageExpiryTz:[d[@"messageExpiryTz"]intValue]];
        [self setMessageNextAttempt:d[@"messageNextAttempt"]];
        [self setMessageAttempts:[d[@"messageAttempts"]intValue]];
        [self setMessageMaxAttempts:[d[@"messageMaxAttempts"]intValue]];
        [self setMessageWaitingSet:[d[@"messageWaitingSet"]intValue]];
        [self setDeliveryReportMask:@([d[@"deliveryReportMask"]intValue]]);
        [self setDeliveryReportAddress:d[@"deliveryReportAddress"]];
        [self setDeliveryReportStatusString:d[@"deliveryReportStatus"]];
        [self setDeliveryReportError1:[d[@"deliveryReportError1"]intValue]];
        [self setDeliveryReportError2:[d[@"deliveryReportError2"]intValue]];
        [self setDeliveryReportDelivered:d[@"deliveryReportDelivered"]];
        [self setDeliveryReportFailed:d[@"deliveryReportFailed"]];
        [self setDeliveryReportAttempted:d[@"deliveryReportAttempted"]];
        [self setDeliveryReportExpiry:d[@"deliveryReportExpiry"]];
        [self setDeliveryReportNextAttempt:d[@"deliveryReportNextAttempt"]];
        [self setDeliveryReportAttempts:[d[@"deliveryReportAttempts"]intValue]];
        [self setDeliveryReportMaxAttempts:[d[@"deliveryReportMaxAttempts"]intValue]];
        [self setDeliveryReportWaitingSet:[d[@"deliveryReportWaitingSet"]intValue]];
        [self setMsuCountSriSMTx:[d[@"msuCountSriSMTx"]intValue]];
        [self setMsuCountSriSMRx:[d[@"msuCountSriSMRx"]intValue]];
        [self setMsuCountSriSMHTx:[d[@"msuCountSriSMHTx"]intValue]];
        [self setMsuCountSriSMHRx:[d[@"msuCountSriSMHRx"]intValue]];
        [self setMsuCountSriSMCRx:[d[@"msuCountSriSMCRx"]intValue]];
        [self setMsuCountFsmTx:[d[@"msuCountFsmTx"]intValue]];
        [self setMsuCountFsmRx:[d[@"msuCountFsmRx"]intValue]];
        [self setMsuCountTcapHandshakeTx:[d[@"msuCountTcapHandshakeTx"]intValue]];
        [self setMsuCountTcapHandshakeRx:[d[@"msuCountTcapHandshakeRx"]intValue]];
        [self setTestFlag:[d[@"testFlag"]intValue]];
        [self setPhoneRef:[d[@"phoneRef"]intValue]];
        [self setUdhIndicator:[d[@"udhIndicator"]intValue]];
        [self setToCountry:d[@"toCountry"]];
        [self setToOperatorCode:d[@"toOperatorCode"]];
        [self setToOperatorName:d[@"toOperatorName"]];
        [self setReplyPath:[d[@"replyPath"]intValue]];
        [self setPid:[d[@"pid"]intValue]];
        [self setCompress:[d[@"compress"]intValue]];
        [self setDcs:[d[@"dcs"]intValue]];
        [self setMwi_pdu:[d[@"mwi_pdu"]intValue]];
        [self setUdh:[d[@"udh"]unhexedData]];
        [self setContent:[d[@"content"]unhexedData]];
        //[self setPlaintextContent:d[@"plaintextContent"]];
        [self setMessageClass:[d[@"messageClass"]intValue]];
        [self setCoding:[d[@"coding"]intValue]];
        [self setOpc:d[@"opc"]];
        [self setDpc:d[@"dpc"]];
        [self setOpc2:d[@"opc2"]];
        [self setDpc2:d[@"dpc2"]];
        [self setTcapType:[d[@"tcapType"]intValue]];
        [self setExtensionData:d[@"extensionData"]];
        [self setPurgeFlag:[d[@"purgeFlag"]intValue]];
        [self setAlertingAddress:d[@"alertingAddress"]];
        [self setFromCountry:d[@"fromCountry"]];
        [self setFromOperatorCode:d[@"fromOperatorCode"]];
        [self setFromOperatorName:d[@"fromOperatorName"]];
        [self setRouteId:d[@"routeId"]];
        [self setSubrouteId:d[@"subrouteId"]];
        [self setRoutedOnPrefix:d[@"routedOnPrefix"]];
        [self setAutoRouted:[d[@"autoRouted"]intValue]];
        [self setUserFlags:[d[@"userFlags"]intValue]];
        [self setRetryPatternTable:[d[@"retryPatternTable"]intValue]];
        [self setInterworkingTapCode:d[@"interworkingTapCode"]];
        [self setCostTable:d[@"costTable"]];
        [self setMsuCostTx:[d[@"msuCostTx"]doubleValue]];
        [self setMsuCostRx:[d[@"msuCostRx"]doubleValue]];
        [self setSmsCost:[d[@"smsCost"]doubleValue]];
        [self setInterworkingCost:[d[@"interworkingCost"]doubleValue]];
        //	[self setTotalCost:[d[@"totalCost"]doubleValue]];
        [self setChargeTable1:d[@"chargeTable1"]];
        [self setChargePrice1:[d[@"chargePrice1"]doubleValue]];
        //	[self setProfit1:[d[@"profit1"]doubleValue]];
        [self setChargeTable2:d[@"chargeTable2"]];
        [self setChargePrice2:[d[@"chargePrice2"]doubleValue]];
        //	[self setProfit2:[d[@"profit2"]doubleValue]];
        [self setDestinationQuotaTableName:d[@"destinationQuotaTable"]];
        self.tt_sri=[d[@"tt_sri"]intValue];
        self.tt_fsm=[d[@"tt_fsm"]intValue];
        [self setDlrText:d[@"dlr_text"]];
        [self setComment:d[@"comment"]];
        [self setVas_esme:d[@"vas_esme"]];
        [self setVas_ip:d[@"vas_ip"]];
        [self setDeferredString:d[@"deferred"]];
    }
    return self;
}


#ifdef UNUSED
-(BOOL)updateToDatabaseNew:(BOOL)canFail
{
    if(_userFlags & USERFLAG_DONOT_STORE_IN_DB)
    {
        return YES;
    }
    
    UMDbQuery *query = NULL;
    query = [UMDbQuery queryForFile:__FILE__ line: __LINE__];
    
    UMDbSession *session;
    session = [UMDB_MESSAGE.pool grabSession:FLF];
    
    if(![query isInCache])
    {
        NSArray *fields = [UMDbQuery fieldNamesArrayFromFieldsDefinition:[UMMessage tableDefinition]];
        [query setType:UMDBQUERYTYPE_UPDATE_BY_KEY];
        [query setTable:UMDB_MESSAGE];
        [query setFields:fields];
        [query setPrimaryKeyName:@"archiveId"];
        [query addToCache];
    }
    NSArray *params  = [NSArray arrayWithObjects:
                        STRING_NONEMPTY([self archiveId]),
                        STRING_FROM_INT([self archiveStatus]),
                        STRING_NONEMPTY([self instanceName]),
                        STRING_NONEMPTY([self messageId]),
                        STRING_NONEMPTY([self userId]),
                        STRING_NONEMPTY([self groupId]),
                        STRING_NONEMPTY([self deliveryMethodString]),
                        STRING_NONEMPTY([self submissionTypeString]),
                        STRING_NONEMPTY([self from]),
                        STRING_NONEMPTY([self receivedFromIp]),
                        STRING_NONEMPTY([self submissionIp]),
                        STRING_NONEMPTY([self to]),
                        STRING_NONEMPTY([self deliveryReportMsc]),
                        STRING_NONEMPTY([self deliveryReportImsi]),
                        STRING_NONEMPTY([self fromMsc]),
                        STRING_NONEMPTY([self fromImsi]),
                        STRING_NONEMPTY([self toMsc]),
                        STRING_NONEMPTY([self toImsi]),
                        STRING_NONEMPTY([self smsc]),
                        STRING_NONEMPTY([self smsc2]),
                        STRING_NONEMPTY([self smsc3]),
                        STRING_NONEMPTY([self smsc4]),
                        STRING_NONEMPTY([self hlr]),
                        STRING_NONEMPTY([self created]),
                        STRING_NONEMPTY([self scts]),
                        STRING_FROM_INT([self scts_tz]),
                        STRING_FROM_INT([self qpriority]),
                        STRING_FROM_INT([self upriority]),
                        STRING_FROM_INT([self messagePriority]),
                        STRING_FROM_INT([self btype]),
                        STRING_NONEMPTY([self messageStatusString]),
                        STRING_FROM_INT([self messageError1]),
                        STRING_FROM_INT([self messageError2]),
                        STRING_NONEMPTY([self messageDelivered]),
                        STRING_NONEMPTY([self messageFailed]),
                        STRING_NONEMPTY([self messageAttempted]),
                        STRING_NONEMPTY([self messageExpiry]),
                        STRING_FROM_INT([self messageExpiryTz]),
                        STRING_NONEMPTY([self messageNextAttempt]),
                        STRING_FROM_INT([self messageAttempts]),
                        STRING_FROM_INT([self messageMaxAttempts]),
                        STRING_FROM_INT([self messageWaitingSet]),
                        STRING_FROM_NUMBER([self deliveryReportMask]),
                        STRING_NONEMPTY([self deliveryReportAddress]),
                        STRING_NONEMPTY([self deliveryReportStatusString]),
                        STRING_FROM_INT([self deliveryReportError1]),
                        STRING_FROM_INT([self deliveryReportError2]),
                        STRING_NONEMPTY([self deliveryReportDelivered]),
                        STRING_NONEMPTY([self deliveryReportFailed]),
                        STRING_NONEMPTY([self deliveryReportAttempted]),
                        STRING_NONEMPTY([self deliveryReportExpiry]),
                        STRING_NONEMPTY([self deliveryReportNextAttempt]),
                        STRING_FROM_INT([self deliveryReportAttempts]),
                        STRING_FROM_INT([self deliveryReportMaxAttempts]),
                        STRING_FROM_INT([self deliveryReportWaitingSet]),
                        STRING_FROM_INT([self msuCountSriSMTx]),
                        STRING_FROM_INT([self msuCountSriSMRx]),
                        STRING_FROM_INT([self msuCountSriSMHTx]),
                        STRING_FROM_INT([self msuCountSriSMHRx]),
                        STRING_FROM_INT([self msuCountSriSMCRx]),
                        STRING_FROM_INT([self msuCountFsmTx]),
                        STRING_FROM_INT([self msuCountFsmRx]),
                        STRING_FROM_INT([self msuCountTcapHandshakeTx]),
                        STRING_FROM_INT([self msuCountTcapHandshakeRx]),
                        STRING_FROM_INT([self testFlag]),
                        STRING_FROM_INT([self phoneRef]),
                        STRING_FROM_INT([self udhIndicator]),
                        STRING_NONEMPTY([self toCountry]),
                        STRING_NONEMPTY([self toOperatorCode]),
                        STRING_NONEMPTY([self toOperatorName]),
                        STRING_FROM_INT([self replyPath]),
                        STRING_FROM_INT([self pid]),
                        STRING_FROM_INT([self compress]),
                        STRING_FROM_INT([self dcs]),
                        STRING_FROM_INT([self mwi_pdu]),
                        STRING_FROM_DATA([self udh]),
                        STRING_FROM_DATA([self content]),
                        STRING_NONEMPTY([self plaintextContent]),
                        STRING_FROM_INT([self messageClass]),
                        STRING_FROM_INT([self coding]),
                        STRING_NONEMPTY([self opc]),
                        STRING_NONEMPTY([self dpc]),
                        STRING_NONEMPTY([self opc2]),
                        STRING_NONEMPTY([self dpc2]),
                        STRING_FROM_INT([self tcapType]),
                        STRING_NONEMPTY([self extensionData]),
                        STRING_FROM_INT([self purgeFlag]),
                        STRING_NONEMPTY([self alertingAddress]),
                        STRING_NONEMPTY([self fromCountry]),
                        STRING_NONEMPTY([self fromOperatorCode]),
                        STRING_NONEMPTY([self fromOperatorName]),
                        STRING_NONEMPTY([self routeId]),
                        STRING_NONEMPTY([self subrouteId]),
                        STRING_NONEMPTY([self routedOnPrefix]),
                        STRING_FROM_INT([self autoRouted]),
                        STRING_FROM_INT([self userFlags]),
                        STRING_FROM_INT([self retryPatternTable]),
                        STRING_NONEMPTY([self interworkingTapCode ]),
                        STRING_NONEMPTY([self costTable ]),
                        STRING_FROM_DOUBLE([self msuCostTx]),
                        STRING_FROM_DOUBLE([self msuCostRx]),
                        STRING_FROM_DOUBLE([self smsCost]),
                        STRING_FROM_DOUBLE([self interworkingCost]),
                        STRING_FROM_DOUBLE([self totalCost]),
                        STRING_NONEMPTY([self chargeTable1 ]),
                        STRING_FROM_DOUBLE([self chargePrice1]),
                        STRING_FROM_DOUBLE([self profit1]),
                        STRING_NONEMPTY([self chargeTable2 ]),
                        STRING_FROM_DOUBLE([self chargePrice2]),
                        STRING_FROM_DOUBLE([self profit2]),
                        STRING_NONEMPTY([self destinationQuotaTableName]),
                        STRING_FROM_INT([self tt_sri]),
                        STRING_FROM_INT([self tt_fsm]),
                        STRING_NONEMPTY([self dlrText]),
                        STRING_NONEMPTY([self comment]),
                        STRING_NONEMPTY([self vas_esme]),
                        STRING_NONEMPTY([self vas_ip]),
                        STRING_NONEMPTY([self deferredstring]),
                        @"0", /* exported */
                        NULL];
    BOOL result =  [session cachedQueryWithNoResult:query parameters:params  allowFail:canFail primaryKeyValue:self.archiveId ];
    [session.pool returnSession:session file:FLF];
    return result;
}
#endif


- (void)setHistoryText:(NSString *)text
{
    _historyHasBeenInserted=YES;
    _messageHistory = [[UMHistoryLog alloc]initWithString:text];
}

- (UMUser *)usr
{
    return [UMUser userById:self.userId.integerValue];
}

/* input is a UTF8 String */
- (void)setPlaintextContent:(NSString *)string
{
    NSData *data = [string gsm8];
    self.content = data;

/*
    Octstr *str = octstr_create(s.UTF8String);
    charset_utf8_to_gsm(str);
    msg_set_content_from_binary(self,str);
    plaintextContent = s;
*/
    
}

- (NSString *)plaintextContent
{
    NSString *str = [self.content stringFromGsm8];
    return str;
}

- (NSString *)plaintextContent32
{
    char out[32];
    int i;
    int j=0;
    NSString *s = [self plaintextContent];
    NSInteger max  = [s length];
    if (max > 31)
    {
        max = 31;
    }
    for(i=0;i<max;i++)
    {
        unichar c = [s characterAtIndex:i];
        if(c > 0xFF)
        {
            continue;
        }
        if(isprint((char)c))
        {
            out[j++] = (char)c;
        }
    }
    out[j++]='\0';
    return [NSString stringWithUTF8String:&out[0]];
}


/* from old function static void set_parameters_from_user(UMMessage *msg, UMUser *usr, NSString *smsc) /*/
- (void)copyUserDefaults:(UMUser *)usr;
{
    self.uid = usr.uid;
    self.gid = usr.gid;
    self.deliveryMethodString = usr.method;
    self.upriority = usr.defpri;
    self.smsc  = usr.smsc;
    self.smsc2 = usr.smsc2;
    self.smsc3 = usr.smsc3;
    self.smsc4 = usr.smsc4;
    self.fromMsc = usr.msc;
    self.tt_sri = usr.tt_sri;
    self.tt_fsm = usr.tt_fsm;
    self.hlrOverride = usr.hlr_override;
    self.messageMaxAttempts = usr.s_maxatt;
    self.extensionData = usr.options;
    
    if(_userFlags & USERFLAG_USE_PHASE3)
    {
        self.phase = 3;
    }
    if(_userFlags & USERFLAG_USE_PHASE2)
    {
        self.phase = 2;
    }
    if(_userFlags & USERFLAG_USE_PHASE1)
    {
        self.phase = 1;
    }
}

- (NSData *)pduContent
{
    return self.content;
}

- (void)setPduContent:(NSData *)d
{
    self.content = d;
}


- (void) setPduUdhi:(NSInteger)i
{
    self.udhIndicator = i;
}
- (NSInteger) pduUdhi
{
    return self.udhIndicator;
}


- (NSData *)pduContentIncludingUdh
{
    if(self.pduUdhi)
    {
        NSMutableData *d = [NSMutableData dataWithData:self.pduUdh];
        [d appendData:self.pduContent];
        return d;
    }
    else
    {
        return self.pduContent;
    }
}

- (NSDate *)attemptedDate
{
    return [NSDate dateWithStandardDateString:self.messageAttempted];
}

- (NSDate *)submitDate
{
    return [NSDate dateWithStandardDateString:self.created];
}

- (NSDate *)submitAckTime
{
    return submitAckTime;
}

- (void) setSubmitAckTime:(NSDate *)d
{
    submitAckTime = d;
}

- (void) setValidity:(NSDate *)d
{
    self.messageExpiry = [d stringValue];
}

- (NSDate *)validity
{
    return [_messageExpiry dateValue];
}

- (void) setDeferred:(NSDate *)d
{
    self.deferredString = [d stringValue];
}

- (NSDate *)deferred
{
    return [_deferredString dateValue];
}

- (void) setSubmitString: (NSString *)s
{
    
}

- (NSString *)submitString
{
    /* FIXME */
    return NULL;
}

- (NSDate *)submitErrTime
{
    /* FIXME */
    return NULL;
}
- (void) setSubmitErrTime:(NSDate *)d
{
    /* FIXME */
}
- (NSInteger)submitErrCode
{
    /* FIXME */
    return 0;
}

- (void) setSubmitErrCode:(NSInteger)err
{
    /* FIXME */
}


- (void)setNetworkErrorCode:(int)c
{
    /* FIXME */
}

- (void) setUserTransaction:(id)transaction
{
    /* FIXME */
}

- (id) userTransaction
{
    /* FIXME */
    return NULL;
}

- (void) setRouterTransaction:(id)transaction
{
    
}

- (id) routerTransaction
{
    /* FIXME */
    return NULL;
}

- (int) priority
{
    /* FIXME */
    return 0;
}

- (void) setPriority:(int)prio
{
    /* FIXME */
}

- (int) replaceIfPresentFlag
{
    /* FIXME */
    return 0;
}

- (void) setReplaceIfPresentFlag:(int)i
{
    /* FIXME */
}

- (id)originalSendingObject
{
    return _originalSendingObject;
}

- (void)setOriginalSendingObject:(id)obj
{
    _originalSendingObject = obj;
}

- (NSString *)instance
{
    return self.instanceName;
}
- (void)setInstance:(NSString *)instance
{
    self.instanceName = instance;
}

- (void) setRouterReference:(NSString *)msgid
{
    self.messageId = msgid;
}

- (NSString *)routerReference
{
    return messageId;
}

- (void)setUser:(id)u
{
    /* FIXME */
}
- (UMUser *)user
{
    /* FIXME */
    return NULL;
}


- (void) setProviderReference:(NSString *)msgid
{
    providerReference = msgid;
}

- (NSString *)providerReference
{
    return providerReference;
}

- (NSString *)type
{
    return self.submissionTypeString;
}

- (void) setType:(NSString *)m
{
    self.submissionTypeString = m;
}

- (NSString *)method
{
    return self.deliveryMethodString;
}

- (void) setMethod:(NSString *)m
{
    self.deliveryMethodString = m;
}

- (BOOL)scriptDebugging
{
    if (self.userFlags & USERFLAG_ENABLE_SCRIPT_DEBUGGING)
    {
        return YES;
    }
    return NO;
}

- (void)packExtensionData
{
    NSMutableString *e = [[NSMutableString alloc]init];
    for(NSString *key in _extensionOptions)
    {
        NSString *value = _extensionOptions[key];
        if(e.length>0)
        {
            [e appendString:@","];
        }
        [e appendFormat:@"%@=%@",[key urlencode],[value urlencode]];
    }
    _extensionData = e;
    _dirtyExtensionData = YES;
    dirty = YES;
}


- (void)expandExtensionData
{
    if(_extensionData.length == 0)
    {
        _extensionOptions = @{};
    }
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];

    NSArray *a = [_extensionData componentsSeparatedByString:@","];
    for (NSString *item in a)
    {
        NSArray *b = [item componentsSeparatedByString:@"="];
        if( [b count]==2)
        {
            NSString *var = [[b[0] urldecode] trim];
            NSString *val = [[b[1] urldecode] trim];
            dict[var]=val;
        }
        else
        {
            dict[item]=@"1";
        }
    }
    _extensionOptions = dict;
}

- (int) phase
{
    if(self.userFlags & USERFLAG_USE_PHASE3)
    {
        return 3;
    }
    if(self.userFlags & USERFLAG_USE_PHASE2)
    {
        return 2;
    }
    if(self.userFlags & USERFLAG_USE_PHASE1)
    {
        return 1;
    }
    return [_extensionOptions[@"phase"] intValue];
}

- (void)setPhase:(int)p
{
    self.userFlags = self.userFlags & ~USERFLAG_USE_PHASE3;
    self.userFlags = self.userFlags & ~USERFLAG_USE_PHASE2;
    self.userFlags = self.userFlags & ~USERFLAG_USE_PHASE1;
    switch(p)
    {
        case 0:
            break;
        case 1:
            self.userFlags = self.userFlags | USERFLAG_USE_PHASE1;
            break;
        case 2:
            self.userFlags = self.userFlags | USERFLAG_USE_PHASE2;
            break;
        case 3:
            self.userFlags = self.userFlags | USERFLAG_USE_PHASE3;
            break;
    }
    NSMutableDictionary *e;
    if(_extensionOptions)
    {
        e = [_extensionOptions mutableCopy];
    }
    else
    {
        e = [[NSMutableDictionary alloc]init];
    }
    e[@"phase"] = [NSString stringWithFormat:@"%d",p];
    _extensionOptions = e;
}


- (void)setApplicationContext:(NSString *)ac
{
    NSMutableDictionary *e;
    if(_extensionOptions)
    {
        e = [_extensionOptions mutableCopy];
    }
    else
    {
        e = [[NSMutableDictionary alloc]init];
    }
    e[@"application-context"] = ac;
    _extensionOptions = e;
}

- (void)setApplicationContextSriSM:(NSString *)ac
{
    NSMutableDictionary *e;
    if(_extensionOptions)
    {
        e = [_extensionOptions mutableCopy];
    }
    else
    {
        e = [[NSMutableDictionary alloc]init];
    }
    e[@"application-context-srism"] = ac;
    _extensionOptions = e;
}

- (void)setApplicationContextForwardSM:(NSString *)ac
{
    NSMutableDictionary *e;
    if(_extensionOptions)
    {
        e = [_extensionOptions mutableCopy];
    }
    else
    {
        e = [[NSMutableDictionary alloc]init];
    }
    e[@"application-context-forwardsm"] = ac;
    _extensionOptions = e;
}

/* make SmscConnectionMessageProtocol happy */

- (int)dbStatusFlags
{
    return -2;
}


- (void)setDbStatusFlags:(int)flags
{
    
}
- (NSString *)addr
{
    return @"undefined addr";
}

- (NSString *)inboundMethod
{
    return @"undefined inboundMethod";
}

- (void) setInboundMethod:(NSString *)method
{
    
}

- (NSString *)inboundType;
{
    return @"undefined inboundType";
}

- (void) setInboundType:(NSString *)type
{
}

- (NSString *)inboundAddress
{
    return @"undefined inboundAddress";
}

- (void) setInboundAddress:(NSString *)addr
{
    
}
- (void) setReportTo:(UMSigAddr *)reportTo
{
    
}
- (UMSigAddr *)reportTo
{
    return NULL;
}

- (void) setReportMask:(UMReportMaskValue)mask
{
    
}
- (UMReportMaskValue) reportMask
{
    return 0;
}

- (void) setPduDcs:(NSInteger)dcs
{
    
}
- (NSInteger) pduDcs
{
    return -2;
}

- (void) setPduCoding:(NSInteger)coding
{
}
- (NSInteger) pduCoding
{
    return -2;
}
- (void) setPduPid:(NSInteger)pid
{
    
}
- (NSInteger) pduPid
{
    return -2;
}
- (void) setPduRp:(NSInteger)rp
{
    
}
- (NSInteger) pduRp
{
    return -2;
}


- (NSData *)pduUdh
{
    return udh;
}




- (void)setPduUdh:(NSData *)xudh
{
    self.udh = xudh;
}

- (NSInteger)messageClass
{
    return _messageClass;
}

- (void)setMessageClass:(NSInteger)messageClass
{
    _messageClass = messageClass;
}


- (int)messageStateCode
{
    return _messageStateCode;
}

- (void)setMessageStateCode:(int)state
{
    _messageStateCode = state;
}


- (void) setUdh:(NSData *)data
{
    udh = data;
    if(data.length < 2)
    {
        return;
    }

    const uint8_t *bytes = data.bytes;
    NSInteger len  = data.length;
    NSInteger i;

    if(bytes[0] != len - 1)
    {
        /* invalid-length */
        return;
    }

    /*  Multipart example:
        05 < total UDH length
        00 < iei multipart
        03 < ieilen
        02 < ref
        02 < max parts
        01 < current part
    */
    for(i=1;i<(len-1);i++)
    {
        int iei = bytes[i];
        int ielen = bytes[i+1];
        if( (len - 2 - i ) < ielen)
        {
            /* not enough remaining bytes */
            break;
        }
        const uint8_t *iebytes = &bytes[i+2];
        i += ielen+2;
        switch(iei)
        {
            case 0x00:
            {
                 /* concatenated */
                if(ielen !=3)
                {
                    /* invalid-ielength */
                    break;
                }
                _isMultipart = YES;
                _multipartRef = iebytes[0];
                _multipartMax = iebytes[1];
                _multipartCurrent = iebytes[2];
                break;
            }
            case 0x01:
            {
               /* Special SMS Message Indication */
                if(ielen !=2)
                {
                    /* invalid-ielength */
                    break;
                }
                break;
            }
            case 0x03:
            {
                /* Special SMS Message Indication */
                if(ielen !=2)
                {
                    /* invalid-ielength */
                    break;
                }
                break;
            }
            case 0x04:
            {
                /* Application port addressing scheme 8bit */
                if(ielen !=2)
                {
                    /* invalid-ielength */
                    break;
                }
                break;
            }
            case 0x05:
            {
                /* Application port addressing scheme 16bit */
                if(ielen !=4)
                {
                    /* invalid-ielength */
                    break;
                }
                break;
            }
            case 0x06:
            {
                /* ASMSC Control Parameters */
                if(ielen !=1)
                {
                    /* invalid-ielength */
                    break;
                }
                break;
            }
            case 0x07:
            {
                /* UDH Source Indicator */
                if(ielen !=1)
                {
                    /* invalid-ielength */
                    break;
                }
                break;
            }
            case 0x08:
            {
                /* Concatenated short message, 16-bit reference */
                if(ielen !=4)
                {
                    /* invalid-ielength */
                    break;
                }
                break;
            }
            case 0x09:
            {
                /* WCMP */
                break;
            }
            case 0x0A:
            {
                /* Text Formatting EMS */
                break;
            }
            case 0x0B:
            {
                /* Predefined Sound    EMS */
                break;
            }
            case 0x0C:
            {
                /* User Defined Sound (iMelody EMS) */
                break;
            }
            case 0x0D:
            {
                /* Predefined Animation (EMS) */
                break;
            }
            case 0x0E:
            {
                /* Large Animation (EMS) */
                break;
            }
            case 0x0F:
            {
                /* Small Animation (EMS) */
                break;
            }
            case 0x10:
            {
                /* Large Picture (EMS) */
                break;
            }
            case 0x11:
            {
                /* Smalll Picture (EMS) */
                break;
            }
            case 0x12:
            {
                /* Variable Picture (EMS) */
                break;
            }
            case 0x13:
            {
                /* User prompt indicator (EMS) */
                break;
            }
            case 0x14:
            {
                /* Extended Object (EMS) */
                break;
            }
            case 0x15:
            {
                /* Reused Extended Object (EMS) */
                break;
            }
            case 0x16:
            {
                /* Compression Control (EMS) */
                break;
            }
            case 0x17:
            {
                /* Object Distribution Indicator (EMS) */
                break;
            }
            case 0x18:
            {
                /* Standard WVG object (EMS) */
                break;
            }
            case 0x19:
            {
                /* Character Size WVG object (EMS) */
                break;
            }
            case 0x1A:
            case 0x1B:
            case 0x1C:
            case 0x1D:
            case 0x1E:
            case 0x1F:
            {
                /* Extended Object Data Request Command (EMS) */
                break;
            }

            case 0x20:
            {
                /* RFC 822 E-Mail Header */
                break;
            }
            case 0x21:
            {
                /* Hyperlink format element */
                break;
            }
            case 0x22:
            {
                /* Reply Address Element */
                break;
            }
            case 0x23:
            {
                /* Enhanced Voice Mail Information */
                break;
            }
            case 0x24:
            {
                /* National Language Single Shift*/
                _language_shift_table_number=iebytes[0];
                break;
            }
            case 0x25:
            {
                /* National Language Locking Shift */
                _language_lock_table_number=iebytes[0];
                break;
            }
            default:
                if((iei >=0x26) && (iei <=0x6F))
                {
                    /* Reserved for future use */
                    break;
                }
                if((iei >=0x70) && (iei <=0x7F))
                {
                    /* (U)SIM Toolkit Security Headers */
                    break;
                }
                else if((iei >=0x80) && (iei <=0x9F))
                {
                    /* SME to SME specific use */
                    break;
                }
                else if((iei >=0xA0) && (iei <=0xBF))
                {
                    /* SME to SME specific use */
                    break;
                }
                else if((iei >=0xC0) && (iei <=0xDF))
                {
                    /* SC specific use */
                    break;
                }
                else if((iei >=0xE0) && (iei <=0xFF))
                {
                    /* Reserved for future use */
                    break;
                }
                break;
        }
    }
}

- (NSData *) udh
{
    return udh;
}


/* TLV trigger */
- (void)specialAction:(NSString *)action data:(NSString *)data
{
    if([action isEqualToString:@"S1"])
    {
        NSString *s = self.to;
        self.to = self.from;
        self.from = s;
        self.deliveryMethod = METHOD_MO;
    }
    if([action isEqualToString:@"S2"])
    {
        NSString *s = self.to;
        self.to = self.from;
        self.from = s;
        self.deliveryMethod = METHOD_MO2;
    }
}

#define LIMIT_TO_16BIT(i) \
    if(i>0x7FFF) \
    {\
        i = 0x7FFF; \
    } \
    else if(i<-0x7FFF) \
    { \
        i = - 0x7FFF; \
    }

/* these values are limited to 16 bit in DB */
- (void)setMsuCountSriSMTx:(long)i
{
    LIMIT_TO_16BIT(i);
    _msuCountSriSMTx = i;
}
- (long)msuCountSriSMTx
{
    return     _msuCountSriSMTx;
}

- (void)setMsuCountSriSMRx:(long)i
{
    LIMIT_TO_16BIT(i);
    _msuCountSriSMRx = i;
}
- (long)msuCountSriSMRx
{
    return     _msuCountSriSMRx;
}



- (void)setMsuCountSriSMHTx:(long)i
{
    LIMIT_TO_16BIT(i);
    _msuCountSriSMHTx = i;
}

- (long)msuCountSriSMHTx
{
    return     _msuCountSriSMHTx;
}



- (void)setMsuCountSriSMHRx:(long)i
{
    LIMIT_TO_16BIT(i);
    _msuCountSriSMHRx = i;
}

- (long)msuCountSriSMHRx
{
    return     _msuCountSriSMHRx;
}



- (void)setMsuCountFsmTx:(long)i
{
    LIMIT_TO_16BIT(i);
    _msuCountFsmTx = i;
}

- (long)msuCountFsmTx
{
    return     _msuCountFsmTx;
}


- (void)setMsuCountFsmRx:(long)i
{
    LIMIT_TO_16BIT(i);
    _msuCountFsmRx = i;
}

- (long)msuCountFsmRx
{
    return     _msuCountFsmRx;
}

- (void)setMsuCountTcapHandshakeRx:(long)i
{
    LIMIT_TO_16BIT(i);
    _msuCountTcapHandshakeRx = i;
}

-(long)msuCountTcapHandshakeRx
{
    return _msuCountTcapHandshakeRx;
}
- (void)setMsuCountTcapHandshakeTx:(long)i
{
    LIMIT_TO_16BIT(i);
    _msuCountTcapHandshakeTx = i;
}

-(long)msuCountTcapHandshakeTx
{
    return _msuCountTcapHandshakeTx;
}

+ (NSArray *)loadStatusNew
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    UMDbQuery *query = [UMDbQuery queryForFile:__FILE__ line: __LINE__];
    if(![query isInCache])
    {
        [query setType:UMDBQUERYTYPE_SELECT];
        [query setTable:UMDB_MESSAGE];
        [query setFields:@[@"archiveId"]];
        query.whereCondition = [UMDbQueryCondition queryConditionLeft:[UMDbQueryPlaceholder placeholderField:@"messageStatus"]
                                                                    op:UMDBQUERY_OPERATOR_EQUAL
                                                                 right:[UMDbQueryPlaceholder placeholderString:@"new"]];
        [query addToCache];
    }
    UMDbSession *session = [UMDB_MESSAGE.pool grabSession:FLF];
    UMDbResult *result = [session cachedQueryWithMultipleRowsResult:query parameters:@[] allowFail:NO primaryKeyValue:NULL];
    [session.pool returnSession:session file:FLF];
    NSArray *row = [result fetchRow];
    while(row)
    {
        [arr addObject:[row[0] stringValue]];
        row = [result fetchRow];
    }
    return arr;
}

- (NSString *)userFlagsDescription
{
    NSMutableString *s = [[NSMutableString alloc]init];
    if(_userFlags & USERFLAG_ALLOW_NON_INTERNATIONAL)
    {
        [s appendString:@"ALLOW_NON_INTERNATIONAL "];
    }

    if(_userFlags & USERFLAG_FIX_INVALID_NPI)
    {
        [s appendString:@"FIX_INVALID_NPI "];
    }

    if(_userFlags & USERFLAG_IGNORE_BLACKLISTS)
    {
        [s appendString:@"IGNORE_BLACKLISTS "];
    }

    if(_userFlags & USERFLAG_EXTENDED_SMPP_ATTRIBUTES)
    {
        [s appendString:@"EXTENDED_SMPP_ATTRIBUTES "];
    }

    if(_userFlags & USERFLAG_USE_SECONDARY_HLR)
    {
        [s appendString:@"USE_SECONDARY_HLR "];
    }

    if(_userFlags & USERFLAG_DONOT_STORE_IN_DB)
    {
        [s appendString:@"DONOT_STORE_IN_DB "];
    }

    if(_userFlags & USERFLAG_ENABLE_HISTORY)
    {
        [s appendString:@"ENABLE_HISTORY "];
    }

    if(_userFlags & USERFLAG_ENGINE_V2)
    {
        [s appendString:@"ENGINE_V2 "];
    }

    if(_userFlags & USERFLAG_USE_OPCODE_MT)
    {
        [s appendString:@"USE_OPCODE_MT "];
    }

    if(_userFlags & USERFLAG_USE_PHASE2)
    {
        [s appendString:@"USE_PHASE2 "];
    }

    if(_userFlags & USERFLAG_MSC_IMSI_PROVIDED_BY_USER)
    {
        [s appendString:@"MSC_IMSI_PROVIDED_BY_USER "];
    }

    if(_userFlags & USERFLAG_SKIP_SERIALISATION)
    {
        [s appendString:@"SKIP_SERIALISATION "];
    }

    if(_userFlags & USERFLAG_ENABLE_SCRIPT_DEBUGGING)
    {
        [s appendString:@"ENABLE_SCRIPT_DEBUGGING "];
    }

    if(_userFlags & USERFLAG_USE_PHASE3)
    {
        [s appendString:@"USE_PHASE3 "];
    }

    if(_userFlags & USERFLAG_HLR_BYPASS)
    {
        [s appendString:@"HLR_BYPASS "];
    }

    if(_userFlags & USERFLAG_MO_PERMANENT_DLR)
    {
        [s appendString:@"MO_PERMANENT_DLR "];
    }

    if(_userFlags & USERFLAG_TCAP_OPERATION_GLOBAL_SRISM)
    {
        [s appendString:@"TCAP_OPERATION_GLOBAL_SRISM "];
    }

    if(_userFlags & USERFLAG_TCAP_OPERATION_GLOBAL_FSM)
    {
        [s appendString:@"TCAP_OPERATION_GLOBAL_FSM "];
    }

    if(_userFlags & USERFLAG_FSM_SENT_AS_SUCCESS)
    {
        [s appendString:@"FSM_SENT_AS_SUCCESS "];
    }

    if(_userFlags & USERFLAG_DISABLE_ARCHIVE)
    {
        [s appendString:@"DISABLE_ARCHIVE "];
    }

    if(_userFlags & USERFLAG_DISABLE_REPORT_SM_DELIVERY_STATUS)
    {
        [s appendString:@"DISABLE_REPORT_SM_DELIVERY_STATUS "];
    }

    if(_userFlags & USERFLAG_USE_XUDT)
    {
        [s appendString:@"USE_XUDT "];
    }

    if(_userFlags & USERFLAG_USE_SEGMENTATION)
    {
        [s appendString:@"USE_SEGMENTATION "];
    }

    if(_userFlags & USERFLAG_USE_SRILCS)
    {
        [s appendString:@"USE_SRILCS "];
    }

    if(_userFlags & USERFLAG_USE_PRIVATE_EXTENSIONS)
    {
        [s appendString:@"USE_PRIVATE_EXTENSIONS "];
    }

    if(_userFlags & USERFLAG_USE_SRIVOICE)
    {
        [s appendString:@"USE_SRIVOICE "];
    }

    if(_userFlags & USERFLAG_USE_PHASE1)
    {
        [s appendString:@"USE_PHASE1 "];
    }

    if(_userFlags & USERFLAG_USE_OPCODE_MO)
    {
        [s appendString:@"USE_OPCODE_MO "];
    }

    if(_userFlags & USERFLAG_TRY_SECONDARY_HLR)
    {
        [s appendString:@"TRY_SECONDARY_HLR "];
    }
    return s;
}

@end

