//
//  ECDAdHocFormsController.m
//  EXPERTconnectDemo
//
//  Created by Ken Washington on 8/14/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>

#import "ECDAdHocFormsController.h"
#import "ECDLocalization.h"

#import <EXPERTconnect/EXPERTconnect.h>
#import <EXPERTconnect/ECSTheme.h>

@interface ECDAdHocFormsController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailAddressField;
@property (weak, nonatomic) IBOutlet UITextField *downloadImageNameField;
@property (weak, nonatomic) IBOutlet UITextField *uploadImageNameField;
@property (weak, nonatomic) IBOutlet UITextView *commentsTextView;
@property (weak, nonatomic) IBOutlet UISlider *agentRatingSlider;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (weak, nonatomic) IBOutlet ECSBinaryImageView *binaryView;
@property (weak, nonatomic) IBOutlet ECSCachingImageView *imageView;

@end

@implementation ECDAdHocFormsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeFields];
}

-(void) initializeFields {
    self.commentsTextView.text = @"";
    
    // Set the tintColor so we can see the cursor clear;
    //
    self.emailAddressField.tintColor = UIColor.blueColor;
    self.commentsTextView.tintColor = UIColor.blueColor;
    self.downloadImageNameField.tintColor = UIColor.blueColor;
    self.uploadImageNameField.tintColor = UIColor.blueColor;
    
    // Round button corners
    CALayer *btnLayer = [self.submitButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    
    self.agentRatingSlider.minimumValue = 0.0;
    self.agentRatingSlider.maximumValue = 10.0;
    self.agentRatingSlider.value = (self.agentRatingSlider.maximumValue - self.agentRatingSlider.minimumValue) / 2.0f;
    
    [self.agentRatingSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.binaryView.delegate = self;
    self.binaryView.fillLeftColor = [UIColor greenColor];
    self.binaryView.fillRightColor = [UIColor redColor];
    self.binaryView.insetLeft = 60;
    self.binaryView.spacingBetweenImages = 30;
    self.binaryView.currentRating = BinaryRatingPositive;
    
    [self.binaryView refresh];
    
    [self.submitButton addTarget:self
                          action:@selector(submitRatingButtonTapped:)
                forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *cameraImageFill = [self.photoButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.photoButton.tintColor = [UIColor blackColor];
    [self.photoButton setImage:cameraImageFill forState:UIControlStateNormal];
    
    self.imageView.delegate = self;
    NSString *imageName = self.downloadImageNameField.text;
    [self loadAdHocImage:imageName];
}

- (void) errorOccurred:(NSString *)errorMessage {
    ECSURLSessionManager* sessionManager = [[EXPERTconnect shared] urlSession];
    
    [sessionManager getMediaFileNamesWithCompletion:^(NSArray *fileNames, NSError *error) {
        NSString *delim = @"";
        NSMutableString *detailedErrorMessage = [[NSMutableString alloc] init];
        [detailedErrorMessage appendString:errorMessage];
        [detailedErrorMessage appendString:@" - try one of: "];

        for(NSString *fileName in fileNames)  {
            [detailedErrorMessage appendString:delim];
            [detailedErrorMessage appendString:fileName];
            delim = @", ";
        }
        
        [self showAlert:@"Error!" withMessage:detailedErrorMessage];
    }];
}

- (void) loadAdHocImage:(NSString *)imageName {
    ECSURLSessionManager* sessionManager = [[EXPERTconnect shared] urlSession];
    NSURLRequest *request = [sessionManager urlRequestForMediaWithName:imageName];
    [self.imageView setImageWithRequest:request];
}

- (void)submitRatingButtonTapped:(UIButton*)button
{
    NSMutableArray *formData = [NSMutableArray new];
    
    ECSForm *form = [ECSForm new];
    ECSFormItem *fI1 = [ECSFormItem new];
    ECSFormItem *fI2 = [ECSFormItem new];
    ECSFormItem *fI3 = [ECSFormItem new];
    
    [formData addObject:fI1];
    [formData addObject:fI2];
    [formData addObject:fI3];
    
    form.name = @"adhoc_sdk_demo";     // matches name in Forms Designer!!!
    form.formData = formData;
    
    fI1.label = @"Email Address";
    fI2.label = @"Agent Rating";
    fI2.label = @"Comments";
    
    fI1.formValue = self.emailAddressField.text;
    fI2.formValue = [NSString stringWithFormat:@"%d", (int)self.agentRatingSlider.value];
    fI3.formValue = self.commentsTextView.text;
    
    ECSURLSessionManager* sessionManager = [[EXPERTconnect shared] urlSession];
    
    __weak typeof(self) weakSelf = self;
    
    [sessionManager submitForm:form completion:^(ECSFormSubmitResponse *response, NSError *error) {
        NSLog(@"Form was Submited:");
        [weakSelf showAlert:@"Thank you!" withMessage:@"Form was Submitted!"];
    }];
}

- (void)sliderValueChanged:(id)sender
{
    if( self.agentRatingSlider.value > self.agentRatingSlider.minimumValue &&
        self.agentRatingSlider.value < self.agentRatingSlider.maximumValue &&
        self.binaryView.currentRating != BinaryRatingUnknown )  {
        
        self.binaryView.currentRating = BinaryRatingUnknown;
    }
}

- (IBAction)imageNameUpdated:(id)sender {
    NSString *imageName = self.downloadImageNameField.text;
    [self loadAdHocImage:imageName];
}

- (void)ratingSelected:(BinaryRating)rating {
    if(rating == BinaryRatingNegative) {
        self.agentRatingSlider.value = self.agentRatingSlider.minimumValue;
    } else if (rating == BinaryRatingPositive)  {
        self.agentRatingSlider.value = self.agentRatingSlider.maximumValue;
    } else {
        self.agentRatingSlider.value = (self.agentRatingSlider.maximumValue - self.agentRatingSlider.minimumValue) / 2.0f;;
    }
    // [self showAlert:@"Rating" withMessage:@"Thank you!"];
}

- (IBAction)cameraButtonTapped:(id)sender {
    // [self exampleMakeDecision];
    
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, kUTTypeImage, nil];
    
    [self presentViewController:imagePicker
                       animated:YES
                     completion:nil];
}

- (void) exampleMakeDecision {
    NSMutableArray *interests = [[NSMutableArray alloc] initWithObjects:@"running", @"skiing", @"hiking", nil];
    
    NSMutableDictionary *affinity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     @"9", @"sat_score",
                                     @"chris_horizon", @"expertId",
                                     @"financial advisor", @"skill",
                                     nil];
    
    NSMutableDictionary *interaction = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        @"2", @"nps_score",
                                        @"mutual funds", @"intent",
                                        nil];
    
    NSMutableDictionary *customData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"4", @"nps",
                                       @"60", @"klout",
                                       @"250000", @"clv",
                                       interests, @"interests",
                                       @"midatlantic", @"region",
                                       affinity, @"affinity",
                                       interaction, @"interaction",
                                       nil];
    
    NSMutableDictionary *consumerData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         @"null", @"userID",
                                         @"gwen@email.com", @"username",
                                         @"Gwen", @"firstName",
                                         @"", @"lastName",
                                         @"null", @"address",
                                         @"Denver", @"city",
                                         @"Colorado", @"state",
                                         @"80238", @"postalCode",
                                         @"United States", @"country",
                                         @"(312) 555-1155", @"homePhone",
                                         @"(312) 555-3944", @"mobilePhone",
                                         customData, @"customData",
                                         @"null", @"alternativeEmail",
                                         nil];
    
    NSMutableDictionary *decisionDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               consumerData, @"consumer",
                                               @"horizon", @"ceTenant",
                                               @"determineTreatment", @"eventId",
                                               nil];
    
    NSError *error;
    NSData *decisionData = [NSJSONSerialization dataWithJSONObject:decisionDictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                             error:&error];
    NSString* decisionJson = [[NSString alloc] initWithData:decisionData encoding:NSUTF8StringEncoding];
    
    NSLog(@"Decision Request Json: %@", decisionJson);
    
    
    ECSURLSessionManager* sessionManager = [[EXPERTconnect shared] urlSession];

    [sessionManager makeDecision:decisionDictionary completion:^(NSDictionary *decisionResponse, NSError *error) {
        
        if( error )  {
            NSLog(@"Error: %@", error.description);
        } else  {
            NSData *responseData = [NSJSONSerialization dataWithJSONObject:decisionDictionary
                                                                   options:NSJSONWritingPrettyPrinted
                                                                     error:&error];
            
            NSString* responseJson = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            
            NSLog(@"Decision Response Json: %@", responseJson);
        }
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self uploadPhoto:chosenImage withInfo:info];
}

- (void) uploadPhoto:(UIImage*)chosenImage withInfo:(NSDictionary *) mediaInfo {
    
    NSLog(@"Uploading the photo!");

    
    ECSURLSessionManager* sessionManager = [[EXPERTconnect shared] urlSession];
    
    __weak typeof(self) weakSelf = self;
    
    [sessionManager uploadFileData:[ECSMediaInfoHelpers uploadDataForMedia:mediaInfo]
                   withName:self.uploadImageNameField.text
            fileContentType:@"image/jpg"
                 completion:^(__autoreleasing id *response, NSError *error)
     {
         if (error)
         {
             [self showAlert:@"Error" withMessage: [NSString stringWithFormat:@"Failed to send media %@", error]];
         }
         else
         {
             [weakSelf.imageView setImage:chosenImage];
         }
     }];
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