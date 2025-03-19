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
        NSString *hostname = @"127.0.0.1";
        int port = 9121;
        if(argc>2)
        {
            hostname = @(argv[1]);
        }
        if(argc>3)
        {
            port = atoi(argv[2]);
        }

        UMMessage *msg = [[UMMessage alloc]init];
        msg.messageId = [[UMDirtyString alloc]init];
        msg.messageId.stringValue = [UMMessage uniqueMessageIdWithPrefix:@""];
        UMHost *host = [[UMHost alloc]initWithName:hostname];
        UMMessageClient *client = [[UMMessageClient alloc]initWithHost:host port:port];
        client.instance = @"default-instance";
        client.username = @"testuser";
        client.password = @"testpass";
        [client login];
        NSLog(@"Login completed. inserting now");
        [client insertMessage:msg];
        while([client awaitsResponses])
        {
            sleep(1);
        }
        fprintf(stderr,"completed\n");
    }
    return 0;
}
