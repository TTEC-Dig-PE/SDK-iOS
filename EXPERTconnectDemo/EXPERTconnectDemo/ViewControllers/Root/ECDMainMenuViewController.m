//
//  ECDMainMenuViewController.m
//  EXPERTconnectDemo
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECDMainMenuViewController.h"

#import "ECDMainMenuTableViewCell.h"
#import "ECDNavigationController.h"
#import "ECDZoomViewController.h"
#import "ECDSettingsViewController.h"
#import "ECDAdHocViewController.h"
#import "ECDLocalization.h"

#import <EXPERTconnect/EXPERTconnect.h>

static NSString *configFileName = @"MainMenuConfig";

@interface ECDMainMenuViewController () <UITableViewDataSource, UITableViewDelegate>
{
    BOOL _initialSelectionComplete;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) ECSNavigationContext *navigationContext;
@end

typedef NS_ENUM(NSInteger, ECDMainMenuRow)
{
    ECDMainMenuRowPersonas,
    ECDMainMenuRowHumanify,
    ECDMainMenuRowBeacons,
    ECDMainMenuRowProfile,
    ECDMainMenuRowSettings
};

@implementation ECDMainMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _initialSelectionComplete = NO;
    
    self.view.layoutMargins = UIEdgeInsetsMake(self.tableView.layoutMargins.top, 39, self.tableView.layoutMargins.bottom, self.tableView.layoutMargins.right);
    
    NSString *configPath = [[NSBundle mainBundle] pathForResource:configFileName ofType:@"json"];
    if (configPath)
    {
        NSData *configData = [NSData dataWithContentsOfFile:configPath];
        NSError *error;
        NSDictionary *configJSON = [NSJSONSerialization JSONObjectWithData:configData
                                                                   options:0
                                                                     error:&error];
        
        if (!error)
        {
            self.navigationContext = [ECSJSONSerializer objectFromJSONDictionary:configJSON
                                                                       withClass:[ECSNavigationContext class]];
            
            // Localize the Titles in MainMenuConfig.json
            //
            for (ECSNavigationSection *sect in self.navigationContext.sections) {
                for(ECSActionType *action in sect.items)   {
                    action.displayName = ECDLocalizedString(action.displayName, nil);
                }
            }
        }
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ECDMainMenuTableViewCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_initialSelectionComplete)
    {
        _initialSelectionComplete = YES;
    
        [self reloadContent];
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                    animated:NO
                              scrollPosition:UITableViewScrollPositionNone];
        [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self centerTableCells];
}
- (void)reloadContent
{
    [[self tableView] reloadData];
    [self centerTableCells];
}

- (void)centerTableCells
{
    [[self tableView] layoutSubviews];
    CGSize contentSize = [[self tableView] contentSize];
    
    CGFloat length = [[self topLayoutGuide] length];
    [[self tableView] setContentInset:UIEdgeInsetsMake((CGRectGetHeight([[self tableView] bounds]) - length - contentSize.height) / 2.0f,
                                                       0.0f,
                                                       0.0f,
                                                       0.0f)];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = 0;
    if ([self.navigationContext.sections count] > 0)
    {
        ECSNavigationSection *section = [self.navigationContext.sections firstObject];
        
        rowCount = [[section items] count];
    }
    
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ECDMainMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    cell.backgroundColor = [UIColor clearColor];
    
    if ([self.navigationContext.sections count] > 0)
    {
        ECSNavigationSection *section = [self.navigationContext.sections firstObject];
        
        ECSActionType *item = [[section items] objectAtIndex:indexPath.row];
        
        [[cell menuItemTitleLabel] setText:item.displayName];
        
        cell.itemColor = [self primaryColorForIndexPath:indexPath];
        cell.menuItemImageView.image = [UIImage imageNamed:item.icon];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.navigationContext.sections count] > 0)
    {
        ECSNavigationSection *section = [self.navigationContext.sections firstObject];
        
        ECSActionType *item = [[section items] objectAtIndex:indexPath.row];
        
        UIViewController *actionViewController = nil;
        if ([item.type isEqualToString:@"landing"])
        {
            actionViewController = [[EXPERTconnect shared] landingViewController];
        }
        else
        if ([item.type isEqualToString:@"settings"])
        {
            actionViewController = [[ECDSettingsViewController alloc] initWithNibName:nil bundle:nil];
        }
        else
        if ([item.type isEqualToString:@"adhoc"])
        {
            actionViewController = [[ECDAdHocViewController alloc] initWithNibName:nil bundle:nil];        }
        else
        {
            actionViewController = [ECSRootViewController ecs_viewControllerForActionType:item];
        }
        
        UIColor *color = [self primaryColorForIndexPath:indexPath];
        
        if (actionViewController)
        {
            ECDNavigationController *rootNavigation = [[ECDNavigationController alloc] initWithRootViewController:actionViewController];
            
            rootNavigation.view.tintColor = [UIColor whiteColor];
            rootNavigation.navigationBar.barTintColor = color;
            rootNavigation.navigationBar.barStyle = UIBarStyleBlack;
            [rootNavigation.navigationBar
             setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
            rootNavigation.navigationBar.translucent = YES;

            [[self ecd_zoomViewController] setContentViewController:rootNavigation];
            [[self ecd_zoomViewController] hideLeftViewController];
        }
    }

}

- (UIColor*)primaryColorForIndexPath:(NSIndexPath*)indexPath
{
    UIColor *color = [UIColor colorWithRed:0.16 green:0.66 blue:0.8 alpha:1];
    
    switch (indexPath.row) {
        case 0:
            break;
        case 1:
            color = [UIColor colorWithRed:0.44 green:0.14 blue:0.44 alpha:1];
            break;
        case 2:
            color = [UIColor colorWithRed:0.13 green:0.76 blue:0.7 alpha:1];
            break;
        case 3:
            color = [UIColor colorWithRed:0.99 green:0.75 blue:0.18 alpha:1];
            break;
            
            break;
            
        default:
            break;
    }
    
    return color;
}

@end
