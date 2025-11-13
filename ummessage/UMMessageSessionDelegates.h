//
//  UMMessageSessionDelegates.h
//  um
//
//  Created by Andreas Fink on 21.03.2025.
//


#import <ummessage/UMMessageServerCommandError.h>
@class UMMessageObject;

@protocol UMMessageSessionAuthenticationDelegate
- (UMMessageServerCommandError) login:(NSString *)username password:(NSString *)password host:(NSString *)host instance:(NSString *)instance;
@end

@protocol UMMessageSessionDatabaseDelegate

- (UMMessageObject *)getMessage:(NSString *)messageId instance:(NSString *)instance error:(UMMessageServerCommandError *)err;
- (UMMessageServerCommandError)insertOrUpdateMessage:(UMMessageObject *)msg;
- (UMMessageServerCommandError)updateMessage:(UMMessageObject *)msg;
- (UMMessageServerCommandError)insertMessage:(UMMessageObject *)msg;
- (UMMessageServerCommandError)deleteMessage:(NSString *)messageId;

@end

