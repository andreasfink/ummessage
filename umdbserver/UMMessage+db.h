//
//  UMMessage+db.h
//  ummessage
//
//  Created by Andreas Fink on 21.03.2025.
//

@class UMDbResult;

@interface UMMessageObject(db)
+ (UMMessageObject *)messageFromDbResult:(UMDbResult *)dbResult;
@end

