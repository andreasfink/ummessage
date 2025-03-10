//
//  UMMessageServerCommandError.h
//  ummessage
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <Foundation/Foundation.h>

typedef enum UMMessageServerCommandError
{
    UMMessageServerCommandError_NO_ERROR            = 0,
    UMMessageServerCommandError_UNSUPPORTED_COMMAND = 1,
    UMMessageServerCommandError_PARAMETER_ERROR     = 2,
    UMMessageServerCommandError_INVALID_STATE       = 3,
    UMMessageServerCommandError_INVALID_INSTANCE    = 4,
    UMMessageServerCommandError_NOT_AUTHORIZED      = 5,
    UMMessageServerCommandError_WRITE_FAILURE       = 6,
    UMMessageServerCommandError_UPDATE_FAILURE      = 7,
    UMMessageServerCommandError_NOT_FOUND           = 8,
    UMMessageServerCommandError_DELETE_FAILURE      = 9,
    UMMessageServerCommandError_API_VERSION_MISMATCH = 10,
} UMMessageServerCommandError;

NSString *UMMessageServerCommandErrrorString(UMMessageServerCommandError err);
