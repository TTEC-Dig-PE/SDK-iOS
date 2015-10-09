//
//  ZSSTextView.h
//  ZSSRichTextEditor
//
//  Created by Nicholas Hubbard on 1/29/14.
//  Copyright (c) 2014 Zed Said Studio. All rights reserved.
//

#import "ECSTextView.h"

@interface TextEditorTextView : ECSTextView

@property (nonatomic, strong) UIFont *defaultFont;
@property (nonatomic, strong) UIFont *boldFont;
@property (nonatomic, strong) UIFont *italicFont;

@end
