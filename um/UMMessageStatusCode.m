//
//  UMMessageState.m
//  um
//
//  Created by Andreas Fink on 26.03.2025.
//

#import "UMMessageStatusCode.h"

NSString        *stringFromMessageState(UMMessageStatusCode ms)
{
    static NSDictionary *stringFromStatusCode;
    if(stringFromStatusCode==NULL)
    {
        stringFromStatusCode = @{
            @(UMMESSAGE_STATUS_NOT_USED)        : @"NOT_USED",
            @(UMMESSAGE_STATUS_UNDEFINED)       : @"UNDEFINED",
            @(UMMESSAGE_STATUS_NEW)             : @"NEW",
            @(UMMESSAGE_STATUS_ENROUTE)         : @"ENROUTE",
            @(UMMESSAGE_STATUS_BUFFERED)        : @"BUFFERED",
            @(UMMESSAGE_STATUS_DELIVERED)       : @"DELIVRD",
            @(UMMESSAGE_STATUS_FAILED)          : @"FAILED",
            @(UMMESSAGE_STATUS_IGNORED)         : @"IGNORED",
            @(UMMESSAGE_STATUS_APIBUF)          : @"APIBUF",
            @(UMMESSAGE_STATUS_HLRSENT)         : @"HLRSENT",
            @(UMMESSAGE_STATUS_HLRRECEIVED)     : @"HLRRECEIVED",
            @(UMMESSAGE_STATUS_HLR2SENT)        : @"HLR2SENT",
            @(UMMESSAGE_STATUS_MSGSENT)         : @"MSGSENT",
            @(UMMESSAGE_STATUS_ATISENT)         : @"ATISENT",
            @(UMMESSAGE_STATUS_ATIRECEIVED)     : @"ATIRECEIVED",
            @(UMMESSAGE_STATUS_SRISENT)         : @"SRISENT",
            @(UMMESSAGE_STATUS_SRIRECEIVED)     : @"SRIRECEIVED",
            @(UMMESSAGE_STATUS_PSISENT)         : @"PSISENT",
            @(UMMESSAGE_STATUS_PSIRECEIVED)     : @"PSIRECEIVED",
            @(UMMESSAGE_STATUS_PSLSENT)         : @"PSLSENT",
            @(UMMESSAGE_STATUS_PSLRECEIVED)     : @"PSLRECEIVED",
            @(UMMESSAGE_STATUS_SISENT)          : @"SISENT",
            @(UMMESSAGE_STATUS_SIRECEIVED)      : @"SIRECEIVED",
            @(UMMESSAGE_STATUS_SRILCSSENT)      : @"SRILCSSENT",
            @(UMMESSAGE_STATUS_SRILCSRECEIVED)  : @"SRILCSRECEIVED",
            @(UMMESSAGE_STATUS_SAISENT)         : @"SAISENT",
            @(UMMESSAGE_STATUS_SAIRECEIVED)     : @"SAIRECEIVED",
            @(UMMESSAGE_STATUS_ULSENT)          : @"ULSENT",
            @(UMMESSAGE_STATUS_ULRECEIVED)      : @"ULRECEIVED",
            @(UMMESSAGE_STATUS_MOAUTH_FAILED)   : @"MOAUTH_FAILED",
            @(UMMESSAGE_STATUS_EXPIRED)         : @"EXPIRED",
            @(UMMESSAGE_STATUS_UNDELIVERABLE)   : @"UNDELIV",
            @(UMMESSAGE_STATUS_ACCEPTED)        : @"ACCEPTD",
            @(UMMESSAGE_STATUS_REJECTED)        : @"REJECTD",
            @(UMMESSAGE_STATUS_DELETED)         : @"DELETED",
            @(UMMESSAGE_STATUS_SUBMITTED)       : @"SUBMITD",
        };
    }
    return stringFromStatusCode[@(ms)];
}



UMMessageStatusCode  messageStateFromString(NSString *str)
{
    static NSDictionary *statusCodeFromString;
    if(statusCodeFromString==NULL)
    {
        statusCodeFromString = @{
            @"NOT_USED"         : @(UMMESSAGE_STATUS_NOT_USED),
            @"UNDEFINED"        : @(UMMESSAGE_STATUS_UNDEFINED),
            @"NEW"              : @(UMMESSAGE_STATUS_NEW),
            @"ENROUTE"          : @(UMMESSAGE_STATUS_ENROUTE),
            @"BUFFERED"         : @(UMMESSAGE_STATUS_BUFFERED),
            @"DELIVRD"          : @(UMMESSAGE_STATUS_DELIVERED),
            @"FAILED"           : @(UMMESSAGE_STATUS_FAILED),
            @"IGNORED"          : @(UMMESSAGE_STATUS_IGNORED),
            @"APIBUF"           : @(UMMESSAGE_STATUS_APIBUF),
            @"HLRSENT"          : @(UMMESSAGE_STATUS_HLRSENT),
            @"HLRRECEIVED"      : @(UMMESSAGE_STATUS_HLRRECEIVED),
            @"HLR2SENT"         : @(UMMESSAGE_STATUS_HLR2SENT),
            @"MSGSENT"          : @(UMMESSAGE_STATUS_MSGSENT),
            @"ATISENT"          : @(UMMESSAGE_STATUS_ATISENT),
            @"ATIRECEIVED"      : @(UMMESSAGE_STATUS_ATIRECEIVED),
            @"SRISENT"          : @(UMMESSAGE_STATUS_SRISENT),
            @"SRIRECEIVED"      : @(UMMESSAGE_STATUS_SRIRECEIVED),
            @"PSISENT"          : @(UMMESSAGE_STATUS_PSISENT),
            @"PSIRECEIVED"      : @(UMMESSAGE_STATUS_PSIRECEIVED),
            @"PSLSENT"          : @(UMMESSAGE_STATUS_PSLSENT),
            @"PSLRECEIVED"      : @(UMMESSAGE_STATUS_PSLRECEIVED),
            @"SISENT"           : @(UMMESSAGE_STATUS_SISENT),
            @"SIRECEIVED"       : @(UMMESSAGE_STATUS_SIRECEIVED),
            @"SRILCSSENT"       : @(UMMESSAGE_STATUS_SRILCSSENT),
            @"SRILCSRECEIVED"   : @(UMMESSAGE_STATUS_SRILCSRECEIVED),
            @"SAISENT"          : @(UMMESSAGE_STATUS_SAISENT),
            @"SAIRECEIVED"      : @(UMMESSAGE_STATUS_SAIRECEIVED),
            @"ULSENT"           : @(UMMESSAGE_STATUS_ULSENT),
            @"ULRECEIVED"       : @(UMMESSAGE_STATUS_ULRECEIVED),
            @"MOAUTH_FAILED"    : @(UMMESSAGE_STATUS_MOAUTH_FAILED),
            @"EXPIRED"          : @(UMMESSAGE_STATUS_EXPIRED),
            @"UNDELIV"          : @(UMMESSAGE_STATUS_UNDELIVERABLE),
            @"ACCEPTD"          : @(UMMESSAGE_STATUS_ACCEPTED),
            @"REJECTD"          : @(UMMESSAGE_STATUS_REJECTED),
            @"DELETED"          : @(UMMESSAGE_STATUS_DELETED),
            @"SUBMITD"          : @(UMMESSAGE_STATUS_SUBMITTED),
        };
    }
    NSNumber *n = statusCodeFromString[str];
    if(n==NULL)
    {
        return UMMESSAGE_STATUS_UNDEFINED;
    }
    return (UMMessageStatusCode)n.intValue;
}
