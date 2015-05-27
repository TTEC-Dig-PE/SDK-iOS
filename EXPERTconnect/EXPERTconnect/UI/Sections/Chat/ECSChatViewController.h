//
//  ECSChatViewController.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <EXPERTconnect/EXPERTconnect.h>

@interface ECSChatViewController : ECSRootViewController <UINavigationBarDelegate>

// Setting history makes the view readonly and pulls the chat information from history.
@property (strong, nonatomic) NSString *historyJourney;

@end
