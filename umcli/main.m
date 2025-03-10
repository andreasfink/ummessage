//
//  main.m
//  umcli
//
//  Created by Andreas Fink on 09.03.2025.
//

#import <Foundation/Foundation.h>
#import <um/um.h>

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        UMMessage *msg = [[UMMessage alloc]init];
        msg.messageId = [[UMDirtyString alloc]init];
        msg.messageId.stringValue = [UMMessage uniqueMessageIdWithPrefix:@""];
        UMHost *host = [[UMHost alloc]initWithLocalhost];
        [host resolve];
        UMMessageClient *client = [[UMMessageClient alloc]initWithHost:host port:9121];
        [client insertMessage:msg];
    }
    return 0;
}
