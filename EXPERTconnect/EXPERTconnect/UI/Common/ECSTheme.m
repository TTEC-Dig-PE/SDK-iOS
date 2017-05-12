//
//  ECSTheme.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSTheme.h"
#import "NSBundle+ECSBundle.h"
#import "UIImage+ECSBundle.h"

@implementation ECSTheme

- (id)init
{
    self = [super init];
    if (self)
    {
        self.primaryColor = [UIColor colorWithRed:0.16 green:0.66 blue:0.8 alpha:1];
        self.primaryTextColor = [UIColor colorWithRed:0.16 green:0.16 blue:0.16 alpha:1.0f];
        self.secondaryTextColor = [UIColor lightGrayColor];
        self.primaryBackgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1];
        self.secondaryBackgroundColor = [UIColor whiteColor];
        self.sectionHeaderTextColor = self.primaryColor;
        self.placeholderTextColor = self.primaryBackgroundColor;
        self.separatorColor = [UIColor colorWithRed:0.86f green:0.86f blue:0.86f alpha:1.0f];
        
        self.buttonColor = self.primaryColor;
        self.buttonTextColor = [UIColor whiteColor];
        self.disabledButtonColor = [UIColor colorWithRed:0.16f green:0.66f blue:0.8f alpha:0.5f];
        self.secondaryButtonColor = [UIColor colorWithRed:0x5f/255.0f green:0x60/255.0f blue:0x62/255.0f alpha:1];
        self.secondaryButtonTextColor = [UIColor whiteColor];
        
        
        self.userChatBackground = self.primaryColor;
        self.userChatTextColor = [UIColor whiteColor];
        self.agentChatBackground = self.secondaryBackgroundColor;
        self.agentChatTextColor = self.primaryTextColor;
        self.showAvatarImages = YES;
        self.showChatImageUploadButton = YES;
	    self.showChatBubbleTails = NO;
	    self.showChatTimeStamp = NO;
	    self.chatTimestampTextColor = [UIColor darkGrayColor];
	    self.chatTimestampFont = [UIFont fontWithName:@"HelveticaNeue" size:11.0f];
	    self.chatBubbleTailsImage = [UIImage ecs_bundledImageNamed:@"ecs_chatbubble"];


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
        self.chatSendButtonBackgroundColor = nil;
        self.chatSendButtonTintColor = nil; 
        
        self.chatBubbleCornerRadius = 5;
        self.chatBubbleHorizMargins = 10;
        self.chatBubbleVertMargins = 5;
        
        self.chatSendButtonImage = [UIImage ecs_bundledImageNamed:@"ecs_chat_send"];
        self.chatSendButtonUseImage = NO; // Maintain backwards compatibilty. Use text button.
        
        self.chatNetworkErrorBackgroundColor = [UIColor redColor];
        self.chatNetworkErrorFont = self.chatInfoTitleFont;
        self.chatNetworkErrorTextColor = [UIColor whiteColor];
        
        NSString *path = [[NSBundle ecs_bundle] pathForResource:@"global_style" ofType:@"css"];
        self.cssStyle = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    }
    
    return self;
}

@end
