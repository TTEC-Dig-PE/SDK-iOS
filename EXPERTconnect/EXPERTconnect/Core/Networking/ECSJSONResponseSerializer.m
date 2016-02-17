//
//  ECSJSONResponseSerializer.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSJSONResponseSerializer.h"

@implementation ECSJSONResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error
{
    id result = nil;
    
    if ([data length] == 0) {
        //NSLog(@"WARNING: 0 byte JSON response from server.");
        return nil;
    }
    
    if (*error == nil)
    {
        NSError *serializationError = nil;
        result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&serializationError];
        
        if (serializationError != nil)
        {
            NSString *resultString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            result = resultString;
            *error = serializationError;
        }
    }
    
    return result;
}


@end
