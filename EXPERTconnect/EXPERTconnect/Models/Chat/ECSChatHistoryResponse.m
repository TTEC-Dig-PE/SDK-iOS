//
//  ECSChatHistoryResponse.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatHistoryResponse.h"

#import "ECSChatHistoryMessage.h"
#import "ECSJSONSerializer.h"

#import "ECSChatHistoryMessage.h"
#import "ECSChatMessage.h"
#import "ECSChatStateMessage.h"
#import "ECSChatTextMessage.h"
#import "ECSChatURLMessage.h"
#import "ECSChatFormMessage.h"
#import "ECSChannelStateMessage.h"
#import "ECSChatAddParticipantMessage.h"
#import "ECSChatAddChannelMessage.h"
#import "ECSChatAssociateInfoMessage.h"
#import "ECSChatCoBrowseMessage.h"
#import "ECSChatVoiceAuthenticationMessage.h"
#import "ECSChatInfoMessage.h"
#import "ECSChatMediaMessage.h"
#import "ECSChatNotificationMessage.h"
#import "ECSLocalization.h"

@implementation ECSChatHistoryResponse

- (NSDictionary *)ECSJSONMapping
{
    return @{
             @"journeys": @"journeys"
             };
}

- (NSArray *)chatMessages
{

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:SS"];
    NSMutableArray *chatMessages = [[NSMutableArray alloc] init];

    NSDictionary *messageMapping = @{
                                     @"AddParticipantMessage": [ECSChatAddParticipantMessage class],
                                     @"ChannelState": [ECSChannelStateMessage class],
                                     @"RenderURLCommand": [ECSChatURLMessage class],
                                     @"ChatMessage": [ECSChatTextMessage class],
                                     @"ChatState": [ECSChatStateMessage class],
                                     @"AssociateInfoCommand": [ECSChatAssociateInfoMessage class],
                                     @"CoBrowseMessage": [ECSChatCoBrowseMessage class],
                                     @"VoiceAuthenticationMessage": [ECSChatVoiceAuthenticationMessage class],
                                     @"NotificationMessage": [ECSChatNotificationMessage class]
                                     
                                     };
    
    for (NSDictionary *journey in self.journeys)
    {
        NSMutableArray *historyMessageArray = [[NSMutableArray alloc] initWithCapacity:self.journeys.count];
        for (NSDictionary *detail in [journey objectForKey:@"details"])
        {
            ECSChatHistoryMessage *message = [ECSJSONSerializer objectFromJSONDictionary:detail withClass:[ECSChatHistoryMessage class]];
            if ([message.dateString isKindOfClass:[NSString class]] && message.dateString.length)
            {
                message.date = [dateFormatter dateFromString:message.dateString];
            }
            
            [historyMessageArray addObject:message];
        }
        
       [historyMessageArray sortUsingComparator:^NSComparisonResult(ECSChatHistoryMessage* obj1, ECSChatHistoryMessage* obj2) {
            return [obj1.date compare:obj2.date];
        }];
        
        for (ECSChatHistoryMessage *message in historyMessageArray)
        {
        
            Class transformClass = messageMapping[message.type];
        
            if (transformClass)
            {
                BOOL fromAgent = NO;
                
                NSDictionary *dictionary = nil;
                
                if (message.request && [message.request isKindOfClass:[NSDictionary class]])
                {
                    fromAgent = NO;
                    dictionary = message.request;
                }
                else if (message.response && [message.response isKindOfClass:[NSDictionary class]])
                {
                    fromAgent = YES;
                    dictionary = message.response;
                }
                
                id<ECSJSONSerializing> transformedMessage = [ECSJSONSerializer objectFromJSONDictionary:dictionary
                                                                                              withClass:transformClass];
                if ([transformedMessage isKindOfClass:[ECSChatMessage class]])
                {
                    ((ECSChatMessage*)transformedMessage).fromAgent = fromAgent;
                }
                
                if ([transformedMessage isKindOfClass:[ECSChannelStateMessage class]])
                {
                    ECSChannelStateMessage *stateMessage = (ECSChannelStateMessage*)transformedMessage;
                    
                    if ([stateMessage.state isEqualToString:@"disconnected"])
                    {
                        ECSChatInfoMessage *disconnectedMessage = [ECSChatInfoMessage new];
                        disconnectedMessage.fromAgent = YES;
                        disconnectedMessage.infoMessage = ECSLocalizedString(ECSLocalizeChatDisconnected, @"Disconnected");
                        [chatMessages addObject:disconnectedMessage];
                    }
                    
                }
                else
                {
                    [chatMessages addObject:transformedMessage];
                }
            }
        }
    }
    
    return chatMessages;
}
@end
