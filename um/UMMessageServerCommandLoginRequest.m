//
//  UMMessageServerCommandLoginRequest.m
//  ummessage-server
//
//  Created by Andreas Fink on 09.03.2025.
//

#import "UMMessageServerCommandLoginRequest.h"
#import "UMMessageServerCommandTypes.h"

@implementation UMMessageServerCommandLoginRequest


- (UMMessageServerCommandLoginRequest *)init
{
    self = [super init];
    if(self)
    {
        _command = UMMessageServerCommandType_LOGIN_REQUEST;
    }
    return self;
}

- (void) processBeforeEncode
{
    _command = UMMessageServerCommandType_LOGIN_REQUEST;
    
    [super processBeforeEncode];

    UMASN1UTF8String *s3= [[UMASN1UTF8String alloc]initWithValue:_username];
    s3.asn1_tag.tagNumber = 3;
    s3.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
    [_asn1_list addObject:s3];

    UMASN1UTF8String *s4= [[UMASN1UTF8String alloc]initWithValue:_password];
    s4.asn1_tag.tagNumber = 4;
    s4.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
    [_asn1_list addObject:s4];
    
    UMASN1UTF8String *s5= [[UMASN1UTF8String alloc]initWithValue:_instance];
    s5.asn1_tag.tagNumber = 5;
    s5.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
    [_asn1_list addObject:s5];
    
    UMASN1UTF8String *s6= [[UMASN1UTF8String alloc]initWithValue:_clientName];
    s6.asn1_tag.tagNumber = 6;
    s6.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
    [_asn1_list addObject:s6];

    UMASN1Integer *i= [[UMASN1Integer alloc]initWithValue:_apiVersion];
    i.asn1_tag.tagNumber = 7;
    i.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
    [_asn1_list addObject:i];
}

- (NSString *) objectName
{
    return @"UMMessageServerCommandLoginRequest";
}

- (id) objectValue
{
    UMSynchronizedSortedDictionary *dict = [super objectValue];
    dict[@"username"] = _username;
    dict[@"password"] = _password;
    if(_clientName)
    {
        dict[@"client-name"] = _clientName;
    }
    dict[@"api-version"] = @(_apiVersion);

    return dict;
}

- (UMMessageServerCommandLoginRequest *) processAfterDecodeWithContext:(id)context
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
                    UMASN1UTF8String *s = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];
                    _username = s.stringValue;
                    break;
                }
                case 4:
                {
                    UMASN1UTF8String *s = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];
                    _password = s.stringValue;
                    break;
                }
                case 5:
                {
                    UMASN1UTF8String *s = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];
                    _instance = s.stringValue;
                    break;
                }
                case 6:
                {
                    UMASN1UTF8String *s = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];
                    _clientName = s.stringValue;
                    break;
                }
                case 7:
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
