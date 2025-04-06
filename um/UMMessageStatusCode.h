//
//  UMMessageState.h
//  ummessage
//
//  Created by Andreas Fink on 26.03.2025.
//

#import <Foundation/Foundation.h>
/*
 
    UMMessageStatusCode is used in a multitude of ways. Not all status code make sense in all use cases. For example inside a SMPP delivery report
    only a subset of codes are used. We never the less use a unified set of codes so we can use the same strings everywhere.
    Internally these codes should be stored as strings and not as numerical value as future versions might include new values and shift codes.
    This way old database entries are never affected from upgrades
 */
typedef    enum UMMessageStatusCode
{
    UMMESSAGE_STATUS_NOT_USED       = 0,     /* this is indicated that no operation will occur. for example
                                                on delivery report status when there is no delivery report asked */
    UMMESSAGE_STATUS_NEW            = 100,   /* this internal status indicates a new message not being attemted to be delivered yet */
    UMMESSAGE_STATUS_ENROUTE        = 101,   /* this indicates it is being processed. This can be used in SMPP */
    UMMESSAGE_STATUS_BUFFERED       = 102,   /* this means a delivery attemt has been made but the message is now buffered for further attemps */
    UMMESSAGE_STATUS_DELIVERED      = 201,   /* message got delivered fine . final state */
    UMMESSAGE_STATUS_FAILED         = 202,   /* message failed to deliver . final state*/
    UMMESSAGE_STATUS_IGNORED        = 105,   /* message is ignored/discarded. . final state*/
    UMMESSAGE_STATUS_APIBUF         = 106,   /* message is buffered towards a inbound ESME or API */
    UMMESSAGE_STATUS_HLRSENT        = 107,   /* SRISM was sent but no response received yet */
    UMMESSAGE_STATUS_HLRRECEIVED    = 108,   /* SRISM response was received but no forwardSM was sent yet */
    UMMESSAGE_STATUS_HLR2SENT       = 109,   /* second SRISM was sent */
    UMMESSAGE_STATUS_MSGSENT        = 110,   /* ForwardSM was sent */
    UMMESSAGE_STATUS_ATISENT        = 111,   /* ATI was sent */
    UMMESSAGE_STATUS_ATIRECEIVED    = 112,   /* ATI response was received */
    UMMESSAGE_STATUS_SRISENT        = 113,   /* SRI was sent */
    UMMESSAGE_STATUS_SRIRECEIVED    = 114,   /* SRI response was received */
    UMMESSAGE_STATUS_PSISENT        = 115,   /* PSI was sent */
    UMMESSAGE_STATUS_PSIRECEIVED    = 116,   /* PSI response was received */
    UMMESSAGE_STATUS_PSLSENT        = 117,   /* PSL was sent */
    UMMESSAGE_STATUS_PSLRECEIVED    = 118,   /* PSL response was received */
    UMMESSAGE_STATUS_SISENT         = 119,   /* SI was sent */
    UMMESSAGE_STATUS_SIRECEIVED     = 120,   /* SI was received */
    UMMESSAGE_STATUS_SRILCSSENT     = 121,   /* SRILCS was sent */
    UMMESSAGE_STATUS_SRILCSRECEIVED = 122,   /* SRILCS was received */
    UMMESSAGE_STATUS_SAISENT        = 123,   /* SAI was sent */
    UMMESSAGE_STATUS_SAIRECEIVED    = 124,   /* SAI was received */
    UMMESSAGE_STATUS_ULSENT         = 125,   /* UL was sent */
    UMMESSAGE_STATUS_ULRECEIVED     = 126,   /* UL was received */
    UMMESSAGE_STATUS_MOAUTH_FAILED  = 127,   /* MO authentication failed */
    UMMESSAGE_STATUS_EXPIRED        = 128,   /* message is now expired (SMPP DLR) */
    UMMESSAGE_STATUS_UNDELIVERABLE  = 129,   /* message is undeliverable (SMPP DLR) */
    UMMESSAGE_STATUS_ACCEPTED       = 130,   /* message has been accepted (SMPP DLR) */
    UMMESSAGE_STATUS_REJECTED       = 131,   /* message has been rejected(SMPP DLR) */
    UMMESSAGE_STATUS_DELETED        = 132,   /* message has been deleted (SMPP DLR) */
    UMMESSAGE_STATUS_SUBMITTED      = 133,   /* message has been submitted (SMPP DLR) */
    UMMESSAGE_STATUS_UNDEFINED      = 134,   /* message state is undefined/unknown */
} UMMessageStatusCode;


NSString        *stringFromMessageState(UMMessageStatusCode ms);
UMMessageStatusCode  messageStateFromString(NSString *str);


