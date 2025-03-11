//
//  UMMessageServerCommandLoginRequest.h
//  ummessage-server
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <um/UMMessageServerCommand.h>

@interface UMMessageServerCommandLoginRequest : UMMessageServerCommand
{
    NSString    *_username;
    NSString    *_password;
    NSString    *_instance;
    NSString    *_clientName;
    NSInteger   _apiVersion;
}

@property(readwrite,atomic,strong)  NSString    *username;
@property(readwrite,atomic,strong)  NSString    *password;
@property(readwrite,atomic,strong)  NSString    *instance;
@property(readwrite,atomic,strong)  NSString    *clientName;
@property(readwrite,atomic,assign)  NSInteger   apiVersion;

@end

