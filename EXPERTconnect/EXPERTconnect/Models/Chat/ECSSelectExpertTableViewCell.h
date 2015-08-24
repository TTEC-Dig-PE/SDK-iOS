//
//  ECSSelectExpertTableViewCell.h
//  EXPERTconnect
//
//  Created by Mohammad Abdurraafay on 21/06/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ECSCircleImageView;
@class ECSDynamicLabel;

@protocol ECSSelectExpertTableViewCellDelegate <NSObject>

- (void)chatPressed;
- (void)callBackPressed;
- (void)videoPressed;
- (void)actionPressed;

@end

@interface ECSSelectExpertTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet ECSCircleImageView *profileImage;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *name;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *region;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *expertiese;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *interests;

@property (nonatomic, weak) id <ECSSelectExpertTableViewCellDelegate> selectExpertCellDelegate;

- (void)configureCellForActionType:(NSString *)actionType;

@end
