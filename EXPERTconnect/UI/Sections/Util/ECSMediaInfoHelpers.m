//
//  ECSMediaInfoHelpers.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "ECSMediaInfoHelpers.h"

@implementation ECSMediaInfoHelpers

+ (UIImage *)thumbnailForMedia:(NSDictionary *)mediaInfo
{
    NSString *mediaType = mediaInfo[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString*)kUTTypeImage])
    {
        return mediaInfo[UIImagePickerControllerOriginalImage];
    }
    else if ([mediaType isEqualToString:(NSString*)kUTTypeMovie])
    {
        NSURL *movieURL = mediaInfo[UIImagePickerControllerMediaURL];
        AVAsset *movie = [AVAsset assetWithURL:movieURL];
        
        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:movie];
        imageGenerator.appliesPreferredTrackTransform = YES;
        
        NSError *error;
        CMTime actualTime;
        
        CGImageRef firstFrame = [imageGenerator copyCGImageAtTime:CMTimeMakeWithSeconds(0, 600)
                                                         actualTime:&actualTime
                                                              error:&error];
        
        if (firstFrame != NULL) {
            UIImage *image = [[UIImage alloc] initWithCGImage:firstFrame scale:[UIScreen mainScreen].scale
                                                  orientation:UIImageOrientationUp];
            CGImageRelease(firstFrame);
            return image;
        }

    }
    return nil;
}

+ (NSString *)fileTypeForMedia:(NSDictionary *)mediaInfo
{
    NSString *mediaType = mediaInfo[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString*)kUTTypeImage])
    {
        return @"image/jpg";
    }
    else if ([mediaType isEqualToString:(NSString*)kUTTypeMovie])
    {
        return @"video/quicktime";
    }
    
    return nil;
}

+ (NSString*)filePathForMedia:(NSDictionary *)mediaInfo
{
    NSURL *movieURL = mediaInfo[UIImagePickerControllerMediaURL];
    return [movieURL absoluteString];
}

+ (NSString *)uploadNameForMedia:(NSDictionary *)mediaInfo
{
    NSString *mediaType = mediaInfo[UIImagePickerControllerMediaType];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMdd_HHmmss";
    
    if ([mediaType isEqualToString:(NSString*)kUTTypeImage])
    {
        return [NSString stringWithFormat:@"JPEG_%@.jpg", [formatter stringFromDate:[NSDate date]]];
    }
    else if ([mediaType isEqualToString:(NSString*)kUTTypeMovie])
    {
        return [NSString stringWithFormat:@"MOV_%@.mov", [formatter stringFromDate:[NSDate date]]];
    }

    return @"unknown";
}

+ (NSData*)uploadDataForMedia:(NSDictionary *)mediaInfo
{
    NSString *mediaType = mediaInfo[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString*)kUTTypeImage])
    {
        return UIImageJPEGRepresentation(mediaInfo[UIImagePickerControllerOriginalImage], 0);
    }
    else if ([mediaType isEqualToString:(NSString*)kUTTypeMovie])
    {
        return [NSData dataWithContentsOfFile:[mediaInfo[UIImagePickerControllerMediaURL] absoluteString]];
    }

    return nil;
}



@end
