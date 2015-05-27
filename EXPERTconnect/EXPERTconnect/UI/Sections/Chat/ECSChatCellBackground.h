//
//  ECSChatTableViewCell.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ECSCachingImageView.h"

@interface ECSChatCellBackground : UIView

@property (weak, nonatomic) IBOutlet ECSCachingImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIView *messageContainerView;
@property (weak, nonatomic) IBOutlet UIView *responseContainerView;

@property (assign, nonatomic) BOOL showAvatar;
@property (assign, nonatomic, getter=isUserMessage) BOOL userMessage;

@end
