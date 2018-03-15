//
//  ECSRadioTableViewCell.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString *const ECSRadioTableViewCellIdentifier;

/**
 Cell for displaying a Radio style selection cell
 */
@interface ECSRadioTableViewCell : UITableViewCell

// The text for the option
@property(nonatomic, strong) NSString* choiceText;

- (void)setRadioSelected:(BOOL)selected;

@end
