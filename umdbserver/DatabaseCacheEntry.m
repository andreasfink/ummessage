//
//  DatabaseCacheEntry.m
//  umdbserver
//
//  Created by Andreas Fink on 21.03.2025.
//

#import "DatabaseCacheEntry.h"

@implementation DatabaseCacheEntry


- (DatabaseCacheEntry *)initWithObject:(id)obj  expiry:(NSDate *)d key:(NSString *)key
{
    self = [super init];
    if(self)
    {
        _key = key;
        _expiry = d;
        _cachedObject = obj;
    }
    return self;
}

@end
