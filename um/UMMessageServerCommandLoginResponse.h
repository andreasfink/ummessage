//
//  UMMessageServerCommandLoginResponse.h
//  ummessage-server
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <um/UMMessageServerCommand.h>


@interface UMMessageServerCommandLoginResponse : UMMessageServerCommand
{
    NSInteger   _status;
    NSString    *_error;
}

@property(readwrite,atomic,assign)   NSInteger   status;
@property(readwrite,atomic,strong)   NSString    *error;
@end

