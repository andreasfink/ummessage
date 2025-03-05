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

#include "UMMessage_macroVariables.h"
#include "UMMessage.def.h"
#include "UMMessage_macroClear.h"

}

#include "UMMessage_macroProperties.h"
#include "UMMessage.def.h"
#include "UMMessage_macroClear.h"

@end
