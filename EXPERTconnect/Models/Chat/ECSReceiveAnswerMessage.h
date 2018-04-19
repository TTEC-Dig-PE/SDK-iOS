//
//  ECSReceiveAnswerMessage.h
//  EXPERTconnect
//
//  Created by Ken Washington on 8/20/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSChatMessage.h"


@interface ECSReceiveAnswerMessage : ECSChatMessage

@property (strong, nonatomic) NSString *from;
@property (strong, nonatomic) NSString *answerText;

@end
