//
//  ConfigObject.def.h
//  ummessage
//
//  Created by Andreas Fink on 20.03.2025.
//
//
#if defined(INCLUDE_OBJECT_GROUP_COLUM)
STRING(o,   18,    1,  "group",        self.type,          type,               "group",       "index");
#endif

#if !defined(IGNORE_NAME_COLUM)
STRING  (o, 18,  2,    "name",        _name,              name,               "name",         "unique");
#endif
TEXT    (o, 65535,3,    "description", _objectDescription, objectDescription,  "description",  "");
BOOLEAN (o, 1,    4,    "enable",      _enabled,           enabled,            "enable",       "indexed");
INTEGER (o, 1,    5,    "log-level",   _logLevel,          logLevel,           "log_level",    "");
STRING  (o, 255,  6,    "log-file",    _logFile,           logFile,            "log_file",     "");

