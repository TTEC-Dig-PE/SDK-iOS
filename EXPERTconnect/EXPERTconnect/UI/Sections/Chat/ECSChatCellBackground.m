//
//  ECSChatTableViewCell.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatCellBackground.h"

#import "ECSDynamicLabel.h"
#import "ECSInjector.h"
#import "UIImage+ECSBundle.h"
#import "ECSTheme.h"


@interface ECSChatCellBackground()


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *messageWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarEdgeConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timestampHeightConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *messageBoxHorizontalAlignConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *timestampBoxHorizontalAlignConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorContstraint;

@end

@implementation ECSChatCellBackground

- (void)awakeFromNib {
	 // Initialization code
    [super awakeFromNib];
    
	 [self setup];
	 
	 self.messageWidthConstraint = [NSLayoutConstraint constraintWithItem:self.messageContainerView attribute:NSLayoutAttributeWidth
																relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:0.5 constant:0.0f];
	 [self addConstraint:self.messageWidthConstraint];
	 
	 [self configureConstraints];
}

- (void)setup
{
	 [self setUserMessage:NO];
}

- (void)setUserMessage:(BOOL)userMessage
{
	 _userMessage = userMessage;
	 
	 ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
	 CGPoint center = CGPointMake(theme.chatBubbleTailsImage.size.width / 2.0f, theme.chatBubbleTailsImage.size.height / 2.0f);
	 UIEdgeInsets capInsets = UIEdgeInsetsMake(center.y, center.x, center.y, center.x);
	 
	 self.timestampLabel.textColor = theme.chatTimestampTextColor;
	 self.timestampLabel.font = theme.chatTimestampFont;
	 
	 if (_userMessage)
	 {
		  if(theme.showChatBubbleTails == NO)
		  {
			   self.messageContainerView.backgroundColor = theme.userChatBackground;
		  }
		  else
		  {
			   UIImage *maskedWithColorImage = [self imageMaskedWithColor:theme.userChatBackground];
			   UIImage *changeImageOrientation = [UIImage imageWithCGImage:maskedWithColorImage.CGImage
													  scale:maskedWithColorImage.scale
												orientation:UIImageOrientationDownMirrored];
			   UIImage *stretchabeImage =  [self stretchableImageFromImage:changeImageOrientation withCapInsets:capInsets];
			   [self.bubbleImageView setImage:stretchabeImage];
		  }
	 }
	 else
	 {
		  if(theme.showChatBubbleTails == NO)
		  {
			   self.messageContainerView.backgroundColor = theme.agentChatBackground;
		  }
		  else
		  {
			   UIImage *maskedWithColorImage = [self imageMaskedWithColor:theme.agentChatBackground];
			   UIImage *changeImageOrientation = [UIImage imageWithCGImage:maskedWithColorImage.CGImage
													  scale:maskedWithColorImage.scale
												orientation:UIImageOrientationDown];
			   UIImage *stretchabeImage =  [self stretchableImageFromImage:changeImageOrientation withCapInsets:capInsets];
			   [self.bubbleImageView setImage:stretchabeImage];
		  }
	 }
	 
	 if (theme.showChatTimeStamp == NO) {
		  
		  self.timestampHeightConstraint.constant = 0.0f;
	 }
	 else{
		  
		  self.timestampHeightConstraint.constant = 21.0f;
	 }
	 
	 self.responseContainerView.backgroundColor = theme.userChatBackground;
	 
	 self.messageContainerView.layer.cornerRadius = theme.chatBubbleCornerRadius;
	 
	 [self configureConstraints];
}

- (UIImage *)imageMaskedWithColor:(UIColor *)maskColor
{
	 ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
	 CGRect rect = CGRectMake(0, 0, theme.chatBubbleTailsImage.size.width, theme.chatBubbleTailsImage.size.height);
	 UIGraphicsBeginImageContext(rect.size);
	 CGContextRef context = UIGraphicsGetCurrentContext();
	 CGContextClipToMask(context, rect, theme.chatBubbleTailsImage.CGImage);
	 CGContextSetFillColorWithColor(context, maskColor.CGColor);
	 CGContextFillRect(context, rect);
	 UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	 UIGraphicsEndImageContext();
	 return newImage;
}

- (UIImage *)stretchableImageFromImage:(UIImage *)image withCapInsets:(UIEdgeInsets)capInsets
{
	 return [image resizableImageWithCapInsets:capInsets resizingMode:UIImageResizingModeStretch];
}

