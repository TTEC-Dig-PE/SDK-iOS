//
//  ECDLicenseViewController.m
//  EXPERTconnectDemo
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECDLicenseViewController.h"

#import <EXPERTconnect/EXPERTconnect.h>
#import <EXPERTconnect/ECSTheme.h>

@interface ECDLicenseViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ECDLicenseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ECSTheme *theme = [[EXPERTconnect shared] theme];
    self.view.backgroundColor = theme.primaryBackgroundColor;
    self.textView.backgroundColor = theme.primaryBackgroundColor;
    self.textView.textColor = theme.primaryTextColor;
    self.textView.contentInset = UIEdgeInsetsMake(10, 20, 10, 20);
    self.textView.editable = NO;
    self.textView.selectable = NO;
    
    NSString *licensePath = [[NSBundle mainBundle] pathForResource:@"ECDLicenses" ofType:@"txt"];
    NSString *license = [NSString stringWithContentsOfFile:licensePath
                                                  encoding:NSUTF8StringEncoding
                                                     error:nil];
    self.textView.text = license;
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
