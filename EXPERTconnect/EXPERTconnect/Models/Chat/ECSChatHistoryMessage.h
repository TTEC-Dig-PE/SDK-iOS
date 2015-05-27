//
//  ECSChatHistoryMessage.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSJSONObject.h"

@interface ECSChatHistoryMessage : ECSJSONObject <ECSJSONSerializing>

@property (strong, nonatomic) NSString *actionId;
@property (strong, nonatomic) NSString *context;
@property (strong, nonatomic) NSString *dateString;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSString *messageId;
@property (strong, nonatomic) NSString *journeyId;
@property (strong, nonatomic) NSDictionary *request;
@property (strong, nonatomic) NSDictionary *response;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *type;

@end
