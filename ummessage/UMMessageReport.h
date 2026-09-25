//
//  UMMessageReport *.h
//  um
//
//  Created by Andreas Fink on 26.03.2025.
//

#import <ulib/ulib.h>
#include <ummessage/UMMessageObject.h>
#import <ummessage/UMMessageStatusCode.h>

@class UMDbResult;

@interface UMMessageReport : UMASN1Sequence
{
    BOOL                                _isDirty;
    BOOL                                _hasBeenInserted;
    id                                  _currentTransaction;
    id                                  _originalSendingObject;
    UMMessageStatusCode                 _reportType;
    int                                 _priority;
    int                                 _responseCode;
    UMMessageObject                     *_reportToMsg;
    NSDictionary                        *_tlvs; /* not stored in DB directly */

    
#define INTEGER(o,len,tag,dictname,var,accessor,dbname,options)           NSNumber *var;
#define STRING(o,len,tag,dictname,var,accessor,dbname,options)            NSString *var;
#define TEXT(o,len,tag,dictname,var,accessor,dbname,options)              NSString *var;
#define DATE(o,len,tag,dictname,var,accessor,dbname,options)              NSDate   *var;
    
#include <ummessage/UMMessageReport.def.h>

#undef INTEGER
#undef STRING
#undef TEXT
#undef DATE


}

@property(readwrite,assign,atomic)  BOOL                isDirty;
@property(readwrite,assign,atomic)  BOOL                hasBeenInserted;
@property(readwrite,strong,atomic)  id                  currentTransaction;
@property(readwrite,strong,atomic)  id                  originalSendingObject;
@property(readwrite,assign,atomic)  UMMessageStatusCode      reportType;
@property(readwrite,assign,atomic)  int                 priority;
@property(readwrite,assign,atomic)  int                 responseCode;
@property(readwrite,strong,atomic)  UMMessageObject     *reportToMsg;

#define INTEGER(o,len,tag,dictname,var,accessor,dbname,options)          @property(readwrite,strong,atomic) NSNumber *accessor;
#define STRING(o,len,tag,dictname,var,accessor,dbname,options)           @property(readwrite,strong,atomic) NSString *accessor;
#define TEXT(o,len,tag,dictname,var,accessor,dbname,options)             @property(readwrite,strong,atomic) NSString *accessor;
#define DATE(o,len,tag,dictname,var,accessor,dbname,options)             @property(readwrite,strong,atomic) NSDate *accessor;

#include <ummessage/UMMessageReport.def.h>

#undef INTEGER
#undef STRING
#undef TEXT
#undef DATE

- (NSString *)insertOrUpdate:(NSString *)tableName session:(UMDbSession *)session;
+ (UMMessageReport *)reportFromDbResult:(UMDbResult *)dbResult;

@end

