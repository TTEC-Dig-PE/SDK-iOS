//
//  ECSCachingImageView.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSCachingImageView.h"

#import "ECSImageCache.h"
#import "ECSInjector.h"
#import "ECSUtilities.h"

@interface ECSCachingImageView()

@property (nonatomic, strong) NSString *currentImagePath;

@end

@implementation ECSCachingImageView

- (instancetype)initWithImagePath:(NSString *)imagePath
{
    ECSImageCache *imageCache = [[ECSInjector defaultInjector] objectForClass:[ECSImageCache class]];
    
    UIImage *image = [imageCache imageForPath:imagePath];

    self = [super initWithImage:image];
    
    if (self)
    {
        self.currentImagePath = imagePath;
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setImageWithPath:(NSString *)path
{
    if (!IsNullOrEmpty(path))
    {
        self.currentImagePath = path;
        
        ECSImageCache *imageCache = [[ECSInjector defaultInjector] objectForClass:[ECSImageCache class]];

        UIImage *image = [imageCache imageForPath:path];
        if (!image)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageDownloaded:) name:ECSImageCacheImageDownloadedNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageDownloadFailed:) name:ECSImageCacheImageDownloadFailedNotification object:nil];
            
            [imageCache downloadImageForPath:path];
        }
        else
        {
            self.image = image;
        }
    }
}

- (void)setImageWithRequest:(NSURLRequest*)request
{
    if (!IsNullOrEmpty([[request URL] absoluteString]))
    {
        self.currentImagePath = [[request URL] absoluteString];
        
        ECSImageCache *imageCache = [[ECSInjector defaultInjector] objectForClass:[ECSImageCache class]];
        
        UIImage *image = [imageCache imageForPath:self.currentImagePath];
        if (!image)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageDownloaded:) name:ECSImageCacheImageDownloadedNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageDownloadFailed:) name:ECSImageCacheImageDownloadFailedNotification object:nil];
            
            [imageCache downloadImageWithRequest:request];
        }
        else
        {
            self.image = image;
        }
    }

}

- (void)imageDownloaded:(NSNotification*)notification
{
    NSString *imageURL = [[notification userInfo] objectForKey:ECSImageCacheImageUrlKey];

    if (imageURL && [imageURL isEqualToString:self.currentImagePath])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            ECSImageCache *imageCache = [[ECSInjector defaultInjector] objectForClass:[ECSImageCache class]];
            
            [self setImage:[imageCache objectForKey:self.currentImagePath]];
        });
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}


- (void)imageDownloadFailed:(NSNotification*)notification
{
    NSString *path = @"error_not_found";
    NSString *message = [[notification userInfo] objectForKey:ECSImageDownloadFailedMessageKey];
    UIImage *image = [UIImage imageNamed:path];
    
    if(!image)  {
        image = [UIImage imageNamed:path inBundle:[NSBundle mainBundle] compatibleWithTraitCollection:nil];
        
        if (!image)
        {
            image = [UIImage imageNamed:path inBundle:[NSBundle bundleForClass:[ECSImageCache class]] compatibleWithTraitCollection:nil];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setImage:image];
        
        if(self.delegate)
        {
            [self.delegate errorOccurred:message];
        }
    });
}
@end
