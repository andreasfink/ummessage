//
//  UMMessageServerCommandGetMessageRequest.h
//  ummessage
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <um/UMMessageServerCommand.h>


@interface UMMessageServerCommandGetMessageRequest : UMMessageServerCommand
{
    NSString *_archiveId;
}
@property(readwrite,atomic,strong)  NSString *archiveId;

@end

