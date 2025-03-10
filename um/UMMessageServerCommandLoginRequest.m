//
//  UMMessageServerCommandLoginRequest.m
//  ummessage-server
//
//  Created by Andreas Fink on 09.03.2025.
//

#import "UMMessageServerCommandLoginRequest.h"
#import "UMMessageServerCommandTypes.h"

@implementation UMMessageServerCommandLoginRequest

- (void) processBeforeEncode
{
    _command = UMMessageServerCommandType_LOGIN_REQUEST;
    
    [super processBeforeEncode];

    UMASN1UTF8String *s101= [[UMASN1UTF8String alloc]initWithValue:_username];
    s101.asn1_tag.tagNumber = 101;
    s101.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
    [_asn1_list addObject:s101];

    UMASN1UTF8String *s102= [[UMASN1UTF8String alloc]initWithValue:_password];
    s101.asn1_tag.tagNumber = 102;
    s101.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
    [_asn1_list addObject:s102];

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
            }
        }
        o = [self getObjectAtPosition:pos++];
    }
    return self;
}
@end
