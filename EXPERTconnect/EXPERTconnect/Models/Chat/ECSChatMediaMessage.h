//
//  ECSChatImageMessage.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatMessage.h"

#import "ECSAddressableChatMessage.h"

typedef NS_ENUM(NSUInteger, ECSChatMediaType)
{
    ECSChatMediaTypeImage,
    ECSChatMediaTypeMovie
};
@interface ECSChatMediaMessage : ECSChatMessage <ECSAddressableChatMessage>

//@property (strong, nonatomic) NSString *conversationId;
@property (strong, nonatomic) NSString *channelId;
@property (strong, nonatomic) NSString *from;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *urlType;
@property (assign, nonatomic) ECSChatMediaType mediaType;
@property (strong, nonatomic) NSString *comment;
@property (strong, nonatomic) NSNumber *version;
@property (strong, nonatomic) UIImage *imageThumbnail;

@end
