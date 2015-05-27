//
//  ECSRequestSerializer.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSRequestSerializer.h"

@implementation ECSRequestSerializer

- (NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request parameters:(id)parameter error:(NSError **)error
{
    return request;
}

@end
