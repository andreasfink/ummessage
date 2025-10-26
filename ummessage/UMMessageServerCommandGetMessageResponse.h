//
//  UMMessageServerCommandGetMessageResponse.h
//  ummessage
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <um/UMMessageServerCommand.h>
#import <um/UMMessageServerCommandError.h>
@class UMMessage;

@interface UMMessageServerCommandGetMessageResponse : UMMessageServerCommand
{
    UMMessageServerCommandError   _status;
    NSString    *_error;
    UMMessage   *_message;
}

@property(readwrite,atomic,assign)  UMMessageServerCommandError   status;
@property(readwrite,atomic,strong)  NSString    *error;
@property(readwrite,strong,atomic)  UMMessage   *message;

@end
