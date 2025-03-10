//
//  UMMessageSession.h
//  ummessage
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <ulib/ulib.h>

#import <ummessage/UMessageCommandHandlerProtocol.h>

@class UMMessageServer;
@class UMMessageClient;
@class UMMessageHandler;

@interface UMMessageSession : UMObject<UMessageCommandHandlerProtocol>
{
    UMSocket         *_socket;
    UMMessageServer  *_server;
    UMMessageClient  *_client;
    UMMessageHandler *_handler;
    NSString         *_rootDirectory;
    NSString         *_instance;
    BOOL             _authenticated;
    NSString         *_username;
    NSString         *_password;
    NSDate              *_lastHandshakeRequested;
    NSDate              *_lastHandshakeResponse;
    NSDate              *_lastHandshakeReceived;
    UMTimer             *_handshakeTimer;
    UMMMutex            *_lock;
    NSInteger           _lastSequenceNumber;
    
}

@property(readwrite,strong,atomic)  UMSocket        *socket;
@property(readwrite,strong,atomic)  UMMessageServer *server;
@property(readwrite,strong,atomic)  UMMessageClient *client;
@property(readwrite,strong,atomic)  UMMessageHandler *handler;
@property(readwrite,strong,atomic)  NSString *rootDirectory;
@property(readwrite,strong,atomic)  NSString *instance;
@property(readwrite,assign,atomic)  BOOL             authenticated;
@property(readwrite,strong,atomic)  NSString        *username;
@property(readwrite,strong,atomic)  NSString        *password;
@property(readwrite,strong,atomic)  NSDate          *lastHandshakeRequested;
@property(readwrite,strong,atomic)  NSDate          *lastHandshakeResponse;
@property(readwrite,strong,atomic)  NSDate          *lastHandshakeReceived;

- (int)processCommand:(UMMessageServerCommand *)cmd; /* return error code*/
@end

