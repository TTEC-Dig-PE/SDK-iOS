//
//  ECSSelectExpertViewController.m
//  EXPERTconnect
//
//  Created by Mohammad Abdurraafay on 18/06/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSSelectExpertViewController.h"
#import "ECSFeaturedTableViewCell.h"
#import "ECSExpertDetail.h"

#import "ECSSelectExpertTableViewCell.h"

#import "ECSCafeXController.h"
#import "ECSRootViewController+Navigation.h"
#import "ECSTheme.h"
#import "ECSInjector.h"
#import "ECSDynamicLabel.h"
#import "ECSCircleImageView.h"
#import "ECSVideoChatActionType.h"
#import "ECSChatActionType.h"
#import "ECSCafeXVideoViewController.h"
#import "UIViewController+ECSNibLoading.h"

static NSString *const ECSExpertCellId = @"ECSSelectExpertTableViewCell";

@interface ECSSelectExpertViewController () <UITableViewDataSource, UITableViewDelegate, ECSSelectExpertTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *experts;

@end

@implementation ECSSelectExpertViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.experts                = self.actionType.configuration[@"experts"];
    self.tableView.delegate     = self;
    self.tableView.dataSource   = self;
    
    // Apply themes
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
	 
    self.view.backgroundColor = theme.primaryBackgroundColor;
	 
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.tableView.sectionFooterHeight = 0.0f;
    
    self.navigationItem.title = self.actionType.displayName;
    
    UINib *featuredNib = [UINib nibWithNibName:[[ECSSelectExpertTableViewCell class] description]
                                        bundle:[NSBundle bundleForClass:[ECSSelectExpertTableViewCell class]]];
    
    [self.tableView registerNib:featuredNib forCellReuseIdentifier:ECSExpertCellId];
    
    // Try to load experts if none are currently loaded.
    if(self.experts == nil) {
        
        __weak typeof(self) weakSelf = self;

        ECSURLSessionManager *urlSession = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
        
        // Attempt to fetch list of available experts from server
        [urlSession getExpertsWithInteractionItems:nil
                                        completion:^(NSArray *responseArray, NSError *error) {
                     
            [weakSelf setLoadingIndicatorVisible:NO];
                                            
            if (!error && [responseArray isKindOfClass:[NSArray class]] ) {
                
                [self populateTable:responseArray];
                
            } else {
                
                // Show a message to the user.
                [weakSelf showMessageForError:error];
            }
        }];
        
    } else {
        [self populateTable:self.experts];
    }
	 
    [self.tableView reloadData];
}

