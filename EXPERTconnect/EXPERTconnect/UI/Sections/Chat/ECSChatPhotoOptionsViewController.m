//
//  ECSChatPhotoOptionsView.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//
#import <MobileCoreServices/MobileCoreServices.h>

#import "ECSChatPhotoOptionsViewController.h"

#import "ECSButton.h"
#import "ECSLocalization.h"

@interface ECSChatPhotoOptionsViewController() <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet ECSButton *takePhotoButton;
@property (weak, nonatomic) IBOutlet ECSButton *recordVideoButton;
@property (weak, nonatomic) IBOutlet ECSButton *existingImageButton;

@end

@implementation ECSChatPhotoOptionsViewController


- (void)viewDidLoad {
    [self setup];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    [self.takePhotoButton setTitle:ECSLocalizedString(ECSLocalizeTakeAPhoto, @"Take a Photo")
                          forState:UIControlStateNormal];
    [self.recordVideoButton setTitle:ECSLocalizedString(ECSLocalizeRecordVideo, @"Record a Video")
                            forState:UIControlStateNormal];
    [self.existingImageButton setTitle:ECSLocalizedString(ECSLocalizeExistingFromAlbum, @"Existing from Album")
                              forState:UIControlStateNormal];
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        self.takePhotoButton.enabled = NO;
        self.recordVideoButton.enabled = NO;
    }
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        self.existingImageButton.enabled = NO;
    }
}

- (IBAction)takePhotoTapped:(id)sender {
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePicker
                       animated:YES
                     completion:nil];
}

- (IBAction)recordVideoTapped:(id)sender {
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];

    [self presentViewController:imagePicker
                       animated:YES
                     completion:nil];
}

- (IBAction)pickFromAlbumTapped:(id)sender {
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, kUTTypeImage, nil];
    
    [self presentViewController:imagePicker
                       animated:YES
                     completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
        if ([self.delegate respondsToSelector:@selector(mediaSelected:)])
        {
            [self.delegate mediaSelected:info];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
@end
