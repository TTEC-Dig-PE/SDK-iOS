//
//  ECDJourneyConfigVC.h
//  EXPERTconnectDemo
//
//  Created by Michael Schmoyer on 6/17/16.
//  Copyright © 2016 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EXPERTconnect/EXPERTconnect.h>

@interface ECDJourneyConfigVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *lblJourneyInfo;
@property (weak, nonatomic) IBOutlet UITextField *txtJourneyName;
@property (weak, nonatomic) IBOutlet UITextField *txtJourneyContext;


@property (weak, nonatomic) IBOutlet UIButton *btnStartJourney;
@property (weak, nonatomic) IBOutlet UIButton *btnSetJourneyContext;

- (IBAction)btnStartJourney_Touch:(id)sender;
- (IBAction)btnSetJourneyContext_Touch:(id)sender;

@end
