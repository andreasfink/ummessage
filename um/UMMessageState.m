//
//  UMMessageState.m
//  um
//
//  Created by Andreas Fink on 26.03.2025.
//

#import "UMMessageState.h"

NSString        *stringFromMessageState(UMMessageState ms)
{
    switch(ms)
    {
        case UMMESSAGE_STATE_ENROUTE:
            return @"ENROUTE";
        case UMMESSAGE_STATE_DELIVERED:
            return @"DELIVRD";
        case UMMESSAGE_STATE_EXPIRED:
            return @"EXPIRED";
        case UMMESSAGE_STATE_DELETED:
            return @"DELETED";
        case UMMESSAGE_STATE_UNDELIVERABLE:
            return @"UNDELIV";
        case UMMESSAGE_STATE_ACCEPTED:
            return @"ACCEPTD";
        case UMMESSAGE_STATE_REJECTED:
            return @"REJECTD";
        case UMMESSAGE_STATE_UNKNOWN:
            return @"UNKNOWN";
        case UMMESSAGE_STATE_SUBMITTED:
            return @"SUBMITD";
        case UMMESSAGE_STATE_UNDEFINED:
        default:
            return @"undefined";
    }
}

UMMessageState  messageStateFromString(NSString *str)
{
    if([str isEqualTo:@"ENROUTE"])
        return UMMESSAGE_STATE_ENROUTE;
    if([str isEqualTo:@"DELIVRD"])
        return UMMESSAGE_STATE_DELIVERED;
    if([str isEqualTo:@"EXPIRED"])
        return UMMESSAGE_STATE_EXPIRED;
    if([str isEqualTo:@"DELETED"])
        return UMMESSAGE_STATE_DELETED;
    if([str isEqualTo:@"ACCEPTD"])
        return UMMESSAGE_STATE_ACCEPTED;
    if([str isEqualTo:@"UNDELIV"])
        return UMMESSAGE_STATE_UNDELIVERABLE;
    if([str isEqualTo:@"REJECTD"])
        return UMMESSAGE_STATE_REJECTED;
    if([str isEqualTo:@"UNKNOWN"])
        return UMMESSAGE_STATE_UNKNOWN;
    if([str isEqualTo:@"SUBMITD"])
        return UMMESSAGE_STATE_SUBMITTED;
    return UMMESSAGE_STATE_UNDEFINED;
}
