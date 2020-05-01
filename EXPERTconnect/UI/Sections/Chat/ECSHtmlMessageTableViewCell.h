//
//  ECSHtmlMessageTableViewCell.h
//  EXPERTconnect
//
//  Created by Ken Washington on 8/21/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatTableViewCell.h"
#import <WebKit/WebKit.h>

// #import "ECSDynamicLabel.h"

@interface ECSHtmlMessageTableViewCell : ECSChatTableViewCell

@property (strong, nonatomic) WKWebView *webContent;

@end
