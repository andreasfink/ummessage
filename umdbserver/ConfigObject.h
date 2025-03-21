//
//  ConfigObject.h
//  umdbserver
//
//  Created by Andreas Fink on 20.03.2025.
//


#import <ulib/ulib.h>


@interface ConfigObject : UMObject
{
    BOOL            _dirty;
    NSString         *_name;
    NSString         *_oldName;
    NSNumber         *_enabled;
    NSNumber         *_logLevel;
    NSString         *_logFile;
    NSArray<NSString *>*_comments;
    NSString         *_objectDescription;
    NSMutableArray<ConfigObject *> *_subEntries;
    BOOL            _nameChanged;
}

@property(readwrite,strong,atomic)  NSString        *name;
@property(readwrite,strong,atomic)  NSNumber        *enabled;
@property(readwrite,strong,atomic)  NSNumber        *logLevel;
@property(readwrite,strong,atomic)  NSString        *logFile;
@property(readwrite,strong,atomic)  NSArray         *comments;
@property(readwrite,strong,atomic)  NSString        *objectDescription; /*we have to name this differently due to [NSObject description] */
@property(readwrite,strong,atomic)  NSMutableArray<ConfigObject *> *subEntries;
@property(readwrite,assign,atomic)  BOOL            nameChanged;

- (BOOL) isDirty;
- (void) setDirty:(BOOL)d;

- (ConfigObject *)initWithConfig:(NSDictionary *)dict;
- (ConfigObject *)initWithString:(NSString *)s;

- (NSString *)configString;
- (NSString *)type;

- (void)appendConfigToString:(NSMutableString *)o;
- (void)appendConfigToString:(NSMutableString *)o withoutName:(BOOL)withoutName;

- (UMSynchronizedSortedDictionary *)config;
- (UMSynchronizedSortedDictionary *)configWithoutName:(BOOL)withoutName;

- (void)setConfig:(NSDictionary *)config;
- (void)setSuperConfig:(NSDictionary *)config;

+ (NSString *)filterName:(NSString *)str;
- (ConfigObject *)copyWithZone:(NSZone *)zone;
- (void)addSubEntry:(ConfigObject *)obj;

- (NSArray<NSDictionary *> *)subConfigs;
- (id)proxyForJson;
- (NSString *)description;
+ (NSNumber *)boolFromString:(NSString *)str;

- (BOOL)canHaveNoName;

@end
