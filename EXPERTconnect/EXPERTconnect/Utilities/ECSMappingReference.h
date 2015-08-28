//
//  ECSMappingReference.h
//  EXPERTconnect
//
//  Created by Sam Solomon on 8/17/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ECSRootViewController;

@interface ECSMappingReference : NSObject

- (ECSRootViewController *)viewControllerForAction:(NSString *)actionType;

@end
