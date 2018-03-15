//
//  ECSMessageTask.h
//  EXPERTconnect
//
//  Created by Michael Schmoyer on 8/7/17.
//  Copyright © 2017 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ECSSessionManagerSuccess)(id result, NSURLResponse *response);
typedef void (^ECSSessionManagerFailure)(id result, NSURLResponse *response, NSError *error);

@interface ECSMessageTask : NSObject

@property (nonatomic, strong) NSString * path;
@property (nonatomic, strong) NSDictionary * parameters;
@property (nonatomic) ECSSessionManagerSuccess success;
@property (nonatomic) ECSSessionManagerFailure failure;

@end
