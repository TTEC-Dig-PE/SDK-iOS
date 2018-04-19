//
//  ECSJSONSerializer.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//
#import <Foundation/NSKeyValueCoding.h>
#import "ECSJSONSerializer.h"

#import "ECSJSONSerializing.h"

#import "ECSActionType.h"
#import "ECSActionTypeClassTransformer.h"

@implementation ECSJSONSerializer

+ (id)objectFromJSONDictionary:(NSDictionary*)dictionary
              withClass:(Class)aClass
{
    NSAssert(([aClass conformsToProtocol:@protocol(ECSJSONClassTransformer)] ||
              [aClass conformsToProtocol:@protocol(ECSJSONSerializing)]),
             @"Specified class must conform to either the ECSJSONClassTransformer or ECSJSONSerializing protocols");
    
    Class objectType = nil;
    
    // Convert the class type if a transformer exists.
    if ([aClass conformsToProtocol:@protocol(ECSJSONClassTransformer)])
    {
        id<ECSJSONClassTransformer> classTransformer = [[aClass alloc] init];
        objectType = [classTransformer classForJSONObject:dictionary];
    }
    else
    {
        objectType = aClass;
    }
    
    id importObject = [[objectType alloc] init];
    
    if ([importObject conformsToProtocol:@protocol(ECSJSONSerializing)])
    {
        id<ECSJSONSerializing> ecsImportObject = importObject;
        NSDictionary *mappedProperties = [ecsImportObject ECSJSONMapping];
        
        // Iterate through the mapped JSON properties
        for (NSString *key in [mappedProperties allKeys])
        {
            NSString *propertyKey = [mappedProperties objectForKey:key];
            id jsonValue = [dictionary valueForKeyPath:key];
            id convertedJSONValue = jsonValue;
            
            Class jsonClassType = [[ecsImportObject ECSJSONTransformMapping] objectForKey:key];
            
            // If there is a class for transforming the JSON object, then import with the
            // transformer
            if (jsonClassType)
            {
                if ([jsonValue isKindOfClass:[NSArray class]])
                {
                    convertedJSONValue = [ECSJSONSerializer arrayFromJSONArray:jsonValue
                                                                     withClass:jsonClassType];


                }
                else if ([jsonValue isKindOfClass:[NSDictionary class]])
                {
                    convertedJSONValue = [ECSJSONSerializer objectFromJSONDictionary:jsonValue
                                                                           withClass:jsonClassType];
                    
                    if([convertedJSONValue isKindOfClass:[NSDictionary class]])  {
                        convertedJSONValue = jsonValue;
                    }
                }
            }

            if (![convertedJSONValue isKindOfClass:[NSNull class]] && convertedJSONValue != nil)
            {
                [importObject setValue:convertedJSONValue forKey:propertyKey];
            }
        }
        
        if ([importObject respondsToSelector:@selector(didImportObject)])
        {
            [importObject didImportObject];
        }
    }
    
    return importObject;
}

+ (NSArray*)arrayFromJSONArray:(NSArray*)jsonArray
                     withClass:(Class)aClass
{
    NSAssert(([aClass conformsToProtocol:@protocol(ECSJSONClassTransformer)] ||
              [aClass conformsToProtocol:@protocol(ECSJSONSerializing)]),
             @"Specified class must conform to either the ECSJSONClassTransformer or ECSJSONSerializing protocols");

    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:jsonArray.count];
    
    id<ECSJSONClassTransformer> classTransformer = nil;
    
    if ([aClass conformsToProtocol:@protocol(ECSJSONClassTransformer)])
    {
        classTransformer = [[aClass alloc] init];
    }
    
    for (id arrayObject in jsonArray)
    {
        if ([arrayObject isKindOfClass:[NSDictionary class]])
        {
            Class modelClass = aClass;
            
            if (classTransformer)
            {
                modelClass = [classTransformer classForJSONObject:arrayObject];
                
            }
            
            [array addObject:[ECSJSONSerializer objectFromJSONDictionary:arrayObject
                                                               withClass:modelClass]];
        }
    }
    
    return array;
}

+ (NSDictionary*)jsonDictionaryFromObject:(id)object
{
    NSMutableDictionary *jsonDictionary = [NSMutableDictionary new];
    
    NSArray *jsonKeys = [[object ECSJSONMapping] allKeys];
    
    BOOL ignoreNilValues = NO;
    if ([object respondsToSelector:@selector(ignoreNilValues)])
    {
        ignoreNilValues = [object ignoreNilValues];
    }
    
    for (NSString *jsonKey in jsonKeys)
    {
        NSString *propertyPath = [[object ECSJSONMapping] objectForKey:jsonKey];
        
        id propertyValue = [object valueForKey:propertyPath];
        
        if ([propertyValue isKindOfClass:[NSArray class]])
        {
            NSMutableArray *arrayProperty = [[NSMutableArray alloc] initWithCapacity:((NSArray*)propertyValue).count];
            
            for (NSObject *arrayObject in propertyValue)
            {
                if ([arrayObject conformsToProtocol:@protocol(ECSJSONSerializing)])
                {
                    [arrayProperty addObject:[ECSJSONSerializer jsonDictionaryFromObject:(NSObject<ECSJSONSerializing>*)arrayObject]];
                }
                else
                {
                    [arrayProperty addObject:arrayObject];
                }
            }
            [jsonDictionary setObject:arrayProperty forKey:jsonKey];
        }
        else
        {
            if ([propertyValue conformsToProtocol:@protocol(ECSJSONSerializing)])
            {
                id object = [ECSJSONSerializer jsonDictionaryFromObject:propertyValue];
                
                if (!(ignoreNilValues && (object == nil || [object isKindOfClass:[NSNull class]])))
                {
                    [jsonDictionary setObject:[ECSJSONSerializer jsonDictionaryFromObject:propertyValue]
                                       forKey:jsonKey];
                }
            }
            else
            {
                if (propertyValue)
                {
                    if (!(ignoreNilValues && (object == nil || [object isKindOfClass:[NSNull class]])))
                    {
                        [jsonDictionary setObject:propertyValue forKey:jsonKey];
                    }
                }
                else if (!ignoreNilValues)
                {
                    [jsonDictionary setObject:[NSNull null] forKey:jsonKey];
                }
            }
        }
    }
    
    return jsonDictionary;
}

@end
