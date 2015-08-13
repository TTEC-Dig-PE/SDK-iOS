
#import <Foundation/Foundation.h>
#import "ACBClientMessage.h"

@class ACBClientConversation;

/**
 The conversation delegate.
 */
@protocol ACBClientConversationDelegate <NSObject>

@required

/**
 Notifies that an incoming message has been received.
 
 @param conversation The conversation that received the message.
 @param message The inbound message.
 */
- (void) conversation:(ACBClientConversation*)conversation didReceiveMessage:(ACBClientMessage*)message;

@optional

/**
 Notifies that a conversation has started, either by the local or remote party.
 
 @param conversation The conversation that started.
 */
- (void) conversationDidStart:(ACBClientConversation*)conversation;

/**
 Notifies that an outbound request to start a conversation was not received by the remote party.
 
 @param conversation The conversation that failed to start.
 */
- (void) conversationDidFailToStart:(ACBClientConversation*)conversation;

/**
 Notifies that a conversation has ended, either by the local or remote party.
 
 @param conversation The conversation that ended.
 */
- (void) conversationDidEnd:(ACBClientConversation*)conversation;

@end

/** Conversation statuses. */
typedef enum
{
    /** A request to start a conversation has been sent, but no response has been received. */
    ACBClientConversationStatusStarting,
    /** The conversation failed to start. */
    ACBClientConversationStatusFailedToStart,
    /** The conversation is in progress. */
    ACBClientConversationStatusStarted,
    /** A request to end a conversation has been sent, but no response has been received. */
    ACBClientConversationStatusEnding,
    /** The conversation has ended. */
    ACBClientConversationStatusEnded
}
ACBClientConversationStatus;

/**
 An object that represents an IM conversation between 2 parties.
 */
@interface ACBClientConversation : NSObject

/** The delegate. */
@property (weak) id<ACBClientConversationDelegate> delegate;
/** The conversation status. */
@property (readonly) ACBClientConversationStatus status;
/** The remote contact address. */
@property (readonly) NSString* contactAddress;
/** The messages in this conversation. */
@property (readonly) NSArray* messages;

/**
 Sends a message to the remote contact.
 
 @param text The text of the message to send.
 @param delegate The message delegate.
 */
- (ACBClientMessage*) sendMessage:(NSString*)text delegate:(id<ACBClientMessageDelegate>)delegate;

/**
 Ends the conversation.
 */
- (void) end;

@end
