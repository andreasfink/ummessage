//
//  UMMessageSession.h
//  ummessage
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <ulib/ulib.h>

#import <um/UMessageCommandHandlerProtocol.h>

@class UMMessageServer;
@class UMMessageClient;
@class UMMessageHandler;
@class UMMessage;

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
    UMMutex             *_lock;
    NSInteger           _lastSequenceNumber;
    NSString            *_clientName;
    NSInteger           _clientApiVersion;
    NSString            *_serverName;
    NSInteger           _serverApiVersion;
    BOOL                _clientSuccessfullyLoggedIn;
    UMSynchronizedDictionary *_pendingSequences; /* dictionary key=NSNumber(SequenceNumber) value:UMMessageSessionCompletionObject */
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
@property(readwrite,strong,atomic)  NSString        *clientName;
@property(readwrite,strong,atomic)  NSString        *serverName;
@property(readwrite,assign,atomic)  NSInteger        clientApiVersion;
@property(readwrite,assign,atomic)  NSInteger        serverApiVersion;
@property(readwrite,assign,atomic)  BOOL             cclientSuccessfullyLoggedIn;

- (int)processCommand:(UMMessageServerCommand *)cmd; /* return error code*/

- (BOOL)insertMessage:(UMMessage *)msg onCompletionCallObject:(id)obj withSelector:(SEL)selector;

@end

