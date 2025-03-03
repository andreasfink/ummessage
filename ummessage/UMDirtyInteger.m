//
//  UMDirtyInteger.m
//  ummessage
//
//  Created by Andreas Fink on 03.03.2025.
//

#import "UMDirtyInteger.h"

@implementation UMDirtyInteger



- (UMDirtyInteger *)initWithNumber:(NSNumber *)n
{
    self = [super init];
    if(self)
    {
        _currentValue = @(n.integerValue);
        _previousValue = NULL;
        _isDirty = YES;
    }
    return self;
}

- (UMDirtyInteger *)initWithInteger:(NSInteger)i
{
    self = [super init];
    if(self)
    {
        _currentValue = @(i);
        _previousValue = NULL;
        _isDirty = YES;
    }
    return self;
}

- (NSNumber *)number
{
    return _currentValue;
}

- (void)setNumber:(NSNumber *)n
{
    _previousValue = _currentValue;
    _currentValue = @(n.integerValue);
    if(_currentValue.integerValue != _previousValue.integerValue)
    {
        _isDirty = YES;
    }
}
- (void)setInteger:(NSInteger)newValue
{
    [self setNumber:@(newValue)];
}

- (NSInteger)integer
{
    return _currentValue.integerValue;
}

- (NSString *)stringValue
{
    return [NSString stringWithFormat:"%@",_currentValue];
}

- (void)setStringValue:(NSString *)s
{
    atol
}

@end
