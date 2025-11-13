//
//  UMMessageHistoryEntry.def.h
//  ummessage
//
//  Created by Andreas Fink on 07.04.2025.
//

STRING(o ,   37,UMMESSAGE_HISTORY_ENTRY_CODETAG_ARCHIVEID       ,"archive-id"   ,_archiveId         ,archiveId          ,"archive_id"  ,"indexed,unique,mandatory")
STRING(o ,   18,UMMESSAGE_HISTORY_ENTRY_CODETAG_INSTANCENAME    ,"instance"     ,_instance          ,instance           ,"instance"    ,"indexed,mandatory")
STRING(o ,   18,UMMESSAGE_HISTORY_ENTRY_CODETAG_MESSAGEID       ,"message-id"   ,_messageId         ,messageId          ,"message_id"  ,"indexed,mandatory")
STRING(o ,   18,UMMESSAGE_HISTORY_ENTRY_CODETAG_MSISDN          ,"msisdn"       ,_msisdn            ,msisdn             ,"msisdn"      ,"indexed,mandatory")
DATE(o   ,   14,UMMESSAGE_HISTORY_ENTRY_CODETAG_TIMESTAMP       ,"ts"           ,_ts                ,ts                 ,"ts"          ,"indexed,mandatory")
REAL(o   ,    0,UMMESSAGE_HISTORY_ENTRY_CODETAG_DELAY           ,"delay"        ,_delaySinceStart   ,delaySinceStart    ,"delay"       ,"")
STRING(o ,  255,UMMESSAGE_HISTORY_ENTRY_CODETAG_TEXT            ,"text"         ,_text              ,text               ,"text"        ,"mandatory")
