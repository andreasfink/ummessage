//
//  ConfigObject.m
//  umdbServer
//
//  Created by Andreas Fink on 23.01.2025.
//

#import "ConfigObject.h"
#import "ConfigObject.h"
#import "ConfigMacroHelper.h"

@implementation ConfigObject

- (BOOL) isDirty
{
    return _dirty;
}

- (void)setDirty:(BOOL)d
{
    _dirty = d;
}

- (NSString *)type
{
    return @"undefined";
}

- (void)setType:(NSString *)type
{
    /* dummy */
}

- (ConfigObject *)initWithConfig:(NSDictionary *)o
{
    self = [super init];
    if(self)
    {
        _subEntries =     [[NSMutableArray<ConfigObject *> alloc] init];
        [self setSuperConfig:o];
    }
    return self;
}

- (NSString *)configString
{
    NSMutableString *s = [[NSMutableString alloc]init];
    [self appendConfigToString:s];
    return s;
}

- (void)appendConfigToString:(NSMutableString *)o
{
    return [self appendConfigToString:o withoutName:NO];
}

- (void)appendConfigToString:(NSMutableString *)o withoutName:(BOOL)withoutName
{
    [o appendFormat:@"\n"];

    if(withoutName==NO)
    {
#define IGNORE_NAME_COLUM 1
#include "Config_macroAppendConfig.h"
#include "ConfigObject.def.h"
#include <um/UMMessage_macroClear.h>
    }
    else
    {
#define IGNORE_NAME_COLUM 1
#include "Config_macroAppendConfig.h"
#include "ConfigObject.def.h"
#include <um/UMMessage_macroClear.h>
    }
}

- (UMSynchronizedSortedDictionary *)config
{
    return [self configWithoutName:NO];
}

- (UMSynchronizedSortedDictionary *)configWithoutName:(BOOL)withoutName
{
    UMSynchronizedSortedDictionary *o = [[UMSynchronizedSortedDictionary alloc]init];

    if(withoutName)
    {
#define IGNORE_NAME_COLUM 1
#define INCLUDE_OBJECT_GROUP_COLUM 1
#define IGNORE_NAME_COLUM 1
#include "Config_macroAppendDict.h"
#include "ConfigObject.def.h"
#include "Config_macroClear.h"
#undef INCLUDE_OBJECT_GROUP_COLUM
}
else
{
#undef INCLUDE_OBJECT_GROUP_COLUM
#include "Config_macroAppendDict.h"
#include "ConfigObject.def.h"
#include "Config_macroClear.h"
}

    return o;
}

- (NSArray *)subConfig
{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for(ConfigObject *e in _subEntries)
    {
        [array addObject:e.config];
    }
    return array;
}

- (void)setConfig:(NSDictionary *)o
{
    /* to be defined in subclass */
}

- (void)setSubConfig:(NSArray *)configs
{
    /* to be defined in subclass */
}

- (void)setSuperConfig:(NSDictionary *)o
{
    /* group can not be set as the subclass defines it statically.
     So we already have to be the right object */

    /* names can only be filtered names */
    NSString *group =  o[@"group"];
    id n = o[@"name"];
    BOOL mustHaveName = ![self canHaveNoName];
    if(n==NULL)
       {
        if(mustHaveName)
        {
            fprintf(stderr,"Object of type %s must have a name",group.UTF8String);
            exit(-1);
        }
    }
    else if([n isKindOfClass:[NSString class]])
    {
        NSString *n2 = [ConfigObject filterName:(NSString *)n];
        if(n2.length > 0)
        {
            _name = n2;
        }
    }
    else
    {
        NSLog(@"Warning: Not a string for an object name. Probably misconfiguration: %@ in group %@",n,group);
    }

    NSString *newName = [ConfigObject filterName:o[@"newname"]];
    if((newName.length > 0) && (![newName isEqualToString:_name]))
    {
        _oldName = _name;
        _name = newName;
        _nameChanged = YES;
    }
#define IGNORE_NAME_COLUM 1
#include "Config_macroSetConfigFromDict.h"
#include "ConfigObject.def.h"
#include <um/UMMessage_macroClear.h>

    id comments = o[@"comment"];
    if([comments isKindOfClass:[NSArray class]])
    {
        _comments = (NSArray *)comments;
    }
    else if([comments isKindOfClass:[NSString class]])
    {
        _comments = [((NSString *)comments) componentsSeparatedByString:@"\n"];
    }
}

