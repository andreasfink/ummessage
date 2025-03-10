//
//  UMMessageServerCommandGenericError.h
//  ummessage-server
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <ummessage/UMMessageServerCommand.h>


@interface UMMessageServerCommandGenericError : UMMessageServerCommand
{
    int         _status;
    NSString    *_error;
}

@property(readwrite,assign) int     status;
@property(readwrite,strong) NSString *error;
@end

