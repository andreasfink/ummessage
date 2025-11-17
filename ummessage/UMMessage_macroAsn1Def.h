//
//  UMMessage_macroAsn1Def.h
//  ummessage
//
//  Created by Andreas Fink on 17.11.2025.
//



#define STRING(o,len1,tag1,dictname1,field1,accessor1,dbname1,options1) \
[UMASN1Object asn1DefAppendString:o len:len1 \
tag:tag1 \
dictname:dictname1 \
options:options1 \
type:"UTF8String"];

#define TEXT(o,len1,tag1,dictname1,field1,accessor1,dbname1,options1) \
[UMASN1Object asn1DefAppendString:o len:len1 \
tag:tag1 \
dictname:dictname1 \
options:options1 \
type:"UTF8String"];

#define INTEGER(o,len1,tag1,dictname1,field1,accessor1,dbname1,options1) \
[UMASN1Object asn1DefAppendString:o len:len1 \
tag:tag1 \
dictname:dictname1 \
options:options1 \
type:"INTEGER"];

#define DATE(o,len1,tag1,dictname1,field1,accessor1,dbname1,options1) \
[UMASN1Object asn1DefAppendString:o len:len1 \
tag:tag1 \
dictname:dictname1 \
options:options1 \
type:"UTF8String"];

#define DATA(o,len1,tag1,dictname1,field1,accessor1,dbname1,options1) \
[UMASN1Object asn1DefAppendString:o len:len1 \
tag:tag1 \
dictname:dictname1 \
options:options1 \
type:"OCTETSTRING"];


#define REAL(o,len1,tag1,dictname1,field1,accessor1,dbname1,options1) \
[UMASN1Object asn1DefAppendString:o len:len1 \
tag:tag1 \
dictname:dictname1 \
options:options1 \
type:"REAL"];
