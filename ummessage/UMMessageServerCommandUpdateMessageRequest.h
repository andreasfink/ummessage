//
//  UMMessageServerCommandUpdateMessageRequest.h
//  ummessage
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <ummessage/UMMessageServerCommand.h>

@class UMMessageObject;

@interface UMMessageServerCommandUpdateMessageRequest : UMMessageServerCommand
{
    UMMessageObject *_message;
}
@property(readwrite,strong,atomic)    UMMessageObject *message;

@end
