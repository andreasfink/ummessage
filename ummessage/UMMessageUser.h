//
//  UMMessageUser.h
//  ummessage
//
//  Created by Andreas Fink on 26.03.2025.
//

#import <ulibasn1/ulibasn1.h>

@interface UMMessageUser : UMObject
{
    NSString *_username;
    NSString *_password;
    NSString *_group;
    NSString *_billingAccount;
    NSString *_defaultRoute;
    double  _credits;
    BOOL    _prepaid;
    double  _maxSpeed;
    NSString *_shortIdAsString;
    
    NSInteger               _errorCounter;
    NSInteger               _submitCounter;
    UMThroughputCounter     *_throughput;
    UMMutex                 *_lock;
    id                      _userRoutingTable;
}

@property(readwrite,strong,atomic)  NSString                *username;
@property(readwrite,strong,atomic)  NSString                *password;
@property(readwrite,strong,atomic)  NSString                *group;
@property(readwrite,strong,atomic)  NSString                *billingAccount;
@property(readwrite,strong,atomic)  NSString                *defaultRoute;
@property(readwrite,strong,atomic)  NSString                *shortIdAsString;
@property(readwrite,assign,atomic)  double                  credits;
@property(readwrite,assign,atomic)  BOOL                    prepaid;
@property(readwrite,assign,atomic)  double                  maxSpeed;
@property(readwrite,assign,atomic)  NSInteger               errorCounter;
@property(readwrite,assign,atomic)  NSInteger               submitCounter;
@property(readwrite,strong,atomic)  UMThroughputCounter     *throughput;
@property(readwrite,strong,atomic)  id                      userRoutingTable;

- (UMMessageUser *)initWithConfigDictionary:(NSDictionary *)config;

@end
