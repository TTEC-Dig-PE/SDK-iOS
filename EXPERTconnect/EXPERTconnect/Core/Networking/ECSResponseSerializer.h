//
//  ECSResponseSerializer.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Base class for serializing network responses.
 */
@interface ECSResponseSerializer : NSObject

/**
 Returns a response object based on the specified NSURLResponse and data.
 
 @param response the URL response for the network call.
 @param data the data returned from the network call to parse for the response object
 @param error the error to return if parsing failed
 
 @return the parsed object or nil if the object could not be parsed.
 */
- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError **)error;

@end
