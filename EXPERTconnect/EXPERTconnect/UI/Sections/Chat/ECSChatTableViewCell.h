//
//  ECSChatTableVIewCellTableViewCell.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ECSChatCellBackground;

@interface ECSChatTableViewCell : UITableViewCell

@property (strong, nonatomic) ECSChatCellBackground *background;

@property (assign, nonatomic, getter=isUserMessage) BOOL userMessage;

@end
