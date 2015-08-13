
#import <Foundation/Foundation.h>

@class ACBClientMessage;
@class ACBClientConversation;

/**
 The delegate for an individual message being sent. Delegate methods will only fire for outbound messages. Inbound messages will never invoke delegate methods.
 */
@protocol ACBClientMessageDelegate <NSObject>

@optional

/**
 Notifies that the outbound message was delivered.
 
 @param message The message that was delivered.
 @param conversation The conversation that the message is part of.
 */
- (void) message:(ACBClientMessage*)message didReceiveDeliveryConfirmationInConversation:(ACBClientConversation*)conversation;

/**
 Notifies that the outbound message was not delivered.
 
 @param message The message that was not delivered.
 @param conversation The conversation that the message is part of.
 */
- (void) message:(ACBClientMessage*)message didReceiveDeliveryFailureInConversation:(ACBClientConversation*)conversation;

@end

/** Conversation statuses. */
typedef enum
{
    /** An outbound message has been sent, but no delivery confirmation has been received. */
    ACBClientMessageStatusSending,
    /** An outbound message was sent and a delivery confirmation has been received. */
    ACBClientMessageStatusSent,
    /** An outbound message was sent and a delivery failure has been received. */
    ACBClientMessageStatusFailedToSend,
    /** An inbound message has been received. */
    ACBClientMessageStatusReceived
}
ACBClientMessageStatus;

/**
 An object that represents a single IM message. If an application wants to be informed of the delivery
 state of an outbound message, it should attach a delegate. The delegate has no use in an inbound message.
 */
@interface ACBClientMessage : NSObject

/** The delegate. */
@property (weak) id<ACBClientMessageDelegate> delegate;
/** The message status. */
@property (readonly) ACBClientMessageStatus status;
/** The text of the message. */
@property (readonly) NSString* text;

@end
