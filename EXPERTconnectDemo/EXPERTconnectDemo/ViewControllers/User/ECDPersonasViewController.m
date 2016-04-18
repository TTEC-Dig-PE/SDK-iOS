//
//  ECDPersonasViewController.m
//  EXPERTconnectDemo
//
//  Created by Michael Schmoyer on 3/28/16.
//  Copyright © 2016 Humanify, Inc. All rights reserved.
//

#import "ECDPersonasViewController.h"


@interface ECDPersonasViewController ()

@end

@implementation ECDPersonasViewController

NSString *_chatSkill;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [EXPERTconnect shared].theme.primaryBackgroundColor;
    
    self.btnCaseOne.backgroundColor = [EXPERTconnect shared].theme.buttonColor;
    self.btnCaseTwo.backgroundColor = [EXPERTconnect shared].theme.buttonColor;
    self.btnCaseThree.backgroundColor = [EXPERTconnect shared].theme.buttonColor;
    self.btnCaseFour.backgroundColor = [EXPERTconnect shared].theme.buttonColor;
    self.actionItemA.backgroundColor = [EXPERTconnect shared].theme.buttonColor;
    self.actionItemB.backgroundColor = [EXPERTconnect shared].theme.buttonColor;
    
    [self.btnCaseOne setTitleColor:[EXPERTconnect shared].theme.buttonTextColor forState:UIControlStateNormal];
    [self.btnCaseTwo setTitleColor:[EXPERTconnect shared].theme.buttonTextColor forState:UIControlStateNormal];
    [self.btnCaseThree setTitleColor:[EXPERTconnect shared].theme.buttonTextColor forState:UIControlStateNormal];
    [self.btnCaseFour setTitleColor:[EXPERTconnect shared].theme.buttonTextColor forState:UIControlStateNormal];
    [self.actionItemA setTitleColor:[EXPERTconnect shared].theme.buttonTextColor forState:UIControlStateNormal];
    [self.actionItemB setTitleColor:[EXPERTconnect shared].theme.buttonTextColor forState:UIControlStateNormal];
    
    [self.btnCaseFour setHidden:YES]; // No case 4 yet.
    [self.actionItemA setHidden:YES];
    [self.actionItemB setHidden:YES];
    
    self.navigationItem.title = @"Personas"; 
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

#pragma mark UIControl Functions

- (IBAction)btnCaseOne_Touch:(id)sender {
    
    [self.textViewLogging setText:@""];
    [self logAction:@"Sending breadcrumb #1..."];
    
    ECSBreadcrumb *bc = [[ECSBreadcrumb alloc] initWithAction:@"Click"
                                                  description:@"Durable Pack 1"
                                                       source:@"SDK"
                                                  destination:@"Product Page"];

    [[EXPERTconnect shared] breadcrumbSendOne:bc withCompletion:^(ECSBreadcrumbResponse *bcResponse1, NSError *error)
    {
        [self ECDAssert:[bcResponse1.actionType isEqualToString:@"Click"] logWhenError:@"Response does not contain actionType"];
        [self logAction:@"Sent. Sending breadcrumb #2..."];
        
        ECSBreadcrumb *bc2 = [[ECSBreadcrumb alloc] initWithAction:@"Click"
                                                       description:@"Lightweight Pack 2"
                                                            source:@"SDK"
                                                       destination:@"Product Page"];
        
        [[EXPERTconnect shared] breadcrumbSendOne:bc2 withCompletion:^(ECSBreadcrumbResponse *bcResponse2, NSError *error)
         {
            [self logAction:@"Sent. Sending breadcrumb #3..."];

            ECSBreadcrumb *bc3 = [[ECSBreadcrumb alloc] initWithAction:@"Click"
                                                           description:@"Power Pack 3"
                                                                source:@"SDK"
                                                           destination:@"Product Page"];
            
            [[EXPERTconnect shared] breadcrumbSendOne:bc3 withCompletion:^(ECSBreadcrumbResponse *bcResponse3, NSError *error)
             {
                [self logAction:@"Sent."];
                 
                 [self logAction:@"Got action item: Chat! Showing a chat button."]; 
                 [self.actionItemA setTitle:@"Chat" forState:UIControlStateNormal];
                 [self.actionItemA setHidden:NO];
                 _chatSkill = @"CE_Mobile_Chat";
                 
                // Escalation should occur here.
                //[[EXPERTconnect shared] breadcrumbDispatch];
                [self logAction:@"Use Case 1 complete."];
            }];
        }];
    }];
    
}

- (IBAction)btnCaseTwo_Touch:(id)sender {
    
    UIViewController *aeController = [[EXPERTconnect shared] startAnswerEngine:@"Park" withDisplayName:@"Unit Test 2" showSearchBar:YES];
    
    [self.navigationController pushViewController:aeController animated:YES];
}

- (IBAction)btnCaseThree_Touch:(id)sender {
}

- (IBAction)btnCaseFour_Touch:(id)sender {
}

- (IBAction)actionItemA_Touch:(id)sender {
    if( [self.actionItemA.currentTitle isEqualToString:@"Chat"] ) {
        // Start a chat.
        UIViewController *chatView = [[EXPERTconnect shared] startChat:_chatSkill
                                                       withDisplayName:@"Chat"
                                                            withSurvey:NO];
        
        [self.actionItemA setTitle:@"Action Item A" forState:UIControlStateNormal];
        [self.actionItemA setHidden:YES];
        
        [self.navigationController pushViewController:chatView animated:YES];
    }
}

- (IBAction)actionItemB_Touch:(id)sender {
}

-(void) ECDAssert:(bool)statement logWhenError:(NSString *)theString {
    if( !statement ) {
        [self logAction:theString];
        [NSException raise:@"Test Failure" format:theString];
    }
}

-(void) logAction:(NSString *)text {
    self.textViewLogging.text = [self.textViewLogging.text stringByAppendingString:[NSString stringWithFormat:@"\n%@", text]];
}

@end
