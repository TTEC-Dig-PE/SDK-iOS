//
//  ECSJSONObject.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSJSONSerializing.h"

/** 
 Base object type for all JSON objects.  Provides a boilerplate description call.
 */
@interface ECSJSONObject : NSObject <ECSJSONSerializing>

@end
