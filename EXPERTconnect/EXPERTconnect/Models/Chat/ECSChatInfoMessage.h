//
//  ECSChatInfoMessage.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatMessage.h"

@interface ECSChatInfoMessage : ECSChatMessage

@property (strong, nonatomic) NSString *infoMessage;
@property (nonatomic) bool useBiggerFont;

-(id)init;
-(id)initWithInfoMessage:(NSString *)message biggerFont:(BOOL)bigger ;

@end
