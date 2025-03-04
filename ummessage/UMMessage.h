//
//  UMMessage.h
//  ummessage
//
//  Created by Andreas Fink on 03.03.2025.
//  Copyright 2025 Andreas Fink, Paradieshofstrasse 101, 4054 Basel andreas@fink.org
//


#import <ulibasn1/ulibasn1.h>

@interface UMMessage : UMASN1Sequence
{

#include "Config_macroVariables.h"
#include "UMMessage.def.h"
#include "Config_macroClear.h"

}

#include "Config_macroProperties.h"
#include "UMMessage.def.h"
#include "Config_macroClear.h"

@end
