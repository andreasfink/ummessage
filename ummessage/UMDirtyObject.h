//
//  UMDirtyObject.h
//  ummessage
//
//  Created by Andreas Fink on 03.03.2025.
//

#import <ulib/ulib.h>

@interface UMDirtyObject : UMObject
{
    BOOL    _isDirty;
    id      _currentValue;
    id      _previousValue;
}

@property(readwrite,assign) BOOL    isDirty;
@property(readwrite,strong) id      currentValue;
@property(readwrite,strong) id      previousValue;

@end

