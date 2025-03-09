//
//  UMMessageServerCommandGetMessageResponse.h
//  ummessage
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <ummessage/UMMessageServerCommand.h>
@class UMMessage;

@interface UMMessageServerCommandGetMessageResponse : UMMessageServerCommand
{
    NSInteger   _status;
    NSString    *_error;
    UMMessage   *_message;
}

@property(readwrite,atomic,assign)  NSInteger   status;
@property(readwrite,atomic,strong)  NSString    *error;
@property(readwrite,strong,atomic)  UMMessage   *message;

@end
