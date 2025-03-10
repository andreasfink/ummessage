//
//  UMMessageHandler.h
//  ummessage-server
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <ulib/ulib.h>

#import <ummessage/UMessageCommandHandlerProtocol.h>
@class UMMessageSession;
@class UMMessageServer;

@interface UMMessageHandler : UMBackgrounder
{
    UMSocket *               _socket;
    int                      _maxReceiveBuffer;
    UMMessageSession         *_session;
    UMMessageServer          *_server;
}

@property(readwrite,strong,atomic)  id<UMessageCommandHandlerProtocol> commandHandlerDelegate;
@property(readwrite,strong,atomic)  UMMessageSession *session;

- (UMMessageHandler *)initWithSocket:(UMSocket *)s server:(UMMessageServer *)server;


@end

