//
//  ConfigDatabasePool.def.h
//  ummessage
//
//  Created by Andreas Fink on 20.03.2025.
//

// o,tag,len,dictname,var,accessor,dbname,options
STRING(o,255,10,"host",_host,host,"host","")
STRING(o,255,11,"database-name",_databaseName,databaseName,"database_name","")
STRING(o,255,12,"driver",_driver,driver,"driver","")
STRING(o,255,13,"user",_user,user,"user","")
STRING(o,255,14,"pass",_pass,pass,"pass","encrypt")
INTEGER(o,4,15,"port",_port,port,"port","")
INTEGER(o,4,16,"min-sessions",_minSessions,minSessions,"min_sessions","")
INTEGER(o,4,17,"max-sessions",_maxSessions,maxSessions,"max_sessions","")
STRING(o,255,18,"socket",_socket,socket,"socket","")
DOUBLE(o,0,19,"ping-intervall",_pingIntervall,pingIntervall,"ping_intervall","")
STRING(o,255,20,"storage-type",_storageType,storageType,"storage_type","")
STRING(o,255,21,"version",_version,version,"version","")
STRING(o,255,22,"encryption-key",_encryptionKey,encryptionKey,"encryption_key","nodb")
