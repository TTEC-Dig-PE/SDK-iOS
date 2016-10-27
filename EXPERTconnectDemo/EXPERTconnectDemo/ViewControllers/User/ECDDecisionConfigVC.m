//
//  ECDDecisionConfigVC.m
//  EXPERTconnectDemo
//
//  Created by AgilizTech Mac on 26/10/16.
//  Copyright © 2016 Humanify, Inc. All rights reserved.
//

#import "ECDDecisionConfigVC.h"
#import "ECDLocalization.h"

@interface ECDDecisionConfigVC ()
@property (weak, nonatomic) IBOutlet UITextView *requestDecisionTextView;
@property (weak, nonatomic) IBOutlet UITextView *responseDecisionTextView;
- (IBAction)postButtonTapped:(id)sender;
@property (strong, nonatomic) NSMutableDictionary *decisionDictionary;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *requestDecisionLabel;
@property (weak, nonatomic) IBOutlet UILabel *responseDecisionLabel;
@property (weak, nonatomic) IBOutlet UIButton *postCosumerDataButton;

@end

@implementation ECDDecisionConfigVC

- (void)viewDidLoad {
    [super viewDidLoad];
     // Do any additional setup after loading the view from its nib.
     
     [self.postCosumerDataButton setBackgroundColor:[EXPERTconnect shared].theme.buttonColor];
     [self.postCosumerDataButton setTitleColor:[EXPERTconnect shared].theme.buttonTextColor forState:UIControlStateNormal];

     self.requestDecisionLabel.text = ECDLocalizedString(ECDLocalizedRequestDecisionLabel, @"Request Decision Data:");
     self.responseDecisionLabel.text = ECDLocalizedString(ECDLocalizedResponseDecisionLabel, @"Response Decision Data:");
     
     self.decisionDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"determineRule",@"eventId",@"mktwebextc",@"clientRequestId",@"EN",@"userLanguage",@"US",@"userCountry",@"current local page",@"function",@"henry",@"name",@"My Vehicles",@"service",@"horizon",@"ceTenant", nil];
     self.requestDecisionTextView.text = [NSString stringWithFormat:@"%@",self.decisionDictionary];

     [self.postCosumerDataButton setTitle:ECDLocalizedString(ECDLocalizedPostConsumerButtonLabel, @"Post Consumer Data") forState:UIControlStateNormal];
     
}

- (NSString *)getClientID {
     
     NSString *currentOrganization = nil;
     NSString *currentEnv = [[NSUserDefaults standardUserDefaults]
                             objectForKey:@"environmentName"];
     
     if (currentEnv) {
          currentOrganization = [[NSUserDefaults standardUserDefaults]
                                 objectForKey:[NSString stringWithFormat:@"%@_%@", currentEnv, @"organization"]];
     }
     
     return ( currentOrganization ? currentOrganization : @"mktwebextc" );
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

- (IBAction)postButtonTapped:(id)sender {
     [self exampleMakeDecision];
}

- (void) exampleMakeDecision {
     
     if (self.responseDecisionTextView.text) {
          self.responseDecisionTextView.text = nil;
     }
     
     ECSURLSessionManager* sessionManager = [[EXPERTconnect shared] urlSession];
     [sessionManager makeDecision:self.decisionDictionary completion:^(NSDictionary *decisionResponse, NSError *error) {
          
          if( error )  {
               NSLog(@"Error: %@", error.description);
          } else  {
               NSData *responseData = [NSJSONSerialization dataWithJSONObject:self.decisionDictionary
                                                                      options:NSJSONWritingPrettyPrinted
                                                                        error:&error];
               
               NSString* responseJson = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
               
               NSLog(@"Decision Response Json: %@", responseJson);
               self.responseDecisionTextView.text = [NSString stringWithFormat:@"%@",decisionResponse];
          }
     }];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
     
     if([text isEqualToString:@"\n"]) {
          [textView resignFirstResponder];
          return NO;
     }
     
     return YES;
}

@end
