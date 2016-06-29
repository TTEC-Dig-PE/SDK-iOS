//
//  ECSTheme.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 ECSTheme provides theme support for the SDK, by providing references to commonly used colors
 */
@interface ECSTheme : NSObject

// The primary color used for hightlights in the SDK.  The color is used by section header text,
// and enabled button colors;
@property (strong, nonatomic) UIColor *primaryColor;

// Color for the primary text components (content, cell text, etc.)
@property (strong, nonatomic) UIColor *primaryTextColor;

// Light text color for secondary text
@property (strong, nonatomic) UIColor *secondaryTextColor;

// Color behind the table views and as the background of the chat interface.
@property (strong, nonatomic) UIColor *primaryBackgroundColor;

// Background of table view cells and other content containers
@property (strong, nonatomic) UIColor *secondaryBackgroundColor;

// Text color for section headers
@property (strong, nonatomic) UIColor *sectionHeaderTextColor;

// Placeholder text field color
@property (strong, nonatomic) UIColor *placeholderTextColor;

// Color used by table and container separators
@property (strong, nonatomic) UIColor *separatorColor;

#pragma mark - Buttons

// Color for rounded rect buttons
@property (strong, nonatomic) UIColor *buttonColor;

// Color for button text
@property (strong, nonatomic) UIColor *buttonTextColor;

// Color for the disabled button
@property (strong, nonatomic) UIColor *disabledButtonColor;

// Color for secondary buttons (e.g. previous button)
@property (strong, nonatomic) UIColor *secondaryButtonColor;

// Text color for secondary buttons
@property (strong, nonatomic) UIColor *secondaryButtonTextColor;

#pragma mark - Chat

// User chat bubble background
@property (strong, nonatomic) UIColor *userChatBackground;

// User chat text color
@property (strong, nonatomic) UIColor *userChatTextColor;

// Agent chat bubble background
@property (strong, nonatomic) UIColor *agentChatBackground;

// Agent chat text
@property (strong, nonatomic) UIColor *agentChatTextColor;

// Show or hide the image/video upload icon.
@property (assign, nonatomic) BOOL showChatImageUploadButton;

// Show avatar images if set to YES.
@property (assign, nonatomic) BOOL showAvatarImages;

// Show Chat Bubble Tails if set to YES.
@property (assign, nonatomic) BOOL showChatBubbleTails;

// Show Chat TimeStamp if set to YES.
@property (assign, nonatomic) BOOL showChatTimeStamp;

//Chat bubble tails image
@property (strong, nonatomic) IBOutlet UIImage *chatBubbleTailsImage;

//Text color for timestamp label
@property (strong, nonatomic) UIColor *chatTimestampTextColor;

//Font for timestamp label
@property (strong, nonatomic) UIFont *chatTimestampFont;

#pragma mark - Font

// Font for headlines
@property (strong, nonatomic) UIFont *headlineFont;

//  Font for titles
@property (strong, nonatomic) UIFont *titleFont;

// Font for subheader
@property (strong, nonatomic) UIFont *subheaderFont;

// Font for captions
@property (strong, nonatomic) UIFont *captionFont;

// Font for buttons
@property (strong, nonatomic) UIFont *buttonFont;

// Font for body text
@property (strong, nonatomic) UIFont *bodyFont;

// Font for bolded body text
@property (strong, nonatomic) UIFont *boldBodyFont;

// Font for large body items.
@property (strong, nonatomic) UIFont *largeBodyFont;

// Font used in chat text bubbles
@property (strong, nonatomic) UIFont *chatFont;

// Font used in the chat text field
@property (strong, nonatomic) UIFont *chatTextFieldFont;

// Font used for agent join messages
@property (strong, nonatomic) UIFont *chatInfoTitleFont;

// Font used for chat informational messages
@property (strong, nonatomic) UIFont *chatInfoSubtitleFont;

// Font used for the send button
@property (strong, nonatomic) UIFont *chatSendButtonFont;

@property (nonatomic) NSInteger chatBubbleCornerRadius;

@property (nonatomic) NSInteger chatBubbleHorizMargins;

@property (nonatomic) NSInteger chatBubbleVertMargins;

@property (strong, nonatomic) IBOutlet UIImage *chatSendButtonImage;
@property (assign, nonatomic) BOOL chatSendButtonUseImage;

// Style string for CSS
@property (strong, nonatomic) NSString *cssStyle;

@end
