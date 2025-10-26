//
//  UMMessageUser.m
//  um
//
//  Created by Andreas Fink on 26.03.2025.
//

#import "UMMessageUser.h"

@implementation UMMessageUser


- (UMMessageUser *)init
{
    self = [super init];
    {
        _throughput = [[UMThroughputCounter alloc]initWithResolutionInSeconds: 1.0 maxDuration: 1260.0];
    }
    return self;
}

- (UMMessageUser *)initWithConfigDictionary:(NSDictionary *)config
{
    self = [super init];
    if(self)
    {
        _throughput      = [[UMThroughputCounter alloc]initWithResolutionInSeconds: 1.0 maxDuration: 1260.0];
        _username        = config[@"name"];
        _password        = config[@"password"];
        _group           = config[@"usergroup"];
        _defaultRoute    = config[@"defaultRoute"];
        _shortIdAsString = config[@"shortId"];
        NSString *s;
        s = config[@"credits"];
        _credits         = s.doubleValue;
        s = config[@"prepaid"];
        _prepaid         = s.boolValue;
        s = config[@"maxSpeed"];
        _maxSpeed        =  s ? s.doubleValue : -1.0;
    }
    return self;

}

- (NSString *)alphaCoding
{
    return @"latin1";
}


- (void)errorCounterIncrease
{
    _errorCounter++;
}

- (BOOL)hasCredits
{
    return YES;
}


- (void)increase
{
    _submitCounter++;
}


- (void)removeCredits:(NSInteger)count
{
    _credits -= count;
}



- (BOOL)withinSpeedlimit
{
    if(_maxSpeed >0.0)
    {
        double current_speed = [_throughput getSpeedForSeconds:3];
        if(current_speed > _maxSpeed)
        {
            return NO;
        }
    }
    return YES;
}

@end
