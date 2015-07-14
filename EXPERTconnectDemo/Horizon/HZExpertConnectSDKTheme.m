//
//  HZExpertConnectSDKTheme.m
//  EXPERTconnectDemo
//
//  Created by Shammi Didla on 20/06/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "HZExpertConnectSDKTheme.h"

@implementation HZExpertConnectSDKTheme

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        // primary colors
        self.primaryColor = [UIColor colorWithRed:220/255.0f green:20/255.0f blue:49/255.0f alpha:1.0f];

        // background colors
        self.primaryBackgroundColor = [UIColor whiteColor];
        self.secondaryBackgroundColor = [UIColor colorWithRed:238/255.0f green:238/255.0f blue:238/255.0f alpha:1.0f];;

        // text colors
        self.primaryTextColor = [UIColor grayColor];
        self.secondaryTextColor = [UIColor grayColor];
        
        // other text colors
        self.sectionHeaderTextColor = self.primaryColor;
        self.placeholderTextColor = [UIColor lightGrayColor];

        // separator color
        self.separatorColor = [UIColor whiteColor];

        // buttons
        self.buttonColor = [UIColor colorWithRed:220/255.0f green:20/255.0f blue:49/255.0f alpha:1.0f];
        self.buttonTextColor = [UIColor whiteColor];

        self.secondaryButtonColor = [UIColor darkGrayColor];
        self.secondaryButtonTextColor = [UIColor whiteColor];
        
        self.disabledButtonColor = [UIColor lightGrayColor];
        
        // chat
        self.userChatBackground = self.primaryColor;
        self.userChatTextColor = [UIColor whiteColor];
        self.agentChatBackground = self.secondaryBackgroundColor;
        self.agentChatTextColor = self.primaryTextColor;
        
        
        // fonts
        self.headlineFont = [UIFont fontWithName:@"HelveticaNeue" size:24.0f];
        self.titleFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:20.0f];
        self.subheaderFont = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
        self.captionFont = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
        self.buttonFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0f];
        self.bodyFont = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
        self.boldBodyFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0f];
        self.largeBodyFont = [UIFont fontWithName:@"HelveticaNeue" size:17.0f];
        
        self.chatFont = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
        self.chatTextFieldFont = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
        self.chatInfoTitleFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];
        self.chatInfoSubtitleFont = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
        self.chatSendButtonFont = [UIFont fontWithName:@"HelveticaNeue" size:18.0f];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"HZExpertConnectSDKTheme" ofType:@"css"];
        self.cssStyle = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    }
    
    return self;
}

@end
