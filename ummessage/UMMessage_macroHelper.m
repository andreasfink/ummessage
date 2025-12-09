//
//  UMMessage_macroHelper.m
//  ummessage
//
//  Created by Andreas Fink on 05.03.2025.
//

#import "UMMessage_macroHelper.h"

/// adds a dbField declaration
/// - Parameters:
///     - type: The food for the sloth to eat.
///     - len: The quantity of the food for the sloth to eat.
///     - dbname: field name when used in a database
///     - options: string containing comma separated options
/// - Returns: a dictionary containing all the options by key 'name', 'type','len', 'indexed', 'unique','autoincrement'
/// - Throws: doesnt throw

static UMSynchronizedSortedDictionary * dbFieldWithOptions( NSString *type,int len, const char *dbname,const char *options);

static UMSynchronizedSortedDictionary * dbFieldWithOptions( NSString *type,int len, const char *dbname,const char *options)
{
    UMSynchronizedSortedDictionary *e = [[UMSynchronizedSortedDictionary alloc]init];
    e[@"name"]  = @(dbname);
    e[@"type"]  = type;
    e[@"len"]   = @(len);
    NSString *s = @(options);
    NSArray *a = [s componentsSeparatedByString:@","];
    for(NSString *option in a)
    {
        if ([option isEqualToStringCaseInsensitive:@"indexed"])
        {
            e[@"indexed"]   = @YES;
        }
        if ([option isEqualToStringCaseInsensitive:@"unique"])
        {
            e[@"unique"]   = @YES;
        }
        if ([option isEqualToStringCaseInsensitive:@"autoincrement"])
        {
            e[@"autoincrement"]   = @YES;
        }
    }
    return e;
}

void ummessage_addFieldDefBoolean(UMSynchronizedSortedDictionary *o,int len,const char *dbname,const char *options)
{
    NSString *type;
    type = @"smallint";
    UMSynchronizedSortedDictionary *e = dbFieldWithOptions(type,len,dbname,options);
    o[@(dbname)] = e;
}

void ummessage_addFieldDefString(UMSynchronizedSortedDictionary *o,int len, const char *dbname,const char *options)
{
    NSString *type  = [NSString stringWithFormat:@"varchar(%d)",len];
    UMSynchronizedSortedDictionary *e = dbFieldWithOptions(type,len,dbname,options);
    o[@(dbname)] = e;
}

void ummessage_addFieldDefInteger(UMSynchronizedSortedDictionary *o,int len, const char *dbname,const char *options)
{
    NSString *type;
    if((len==1) || (len==2))
    {
        type = @"smallint";
    }
    else
    {
        type = @"integer";
    }
    UMSynchronizedSortedDictionary *e = dbFieldWithOptions(type,len,dbname,options);
    o[@(dbname)] = e;
}

void ummessage_addFieldDefDate(UMSynchronizedSortedDictionary *o,int len, const char *dbname,const char *options)
{
    if(len < 14)
    {
        len = 14;
    }
    NSString *type  = [NSString stringWithFormat:@"varchar(%d)",len];
    UMSynchronizedSortedDictionary *e = dbFieldWithOptions(type,len,dbname,options);
    o[@(dbname)] = e;
}

void ummessage_addFieldDefData(UMSynchronizedSortedDictionary *o,int len, const char *dbname,const char *options)
{
    UMSynchronizedSortedDictionary *e = dbFieldWithOptions(@"text",len,dbname,options);
    o[@(dbname)] = e;
}

void ummessage_addFieldDefBinary(UMSynchronizedSortedDictionary *o,int len, const char *dbname,const char *options)
{
    UMSynchronizedSortedDictionary *e = dbFieldWithOptions(@"blob",len,dbname,options);
    o[@(dbname)] = e;
}


void ummessage_addFieldDefText(UMSynchronizedSortedDictionary *o,int len, const char *dbname,const char *options)
{
    UMSynchronizedSortedDictionary *e = dbFieldWithOptions(@"text",len,dbname,options);
    o[@(dbname)] = e;
}

void ummessage_addFieldDefArray(UMSynchronizedSortedDictionary *o,int len, const char *dbname,const char *options)
{
    UMSynchronizedSortedDictionary *e = dbFieldWithOptions(@"text",len,dbname,options);
    o[@(dbname)] = e;
}


