//
//  DatabaseCacheEntry.h
//  ummessage
//
//  Created by Andreas Fink on 21.03.2025.
//

#import <ulib/ulib.h>


@interface DatabaseCacheEntry : UMObject
{
    NSString    *_key;
    NSDate      *_expiry;
    id          _cachedObject;
}

@property(readwrite,strong,atomic)  NSString    *key;
@property(readwrite,strong,atomic)  NSDate      *expiry;
@property(readwrite,strong,atomic)  id          cachedObject;


- (DatabaseCacheEntry *)initWithObject:(id)obj
                                expiry:(NSDate *)d
                                   key:(NSString *)key;

@end
