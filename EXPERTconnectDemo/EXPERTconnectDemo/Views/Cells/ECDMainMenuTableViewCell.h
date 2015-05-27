//
//  ECDMainMenuTableViewCell.h
//  EXPERTconnectDemo
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECDMainMenuTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *menuItemImageView;
@property (weak, nonatomic) IBOutlet UILabel *menuItemTitleLabel;

@property (strong, nonatomic) UIColor *itemColor;

@end
