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
@class UMMessageClient;

@interface UMMessageHandler : UMBackgrounder
{
    UMSocket *               _socket;
    int                      _maxReceiveBuffer;
    UMMessageSession         *_session;
    UMMessageServer          *_server;
    UMMessageClient          *_client;
}

@property(readwrite,strong,atomic)  id<UMessageCommandHandlerProtocol> commandHandlerDelegate;
@property(readwrite,strong,atomic)  UMMessageSession *session;

- (UMMessageHandler *)initWithSocket:(UMSocket *)s server:(UMMessageServer *)server;
- (UMMessageHandler *)initWithSocket:(UMSocket *)s client:(UMMessageClient *)client;


@end

