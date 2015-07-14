//
//  HZResearchViewController.m
//  EXPERTconnectDemo
//
//  Created by Shammi Didla on 24/06/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "HZResearchViewController.h"
#import <MMDrawerController/UIViewController+MMDrawerController.h>

@interface HZResearchViewController ()
@property (weak, nonatomic) IBOutlet UIButton *performanceButton;
@property (weak, nonatomic) IBOutlet UIButton *portfolioButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;

@end

@implementation HZResearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.portfolioButton.selected = YES;
}

- (IBAction)hamburgerButtonTapped:(id)sender {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (IBAction)performanceButtonTapped:(UIButton *)sender {
    [self deselectAllButtons];
    sender.selected = YES;
    
    self.backgroundImage.image = [UIImage imageNamed:@"research-performance"];
}

- (IBAction)portfolioButtonTapped:(UIButton *)sender {
    [self deselectAllButtons];
    sender.selected = YES;

    self.backgroundImage.image = [UIImage imageNamed:@"research-portfolio"];
}

- (void)deselectAllButtons {
    self.performanceButton.selected = NO;
    self.portfolioButton.selected = NO;
}
@end
