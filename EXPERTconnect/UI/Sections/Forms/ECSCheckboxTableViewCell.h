//
//  ECSCheckboxTableViewCell.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString* const ECSCheckboxTableViewCellIdentifier;

@interface ECSCheckboxTableViewCell : UITableViewCell

@property(nonatomic, strong) NSString* choiceText;
@property(nonatomic, assign) BOOL checked;

@end
