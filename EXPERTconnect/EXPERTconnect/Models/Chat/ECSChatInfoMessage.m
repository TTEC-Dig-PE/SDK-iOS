//
//  ECSChatInfoMessage.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatInfoMessage.h"

@implementation ECSChatInfoMessage

- (id) init {
    return [self initWithInfoMessage:@"" biggerFont:NO];
}

-(id)initWithInfoMessage:(NSString *)message biggerFont:(BOOL)bigger {
    if (self = [super init]) {
        /* perform your post-initialization logic here */
        self.infoMessage = message;
        self.useBiggerFont = bigger;
    }
    return self;
}

- (NSDictionary *)ECSJSONMapping
{
    NSMutableDictionary *jsonMapping = [[super ECSJSONMapping] mutableCopy];
    
    [jsonMapping addEntriesFromDictionary:@{
                                            @"conversationId": @"conversationId",
                                            @"channelId": @"channelId",
                                            }];
    return jsonMapping;
}

- (id)copyWithZone:(NSZone*)zone
{
    ECSChatInfoMessage *message = [[[self class] allocWithZone:zone] init];
    
    message.useBiggerFont =    self.useBiggerFont; 
    message.infoMessage =      [self.infoMessage copyWithZone:zone];
    message.conversationId =   [self.conversationId copyWithZone:zone];
    message.channelId =        [self.channelId copyWithZone:zone];
    
    return message;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"<ECSChatInfoMessage : infoMessage=%@, useBiggerFont=%@, conversationId=%@, channelId=%@>",
            self.infoMessage, self.useBiggerFont, self.conversationId, self.channelId];
}

@end
