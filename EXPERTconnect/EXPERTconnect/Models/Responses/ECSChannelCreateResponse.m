//
//  ECSChannelCreateResponse.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChannelCreateResponse.h"

#import "ECSConversationLink.h"

@implementation ECSChannelCreateResponse

- (NSDictionary *)ECSJSONMapping
{
    return @{@"id": @"channelId",
             @"conversationId": @"conversationId",
             @"mediaType": @"mediaType",
             @"creationDate": @"creationDate",
             @"lastModifiedDate": @"lastModifiedDate",
             @"expirationDate": @"expirationDate",
             @"state": @"state",
             @"_links.chatState.href": @"chatStateLink",
             @"_links.close.href": @"closeLink",
             @"_links.messages.href": @"messagesLink",
             @"_links.mself.href": @"selfLink",
             @"estimatedWait": @"estimatedWait"
             };
}

// rharvey (via email): Long term it might make sense to add new _links for things like STOMP.  I think
//                      that is too much of a change right now.  The SDK must already be truncating the
//                      http://<host>/conversationengine/v1 part of the _link.  I would say just do a
//                      '/' to '.' string replacement.
//
- (NSString *)messagesLink {
    
    // Transform: http://api.humanify.com:8080/conversationengine/v1/channels/chan_5cc5b963-d3c6-4dd8-99b6-54305f3194e5_mktwebextc/messages
    //        To: http://api.humanify.com:8080/conversationengine/v1.channels.chan_5cc5b963-d3c6-4dd8-99b6-54305f3194e5_mktwebextc.messages
    //
    if(!_stompMessagesLink)  {

        
/*

        // This solution did not work. It did not account for the "." after the v1
        //
        NSURL *messagesUrl = [NSURL URLWithString:_messagesLink];
        NSURL *notificationURLWithChannel = [[NSURL URLWithString:_messagesLink] URLByDeletingLastPathComponent];
        NSURL *baseUrl = [notificationURLWithChannel URLByDeletingLastPathComponent];
        
        NSString *channel = [notificationURLWithChannel lastPathComponent];
        NSString *stompTopic = [@"." stringByAppendingString:[[channel stringByAppendingString:@"."] stringByAppendingString:[messagesUrl lastPathComponent]]];
        
        NSString *baseString = [baseUrl absoluteString];
        
        NSRange lastSlash = [baseString rangeOfString:@"/" options:NSBackwardsSearch];
        NSLog(@"Last Slash: %lu, Base String: %lu", (unsigned long)lastSlash.location, baseString.length);
        
        if(lastSlash.location == baseString.length - 1) {
            baseString = [baseString stringByReplacingCharactersInRange:lastSlash withString:@""];
        }
        
        _stompMessagesLink = [baseString stringByAppendingString:stompTopic];
*/

        // Replace the trailing 3 slashes "/" with periods "."
        //
        //
        NSRange lastSlash = [_messagesLink rangeOfString:@"/" options:NSBackwardsSearch];
        
        _stompMessagesLink = [_messagesLink stringByReplacingCharactersInRange:lastSlash withString: @"."];
        
        lastSlash = [_stompMessagesLink rangeOfString:@"/" options:NSBackwardsSearch];
        
        _stompMessagesLink = [_stompMessagesLink stringByReplacingCharactersInRange:lastSlash withString: @"."];
        
        lastSlash = [_stompMessagesLink rangeOfString:@"/" options:NSBackwardsSearch];
        
        _stompMessagesLink = [_stompMessagesLink stringByReplacingCharactersInRange:lastSlash withString: @"."];
    }

    return _stompMessagesLink;
}

- (NSString *)description
{
    NSMutableString *string = [[NSMutableString alloc] initWithString:[super description]];
    for (NSString *property in self.ECSJSONMapping.allValues)
    {
        [string appendString:[NSString stringWithFormat:@"%@: %@\n", property, [self valueForKey:property]]];
    }
    
    return string;
}

@end
