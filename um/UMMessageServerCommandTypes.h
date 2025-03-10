//
//  UMMessageServerCommandTypes.h
//  ummessage-server
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <Foundation/Foundation.h>

typedef enum UMMessageServerCommandType
{
    UMMessageServerCommandType_GENERIC_ERROR_RESPONSE   = 1,
    UMMessageServerCommandType_HELLO_REQUEST            = 2,
    UMMessageServerCommandType_HELLO_RESPONSE           = 3,
    UMMessageServerCommandType_LOGIN_REQUEST            = 4,
    UMMessageServerCommandType_LOGIN_RESPONSE           = 5,
    UMMessageServerCommandType_INSERT_MESSAGE_REQUEST   = 6,
    UMMessageServerCommandType_INSERT_MESSAGE_RESPONSE  = 7,
    UMMessageServerCommandType_UPDATE_MESSAGE_REQUEST   = 8,
    UMMessageServerCommandType_UPDATE_MESSAGE_RESPONSE  = 9,
    UMMessageServerCommandType_GET_MESSAGE_REQUEST      = 10,
    UMMessageServerCommandType_GET_MESSAGE_RESPONSE     = 11,
    UMMessageServerCommandType_DELETE_MESSAGE_REQUEST   = 12,
    UMMessageServerCommandType_DELETE_MESSAGE_RESPONSE  = 13,
} UMMessageServerCommandType;

NSString *UMMessageServerCommandTypeString(UMMessageServerCommandType err);
