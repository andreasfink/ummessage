//
//  UMMessageServerCommandGetMessageRequest.h
//  ummessage
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <ummessage/UMMessageServerCommand.h>


@interface UMMessageServerCommandGetMessageRequest : UMMessageServerCommand
{
    NSString *_messageId;
}
@property(readwrite,atomic,strong)  NSString *messageId;

@end

