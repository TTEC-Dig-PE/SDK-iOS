//
//  ECSUtilities.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef ECS_UTILITIES_H
#define ECS_UTILITIES_H

/** 
 Returns YES if the provided object is nil, NSNull or an empty container
 */
static inline BOOL IsNullOrEmpty(id object)
{
    return (object == nil) ||
    ([object isEqual:[NSNull null]]) ||
    ([object respondsToSelector:@selector(length)] && [(NSData*)object length] == 0) ||
    ([object respondsToSelector:@selector(count)] && [(NSArray*)object count] == 0);
}


#endif
