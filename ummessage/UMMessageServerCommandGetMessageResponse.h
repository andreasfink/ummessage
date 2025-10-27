//
//  UMMessageServerCommandGetMessageResponse.h
//  ummessage
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <ummessage/UMMessageServerCommand.h>
#import <ummessage/UMMessageServerCommandError.h>
@class UMMessageObject;

@interface UMMessageServerCommandGetMessageResponse : UMMessageServerCommand
{
    UMMessageServerCommandError   _status;
    NSString    *_error;
    UMMessageObject *_message;
}

@property(readwrite,atomic,assign)  UMMessageServerCommandError   status;
@property(readwrite,atomic,strong)  NSString    *error;
@property(readwrite,strong,atomic)  UMMessageObject   *message;

@end
