//
//  ECSAnswerHistoryResponse.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <EXPERTconnect/EXPERTconnect.h>

@interface ECSAnswerHistoryResponse : ECSJSONObject <NSCopying, UIActivityItemSource>

@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *answerId;
@property (strong, nonatomic) NSString *request;
@property (strong, nonatomic) NSString *response;
@property (strong, nonatomic) NSString *title;

@property (readonly, nonatomic) NSString *shareText;

@end
