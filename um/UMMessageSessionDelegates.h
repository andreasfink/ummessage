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

- (UMMessage *)loadMessage:(NSString *)messageId error:(UMMessageServerCommandError *)err;
- (UMMessageServerCommandError)insertOrUpdateMessage:(UMMessage *)msg;
- (UMMessageServerCommandError)deleteMessage:(NSString *)messageId;

@end