- (void)setShowAvatar:(BOOL)showAvatar
{
	 _showAvatar = showAvatar;
	 
	 if (_showAvatar)
	 {
		  [self.avatarImageView setAlpha:1.0f];
	 }
	 else
	 {
		  [self.avatarImageView setAlpha:0.0f];
	 }
	 
	 [self configureConstraints];
}

- (void)setAvatarImageFromPath:(NSString *)theAvatar
{
	 [self.avatarImageView setImageWithPath:theAvatar];
}

- (void)setAvatarImage:(UIImage *)theAvatar
{
	 [self.avatarImageView setImage:theAvatar];
}

- (void)configureConstraints
{
	 double margin = 10.0f;
	 double margin1 = 30.0f;
	 
	 // This would make the chat bubble huge the edge instead of keep the same margins whether
	 // an avatar photo was displayed or not.
	 ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
	 self.avatarWidthConstraint.constant = (theme.showAvatarImages) ? 40.0f : 0.0f;
	 
	 [self removeConstraint:self.timestampBoxHorizontalAlignConstraint];
	 [self removeConstraint:self.messageBoxHorizontalAlignConstraint];
	 [self removeConstraint:self.avatarEdgeConstraint];
	 
	 if (self.isUserMessage)
	 {
		  // Remove leading. Add trailing.
		  self.avatarEdgeConstraint = [NSLayoutConstraint constraintWithItem:self.avatarImageView
																   attribute:NSLayoutAttributeTrailing
																   relatedBy:NSLayoutRelationEqual
																	  toItem:self
																   attribute:NSLayoutAttributeTrailing
																  multiplier:1.0f
																	constant:-margin];
		  
		  self.messageBoxHorizontalAlignConstraint = [NSLayoutConstraint constraintWithItem:self.messageContainerView
																				  attribute:NSLayoutAttributeTrailing
																				  relatedBy:NSLayoutRelationEqual
																					 toItem:self.avatarImageView
																				  attribute:NSLayoutAttributeLeading
																				 multiplier:1.0f
																				   constant:-margin];
		  self.timestampBoxHorizontalAlignConstraint = [NSLayoutConstraint constraintWithItem:self.timestampLabel
																				 attribute:NSLayoutAttributeTrailing
																				 relatedBy:NSLayoutRelationEqual
																					   toItem:self.avatarImageView
																				 attribute:NSLayoutAttributeLeading
																				   multiplier:1.0f
																				  constant:-margin1];
		  
		  //[self addConstraint:self.messageBoxHorizontalAlignConstraint];
	 }
	 else
	 {
		  self.avatarEdgeConstraint = [NSLayoutConstraint constraintWithItem:self.avatarImageView
																   attribute:NSLayoutAttributeLeading
																   relatedBy:NSLayoutRelationEqual
																	  toItem:self
																   attribute:NSLayoutAttributeLeading
																  multiplier:1.0f
																	constant:margin];
		  
		  self.messageBoxHorizontalAlignConstraint = [NSLayoutConstraint constraintWithItem:self.messageContainerView
																				  attribute:NSLayoutAttributeLeading
																				  relatedBy:NSLayoutRelationEqual
																					 toItem:self.avatarImageView
																				  attribute:NSLayoutAttributeTrailing
																				 multiplier:1.0f
																				   constant:margin];
		  self.timestampBoxHorizontalAlignConstraint = [NSLayoutConstraint constraintWithItem:self.timestampLabel
																				 attribute:NSLayoutAttributeLeading
																				 relatedBy:NSLayoutRelationEqual
																					   toItem:self.avatarImageView
																				 attribute:NSLayoutAttributeTrailing
																				   multiplier:1.0f
																				  constant:margin1];
	 }
	 [self addConstraint:self.avatarEdgeConstraint];
	 [self addConstraint:self.messageBoxHorizontalAlignConstraint];
	 [self addConstraint:self.timestampBoxHorizontalAlignConstraint];
	 
	 [self setNeedsLayout];
}

- (void)layoutSubviews
{
	 if (self.responseContainerView.subviews.count)
	 {
		  self.separatorContstraint.constant = 5.0f;
	 }
	 else
	 {
		  self.separatorContstraint.constant = 0.0f;
	 }
	 
	 [super layoutSubviews];
}
@end
