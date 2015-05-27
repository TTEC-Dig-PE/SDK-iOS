//
//  ECSChatHistoryResponse.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSJSONObject.h"

@interface ECSChatHistoryResponse : ECSJSONObject <ECSJSONSerializing>

@property (strong, nonatomic) NSArray *journeys;

/**
 Returns an array of chat messages in the format that they would come through the chat API
 
 @return the converted array of chat messages
 */
- (NSArray*)chatMessages;

@end
