//
//  ECDChatWithTabBarVC.h
//  EXPERTconnectDemo
//
//  Created by Michael Schmoyer on 11/29/17.
//  Copyright © 2017 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EXPERTconnect/EXPERTconnect.h>

@interface ECDChatWithTabBarVC : UIViewController

@property (weak, nonatomic) IBOutlet UIView *chatView;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;

@property (strong, nonatomic) ECSChatViewController *chatController;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabBarBottom;

@end
