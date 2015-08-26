//
//  ECSSendQuestionMessage.h
//  EXPERTconnect
//
//  Created by Ken Washington on 8/20/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSChatMessage.h"
#import "ECSJSONObject.h"
#import "ECSJSONSerializing.h"


@interface ECSSendQuestionMessage : ECSChatMessage

@property (strong, nonatomic) NSString *questionText;
@property (strong, nonatomic) NSString *channelId;
@property (strong, nonatomic) NSString *version;
@property (strong, nonatomic) NSString *conversationId;
@property (strong, nonatomic) NSString *interfaceName;
@property (strong, nonatomic) NSString *from;

@end
