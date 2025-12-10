//
//  UMMessageHistory.def.h
//  ummessage
//
//  Created by Andreas Fink on 07.04.2025.
//
//type (object,length,tag,dictionary-key,variable-name,accessor-name,database-name,options)

STRING(o ,  255,UMMESSAGE_HISTORY_CODETAG_ARCHIVEID     ,"archive-id"   ,_archiveId  ,archiveId    ,"archive_id"   ,"indexed,unique,mandatory")
STRING(o ,   18,UMMESSAGE_HISTORY_CODETAG_INSTANCE      ,"instance"     ,_instance   ,instance     ,"instance"     ,"indexed,mandatory")
STRING(o ,   18,UMMESSAGE_HISTORY_CODETAG_MESSAGEID     ,"message-id"   ,_messageId  ,messageId    ,"message_id"   ,"indexed,mandatory")
STRING(o ,   18,UMMESSAGE_HISTORY_CODETAG_MSISDN        ,"msisdn"       ,_msisdn     ,msisdn       ,"msisdn"       ,"indexed,mandatory")
DATE(o   ,   14,UMMESSAGE_HISTORY_CODETAG_CREATED       ,"created"      ,_created    ,created      ,"created"      ,"indexed,mandatory")
DATE(o   ,   14,UMMESSAGE_HISTORY_CODETAG_UPDATED       ,"updated"      ,_updated    ,updated      ,"updated"      ,"indexed,mandatory")
/* ASN1 SEQUENCE for UMMESSAGE_HISTORY_CODETAG_ENTRIES to be added */
