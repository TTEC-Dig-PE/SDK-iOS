//
//  ECSCustomDataClassTransformer.m
//  EXPERTconnect
//
//  Created by Ken Washington on 8/12/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSCustomDataClassTransformer.h"

@implementation ECSCustomDataClassTransformer

- (Class)defaultTransformClass
{
    return [NSDictionary class];
}

- (Class)classForJSONObject:(NSDictionary *)jsonDictionary
{
    return [self defaultTransformClass];
}

@end
