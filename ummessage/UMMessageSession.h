//
//  UMMessageSession.h
//  ummessage
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <ulib/ulib.h>

#import <ummessage/UMessageCommandHandlerProtocol.h>

@class UMMessageServer;
@class UMMessageHandler;

@interface UMMessageSession : UMObject<UMessageCommandHandlerProtocol>
{
    UMSocket         *_socket;
    UMMessageServer  *_server;
    UMMessageHandler *_handler;
    NSString         *_directory;
}

@property(readwrite,strong,atomic)  UMSocket        *socket;
@property(readwrite,strong,atomic)  UMMessageServer *server;
@property(readwrite,strong,atomic)  UMMessageHandler *handler;
@property(readwrite,strong,atomic)  NSString *directory;

- (int)processCommand:(UMMessageServerCommand *)cmd; /* return error code*/
@end

