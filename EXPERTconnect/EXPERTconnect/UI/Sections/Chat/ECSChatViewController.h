//
//  ECSChatViewController.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <EXPERTconnect/EXPERTconnect.h>
#import "ECSStompChatClient.h"

@class ECSLog;

#define SCREEN_SHARE_FRAME_HEIGHT            100

@interface ECSChatViewController : ECSRootViewController <UINavigationBarDelegate>

// Setting history makes the view readonly and pulls the chat information from history.
@property (strong, nonatomic) NSString *historyJourney;

//@property (assign, nonatomic) BOOL showingMoxtra;

// Current list of messages in this chat
@property (strong, nonatomic) NSMutableArray *messages;

// Current chat participants (name, avatar image, etc). Array key is UserID of agent
@property (strong, nonatomic) NSMutableDictionary *participants;



@property (nonatomic, strong) ECSLog *logger;

/*!
 * @discussion Hangs up the chat by user input of some kind
 */
- (void) endChatByUser;

/*!
 * @discussion Is the chat currently in-queue?
 * @return Yes if the user is waiting in queue. No otherwise.
 */
- (BOOL) userInQueue;

/*!
 * @discussion For advanced use. This returns the underlying STOMP chat client.
 * @return An ECSStompChatClient object.
 */
- (ECSStompChatClient *)getChatClient;

@end
