//
//  ECSMessageActionType.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <EXPERTconnect/EXPERTconnect.h>

@interface ECSMessageActionType : ECSActionType <NSCopying>

@property (strong, nonatomic) NSString *messageHeader;
@property (strong, nonatomic) NSString *messageText;
@property (strong, nonatomic) NSString *hoursText;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *emailSubject;
@property (strong, nonatomic) NSString *emailBody;
@property (strong, nonatomic) NSString *emailButtonText;

@end
