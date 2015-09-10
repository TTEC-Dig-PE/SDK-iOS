//
//  ECDAPIConfigViewController.m
//  EXPERTconnectDemo
//
//  Created by Ken Washington on 8/12/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//
#import "ECDAdHocAnswerEngineContextPicker.h"
#import "ECDAPIConfigViewController.h"
#import "ECDLocalization.h"

#import <EXPERTconnect/EXPERTconnect.h>
#import <EXPERTconnect/ECSTheme.h>
#import <EXPERTconnect/ECSUserProfile.h>
#import <EXPERTconnect/ECSRatingView.h>         // kdw: Causes Warning: "Missing submodule EXPERTconnect.ECSRatingView"

static NSString * const kReadConfigUrlPath = @"/appconfig/v1/read_rconfig?name={name}";
static NSString * const kClearCacheUrlPath = @"/answerengine/v1/clear_cache";

@interface ECDAPIConfigViewController ()

@property (weak, nonatomic) IBOutlet UITextField *configNameField;
@property (weak, nonatomic) IBOutlet UITextField *configEndpointField;
@property (weak, nonatomic) IBOutlet UITextField *configValueField;
@property (weak, nonatomic) IBOutlet UITextField *sliderValueField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UIButton *askQuestionButton;
@property (weak, nonatomic) IBOutlet UIButton *submitRatingButton;
@property (weak, nonatomic) IBOutlet UITextView *answerEngineResponseTextView;
@property (weak, nonatomic) IBOutlet ECDAdHocAnswerEngineContextPicker *selectAnswerEngineContextPicker;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISlider *rateResponseSlider;
@property (weak, nonatomic) IBOutlet ECSRatingView *rateResponseStars;
@property (strong, nonatomic) NSArray *topQuestions;
@property (strong, nonatomic) ECSAnswerEngineResponse *lastAnswerEngineResponse;

@end

@implementation ECDAPIConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeFields];

    NSString *endpoint = [kReadConfigUrlPath
                          stringByReplacingOccurrencesOfString:@"{name}" withString:self.configNameField.text];
    
    __weak typeof(self) weakSelf = self;
    
    ECSCodeBlock whenCompleted = ^(NSString *response, NSError *error)   {
        weakSelf.configValueField.text = response;
    };
    
    ECSURLSessionManager* sessionManager = [[EXPERTconnect shared] urlSession];
    [sessionManager getResponseFromEndpoint:endpoint withCompletion:whenCompleted];
}

