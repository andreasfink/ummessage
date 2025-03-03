//
//  UMDirtyInteger.h
//  ummessage
//
//  Created by Andreas Fink on 03.03.2025.
//

#import "UMDirtyObject.h"

@interface UMDirtyInteger : UMDirtyObject
{
    
}

- (UMDirtyInteger *)initWithNumber:(NSNumber *)n;
- (UMDirtyInteger *)initWithInteger:(NSInteger)i;
- (NSNumber *)number;
- (void)setNumber:(NSNumber *)n;
- (void)setInteger:(NSInteger)newValue;
- (NSInteger)integer;
- (NSString *)stringValue;
- (void)setStringValue:(NSString *)s;

@end


