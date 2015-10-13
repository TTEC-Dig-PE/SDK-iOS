//
//  ECSCallbackViewController.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ECSRootViewController.h"
#import "ECSStompChatClient.h"
#import "ECSStompCallbackClient.h"

@interface ECSCallbackViewController : ECSRootViewController <ECSStompCallbackDelegate>

@property (assign, nonatomic) BOOL displaySMSOption;
@property (assign, nonatomic) BOOL skipConfirmationView;

- (void)setChatClient: (ECSStompChatClient *)client;

@end
