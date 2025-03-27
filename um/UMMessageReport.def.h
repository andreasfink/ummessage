//
//  UMMessageReport.def.h
//  um
//
//  Created by Andreas Fink on 26.03.2025.
//

INTEGER(o,18,11,"db-id",_dbid,dbid,"dbid","unique,autoincrement")
DATE(o,0,12,"ts",_timestamp,timestamp,"ts","indexed")
STRING(o,18,13,"message-id",_messageId,messageId,"message_id","indexed")
STRING(o,18,14,"user",_user,user,"user","indexed")
STRING(o,18,15,"provider",_provider,provider,"provider","")
STRING(o,255,16,"user-reference",_userReference,userReference,"user_reference","indexed")
STRING(o,255,17,"router-reference",_routerReference,routerReference,"router_reference","indexed")
STRING(o,255,18,"provider-reference",_providerReference,providerReference,"provider_reference","indexed")
STRING(o,18,19,"from-number",_fromNumber,fromNumber,"from_number","")
STRING(o,18,20,"to-number",_toNumber,toNumber,"to_number","")
STRING(o,255,21,"report-text",_reportText,reportText,"report_text","")
STRING(o,18,22,"report-type",_reportTypeAsString,reportTypeAsString,"report_type","")
INTEGER(o,4,23,"error",_errorInt,errorInt,"error","")
INTEGER(o,4,24,"priority",_priorityInt,priorityInt,"priority","")
STRING(o,255,25,"imsi",_imsi,imsi,"imsi","")
STRING(o,255,26,"msc",_msc,msc,"msc","")
STRING(o,255,27,"mnc",_mnc,mnc,"mnc","")
STRING(o,255,28,"mcc",_mcc,mcc,"mcc","")
STRING(o,255,29,"hlr",_hlr,hlr,"hlr","")
INTEGER(o,255,30,"response-code",_responseCodeInt,responseCodeInt,"response_code","")
INTEGER(o,4,31,"error",_error,error,"error","")
INTEGER(o,4,32,"network-error",_networkError,networkError,"network_error","")
STRING(o,255,33,"error-description",_errorString,errorString,"error-description","")
TEXT(o,65535,34,"tlvs",_tlvsText,tlvsText,"tlvs","")
