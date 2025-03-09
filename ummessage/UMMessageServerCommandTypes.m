//
//  UMMessageServerCommandTypes.m
//  ummessage
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <ummessage/UMMessageServerCommandTypes.h>

NSString *UMMessageServerCommandTypeString(UMMessageServerCommandType t)
{
    switch(t)
    {
        case UMMessageServerCommandType_GENERIC_ERROR_RESPONSE:
            return @"GENERIC_ERROR_RESPONSE";
        case UMMessageServerCommandType_HELLO_REQUEST:
            return @"HELLO_REQUEST";
        case UMMessageServerCommandType_HELLO_RESPONSE:
            return @"HELLO_RESPONSE";
        case UMMessageServerCommandType_LOGIN_REQUEST:
            return @"LOGIN_REQUEST";
        case UMMessageServerCommandType_LOGIN_RESPONSE:
            return @"LOGIN_RESPONSE";
        case UMMessageServerCommandType_INSERT_MESSAGE_REQUEST:
            return @"INSERT_MESSAGE_REQUEST";
        case UMMessageServerCommandType_INSERT_MESSAGE_RESPONSE:
            return @"INSERT_MESSAGE_RESPONSE";
        case UMMessageServerCommandType_UPDATE_MESSAGE_REQUEST:
            return @"UPDATE_MESSAGE_REQUEST";
        case UMMessageServerCommandType_UPDATE_MESSAGE_RESPONSE:
            return @"UPDATE_MESSAGE_RESPONSE";
        case UMMessageServerCommandType_GET_MESSAGE_REQUEST:
            return @"GET_MESSAGE_REQUEST";
        case UMMessageServerCommandType_GET_MESSAGE_RESPONSE:
            return @"GET_MESSAGE_RESPONSE";
        case UMMessageServerCommandType_DELETE_MESSAGE_REQUEST:
            return @"DELETE_MESSAGE_REQUEST";
        case UMMessageServerCommandType_DELETE_MESSAGE_RESPONSE:
            return @"DELETE_MESSAGE_RESPONSE";
    }
    return NULL;
}

