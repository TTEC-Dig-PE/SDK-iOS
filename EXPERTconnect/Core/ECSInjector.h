//
//  ECSInjector.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 ECSInjector provides simple dependency injection used across the SDK.
 */
@interface ECSInjector : NSObject

/**
 Returns the default injector.
 */
+ (instancetype)defaultInjector;

/**
 Retrieves the current object for the specified class or creates one if one does not yet exist.
 
 @param objectClass the class of the object to return
 
 @return an object for the specified class
 */
- (id)objectForClass:(Class)objectClass;

/**
 Sets the specified object for the specified class type.
 
 @param object the object to set for this class type.
 @param objectClass the class type to set
 */
- (void)setObject:(id)object forClass:(Class)objectClass;

@end
