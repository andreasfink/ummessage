//
//  UMMessageServerCommandError.m
//  ummessage
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <ummessage/UMMessageServerCommandError.h>

NSString *UMMessageServerCommandErrrorString(UMMessageServerCommandError err)
{
    switch(err)
    {
        case UMMessageServerCommandError_NO_ERROR:
            return @"NO_ERROR";
        case UMMessageServerCommandError_UNSUPPORTED_COMMAND:
            return @"UNSUPPORTED_COMMAND";
        case UMMessageServerCommandError_PARAMETER_ERROR:
            return @"PARAMETER_ERROR";
        case UMMessageServerCommandError_INVALID_STATE:
            return @"INVALID_STATE";
        case UMMessageServerCommandError_INVALID_INSTANCE:
            return @"INVALID_INSTANCE";
        case UMMessageServerCommandError_NOT_AUTHORIZED:
            return @"NOT_AUTHORIZED";
    }
    return NULL;
}

