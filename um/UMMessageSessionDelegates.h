//
//  UMMessageSessionDelegates.h
//  um
//
//  Created by Andreas Fink on 21.03.2025.
//


#import <um/UMMessageServerCommandError.h>
@class UMMessage;

@protocol UMMessageSessionAuthenticationDelegate
- (UMMessageServerCommandError) login:(NSString *)username password:(NSString *)password host:(NSString *)host instance:(NSString *)instance;
@end

@protocol UMMessageSessionDatabaseDelegate

- (UMMessage *)getMessage:(NSString *)messageId instance:(NSString *)instance error:(UMMessageServerCommandError *)err;
- (UMMessageServerCommandError)insertOrUpdateMessage:(UMMessage *)msg;
- (UMMessageServerCommandError)updateMessage:(UMMessage *)msg;
- (UMMessageServerCommandError)insertMessage:(UMMessage *)msg;
- (UMMessageServerCommandError)deleteMessage:(NSString *)messageId;

@end