-(void) initializeFields {
    self.answerEngineResponseTextView.text = @"";

    // Set the tintColor so we can see the cursor clear;
    //
    self.configNameField.tintColor = UIColor.blueColor;
    self.configEndpointField.tintColor = UIColor.blueColor;
    self.configValueField.tintColor = UIColor.blueColor;
    self.answerEngineResponseTextView.tintColor = UIColor.blueColor;
    
    // Round button corners
    CALayer *btnLayer = [self.submitButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    
    btnLayer = [self.refreshButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    
    btnLayer = [self.askQuestionButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    
    btnLayer = [self.submitRatingButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    
    [self.submitButton addTarget:self
                          action:@selector(submitButtonTapped:)
                forControlEvents:UIControlEventTouchUpInside];
    
    [self.refreshButton addTarget:self
                           action:@selector(refreshButtonTapped:)
                 forControlEvents:UIControlEventTouchUpInside];
    
    [self.askQuestionButton addTarget:self
                               action:@selector(askQuestionButtonTapped:)
                     forControlEvents:UIControlEventTouchUpInside];
    
    [self.submitRatingButton addTarget:self
                               action:@selector(submitRatingButtonTapped:)
                     forControlEvents:UIControlEventTouchUpInside];

    self.submitRatingButton.enabled = false;
    
    [self.selectAnswerEngineContextPicker setup];

    self.sliderValueField.text = @"5";
    self.rateResponseStars.value = 2.5;
    [self.rateResponseStars setStepInterval:0.5];
    
    // [self.rateResponseStars sizeToFit];
    
    [self.rateResponseStars addTarget:self action:@selector(ratingChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.tableView.delegate = self;
    [self refreshButtonTapped:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.topQuestions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"Top Questions";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [self.topQuestions objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.answerEngineResponseTextView.text = [self.topQuestions objectAtIndex:indexPath.row];
    NSLog(@"Row Selected: %d", indexPath.row);
}

- (void)submitButtonTapped:(UIButton*)button
{
    NSString *endpoint = [[self.configEndpointField.text
                           stringByReplacingOccurrencesOfString:@"{name}" withString:self.configNameField.text]
                           stringByReplacingOccurrencesOfString:@"{value}" withString:self.configValueField.text];
    
    ECSURLSessionManager* sessionManager = [[EXPERTconnect shared] urlSession];
    
    __weak typeof(self) weakSelf = self;
    
    ECSCodeBlock whenCompleted = ^(NSString *response, NSError *error)   {
        NSString *title = ECSLocalizedString(ECSLocalizeInfoKey, @"Info");
        NSString *profileMessage = ECDLocalizedString(ECDLocalizeConfigWasUpdatedKey, @"Config Value was updated:");
        NSString *message = [NSString stringWithFormat:[profileMessage stringByAppendingString:@": %@"], response];
        
        [weakSelf showAlert:title withMessage:message];
    };
    
    ECSCodeBlock whenUpdated = ^(NSString *response, NSError *error)   {
        NSString *profileMessage = ECDLocalizedString(ECDLocalizeConfigWasUpdatedKey, @"Config Value was updated:");
        NSLog(@"%@", profileMessage);
        
        // Now that the Config Value has been updated, Clear the Answer Engine Cache so our next request
        // will go against the requested Answer Engine Type (Synthetix / IntelliResponse)
        //
        [sessionManager getResponseFromEndpoint:kClearCacheUrlPath withCompletion:whenCompleted];
    };
    
    [sessionManager getResponseFromEndpoint:endpoint withCompletion:whenUpdated];
}

- (void)refreshButtonTapped:(UIButton*)button
{
    NSString *context = self.selectAnswerEngineContextPicker.currentSelection;
    NSNumber *num_questions = [NSNumber numberWithInt:4];
    
    ECSURLSessionManager* sessionManager = [[EXPERTconnect shared] urlSession];
    
    __weak typeof(self) weakSelf = self;
    
    [sessionManager getAnswerEngineTopQuestions:num_questions forContext:context withCompletion:^(NSArray *response, NSError *error)   {
        weakSelf.topQuestions = response;
        
        [weakSelf.tableView reloadData];
        
        NSLog(@"Received %d Top Questions", [response count]);
    }];
}

- (void)askQuestionButtonTapped:(UIButton*)button
{
    NSString *question = self.answerEngineResponseTextView.text;
    NSString *context = self.selectAnswerEngineContextPicker.currentSelection;
    
    ECSURLSessionManager* sessionManager = [[EXPERTconnect shared] urlSession];
    
    __weak typeof(self) weakSelf = self;
    
    [sessionManager getAnswerForQuestion:question inContext:context parentNavigator:@"" actionId:@"" questionCount:0
                              customData:nil completion:^(ECSAnswerEngineResponse *response, NSError *error) {
        
        NSLog(@"Received AnswerEngine Response: %@", @"response.answerContent");
                                  
        weakSelf.answerEngineResponseTextView.text = response.answer;
        weakSelf.lastAnswerEngineResponse = response;
        weakSelf.submitRatingButton.enabled = true;
    }];
}

- (void)submitRatingButtonTapped:(UIButton*)button
{
    if(self.lastAnswerEngineResponse == nil) {
        NSLog(@"No Answer Engine Response to Rate");
        self.submitRatingButton.enabled = false;
     
        return;
    }
    
    NSString *answerid = self.lastAnswerEngineResponse.answerId;
    NSString *inquiryid = self.lastAnswerEngineResponse.inquiryId;
    NSNumber *rating = [NSNumber numberWithInt:[self.sliderValueField.text intValue]];
    
    ECSURLSessionManager* sessionManager = [[EXPERTconnect shared] urlSession];
    
    [sessionManager rateAnswerWithAnswerID:answerid inquiryID:inquiryid parentNavigator:@"" actionId:@""
                rating:rating questionCount:[NSNumber numberWithInt:0]
                completion:^(ECSAnswerEngineRateResponse *response, NSError *error) {
                    
        NSLog(@"Received AnswerEngine Rate Response:");
    }];
}

- (IBAction)sliderValueChanged:(id)sender {
    self.sliderValueField.text = [NSString stringWithFormat:@"%d", (int)self.rateResponseSlider.value];
    self.rateResponseStars.value = ((int)self.rateResponseSlider.value) / 2.0;
}

- (IBAction)ratingChanged:(id)sender {
    self.sliderValueField.text = [NSString stringWithFormat:@"%d", (int)(self.rateResponseStars.value * 2.0)];
    self.rateResponseSlider.value = self.rateResponseStars.value * 2.0;
}

- (void) showAlert:(NSString *)title withMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:ECSLocalizedString(ECSLocalizedOkButton, @"Ok Button")
                                          otherButtonTitles:nil];
    [alert show];
}

@end