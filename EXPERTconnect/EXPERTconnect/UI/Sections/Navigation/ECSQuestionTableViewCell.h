//
//  ECSQuestionTableViewCell.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ECSSearchTextField;

/**
 The ECSQuestionTableViewCell provides a table cell with a search field used for answer engine
 questions.
 */
@interface ECSQuestionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet ECSSearchTextField *searchField;

@end
