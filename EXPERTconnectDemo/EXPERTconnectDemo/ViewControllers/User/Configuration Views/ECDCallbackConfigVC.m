//
//  ECDCallbackConfigVC.m
//  EXPERTconnectDemo
//
//  Created by Michael Schmoyer on 12/6/17.
//  Copyright © 2017 Humanify, Inc. All rights reserved.
//

#import "ECDCallbackConfigVC.h"

@interface ECDCallbackConfigVC () <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@end

@implementation ECDCallbackConfigVC

static NSString *const lastCallbackSkillSelected = @"lastCallbackSkillSelected";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.pickerChatSkill.delegate = self;
    self.pickerChatSkill.dataSource = self;
    
    // Attempt to load the selected skill for the selected environment
    currentChatSkill = [[NSUserDefaults standardUserDefaults]
                        stringForKey:[NSString stringWithFormat:@"%@_%@", currentEnvironment, lastCallbackSkillSelected]];
    
    // Select the current skill in the flipper control.
    int currentRow = 0;
    rowToSelect = 0;
    if(currentChatSkill != nil)  {
        for(NSString* skill in chatSkillsArray) {
            if([skill isEqualToString:currentChatSkill])  {
                selectedRow = currentRow;
                break;
            }
            currentRow++;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self setupPickerView];
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

- (IBAction)btnHighLevelCallback_Touch:(id)sender {
    
    NSLog(@"Starting an ad-hoc Voice Callback Session");
    
//    NSString *callSkill = [self.selectAdHocVoiceCallbackPicker currentSelection];
    
//    [self localBreadCrumb:@"Voice callback started"
//              description:[NSString stringWithFormat:@"Voice callback with skill=%@", callSkill]];
    
    NSString *callSkill = chatSkillsArray[selectedRow];
    
    UIViewController *chatController = [[EXPERTconnect shared] startVoiceCallback:callSkill
                                                                  withDisplayName:@"Voice Callback"];
    
    [self.navigationController pushViewController:chatController animated:YES];
    
}

- (IBAction)btnLowLevelCallback_Touch:(id)sender {
    
    ECDSimpleCallbackVC * lowLevelCallbackView = [[ECDSimpleCallbackVC alloc] init];
    
    lowLevelCallbackView.callbackSkill = chatSkillsArray[selectedRow];
    [self.navigationController pushViewController:lowLevelCallbackView animated:YES];
    
}

#pragma mark Picker View

-(void)setupPickerView {
    
    currentEnvironment = [[NSUserDefaults standardUserDefaults] objectForKey:@"environmentName"];
    if(!currentEnvironment) {
        currentEnvironment = @"IntDev";
    }
    
    if (![self addChatSkillsFromServer]) {
        //[self addChatSkillsHardcoded];
        NSLog(@"PROBLEM!");
    }
    
    // Attempt to load the selected skill for the selected environment
    currentChatSkill = [[NSUserDefaults standardUserDefaults]
                        stringForKey:[NSString stringWithFormat:@"%@_%@", currentEnvironment, lastCallbackSkillSelected]];
    
    // Select the current skill in the flipper control.
    int currentRow = 0;
    rowToSelect = 0;
    if(currentChatSkill != nil)  {
        for(NSString* skill in chatSkillsArray) {
            if([skill isEqualToString:currentChatSkill])  {
                rowToSelect = currentRow;
                break;
            }
            currentRow++;
        }
    }
    
    [self getAgentsAvailableForExpertSkill:rowToSelect];
    
    [self.pickerChatSkill reloadAllComponents];
    [self.pickerChatSkill selectRow:rowToSelect inComponent:0 animated:NO];
    selectedRow = rowToSelect; // mas - fixed issue if user did not touch the slider would load skill at index 0.
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    //[super pickerView:pickerView didSelectRow:row inComponent:component];
    [[NSUserDefaults standardUserDefaults] setObject:[chatSkillsArray objectAtIndex:row]
                                              forKey:[NSString stringWithFormat:@"%@_%@", currentEnvironment, lastCallbackSkillSelected]];
    
    [self getAgentsAvailableForExpertSkill:(int)row];
    
    selectedRow = (int)row;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// Total rows in our component.
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [chatSkillsArray count];
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSString *title;
    title=[chatSkillsArray objectAtIndex:row];
    return title;
}

-(void)getAgentsAvailableForExpertSkill:(int)index
{
    if( chatSkillsArray.count == 0 || chatSkillsArray.count < index) {
        NSLog(@"ChatConfigView - Attempted to load skill in array out of bounds.");
        return;
    }
    
    NSLog(@"Test Harness::AdHoc - Getting details for skill: %@", [chatSkillsArray objectAtIndex:index]);
    
    [[EXPERTconnect shared] getDetailsForExpertSkill:[chatSkillsArray objectAtIndex:index]
                                          completion:^(ECSSkillDetail *data, NSError *error)
     {
         NSMutableString *labelText = [[NSMutableString alloc] initWithString:@""];
         
         if( !error && [data isKindOfClass:[ECSSkillDetail class]] )
         {
             if(data.active && data.queueOpen && data.chatReady > 0)
             {
                 [labelText appendString:[NSString stringWithFormat:@"Estimated wait: %d seconds.", data.estWait]];
                 //[self.btnStartChat setEnabled:YES];
             }
             else
             {
                 // No agents available.
                 //[self.btnStartChat setEnabled:NO];
             }
             
             [self.lblAgentAvailability setText:[NSString stringWithFormat:@"Estimated wait is %d seconds. %d of %d agents ready. Queue is: %@. %d in queue now. Active=%d.",
                                                 data.estWait,
                                                 data.chatReady,
                                                 data.chatCapacity,
                                                 (data.queueOpen ? @"Open" : @"Closed"),
                                                 data.inQueue,
                                                 data.active]];
         } else {
             [labelText appendString:[NSString stringWithFormat:@"/experts/v1/skills ERROR: %@", error]];
         }
     }];
}

-(BOOL)addChatSkillsFromServer {
    
    NSArray *environmentConfig = [[NSUserDefaults standardUserDefaults] objectForKey:@"environmentConfig"];
    
    if (!environmentConfig) {
        return NO;
    }
    
    for( NSDictionary *envData in environmentConfig) {
        
        if (envData[@"name"] && [envData[@"name"] isEqualToString:currentEnvironment]) {
            
            if(envData[@"agent_skills"]) {
                
                chatSkillsArray = [NSMutableArray new];
                for ( NSString *skill in envData[@"agent_skills"] ) {
                    [chatSkillsArray addObject:skill];
                }
                [chatSkillsArray addObject:@"INVALID_SKILL"];
            }
        }
    }
    
    return YES;
}

@end
