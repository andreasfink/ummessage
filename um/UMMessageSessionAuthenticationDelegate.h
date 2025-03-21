//
//  UMMessageSessionAuthenticationDelegate.h
//  um
//
//  Created by Andreas Fink on 21.03.2025.
//


#import <um/UMMessageServerCommandError.h>

@protocol UMMessageSessionAuthenticationDelegate
- (UMMessageServerCommandError) login:(NSString *)username password:(NSString *)password host:(NSString *)host instance:(NSString *)instance;
@end

