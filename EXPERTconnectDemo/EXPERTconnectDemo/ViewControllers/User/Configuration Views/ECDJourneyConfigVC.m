//
//  ECDJourneyConfigVC.m
//  EXPERTconnectDemo
//
//  Created by Michael Schmoyer on 6/17/16.
//  Copyright © 2016 Humanify, Inc. All rights reserved.
//

#import "ECDJourneyConfigVC.h"

@interface ECDJourneyConfigVC ()

@end

@implementation ECDJourneyConfigVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.btnStartJourney setBackgroundColor:[EXPERTconnect shared].theme.buttonColor];
    [self.btnSetJourneyContext setBackgroundColor:[EXPERTconnect shared].theme.buttonColor];
    [self.btnStartJourney setTitleColor:[EXPERTconnect shared].theme.buttonTextColor forState:UIControlStateNormal];
    [self.btnSetJourneyContext setTitleColor:[EXPERTconnect shared].theme.buttonTextColor forState:UIControlStateNormal];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.lblJourneyInfo.text = [NSString stringWithFormat:@"JourneyID: %@\nPushID: %@\nContext:%@",
                                [EXPERTconnect shared].journeyID,
                                [EXPERTconnect shared].pushNotificationID,
                                [EXPERTconnect shared].journeyManagerContext];
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

- (IBAction)btnStartJourney_Touch:(id)sender {
    
    self.lblJourneyInfo.text = @"Requesting a journey from server...";
    [[EXPERTconnect shared] startJourneyWithName:self.txtJourneyName.text
                              pushNotificationId:nil
                                         context:self.txtJourneyContext.text
                                      completion:^(NSString *journeyId, NSError *error)
    {
        if(journeyId && !error) {
            self.lblJourneyInfo.text = [NSString stringWithFormat:@"New JourneyID: %@\nPushID: %@\nContext:%@",
                                        [EXPERTconnect shared].journeyID,
                                        [EXPERTconnect shared].pushNotificationID,
                                        [EXPERTconnect shared].journeyManagerContext];
        } else {
            self.lblJourneyInfo.text = [NSString stringWithFormat:@"Error: %@", error.description];
        }
        
        
    }];
}

- (IBAction)btnSetJourneyContext_Touch:(id)sender {
    
    self.lblJourneyInfo.text = @"Setting the journey context...";
    [[EXPERTconnect shared] setJourneyContext:self.txtJourneyContext.text
                               withCompletion:^(ECSJourneyAttachResponse *response, NSError *error)
    {
        if(response && !error) {
            self.lblJourneyInfo.text = [NSString stringWithFormat:@"Response: %@", response.description];
        } else {
            self.lblJourneyInfo.text = [NSString stringWithFormat:@"Error: %@", error.description];
        }
    }];
}

@end
