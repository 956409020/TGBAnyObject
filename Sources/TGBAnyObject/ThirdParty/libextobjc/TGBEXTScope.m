//
//  TGBEXTScope.m
//  extobjc
//
//  Created by Justin Spahr-Summers on 2011-05-04.
//  Copyright (C) 2012 Justin Spahr-Summers.
//  Released under the MIT license.
//

#import "TGBEXTScope.h"

void lc_executeCleanupBlock (__strong ext_cleanupBlock_t *block) {
    (*block)();
}

