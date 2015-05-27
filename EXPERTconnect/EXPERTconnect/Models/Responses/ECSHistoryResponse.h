//
//  ECSHistoryResponse.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <EXPERTconnect/EXPERTconnect.h>

@interface ECSHistoryResponse : ECSJSONObject <NSCopying>

@property (strong, nonatomic) NSArray *responses;

@end
