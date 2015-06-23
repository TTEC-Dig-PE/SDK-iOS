//
//  ECSJSONSerializer.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSActionTypeClassTransformer.h"
#import "ECSJSONSerializing.h"

/**
 ECSJSONSerializer provides methods for importing model objects from a JSON dictionary.
 */
@interface ECSJSONSerializer : NSObject

/**
 Creates a model object using the specified class type from the provided JSON dictionary. If the 
 class conforms to the ECSJSONSerializing protocol then the class is used directly. Otherwise, if
 the class conforms to the ECSJSONClassTransformer protocol, the import class is determined by
 the class transformer.
 
 @param dictionary the JSON dictionary containing the values to return
 @param aClass the class to use for import.  Must conform to either the ECSJSONSerializing or
               ECSJSONClassTransformer protocols.
 
 @return an object of the specified object type that has been populated by the dictionary or nil 
         if the import failed
 */
+ (id)objectFromJSONDictionary:(NSDictionary*)dictionary
                     withClass:(Class)aClass;

/**
 Creates an array of model objects using the specified class type from the provided JSON array. If 
 the class conforms to the ECSJSONSerializing protocol then the class is used directly. Otherwise, 
 if the class conforms to the ECSJSONClassTransformer protocol, the import class is determined by
 the class transformer.
 
 @param jsonArray the JSON dictionary containing the values to return
 @param aClass the class to use for import.  Must conform to either the ECSJSONSerializing or
               ECSJSONClassTransformer protocols.
 
 @return an object of the specified object type that has been populated by the dictionary or nil
         if the import failed
 */
+ (NSArray*)arrayFromJSONArray:(NSArray*)jsonArray
                     withClass:(Class)aClass;

/** 
 Returns a JSON dictionary based on the provided serializable object.
 
 @param object the serializable object
 
 @return the serialized object
 */
+ (NSDictionary*)jsonDictionaryFromObject:(id)object;

@end
