//
//  UMMessageUser.h
//  ummessage
//
//  Created by Andreas Fink on 26.03.2025.
//

#import <ulibasn1/ulibasn1.h>

@interface UMMessageUser : UMObject
{
    NSString                    *_username;
    NSString                    *_password;
    NSString                    *_group;
    NSString                    *_billingAccount;
    NSString                    *_defaultRoute;
    double                      _credit;
    double                      _creditLimit;
    BOOL                        _prepaid;
    double                      _maxSpeed;
    NSString                    *_shortIdAsString;
    BOOL                        _loadedFromBillingServer;
    int                         _loadError;
    NSInteger                   _errorCounter;
    NSInteger                   _submitCounter;
    UMThroughputCounter         *_throughput;
    UMMutex                     *_lock;
    id                          _userRoutingTable;
    id                          _billingRateTable;
    NSString                    *_session;
}

@property(readwrite,strong,atomic)  NSString                *username;
@property(readwrite,strong,atomic)  NSString                *password;
@property(readwrite,strong,atomic)  NSString                *group;
@property(readwrite,strong,atomic)  NSString                *billingAccount;
@property(readwrite,strong,atomic)  NSString                *defaultRoute;
@property(readwrite,strong,atomic)  NSString                *shortIdAsString;
@property(readwrite,assign,atomic)  double                  credit;
@property(readwrite,assign,atomic)  double                  creditLimit;
@property(readwrite,assign,atomic)  BOOL                    prepaid;
@property(readwrite,assign,atomic)  double                  maxSpeed;
@property(readwrite,assign,atomic)  NSInteger               errorCounter;
@property(readwrite,assign,atomic)  NSInteger               submitCounter;
@property(readwrite,strong,atomic)  UMThroughputCounter     *throughput;
@property(readwrite,strong,atomic)  id                      userRoutingTable;
@property(readwrite,strong,atomic)  id                      billingRateTable;
@property(readwrite,assign,atomic)  BOOL                    loadedFromBillingServer;
@property(readwrite,assign,atomic)  int                     loadError;
@property(readwrite,strong,atomic)  NSString                *session;

- (UMMessageUser *)initWithConfigDictionary:(NSDictionary *)config;

@end