void ummessage_addFieldDefDouble(UMSynchronizedSortedDictionary *o,int len, const char *dbname,const char *options)
{
    UMSynchronizedSortedDictionary *e = dbFieldWithOptions(@"real(16,8)",len,dbname,options);
    o[@(dbname)] = e;
}

NSString *ummessage_fieldDefsToSql(UMSynchronizedSortedDictionary *o, NSString *dbTableName)
{
    NSMutableString *s = [[NSMutableString alloc]init];
    [s appendFormat:@"CREATE TABLE `%@`  (\n",dbTableName];
    
    NSString *uniqueKey = NULL;
    NSMutableArray *indexedFields = [[NSMutableArray alloc]init];
    NSArray *keys = [o allKeys];
    for(id key in keys)
    {
        UMSynchronizedSortedDictionary *e = o[key];
        if(e[@"unique"])
        {
            uniqueKey = e[@"name"];
        }
        if(e[@"indexed"])
        {
            [indexedFields addObject:e[@"name"]];
        }
        [s appendFormat:@"  `%@` %@",e[@"name"],e[@"type"]];
        
        if(e[@"unique"])
        {
            [s appendFormat:@" NOT NULL"];
            if(e[@"autoincrement"])
            {
                [s appendFormat:@" AUTO_INCREMENT"];
            }
        }
        else
        {
            if(e[@"notnull"])
            {
                [s appendFormat:@" NOT NULL"];
                if( ([e[@"type"]isEqualToStringCaseInsensitive:@"VARCHAR"]) ||
                   ([e[@"type"]isEqualToStringCaseInsensitive:@"CHAR"])    ||
                   ([e[@"type"]isEqualToStringCaseInsensitive:@"TEXT"]))
                {
                    [s appendFormat:@" DEFAULT ''"];
                }
                if( ([e[@"type"]isEqualToStringCaseInsensitive:@"INTEGER"])  ||
                   ([e[@"type"]isEqualToStringCaseInsensitive:@"SMALLINT"]) ||
                   ([e[@"type"]isEqualToStringCaseInsensitive:@"TINYINT"])  ||
                   ([e[@"type"]isEqualToStringCaseInsensitive:@"INT"]))
                {
                    [s appendFormat:@" DEFAULT '0'"];
                }
            }
            else
            {
                [s appendFormat:@" NULL"];
            }
        }
        [s appendString:@",\n"];
    }
    if(uniqueKey)
    {
        [s appendFormat:@"  PRIMARY KEY (`%@`),\n",uniqueKey];
    }
    for(NSString *index in indexedFields)
    {
        [s appendFormat:@"  INDEX `%@_idx`(`%@`),\n",index,index];
    }

    /* remove the last comma before the linefeed */
    NSRange range = NSMakeRange([s length]-2,1);
    [s replaceCharactersInRange:range withString:@""];
    [s appendString:@") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;\n"];
    return s;
}


void ummessage_addTableDefString(NSMutableString *o,int len, const char *dbname, const char *options)
{
    [o appendFormat:@"    `%s` varchar(%d),\n",dbname,len];
}

void ummessage_addTableDefInteger(NSMutableString *o,int len, const char *dbname, const char *options)
{
    if((len==1) || (len==2))
    {
        [o appendFormat:@"    `%s` smallint,\n",dbname];
    }
    else
    {
        [o appendFormat:@"    `%s` integer,\n",dbname];
    }
}

void ummessage_addTableDefBoolean(NSMutableString *o,int len, const char *dbname, const char *options)
{
    [o appendFormat:@"    `%s` smallint,\n",dbname];
}

void ummessage_addTableDefDate(NSMutableString *o,int len, const char *dbname, const char *options)
{
    [o appendFormat:@"    `%s` varchar(14),\n",dbname];
}

void ummessage_addTableDefData(NSMutableString *o,int len, const char *dbname, const char *options)
{
    [o appendFormat:@"    `%s` blob,\n",dbname];
}


void ummessage_addTableDefText(NSMutableString *o,int len,const char *dbname, const char *options)
{
    [o appendFormat:@"    `%s` text,\n",dbname];
}

void ummessage_addTableDefArray(NSMutableString *o,int len, const char *dbname, const char *options)
{
    [o appendFormat:@"    `%s` text,\n",dbname];
}


void ummessage_addTableDefDouble(NSMutableString *o,int len, const char *dbname, const char *options)
{
    [o appendFormat:@"    `%s` real(16,8),\n",dbname];
}
