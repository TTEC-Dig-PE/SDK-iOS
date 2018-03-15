//
//  ECSSectionHeader.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ECSDynamicLabel.h"

/**
 Provides a section header for table views in the SDK
 */
@interface ECSSectionHeader : UIView

// Text label for the section header
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *textLabel;

@end
