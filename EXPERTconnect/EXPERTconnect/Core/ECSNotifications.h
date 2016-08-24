//
//  ECSNotifications.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#ifndef EXPERTconnect_ECSNotifications_h
#define EXPERTconnect_ECSNotifications_h

// Notification when the user is logged out of the system.
static NSString *const ECSUserSessionInvalidNotification                = @"ECSUserSessionInvalidNotification";
static NSString *const ECSChatStartedNotification                       = @"ECSChatStartedNotification";
static NSString *const ECSChatEndedNotification                         = @"ECSChatEndedNotification";
static NSString *const ECSCallbackEndedNotification                     = @"ECSCallbackEndedNotification";

// Notification when chat messages arrive from the server
static NSString *const ECSChatMessageReceivedNotification               = @"ECSChatMessageReceivedNotification";
static NSString *const ECSChatStateMessageReceivedNotification          = @"ECSChatStateMessageReceivedNotification";
static NSString *const ECSChatNotificationMessageReceivedNotification   = @"ECSChatNotificationMessageReceivedNotification";

// Host app can send this notification to simulate pressing an "End Chat" button.
static NSString *const ECSEndChatNotification               = @"ECSEndChatNotification";

#endif
