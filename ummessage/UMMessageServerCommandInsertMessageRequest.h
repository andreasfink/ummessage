//
//  UMMessageServerCommandInsertMessageRequest.h
//  ummessage
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <ummessage/UMMessageServerCommand.h>

@class UMMessage;

@interface UMMessageServerCommandInsertMessageRequest : UMMessageServerCommand
{
    UMMessage *_message;
}

@property(readwrite,strong,atomic)  UMMessage *message;

@end

