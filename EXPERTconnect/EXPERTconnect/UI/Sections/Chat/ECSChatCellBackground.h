//
//  ECSChatTableViewCell.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ECSCachingImageView.h"
#import <EXPERTconnect/EXPERTconnect.h>

@interface ECSChatCellBackground : UIView

@property (weak, nonatomic) IBOutlet ECSCachingImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIView *messageContainerView;
@property (weak, nonatomic) IBOutlet UIView *responseContainerView;
@property (assign, nonatomic) BOOL showAvatar;
@property (assign, nonatomic, getter=isUserMessage) BOOL userMessage;

@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (strong, nonatomic) IBOutlet UIImage *bubbleImage;

@property (weak, nonatomic) IBOutlet UIImageView *bubbleImageView;

- (void)setAvatarImage:(UIImage *)theAvatar;
- (void)setAvatarImageFromPath:(NSString *)theAvatar;

@end