+(NSString *)filterName:(NSString *)str
{
    if(str==NULL)
    {
        return NULL;
    }
    NSInteger LIMIT = 64;
    char out[LIMIT];
    NSInteger i;
    NSInteger j=0;
    NSInteger n=str.length;
    if(n>LIMIT)
    {
        n = LIMIT;
    }
    memset(out,0x00,sizeof(out));
    for(i=0;i<n;i++)
    {
        unichar c = [str characterAtIndex:i];
        if((c>='a') && (c<='z'))
        {
            out[j++]=c;
        }
        else if((c>='A') && (c<='Z'))
        {
            out[j++]=c-'A'+'a';
        }
        else if((c>='0') && (c<='9'))
        {
            out[j++]=c;
        }
        else
        {
            switch(c)
            {
                case '.':
                    if(i>0)
                    {
                        out[j++]=c;
                    }
                    break;
                case '_':
                case '-':
                case '+':
                case ',':
                case '=':
                case '%':
                    out[j++]=c;
                    break;
                default:
                    break;
            }
        }
    }
    out[LIMIT-1]='\0';
    NSString *result = @(out);
    return result;
}

- (ConfigObject *)copyWithZone:(NSZone *)zone
{
    UMSynchronizedSortedDictionary *currentConfig = [self config];
    ConfigObject *o = [[ConfigObject allocWithZone:zone]initWithConfig:[currentConfig dictionaryCopy]];
    o.subEntries = _subEntries;
    return o;
}

- (void)addSubEntry:(ConfigObject *)obj
{
    if(_subEntries==NULL)
    {
       _subEntries =  [[NSMutableArray alloc]init];
    }
    [_subEntries addObject:obj];
}

- (NSArray<NSDictionary *> *)subConfigs
{
    NSMutableArray *configs = [[NSMutableArray alloc]init];
    for(ConfigObject *co in _subEntries)
    {
        [configs addObject:[co.config dictionaryCopy]];
    }
    return configs;
}

- (id)proxyForJson
{
    return self.config;
}

- (ConfigObject *)initWithString:(NSString *)s
{
    NSArray *lines = [s componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    for(NSString *line in lines)
    {
        NSArray *items  = [line componentsSeparatedByString:@"="];
        if ([items count] == 2)
        {
            NSString *tag = [[items objectAtIndex:0] trim];
            NSString *val = [[items objectAtIndex:1] trim];
            dict[tag] = val;
        }
    }
    return [self initWithConfig:dict];
}

- (NSString *)description
{
    NSMutableString *s = [[NSMutableString alloc]init];
    
    [s appendString:[super description]];
    [s appendString:@"\n{"];
    [s appendString:[self configString]];
    [s appendString:@"\n}"];
    return s;
}

+ (NSNumber *)boolFromString:(NSString *)str
{
    if(str==NULL)
    {
        return NULL;
    }
    if([str isEqualToStringCaseInsensitive:@"YES"])
    {
        return @(YES);
    }
    if([str isEqualToStringCaseInsensitive:@"true"])
    {
        return @(YES);
    }
    if([str isEqualToStringCaseInsensitive:@"on"])
    {
        return @(YES);
    }
    if([str intValue]!=0)
    {
        return @(YES);
    }
    return @(NO);
}

- (BOOL)canHaveNoName
{
    return NO;
}
@end
