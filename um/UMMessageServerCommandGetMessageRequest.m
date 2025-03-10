//
//  UMMessageServerCommandGetMessageRequest.m
//  ummessage
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <um/UMMessageServerCommandGetMessageRequest.h>
#import <um/UMMessageServerCommandTypes.h>

@implementation UMMessageServerCommandGetMessageRequest

- (void) processBeforeEncode
{
    _command = UMMessageServerCommandType_GET_MESSAGE_REQUEST;
    
    [super processBeforeEncode];

    UMASN1UTF8String *s  = [[UMASN1UTF8String alloc]initWithValue:_messageId];
    s.asn1_tag.tagNumber = 3;
    s.asn1_tag.tagClass  = UMASN1Class_ContextSpecific;
    [_asn1_list addObject:s];
}

- (NSString *) objectName
{
    return @"UMMessageServerCommandGetMessageRequest";
}

- (id) objectValue
{
    UMSynchronizedSortedDictionary *dict = [super objectValue];
    dict[@"messageId"] = _messageId;
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
