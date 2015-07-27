//
//  ECSChatViewController.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <EXPERTconnect/EXPERTconnect.h>

#define SCREEN_SHARE_FRAME_HEIGHT            100

@interface ECSChatViewController : ECSRootViewController <UINavigationBarDelegate>

// Setting history makes the view readonly and pulls the chat information from history.
@property (strong, nonatomic) NSString *historyJourney;
@property (assign, nonatomic) BOOL showingMoxtra;

@end
