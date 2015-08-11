
#import <Foundation/Foundation.h>
#import "ACBClientConversation.h"

/** Presence states */
typedef enum
{
    /** The available state. */
    ACBClientPresenceStatusAvailable,
    /** The busy state. */
    ACBClientPresenceStatusBusy,
    /** The away state. */
    ACBClientPresenceStatusAway,
    /** The offline state. */
    ACBClientPresenceStatusOffline
}
ACBClientPresenceStatus;

/**
 An object that represents a contact. Applications will be notified of
 all contacts in the contact list when first logged in allowing the application to
 build up the full list of contacts and their status'.
 */
@interface ACBClientContact : NSObject

/** The contact address. This is a unique identifier. */
@property (readonly) NSString *address;
/** The contact name. */
@property (readonly) NSString *name;
/** The contact's status. */
@property (readonly) ACBClientPresenceStatus status;
/** Any custom message that the contact has published. */
@property (readonly) NSString *customMessage;

@end

@class ACBClientPresence;

/**
 The presence delegate.
 */
@protocol ACBClientPresenceDelegate <NSObject>

/**
 A notification that the logged in user's own state has changed.
 
 @param presence The presence object that fired the change.
 @param status The new status value.
 @param customMessage A custom status message - may be nil.
 */
- (void) presence:(ACBClientPresence*)presence didReceiveUserStatusChange:(ACBClientPresenceStatus)status customMessage:(NSString *)customMessage;

/**
 A notification that a contact's presence state changed.  Applications will be notified of
 all contacts in the contact list when first logged in allowing the application to
 build up the full list of contacts and their status'.
 
 @param presence The presence object that fired the change.
 @param contactAddress The identifier for the contact.
 @param status The new status of this contact
 @param customMessage A custom status message - may be nil.
 */
- (void) presence:(ACBClientPresence*)presence contact:(NSString*)contactAddress didReceiveStatusChange:(ACBClientPresenceStatus)status customMessage:(NSString *)customMessage;

/**
 A notification that a conversation has been started remotely.
 
 @param presence The presence object that fired the change.
 @param conversation The conversation.
 */
- (void) presence:(ACBClientPresence*)presence didStartConversation:(ACBClientConversation*)conversation;

@end

/**
 An object that acts as the entry point for all presence and IM interaction.
 */
@interface ACBClientPresence : NSObject

/** The delegate. */
@property (nonatomic, weak) id<ACBClientPresenceDelegate> delegate;
/** The array of contacts. */
@property (readonly) NSArray* contacts;
/** The array of current conversations. */
@property (readonly) NSArray* currentConversations;

/**
 Sets the status of user.
 
 @param status The status.
 */
-(void) setStatus:(ACBClientPresenceStatus)status;

/**
 Sets the status of user with a custom message.
 
 @param status The status.
 @param message The custom message.
 */
-(void) setStatus:(ACBClientPresenceStatus)status customMessage:(NSString *)message;

/**
 Starts a conversation with a contact.
 
 @param contactAddress The contact address.
 @param delegate The conversation delegate.
 
 @return the conversation.
 */
- (ACBClientConversation*) startConversationWithContact:(NSString*)contactAddress delegate:(id<ACBClientConversationDelegate>)delegate;

@end
