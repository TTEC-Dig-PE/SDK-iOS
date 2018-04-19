//
//  ECSChatImageTableViewCell.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ECSChatTableViewCell.h"

@class ECSCachingImageView;

@interface ECSChatImageTableViewCell : ECSChatTableViewCell


@property (strong, nonatomic) ECSCachingImageView *messageImageView;

@property (assign, nonatomic) BOOL showAvatar;

@property (assign, nonatomic) BOOL showPlayIcon;

@end
