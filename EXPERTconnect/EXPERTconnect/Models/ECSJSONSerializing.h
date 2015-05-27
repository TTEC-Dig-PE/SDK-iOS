//
//  ECSJSONSerializing.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Objects that conform to the ECSJSONSerializing protocol can be imported using the ECSJSONSerializer.
 */
@protocol ECSJSONSerializing <NSObject>

@required

/**
 A dictionary containing a mapping of JSON object keys to model object property names. Keys in this
 dictionary correspond to the JSON object keys and the values correspond to the property names in 
 the model object. Only mappings specified in this dictionary will be populated in the model object.
 */
- (NSDictionary*)ECSJSONMapping;

/**
 A dictionary containing a mapping of model object property names to either the class types they 
 should be imported as or to the transformer class that can be used to transform the JSON.  If
 a class is supplied that conforms to the ECSJSONSerializing protocol, then the object for the given
 property will be created with that class type.  If the class conforms to the ECSJSONClassTransformer
 protocol, then that object will be used to transform the JSON object into an appropriate class type.
 */
- (NSDictionary*)ECSJSONTransformMapping;

@optional

- (NSDictionary*)ECSJSONTypeMap;

/** 
 Return YES to have serialization of an object to JSON ignore nil values and not add them to the 
 JSON dictionary
 */
- (BOOL)ignoreNilValues;

/**
 If implemented, this method is called by ECSJSONSerializer after the initial import is complete.
 */
- (void)didImportObject;

@end
