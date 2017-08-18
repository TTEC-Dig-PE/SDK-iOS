//
//  ECSChatInfoMessage.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatInfoMessage.h"

@implementation ECSChatInfoMessage

- (id) init {
    return [self initWithInfoMessage:@"" biggerFont:NO];
}

-(id)initWithInfoMessage:(NSString *)message biggerFont:(BOOL)bigger {
    if (self = [super init]) {
        /* perform your post-initialization logic here */
        self.infoMessage = message;
        self.useBiggerFont = bigger;
    }
    return self;
}

@end
