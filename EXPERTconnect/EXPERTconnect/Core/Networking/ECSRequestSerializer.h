//
//  ECSRequestSerializer.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Base class for serializing network requests.
 */
@interface ECSRequestSerializer : NSObject

/**
 Creates a URL request pased on the provided request and parameters.
 
 @param request the base request to use when serializing
 @param parameters the parameters to serialize as part of the request
 @param error the error returned if serializing the request fails.
 
 @return the serialized request or nil if serialization failed.
 */
- (NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request
                                   parameters:(id)parameter
                                        error:(NSError **)error;
@end
