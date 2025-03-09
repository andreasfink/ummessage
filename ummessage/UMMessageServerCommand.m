//
//  UMMessageServerCommand.m
//  ummessage-server
//
//  Created by Andreas Fink on 09.03.2025.
//

#import "UMMessageServerCommand.h"

@implementation UMMessageServerCommand

- (void) processBeforeEncode
{
    [super processBeforeEncode];
    [_asn1_tag setTagIsConstructed];
    _asn1_list = [[NSMutableArray alloc]init];

    UMASN1Integer *i1 = [[UMASN1Integer alloc]initWithValue:_command];
    i1.asn1_tag.tagNumber = 0;
    i1.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
    [_asn1_list addObject:i1];

    UMASN1Integer *i2= [[UMASN1Integer alloc]initWithValue:_flags];
    i2.asn1_tag.tagNumber = 1;
    i2.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
    [_asn1_list addObject:i2];

    UMASN1Integer *i3= [[UMASN1Integer alloc]initWithValue:_sequenceNumber];
    i3.asn1_tag.tagNumber = 3;
    i3.asn1_tag.tagClass = UMASN1Class_ContextSpecific;
    [_asn1_list addObject:i3];
}

- (UMMessageServerCommand *) processAfterDecodeWithContext:(id)context
{
    UMASN1Object *o1 = [self getObjectAtPosition:0];
    UMASN1Integer *i1 =  [[UMASN1Integer alloc]initWithASN1Object:o1 context:context];
    _command = i1.value;
    
    UMASN1Object *o2 = [self getObjectAtPosition:1];
    UMASN1Integer *i2 = [[UMASN1Integer alloc]initWithASN1Object:o2 context:context];
    _flags = i2.value;
    
    UMASN1Object *o3 = [self getObjectAtPosition:1];
    UMASN1Integer *i3 = [[UMASN1Integer alloc]initWithASN1Object:o3 context:context];
    _sequenceNumber = i3.value;
    return self;
}

- (NSString *) objectName
{
    return @"MessageServerCommand";
}


- (UMSynchronizedSortedDictionary *) objectValue
{
    UMSynchronizedSortedDictionary *dict = [[UMSynchronizedSortedDictionary alloc]init];
    dict[@"command"]        = @(_command);
    dict[@"flags"]          = @(_flags);
    dict[@"sequenceNumber"] = @(_sequenceNumber);
    return dict;
}

@end
