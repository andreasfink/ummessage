//
//  UMMessageServerCommandUpdateMessageRequest.h
//  ummessage
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <um/UMMessageServerCommand.h>

@class UMMessage;

@interface UMMessageServerCommandUpdateMessageRequest : UMMessageServerCommand
{
    UMMessage *_message;
}
@property(readwrite,strong,atomic)    UMMessage *message;

@end
