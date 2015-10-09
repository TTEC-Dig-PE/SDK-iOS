//
//  ECDTextEditorViewController.m
//  EXPERTconnectDemo
//
//  Created by AgilizTech Mac on 07/10/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECDTextEditorViewController.h"

@interface ECDTextEditorViewController ()

@end

@implementation ECDTextEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    ECSRichTextEditor *richTextEditor = [ECSRichTextEditor new];
    [self addChildViewController:richTextEditor];
    [self.view addSubview:richTextEditor.view];
    [richTextEditor didMoveToParentViewController:self];

    // HTML Content to set in the editor
    NSString *html = @"<h1>WYSIWYG Editor</h1>"
    "<p>Humanify, a wholly owned subsidiary of TeleTech, is based on a patented (9 awarded, 15 pending patents) suite of customer experience solutions. It is a unified cloud-based communications platform that lowers support costs and requires zero capital expenditure. Data is more effectively used, customer interactions are more productive and less repetitive, and customers get to the right resources the first time.<strong>We are Humanify.</strong></p>";
    richTextEditor.toolbarItemTintColor = [UIColor colorWithRed:40.0f/255.0f green:168.0f/255.0f blue:204.0f/255.0f alpha:1.0f];
    [richTextEditor setHTML:html];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
