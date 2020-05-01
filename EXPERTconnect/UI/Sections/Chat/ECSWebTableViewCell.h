//
//  ECSWebTableViewCell.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@class ECSWebTableViewCell;

@protocol ECSWebTableViewCellDelegate <NSObject>

- (void)cell:(ECSWebTableViewCell*)cell didFinishLoadForIndexPath:(NSIndexPath*)indexPath withSize:(CGFloat)size;

@end

@interface ECSWebTableViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIView *webViewContainer;
@property(nonatomic, strong)WKWebView *webView;


@property (weak, nonatomic) IBOutlet UIView *separator;
@property (strong, nonatomic) NSIndexPath *indexPath;

@property (readonly, nonatomic) CGFloat requestedHeight;

@property (weak, nonatomic) id<ECSWebTableViewCellDelegate> delegate;

@end
