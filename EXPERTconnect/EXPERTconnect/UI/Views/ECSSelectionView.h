//
//  PMSelectionView.h
//  PMCalendar
//
//  Created by Pavel Mazurin on 7/14/12.
//  Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * PMSelectionView is an internal class.
 *
 * PMSelectionView is a view which renders selection. 
 */
@interface ECSSelectionView : UIView

/**
 * Selection start index.
 */
@property (nonatomic, assign) NSInteger startIndex;

/**
 * Selection end index.
 */
@property (nonatomic, assign) NSInteger endIndex;

@end
