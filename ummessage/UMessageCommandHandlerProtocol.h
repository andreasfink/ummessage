//
//  UMessageCommandHandlerProtocol.h
//  ummessage-server
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <ulib/ulib.h>

@class UMMessageServerCommand;

@protocol UMessageCommandHandlerProtocol
- (void) processCommand:(UMMessageServerCommand *)md fromSocket:(UMSocket *)s;
@end
