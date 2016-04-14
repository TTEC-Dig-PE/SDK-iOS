//
//  ECDPersonasViewController.m
//  EXPERTconnectDemo
//
//  Created by Michael Schmoyer on 3/28/16.
//  Copyright © 2016 Humanify, Inc. All rights reserved.
//

#import "ECDPersonasViewController.h"
#import <EXPERTconnect/EXPERTconnect.h>

@interface ECDPersonasViewController ()

@end

@implementation ECDPersonasViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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

#pragma mark UIControl Functions

- (IBAction)btnCaseOne_Touch:(id)sender {
    
    [self.textViewLogging setText:@""];
    [self logAction:@"Starting Use Case 1..."];
    
    ECSBreadcrumb *bc = [[ECSBreadcrumb alloc] initWithAction:@"Click"
                                                  description:@"Durable Pack 1"
                                                       source:@"SDK"
                                                  destination:@"Product Page"];

    [[EXPERTconnect shared] breadcrumbSendOne:bc withCompletion:^(NSDictionary *decisionResponse, NSError *error) {
        
        [self logAction:@"User clicked Durable Pack 1 (BC sent)"];
        
        ECSBreadcrumb *bc2 = [[ECSBreadcrumb alloc] initWithAction:@"Click"
                                                       description:@"Lightweight Pack 2"
                                                            source:@"SDK"
                                                       destination:@"Product Page"];
        
        [[EXPERTconnect shared] breadcrumbSendOne:bc2 withCompletion:^(NSDictionary *decisionResponse, NSError *error) {
            
            [self logAction:@"User clicked Lightweight Pack 2 (BC sent)"];

            ECSBreadcrumb *bc3 = [[ECSBreadcrumb alloc] initWithAction:@"Click"
                                                           description:@"Power Pack 3"
                                                                source:@"SDK"
                                                           destination:@"Product Page"];
            
            [[EXPERTconnect shared] breadcrumbSendOne:bc3 withCompletion:^(NSDictionary *decisionResponse, NSError *error) {
                
                [self logAction:@"User clicked Power Pack 3 (BC sent)"];
                
                // Escalation should occur here.
                [[EXPERTconnect shared] breadcrumbDispatch];
                [self logAction:@"**END OF ROUTINE (Under construction)**"];
            }];
        }];
    }];
    
}

-(void) logAction:(NSString *)text {
    self.textViewLogging.text = [self.textViewLogging.text stringByAppendingString:[NSString stringWithFormat:@"\n%@", text]];
}

@end
