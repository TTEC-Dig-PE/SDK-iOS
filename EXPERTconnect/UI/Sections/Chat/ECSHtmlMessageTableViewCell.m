//
//  ECSHtmlMessageTableViewCell.m
//  EXPERTconnect
//
//  Created by Ken Washington on 8/21/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSHtmlMessageTableViewCell.h"

#import "ECSChatCellBackground.h"
#import "ECSInjector.h"
#import "ECSTheme.h"

@implementation ECSHtmlMessageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        CGRect containerFrame = self.background.messageContainerView.frame;
        int width = containerFrame.size.width;
        int height = containerFrame.size.height;
        
        height = 275;  // TODO: Still trying to determine this programatically

        self.webContent = [[WKWebView alloc] initWithFrame:self.background.messageContainerView.frame];
        
        CGRect webViewFrame = CGRectMake(0, 0, width - 10.0f, height - 10.0f);
        self.webContent = [[WKWebView alloc]initWithFrame:webViewFrame];
        self.webContent.translatesAutoresizingMaskIntoConstraints = YES;
        
        [self.background.messageContainerView addSubview:self.webContent];
        [self.background.messageContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(10)-[content]-(10)-|"
                                                                                                     options:0
                                                                                                     metrics:nil
                                                                                                       views:@{@"content": self.webContent}]];
        
        [self.background.messageContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(10)-[content]-(10)-|"
                                                                                                     options:0
                                                                                                     metrics:nil
                                                                                                       views:@{@"content": self.webContent}]];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    int x = self.background.messageContainerView.frame.origin.x;
    int y = self.background.messageContainerView.frame.origin.y;
    
    int width = (self.frame.size.width * 0.5f);
    int height = self.webContent.frame.size.height;
    
    /*
     for (UIView* view in self.webContent.scrollView.subviews)
     {
     height += view.frame.size.height;
     }
     
     if(height > 450) {
     height = 450;
     }
     */
    
    CGRect containerFrame = CGRectMake(x, y, width, height);
    CGRect webViewFrame = CGRectMake(0, 0, width - 10, height);
    
    self.background.messageContainerView.frame = containerFrame;
    self.webContent.frame = webViewFrame;
    
    [super layoutSubviews];
}

@end
