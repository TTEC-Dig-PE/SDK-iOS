//
//  ECSWebViewController.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ECSRootViewController.h"

/**
 View controller for presenting full screen web content.
 */
@interface ECSWebViewController : ECSRootViewController

/**
 Loads a web item at the specified path.
 
 @param path the path to the content
 */
- (void)loadItemAtPath:(NSString*)path;

/**
 Loads a web item with the specified request.
 
 @param request the request to load.
 */
- (void)loadRequest:(NSURLRequest*)request;

@end
