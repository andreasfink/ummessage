//
//  UMMessageState.h
//  ummessage
//
//  Created by Andreas Fink on 26.03.2025.
//

#import <Foundation/Foundation.h>

typedef    enum UMMessageState
{
    UMMESSAGE_STATE_UNDEFINED       = 0,
    UMMESSAGE_STATE_ENROUTE         = 1,
    UMMESSAGE_STATE_DELIVERED       = 2,
    UMMESSAGE_STATE_EXPIRED         = 3,
    UMMESSAGE_STATE_DELETED         = 4,
    UMMESSAGE_STATE_UNDELIVERABLE   = 5,
    UMMESSAGE_STATE_ACCEPTED        = 6,
    UMMESSAGE_STATE_UNKNOWN         = 7,
    UMMESSAGE_STATE_REJECTED        = 8,
    UMMESSAGE_STATE_SUBMITTED       = 9,
} UMMessageState;


NSString        *stringFromMessageState(UMMessageState ms);
UMMessageState  messageStateFromString(NSString *str);


