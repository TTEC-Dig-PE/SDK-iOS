//
//  ECSWebActionType.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <EXPERTconnect/EXPERTconnect.h>

/**
 Action type specifying web content
 */
@interface ECSWebActionType : ECSActionType <NSCopying>

// URL of the web content
@property (strong, nonatomic) NSString *url;

@end
