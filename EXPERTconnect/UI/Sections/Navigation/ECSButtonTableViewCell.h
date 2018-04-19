//
//  ECSButtonTableViewCell.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECSButtonTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *button;

@property (assign, nonatomic) BOOL enabled;

@end
