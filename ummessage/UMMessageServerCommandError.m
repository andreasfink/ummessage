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
        case UMMessageServerCommandError_WRITE_FAILURE:
            return @"WRITE_FAILURE";
            break;
        case UMMessageServerCommandError_UPDATE_FAILURE:
            return @"UPDATE_FAILURE";
            break;
        case UMMessageServerCommandError_NOT_FOUND:
            return @"NOT_FOUND";
            break;
        case UMMessageServerCommandError_DELETE_FAILURE:
            return @"DELETE_FAILURE";
            break;
    }
    return NULL;
}

