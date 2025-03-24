//
//  UMMessageServerCommandLoginResponse.m
//  ummessage-server
//
//  Created by Andreas Fink on 09.03.2025.
//

#import "UMMessageServerCommandLoginResponse.h"
#import "UMMessageServerCommandTypes.h"
#import "UMMessageServerCommandError.h"

@implementation UMMessageServerCommandLoginResponse

- (UMMessageServerCommandLoginResponse *)init
{
    self = [super init];
    if(self)
    {
        _command = UMMessageServerCommandType_LOGIN_RESPONSE;
    }
    return self;
}

- (void) processBeforeEncode
{
    _command = UMMessageServerCommandType_LOGIN_RESPONSE;
    [super processBeforeEncode];
    UMASN1Integer *i3= [[UMASN1Integer alloc]initWithValue:_status];
    i3.asn1_tag.tagNumber = 3;
    i3.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
    [_asn1_list addObject:i3];
    if(_error)
    {
        UMASN1UTF8String *s4= [[UMASN1UTF8String alloc]initWithValue:_error];
        s4.asn1_tag.tagNumber = 4;
        s4.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        [_asn1_list addObject:s4];
    }
    if(_serverName)
    {
        UMASN1UTF8String *s5= [[UMASN1UTF8String alloc]initWithValue:_serverName];
        s5.asn1_tag.tagNumber = 5;
        s5.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
        [_asn1_list addObject:s5];
    }
    UMASN1Integer *i= [[UMASN1Integer alloc]initWithValue:_apiVersion];
    i.asn1_tag.tagNumber = 6;
    i.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
    [_asn1_list addObject:i];
}

- (NSString *) objectName
{
    return @"UMMessageServerCommandLoginResponse";
}

- (id) objectValue
{
    UMSynchronizedSortedDictionary *dict = [super objectValue];
    dict[@"status"] = @(_status);
    
    if(_error)
    {
        dict[@"error"] = _error;
    }
    if(_serverName)
    {
        dict[@"server-name"] = _error;
    }
    dict[@"api-version"] = @(_apiVersion);
    return dict;
}

- (UMMessageServerCommandLoginResponse *) processAfterDecodeWithContext:(id)context
{
    [super processAfterDecodeWithContext:context];
    int pos = 0;
    UMASN1Object *o = [self getObjectAtPosition:pos++];
    while(o)
    {
        if(o.asn1_tag.tagClass==UMASN1Class_ContextSpecific)
        {
            switch(o.asn1_tag.tagNumber)
            {
                case 3:
                {
                    UMASN1Integer *i = [[UMASN1Integer alloc]initWithASN1Object:o context:context];
                    _status = (UMMessageServerCommandError)i.value;
                    break;
                }
                case 4:
                {
                    UMASN1UTF8String *s = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];
                    _error = s.stringValue;
                    break;
                }
                case 5:
                {
                    UMASN1UTF8String *s = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];
                    _serverName = s.stringValue;
                    break;
                }
                case 6:
                {
                    UMASN1Integer *i = [[UMASN1Integer alloc]initWithASN1Object:o context:context];
                    _apiVersion = i.value;
                    break;
                }
            }
        }
        o = [self getObjectAtPosition:pos++];
    }
    return self;
}
@end
