//
//  ECSAuthenticationToken.h
//  EXPERTconnect
//
//  Created by Michael Schmoyer on 2/2/16.
//  Copyright © 2016 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ECSAuthenticationTokenDelegate <NSObject>

- (void)fetchAuthenticationToken:(void (^)(NSString *authToken, NSError *error))completion;

@end

@interface ECSAuthenticationToken : NSObject

@end
