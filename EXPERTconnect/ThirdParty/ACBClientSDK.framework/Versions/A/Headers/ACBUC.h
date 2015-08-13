#import <Foundation/Foundation.h>
#import "ACBClientPhone.h"
#import "ACBClientPresence.h"
#import "ACBClientAED.h"

@class ACBUC;

/**
 The delegate for the ACBUC instance. The delegate deals with session establishment notifications and high-level error scenarios.
 */
@protocol ACBUCDelegate <NSObject>

/**
 A notification to indicate that the session has been initialised successfully.

 @param uc The UC.
 */
- (void) ucDidStartSession:(ACBUC*)uc;

/**
 A notification to indicate that initialisation of the session failed.

 @param uc The UC.
 */
- (void) ucDidFailToStartSession:(ACBUC*)uc;

/**
 A notification to indicate that the server has experienced a system failure.

 @param uc The UC.
 */
- (void) ucDidReceiveSystemFailure:(ACBUC*)uc;

/**
 A notification to indicate that there are problems with the network connection, the session
 has been lost, and all reconnection attempts have failed. See [uc:willRetryConnectionNumber:in:]
 for details.

 The app should log in again and re-establish a new session, or direct the user to do so.

 @param uc The UC.
 */
- (void) ucDidLoseConnection:(ACBUC*)uc;

@optional

/**
 A notification to indicate that there are problems with the network connection and that an attempt
 will be made to re-establish the session.

 In the event of connection problems, several attempts to reconnect will be made, and each attempt will
 be preceded by this notification. If after all of these attempts the session still cannot
 be re-established, the delegate will receive the [ucDidloseConnection:] callback and the attempts
 will stop. If one of the retries is successful then the delegate will receive the
 [ucDidReestablishConnection:] callback.

 The delegate can decide to stop this retry process at any point by calling [stopSession].

 @param attemptNumber - 1 indicates the first reconnection attempt, 2 the second attempt, etc.
 @param delay - the next reconnection attempt will be made after this delay.
 */
- (void) uc:(ACBUC*)uc willRetryConnectionNumber:(NSUInteger)attemptNumber in:(NSTimeInterval)delay;

/**
 A notification to indicate that a reconnection attempt has succeeded. See
 [uc:willRetryConnectionNumber:in:] for details.
 */
- (void) ucDidReestablishConnection:(ACBUC*)uc;

@end

/**
 The ACBUC acts as the entry point to the SDK and provides the client application with a single object exposing all of the other functions through its properties
 (voice/video through 'phone', presence/IM through 'presence' and AED through 'aed'). An instance of this class should be created by sending a message to one of the
 ucWithConfiguration static selectors. <code>[[ACBUC alloc] init]</code> will not work.
 */
@interface ACBUC : NSObject

/** The delegate. */
@property (atomic, weak) id<ACBUCDelegate> delegate;
/** The phone instance. */
@property (nonatomic, readonly) ACBClientPhone *phone;
/** The presence instance. */
@property (nonatomic, readonly) ACBClientPresence *presence;
/** The AED instance. */
@property (nonatomic, readonly) ACBClientAED *aed;
/**
 Specifies whether or not the websocket connection to the gateway should
 send any cookies that have been stored for the gateway domain. This is
 NO by default; if you want to send cookies in the websocket request
 then you must set this to YES before the call to [startSession].
 */
@property BOOL useCookies;

/**
 Starts a UC object which sets up phone and IM depending on the configuration being passed in.

 @param configuration The global UC configuration.
 @param delegate The UC delegate.
 */
+ (id) ucWithConfiguration:(NSString *)configuration delegate:(id<ACBUCDelegate>)delegate;

/**
 Starts a UC object which sets up phone and IM depending on the configuration being passed in.

 @param configuration The global UC configuration
 @param stunServers An array of NSString stun servers in the form stun:stun.l.google.com:19302. This list will be combined with any STUN/TURN servers configured on the server.
 @param delegate The UC delegate.
 */
+ (id) ucWithConfiguration:(NSString *)configuration stunServers:(NSArray*)stunServers delegate:(id<ACBUCDelegate>)delegate;

/**
 Starts a server session with the given session id.
 */
- (void) startSession;

/**
 Stops the active server session.
 */
- (void) stopSession;

/**
 Informs the SDK that the network is reachable or not.

 @param reachable Whether the network is reachable.
 */
- (void) setNetworkReachable:(BOOL)reachable;

/**
 Informs the SDK whether it should accept any server certificate.

 This method should only be called durng development.

 This method should be called before startSession.

 @param accept whether to accept any server certificate.
 */
- (void) acceptAnyCertificate:(BOOL)accept;

@end
