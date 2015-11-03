//
//  ECDSplashViewController.m
//  EXPERTconnectDemo
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECDSplashViewController.h"

#import "AppDelegate.h"
#import "ECDLocalization.h"
#import "ECDRootViewController.h"
#import "ECDLoginViewController.h"
#import "ECDRegisterViewController.h"

#import <EXPERTconnect/EXPERTconnect.h>
#import <objc/runtime.h>


static char ECSUserActionCompletionBlockKey;

@interface ECDSplashViewController () <ECDLoginViewControllerDelegate, ECSRegisterViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *loginButtton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *skipRegistrationButton;


@end

@implementation ECDSplashViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithRed:0.16 green:0.66 blue:0.8 alpha:1];
    
    [self.loginButtton setTitle:ECDLocalizedString(ECDLocalizedLoginButton, @"Login")
                       forState:UIControlStateNormal];
    [self.registerButton setTitle:ECDLocalizedString(ECDLocalizedRegisterButton, @"Register")
                       forState:UIControlStateNormal];
    [self.skipRegistrationButton setTitle:ECDLocalizedString(ECDLocalizedSkipRegistrationButton, @"Skip Registration")
                       forState:UIControlStateNormal];
    
    [self themeButton:self.loginButtton];
    [self themeButton:self.registerButton];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)themeButton:(UIButton*)button;
{
    button.layer.cornerRadius = 5.0f;
    button.backgroundColor = self.loginButtton.backgroundColor = [UIColor whiteColor];
    [button setTitleColor:[UIColor colorWithRed:0.16 green:0.66 blue:0.8 alpha:1]
                 forState:UIControlStateNormal];
    
}

- (IBAction)loginTapped:(id)sender
{
    [[EXPERTconnect shared] breadcrumbWithAction:@"loginTapped"
                                     description:@"User pushed login button"
                                          source:@"ECDemo"
                                     destination:@"Humanify"
                                     geolocation:nil];
    
    [self ecs_presentLoginViewControllerWithCompletion:^(id userInfo) {
        
        [[EXPERTconnect shared] breadcrumbWithAction:@"loginCompleted"
                                         description:[NSString stringWithFormat:@"Did login succeed?%d", (userInfo?1:0)]
                                              source:@"ECDemo"
                                         destination:@"Humanify"
                                         geolocation:nil];
        
        if(userInfo)
        {
            [self switchToRootViewController];
        }
        else
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (IBAction)registerTapped:(id)sender
{
    [[EXPERTconnect shared] breadcrumbWithAction:@"registerTapped"
                                     description:@"User pushed register button"
                                          source:@"ECDemo"
                                     destination:@"Humanify"
                                     geolocation:nil];
    
    [self ecs_presentRegisterViewControllerWithCompletion:^(id userInfo) {
        
        [[EXPERTconnect shared] breadcrumbWithAction:@"registerCompleted"
                                         description:[NSString stringWithFormat:@"Did register succeed?%d", (userInfo?1:0)]
                                              source:@"ECDemo"
                                         destination:@"Humanify"
                                         geolocation:nil];
        
        if(userInfo)
        {
            [self switchToRootViewController];
        }
        else
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (IBAction)skipTapped:(id)sender
{
    [self switchToRootViewController];
}

- (void)switchToRootViewController
{
    ECDRootViewController *rootViewController = [[ECDRootViewController alloc] initWithNibName:nil bundle:nil];
    AppDelegate* app = [UIApplication sharedApplication].delegate;
    app.window.rootViewController = rootViewController;
    [app.window makeKeyAndVisible];
    rootViewController.view.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        rootViewController.view.alpha = 1.0;
    }];
}

- (void)ecs_presentLoginViewControllerWithCompletion:(void (^)(id userInfo))completion
{
    ECDLoginViewController* login = [[ECDLoginViewController alloc] initWithNibName:nil bundle:nil];
    UIBarButtonItem* closeButton = [[UIBarButtonItem alloc] initWithTitle:ECSLocalizedString(ECSLocalizeCloseKey, @"Close")
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self
                                                                   action:@selector(closeUserActionController:)];
    closeButton.tintColor = [UIColor whiteColor];
    login.navigationItem.leftBarButtonItem = closeButton;
    login.navigationItem.title = ECSLocalizedString(ECSLocalizeCompanyNameKey, @"Humanify");
    login.delegate = self;
    
    ECSTheme* theme = [[EXPERTconnect shared] theme];
    
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:login];
    nav.navigationBar.barTintColor = theme.primaryColor;
    nav.navigationBar.barStyle = UIBarStyleBlack;
    
    objc_setAssociatedObject(self, &ECSUserActionCompletionBlockKey, completion, OBJC_ASSOCIATION_COPY);
    
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)ecs_presentRegisterViewControllerWithCompletion:(void (^)(id userInfo))completion
{
    ECDRegisterViewController* registerVc = [[ECDRegisterViewController alloc] initWithNibName:nil bundle:nil];
    UIBarButtonItem* closeButton = [[UIBarButtonItem alloc] initWithTitle:ECSLocalizedString(ECSLocalizeCloseKey, @"Close")
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self
                                                                   action:@selector(closeUserActionController:)];
    closeButton.tintColor = [UIColor whiteColor];
    registerVc.navigationItem.leftBarButtonItem = closeButton;
    registerVc.navigationItem.title = ECSLocalizedString(ECSLocalizeCompanyNameKey, @"Humanify");
    registerVc.delegate = self;
    
    ECSTheme* theme = [[EXPERTconnect shared] theme];
    
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:registerVc];
    nav.navigationBar.barTintColor = theme.primaryColor;
    nav.navigationBar.barStyle = UIBarStyleBlack;
    
    objc_setAssociatedObject(self, &ECSUserActionCompletionBlockKey, completion, OBJC_ASSOCIATION_COPY);
    
    [self presentViewController:nav animated:YES completion:nil];
    
}

- (void)loginViewController:(ECDLoginViewController *)login didLoginWithUserInfo:(id)userInfo
{
    void (^completion)(NSError*) = objc_getAssociatedObject(self, &ECSUserActionCompletionBlockKey);
    
    objc_setAssociatedObject(self, &ECSUserActionCompletionBlockKey, nil, OBJC_ASSOCIATION_COPY);
    
    completion(userInfo);
}

- (void)registerViewController:(ECDRegisterViewController *)viewController didCompleteWithUser:(id)userInfo
{
    void (^completion)(NSError*) = objc_getAssociatedObject(self, &ECSUserActionCompletionBlockKey);
    
    objc_setAssociatedObject(self, &ECSUserActionCompletionBlockKey, nil, OBJC_ASSOCIATION_COPY);
    
    completion(userInfo);
}

- (void)closeUserActionController:(id)sender
{
    void (^completion)(NSError*) = objc_getAssociatedObject(self, &ECSUserActionCompletionBlockKey);
    
    objc_setAssociatedObject(self, &ECSUserActionCompletionBlockKey, nil, OBJC_ASSOCIATION_COPY);
    
    completion(nil);
}



@end
