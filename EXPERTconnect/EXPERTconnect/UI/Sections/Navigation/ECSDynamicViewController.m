//
//  ECSDynamicViewController.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSDynamicViewController.h"

#import "ECSAnswerEngineViewController.h"
#import "ECSCircleImageView.h"
#import "ECSButtonTableViewCell.h"
#import "ECSFeaturedTableViewCell.h"
#import "ECSListTableViewCell.h"
#import "ECSNavigationContext.h"
#import "ECSNavigationSection.h"
#import "ECSNavigationActionType.h"
#import "ECSInjector.h"
#import "ECSRootViewController+Navigation.h"
#import "ECSSectionHeader.h"
#import "ECSQuestionTableViewCell.h"
#import "ECSSearchTextField.h"
#import "ECSTheme.h"
#import "ECSURLSessionManager.h"
#import "ECSUtilities.h"

#import "ECSRootViewController+Navigation.h"

#import "UIViewController+ECSNibLoading.h"

static NSString *const ECSFeaturedCellId = @"ECSFeaturedCellId";
static NSString *const ECSListCellId = @"ECSListCellId";
static NSString *const ECSButtonCellId = @"ECSButtonCellId";
static NSString *const ECSQuestionCellId = @"ECSQuestionCellId";

@interface ECSDynamicViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation ECSDynamicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Apply themes
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    self.view.backgroundColor = theme.primaryBackgroundColor;
    
    self.tableView.backgroundColor = [UIColor clearColor];

    self.tableView.sectionFooterHeight = 0.0f;
    
    self.navigationItem.title = self.actionType.displayName;
    
    UINib *featuredNib = [UINib nibWithNibName:[[ECSFeaturedTableViewCell class] description]
                                        bundle:[NSBundle bundleForClass:[ECSFeaturedTableViewCell class]]];
    [self.tableView registerNib:featuredNib forCellReuseIdentifier:ECSFeaturedCellId];
    
    UINib *buttonNib = [UINib nibWithNibName:[[ECSButtonTableViewCell class] description]
                                        bundle:[NSBundle bundleForClass:[ECSButtonTableViewCell class]]];
    [self.tableView registerNib:buttonNib forCellReuseIdentifier:ECSButtonCellId];
    
    UINib *listNib = [UINib nibWithNibName:[[ECSListTableViewCell class] description]
                                    bundle:[NSBundle bundleForClass:[ECSListTableViewCell class]]];
    [self.tableView registerNib:listNib forCellReuseIdentifier:ECSListCellId];
    
    UINib *questionNib = [UINib nibWithNibName:[[ECSQuestionTableViewCell class] description]
                                    bundle:[NSBundle bundleForClass:[ECSQuestionTableViewCell class]]];
    [self.tableView registerNib:questionNib forCellReuseIdentifier:ECSQuestionCellId];
    
    [self.tableView reloadData];

    [self setLoadingIndicatorVisible:YES];
    
    __weak typeof(self) weakSelf = self;
    ECSURLSessionManager *sessionManager = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    
    ECSNavigationActionType *navigation = (ECSNavigationActionType*)self.actionType;
    
    [sessionManager startConversationForAction:self.actionType
                               andAlwaysCreate:NO
                                 withCompletion:^(ECSConversationCreateResponse *conversation, NSError *error) {
                                     [sessionManager getNavigationContextWithName:navigation.navigationContext
                                                                       completion:^(ECSNavigationContext *context, NSError *error) {
                                                                           if (!error && context)
                                                                           {
                                                                               weakSelf.navigationContext = context;
                                                                               [weakSelf.tableView reloadData];
                                                                           }
                                                                           
                                                                           [weakSelf setLoadingIndicatorVisible:NO];
                                                                       }];

                                 }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSArray *selected = [self.tableView indexPathsForSelectedRows];
    for (NSIndexPath *path in selected)
    {
        [self.tableView deselectRowAtIndexPath:path animated:YES];
    }
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.navigationContext.sections count];
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    ECSNavigationSection *navSection = self.navigationContext.sections[section];
    
    NSInteger rowCount = [navSection.items count];
    
    if (navSection.sectionType == ECSNavigationSectionFeatured)
    {
        rowCount = (rowCount / 2) + rowCount % 2;
    }
    
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    ECSNavigationSection *navSection = self.navigationContext.sections[indexPath.section];
    ECSActionType *rowItem = navSection.items[indexPath.row];
    
    switch (navSection.sectionType) {
        case ECSNavigationSectionFeatured:
        {
            rowItem = navSection.items[(indexPath.row * 2)];
            ECSFeaturedTableViewCell *featuredCell = [self.tableView dequeueReusableCellWithIdentifier:ECSFeaturedCellId];
            [featuredCell.leftTitleLabel setText:rowItem.displayName];
            [featuredCell.leftImageView setImageWithPath:rowItem.icon];
          
            featuredCell.leftViewEnabled = [rowItem.enabled boolValue];
              featuredCell.leftViewEnabled = YES;
            
            NSInteger secondRowItemIndex = (indexPath.row * 2) + 1;
            
            if (secondRowItemIndex < [navSection.items count])
            {
                [featuredCell.rightFeaturedView setAlpha:1.0f];

                ECSActionType *secondRowItem = navSection.items[secondRowItemIndex];
                [featuredCell.rightTitleLabel setText:secondRowItem.displayName];
                [featuredCell.rightImageView setImageWithPath:secondRowItem.icon];
                featuredCell.rightViewEnabled = [secondRowItem.enabled boolValue];
                  featuredCell.rightViewEnabled = YES;
            }
            else
            {
                [featuredCell.rightFeaturedView setAlpha:0.0f];
            }
            
            cell = featuredCell;
        }
            break;
        case ECSNavigationSectionButtons:
        {
            ECSButtonTableViewCell *buttonCell = [self.tableView dequeueReusableCellWithIdentifier:ECSButtonCellId];
            
            [buttonCell.button setTitle:rowItem.displayName forState:UIControlStateNormal];
            buttonCell.button.enabled = rowItem.enabled.boolValue;
            
            cell = buttonCell;
        }
            break;
            
        case ECSNavigationSectionQuestion:
        {
            ECSQuestionTableViewCell *textCell = [self.tableView dequeueReusableCellWithIdentifier:ECSQuestionCellId];
            textCell.searchField.delegate = self;
            textCell.searchField.placeholder = rowItem.displayName;
            textCell.searchField.searchAction = rowItem;
            cell = textCell;
        }
            break;
        case ECSNavigationSectionList:
        default:
        {
            ECSListTableViewCell *listCell = [self.tableView dequeueReusableCellWithIdentifier:ECSListCellId];
            listCell.titleLabel.text = rowItem.displayName;
            listCell.enabled = rowItem.enabled.boolValue;
            [listCell.circleImageView setImageWithPath:rowItem.icon];
            if (indexPath.row == navSection.items.count - 1)
            {
                listCell.horizontalSeparatorVisible = NO;
            }
            
            if (self.navigationController)
            {
                listCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
            cell = listCell;
        }
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ECSNavigationSection *navSection = self.navigationContext.sections[indexPath.section];
    ECSActionType *actiontype = nil;
    switch (navSection.sectionType) {
        case ECSNavigationSectionFeatured:
        {
            ECSFeaturedTableViewCell *cell = (ECSFeaturedTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
            
            if (cell.selectedIndex != -1)
            {
                actiontype = navSection.items[(indexPath.row * 2) + cell.selectedIndex];
            }
        }
            break;
            
        case ECSNavigationSectionQuestion:
            break;
        case ECSNavigationSectionButtons:
        case ECSNavigationSectionList:

            actiontype = navSection.items[indexPath.row];
            break;
        default:
            break;
    }
    
    if (actiontype /*&& actiontype.enabled.boolValue*/)
    {
        [self handleAction:actiontype];
    }
}

- (BOOL)handleAction:(ECSActionType *)actionType
{
    BOOL handled = [super handleAction:actionType];
    
    if (!handled)
    {
        [self ecs_navigateToViewControllerForActionType:actionType];
        handled = YES;
    }
    
    return handled;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    ECSNavigationSection *navSection = self.navigationContext.sections[section];
    CGFloat height = 1.0f;
    if (!IsNullOrEmpty(navSection.sectionTitle))
    {
        height = 42.0f;
    }
    
    return height;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    ECSNavigationSection *navSection = self.navigationContext.sections[section];
    if (!IsNullOrEmpty(navSection.sectionTitle))
    {
        UINib *sectionNib = [UINib nibWithNibName:[[ECSSectionHeader class] description] bundle:[NSBundle bundleForClass:[ECSSectionHeader class]]];
        ECSSectionHeader *sectionHeader = [[sectionNib instantiateWithOwner:nil options:nil] objectAtIndex:0];

        sectionHeader.textLabel.text = navSection.sectionTitle;
        
        return sectionHeader;
    }
    else
    {
        return [[UIView alloc] initWithFrame:CGRectZero];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    
    if (textField.text.length > 0 && [textField isKindOfClass:[ECSSearchTextField class]])
    {
        ECSSearchTextField *searchTextField = (ECSSearchTextField*)textField;
        ECSAnswerEngineViewController *answerEngine = [ECSAnswerEngineViewController ecs_loadFromNib];
        answerEngine.answerEngineAction = (ECSAnswerEngineActionType*)searchTextField.searchAction;
        answerEngine.parentNavigationContext = ((ECSNavigationActionType*)self.actionType).navigationContext;
        answerEngine.initialQuery = searchTextField.text;
        
        [self.navigationController pushViewController:answerEngine animated:YES];
    }
    return YES;
}

- (IBAction)tapTriggered:(id)sender
{
    [self.view endEditing:YES];
}

@end
