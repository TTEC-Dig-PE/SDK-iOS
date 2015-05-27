//
//  ECSJSONRequestSerializer.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSJSONRequestSerializer.h"

@implementation ECSJSONRequestSerializer


- (NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request
                                   parameters:(id)parameters
                                        error:(NSError *__autoreleasing *)error
{
    
    
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    
    if ([NSJSONSerialization isValidJSONObject:parameters])
    {
        NSString *method = [mutableRequest HTTPMethod];
        if ([method isEqualToString:@"GET"])
        {
            NSMutableArray *stringParams = [NSMutableArray new];
            
            for (id key in parameters) {
                id value = parameters[key];
                NSString *encodedKey = [[key description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSString *encodedValue = [[value description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [stringParams addObject:[NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue]];
            }
            
            NSString *paramsString = [stringParams componentsJoinedByString:@"&"];
            NSString *path = [NSString stringWithFormat:@"%@?%@", [[mutableRequest URL] absoluteString], paramsString];
            mutableRequest.URL = [NSURL URLWithString:path];
        }
        else if ([method isEqualToString:@"POST"] || [method isEqualToString:@"PUT"])
        {
            NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:error];
            if (error == nil || *error == nil)
            {
                CFStringRef charSet = CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
                NSString *contentType = [NSString stringWithFormat:@"application/json; charset=%@", charSet];
                [mutableRequest setValue:contentType forHTTPHeaderField:@"Content-Type"];
                [mutableRequest setValue:@"*/*" forHTTPHeaderField:@"Accept"];
                [mutableRequest setHTTPBody:data];
            }
        }
    }
    
    return mutableRequest;
}


@end
