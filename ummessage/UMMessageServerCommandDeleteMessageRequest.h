//
//  UMMessageServerCommandDeleteMessageRequest.h
//  ummessage
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <um/UMMessageServerCommand.h>


@interface UMMessageServerCommandDeleteMessageRequest : UMMessageServerCommand
{
    NSString *_messageId;
}
@property(readwrite,atomic,strong)  NSString *messageId;

@end

