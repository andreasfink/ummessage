//
//  main.m
//  ummessage-server
//
//  Created by Andreas Fink on 08.03.2025.
//

#import <Foundation/Foundation.h>
#import <ulib/ulib.h>
#import "UMMessageServer.h"
#include <stdlib.h>

int main(int argc, const char * argv[])
{
    int port = 9121;
    const char *rootDirectory = "/var/lib/ummessage-server/dbroot";
    @autoreleasepool
    {
        if(argc>1)
        {
            rootDirectory = argv[1];
        }
        if(argc>2)
        {
            port = atoi(argv[2]);
        }
        if((port<1) || (port > 65535))
        {
            fprintf(stderr,"port %dis out of range (1...65535)\n",port);
            return -1;
        }
        UMMessageServer *ms =  [[UMMessageServer alloc]initWithPort:port];
        ms.rootDirectory = @(rootDirectory);
        [ms startBackgroundTask];
        sleep(1); /* wait until listener is listening */
        while(ms.listener.isListening)
        {
            sleep(1);
        }
    }
    return 0;
}

