//
//  ECSJSONClassTransformer.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 ECSJSONClassTransformer protocol defines an interface for allowing an object to return the object 
 class to be used when processing a JSON object.
 */
@protocol ECSJSONClassTransformer <NSObject>

@required

/**
 Returns a class for deserializing JSON based on the original JSON dictionary.
 
 @param jsonDictionary the JSON dictionary to deserialize
 
 @return the class to use when deserializing the JSON
 */
- (Class)classForJSONObject:(NSDictionary*)jsonDictionary;

@end
