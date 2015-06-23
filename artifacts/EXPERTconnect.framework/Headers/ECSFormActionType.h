//
//  ECSFormActionType.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <EXPERTconnect/EXPERTconnect.h>

@class ECSForm;

/**
 ECSFormActionType is an action type defining form to be presented to the user
 */
@interface ECSFormActionType : ECSActionType <NSCopying>

// The form to present to the user
@property(nonatomic, strong) ECSForm* form;

@end
