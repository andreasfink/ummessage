//
//  UMMessageServerCommandGetMessageRequest.m
//  ummessage
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <ummessage/UMMessageServerCommandGetMessageRequest.h>
#import <ummessage/UMMessageServerCommandTypes.h>

@implementation UMMessageServerCommandGetMessageRequest


- (UMMessageServerCommandGetMessageRequest *)init
{
    self = [super init];
    if(self)
    {
        _command = UMMessageServerCommandType_GET_MESSAGE_REQUEST;
    }
    return self;
}

- (void) processBeforeEncode
{
    _command = UMMessageServerCommandType_GET_MESSAGE_REQUEST;
    
    [super processBeforeEncode];
    
    UMASN1UTF8String *s3  = [[UMASN1UTF8String alloc]initWithValue:_instance];
    s3.asn1_tag.tagNumber = 3;
    s3.asn1_tag.tagClass  = UMASN1Class_ContextSpecific;
    [_asn1_list addObject:s3];
    
    UMASN1UTF8String *s4  = [[UMASN1UTF8String alloc]initWithValue:_messageId];
    s4.asn1_tag.tagNumber = 4;
    s4.asn1_tag.tagClass  = UMASN1Class_ContextSpecific;
    [_asn1_list addObject:s4];
}

- (NSString *) objectName
{
    return @"UMMessageServerCommandGetMessageRequest";
}

- (id) objectValue
{
    UMSynchronizedSortedDictionary *dict = [super objectValue];
    if(_instance)
    {
        dict[@"instance"] = _instance;
    }
    if(_messageId)
    {
        dict[@"message-id"] = _messageId;
    }
    return dict;
}

- (UMMessageServerCommandGetMessageRequest *) processAfterDecodeWithContext:(id)context
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
                    _instance = s.stringValue;
                    break;
                }
                case 4:
                {
                    UMASN1UTF8String *s = [[UMASN1UTF8String alloc]initWithASN1Object:o context:context];
                    _messageId = s.stringValue;
                    break;
                }
            }
        }
        o = [self getObjectAtPosition:pos++];
    }
    return self;
}
@end
