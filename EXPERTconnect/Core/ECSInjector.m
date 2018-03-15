//
//  ECSInjector.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSInjector.h"

static ECSInjector *ecsInjector;

@interface ECSInjector()

@property (nonatomic, strong) NSMutableDictionary *objectCache;

@end

@implementation ECSInjector

+ (instancetype)defaultInjector
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ecsInjector = [ECSInjector new];
    });
    
    return ecsInjector;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.objectCache = [NSMutableDictionary new];
    }
    
    return self;
}

- (id)objectForClass:(Class)objectClass
{
    id injectedObject = [self.objectCache objectForKey:[objectClass description]];
    if (!injectedObject)
    {
        injectedObject = [objectClass new];
        [self setObject:injectedObject forClass:objectClass];
    }
    
    return injectedObject;
}

- (void)setObject:(id)object forClass:(Class)objectClass
{
    [self.objectCache setObject:object forKey:[objectClass description]];
}

@end