- (void) populateTable:(NSArray *)expertData {
    if(self) {
        // Reload the table with new data from response
        NSMutableArray *expertsArray = [[NSMutableArray alloc] init];// = [ECSJSONSerializer arrayFromJSONArray:responseArray withClass:[ECSExpertDetail class]];
        for( NSDictionary *item in expertData) {
            ECSExpertDetail *newItem = [ECSJSONSerializer objectFromJSONDictionary:item withClass:[ECSExpertDetail class]];
            [expertsArray addObject:newItem];
        }
        self.experts = expertsArray;
        [self.tableView reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.experts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ECSExpertDetail *expert = [self.experts objectAtIndex:indexPath.row];
    ECSSelectExpertTableViewCell *featuredCell = [tableView dequeueReusableCellWithIdentifier:ECSExpertCellId];
    [featuredCell setSelectExpertCellDelegate:self];
    if(!(expert.pictureURL == (id)[NSNull null]))[featuredCell.profileImage setImageWithPath:expert.pictureURL];
    
    if(!(expert.fullName == (id)[NSNull null])) [featuredCell.name setText:expert.fullName];
    //if(!(expert.region == (id)[NSNull null]))   [featuredCell.region setText:expert.region];
    //if(!(expert.expertise == (id)[NSNull null])) [featuredCell.expertise setText:expert.expertise];
    //if(!(expert.interests == (id)[NSNull null])) [featuredCell.interests setText:[expert.interests componentsJoinedByString:@", "]];
    
    featuredCell.firstLineView.hidden = YES;
    featuredCell.regionView.hidden = NO;
    NSLog(@"%@",self.actionType.type);
    [featuredCell configureCellForActionType:self.actionType.type withExpert:expert];
    
    /*if(expert.region || expert.interests)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            featuredCell.firstLineView.hidden = NO;
            [featuredCell configureConstraints];
        }
    }
    else{*/
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            featuredCell.regionView.hidden = YES;
            [featuredCell configureConstraints];
        }
        else
        {
            featuredCell.regionHeightConstraints.constant = 0.0f;
            featuredCell.regionView.hidden = YES;
        }
    //}
    
    return featuredCell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ECSExpertDetail *expert = self.experts[indexPath.row];
    
    ECSChatActionType *actionType = [ECSChatActionType new];
    actionType.actionId = self.actionType.actionId;
    actionType.agentId = expert.expertID;
    actionType.agentSkill = [NSString stringWithFormat:@"Calls for %@", expert.expertID];
    
     //DEBUG CODE: This only occurs if there's an "override" agent set in the Debug menu. Safe to leave.
    
    NSString *agent = [[NSUserDefaults standardUserDefaults] stringForKey:@"agent_key"];
    if (agent.length > 0) {
        NSString *skill = [NSString stringWithFormat:@"Calls for %@", agent];
        actionType.agentSkill =  skill;
        actionType.agentId = agent;
    }
    
    [self handleAction:actionType];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath; {
	 
	 CGFloat height = 0.0f;
	 if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		  height = 200;
	 }
	 else
	 {
		  //NSDictionary *expert = [self.experts objectAtIndex:indexPath.row];
		  
		  //if([expert objectForKey:@"region"] || [expert objectForKey:@"interests"])
		  //{
			//   height = 250;
		  //}
		  //else{
			   height = 200;
		  //}
		  
	 }
	 return height;
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //ECSNavigationSection *navSection = self.navigationContext.sections[section];
    CGFloat height = 1.0f;
    /*if (!IsNullOrEmpty(self.actionType.displayName))
    {
        height = 42.0f;
    }*/

    return height;
}

#pragma mark - ECSSelectExpertTableViewCellDelegate Methods

- (void)didSelectChatButton:(id)sender forExpert:(ECSExpertDetail *)expert {
    
    ECSChatActionType *actionType = [ECSChatActionType new];
    actionType.actionId = self.actionType.actionId;
    actionType.agentId = expert.expertID;
    actionType.agentSkill = [NSString stringWithFormat:@"Calls for %@", expert.expertID];

    /**
     DEBUG CODE: BEGINS
     **/
    NSString *agent = [[NSUserDefaults standardUserDefaults] stringForKey:@"agent_key"];
    if (agent.length > 0) {
        NSString *skill = [NSString stringWithFormat:@"Calls for %@", agent];
        actionType.agentSkill =  skill;
        actionType.agentId = agent;
    }
    /**
     DEBUG CODE: ENDS
     **/
    
    //    [EXPERTconnect shared]//
    [self handleAction:actionType];
}

- (void)didSelectVideoChatButton:(id)sender forExpert:(ECSExpertDetail *)expert {
    ECSCafeXController *cafeXController = [[ECSInjector defaultInjector] objectForClass:[ECSCafeXController class]];
    
    // Do a login if there's no session:
    if (![cafeXController hasCafeXSession]) {
        [cafeXController setupCafeXSession];
    }
    
    ECSVideoChatActionType *actionType = [ECSVideoChatActionType new];
    actionType.actionId = self.actionType.actionId;
    actionType.agentId = expert.expertID;
    actionType.agentSkill = [NSString stringWithFormat:@"Calls for %@", expert.expertID];
    actionType.cafexmode = @"videoauto"; // @"voicecapable,videocapable,cobrowsecapable";
    actionType.cafextarget = [cafeXController cafeXUsername];
    
    // DEBUG CODE: This only occurs if there's an "override" agent set in the
    // Debug menu. Safe to leave.
    
    NSString *agent = [[NSUserDefaults standardUserDefaults] stringForKey:@"agent_key"];
    if (agent.length > 0) {
        NSString *skill = [NSString stringWithFormat:@"Calls for %@", agent];
        actionType.agentSkill =  skill;
        actionType.agentId = agent;
    }
    
    [self handleAction:actionType];
}

- (void)didSelectVoiceChatButton:(id)sender forExpert:(ECSExpertDetail *)expert {
    ECSCafeXController *cafeXController = [[ECSInjector defaultInjector] objectForClass:[ECSCafeXController class]];
    
    // Do a login if there's no session:
    if (![cafeXController hasCafeXSession]) {
        [cafeXController setupCafeXSession];
    }
    
    ECSVideoChatActionType *actionType = [ECSVideoChatActionType new];
    actionType.actionId = self.actionType.actionId;
    actionType.agentId = expert.expertID;
    actionType.agentSkill = [NSString stringWithFormat:@"Calls for %@", expert.expertID];
    actionType.cafexmode = @"voiceauto"; // @"voicecapable,videocapable,cobrowsecapable";
    actionType.cafextarget = [cafeXController cafeXUsername];
    
    // DEBUG CODE: This only occurs if there's an "override" agent set in the
    // Debug menu. Safe to leave.
    
    NSString *agent = [[NSUserDefaults standardUserDefaults] stringForKey:@"agent_key"];
    if (agent.length > 0) {
        NSString *skill = [NSString stringWithFormat:@"Calls for %@", agent];
        actionType.agentSkill =  skill;
        actionType.agentId = agent;
    }
    
    [self handleAction:actionType];
}

- (void)didSelectCallBackButton:(id)sender forExpert:(NSDictionary *)expert {
      ECSRootViewController *voiceCallbackvc =  (ECSRootViewController *)[[EXPERTconnect shared] startVoiceCallback:@"communications" withDisplayName:@"Callback"];
        voiceCallbackvc.workflowDelegate = self.workflowDelegate;
      [self.navigationController pushViewController:voiceCallbackvc animated:YES];
}

@end
