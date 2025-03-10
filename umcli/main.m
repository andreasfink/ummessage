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
        UMMessageClient *client = [[UMMessageClient alloc]initWithHost:host port:9121];
        [client insertMessage:msg onCompletion:^(int status,NSString *error)
        
         ]
        NSArray *arr2 = [arr sortedArrayUsingComparator: ^(UMMutexStat *a, UMMutexStat *b)
                         {
                             if(sortByName)
                             {
                                 return [a.name compare:b.name];
                             }
                             else
                             {
                                 if(a.lock_count == b.lock_count)
                                 {
                                     return NSOrderedSame;
                                 }
                                 if(a.lock_count < b.lock_count)
                                 {
                                     return NSOrderedDescending;
                                 }
                                 return NSOrderedAscending;
                             }
                         }];
        pthread_mutex_unlock(global_ummutex_stat_mutex);

    }
    return 0;
}
