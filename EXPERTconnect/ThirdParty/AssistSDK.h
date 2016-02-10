#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "ASDKSharedDocument.h"
#import "ASDKScreenShareRequestedDelegate.h"

typedef NS_ENUM(NSInteger, AssistStatus) {
    AssistStatusInitialized,
    AssistStatusRunning,
    AssistStatusStopped
};

extern NSString *kASDKSVGPathKey;
extern NSString *kASDKSVGLayerKey;

extern NSString *kASDKSVGPathStrokeKey;
extern NSString *kASDKSVGPathStrokeWidthKey;
extern NSString *kASDKSVGPathStrokeOpacityKey;

/* The AssistSDK also supports the following Protocols. Its
 implementation is to forward the notification to each of
 any registered delegates
 */

@protocol AssistSDKAnnotationDelegate <NSObject>
@optional
- (void) assistSDKWillAddAnnotation:(NSNotification*)notification;
- (void) assistSDKDidAddAnnotation:(NSNotification*)notification;
- (void) assistSDKDidClearAnnotations:(NSNotification*)notification;
@end


@protocol AssistSDKDelegate <NSObject>
- (void) assistSDKDidEncounterError:(NSNotification*)notification;
- (void) cobrowseActiveDidChangeTo:(BOOL)active;
@end


@protocol AssistSDKDocumentDelegate <NSObject>
@optional
- (void) assistSDKDidOpenDocument:(NSNotification*)notification;
- (void) assistSDKUnableToOpenDocument:(NSNotification*)notification;
- (void) assistSDKDidCloseDocument:(NSNotification*)notification;
@end


@interface AssistSDK : UIViewController <
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    AssistSDKAnnotationDelegate,
    AssistSDKDocumentDelegate>

+ (instancetype)sharedInstance;

@property (atomic) BOOL appActive;

/*!
 * Starts an Assist SDK support session. Unlike the generic "startSupport" method, this call does not set any of the optional parameters.
 * @param server The Assist server to use for the session. This can be just the name (or IP address) of the server or a URL
 * without a path (The URL is just used to specify the protocol and port. An example is: https://demoserver.test.com:8443 ).
 * @param destination The destination of the call. This could be an agent or queue name. It can also be a full sip URL.
 */
+ (AssistSDK*) startSupport: (NSString*) server destination: (NSString*) target;

/*!
 * Starts an AssistSDK support session.
 * @param server The Assist Server to use for this session. This can be just the name (or IP address) of the server or a URL
 * without a path (The URL is just used to specify the protocol and port. An example is: https://demoserver.test.com:8443 ).
 * @param supportParameters A NSDictionary used to specify required and optional parameters to be used by the Assist SDK.
 * Currently, these parameters are (for full details please refer to the developer guide):
 * - destination: The destination of the call. This could be an agent or queue name. It can also be a full sip URL).
 * - hidingTags: NSSet of tag numbers used to identify which UI elements should be obscured with a black rectangle on the agent side when screen
 *   sharing.
 * - maskingTags: NSSet of tag numbers used to identify which UI elements should be masked on the agent side when screen sharing.
 * - maskColor: UIColor The color to use when masking UI elements.
 * - correlationId: Used to map screensharing sessions that uses external audio/video.
 * - uui: A user to user header value to include in outbound SIP message for external correlation purposes
 * - acceptSelfSignedCerts: Indicates if we should accept self-signed security certificates or not. This takes the @NO or @YES objects. Absence of this
 *    attribute will automatically lead to the refusal of self-signed certificates.
 * - timeout: How long (approximatively) should we wait to establish the communication with the server before we give up in seconds. This argument should be expressed as a NSNumber, ideally of type float (for example it could be set with [NSNumber numberWithFloat:30.0]).
 * - sessionToken: a pre-created session ID that will be used to establish connections
 * - useCookies: NSNumber (@YES,@NO) - determine whether whether cookies set up to be sent to the Live Assist server should be sent on the web socket
 *   connection. Default is @NO.
 * - videoMode: Sets the video mode of a call (full, agentOnly or none). Default is full.
 * - keepAnnotationsOnChange: NSNumber (@YES,@NO)- Whether annotations are retained when the content behind them changes. Default is @NO.
 * - addSharedDocCloseLink: NSNumber (@YES, @NO) - Whether a close link should be added to a shared document. Default is @YES.
 * - screenShareRequestedDelegate: A delegate which conforms to the protocol ASDKScreenShareRequestedDelegate. Specifying this and conforming to this
 *   protocol allows an application to choose whether to accept or reject screen sharing however it sees fit.
 * - pushDelegate: A delegate which conforms to the protocol ASDKPushAuthorizationDelegate. Specifying this and conforming to this protocol allows
 *   an application to choose whether to accept or reject pushed content however it sees fit.
 */
+ (AssistSDK*) startSupport: (NSString*) server supportParameters: (NSDictionary*) config;

/*!
 * Ends the active Assist SDK support session if one is in progress. Otherwise has no affect.
 */
+ (void) endSupport;

/*!
 * The delegate is inspected to determine which, if any, Assist Delegate Protocols it supports.
 * If
*/

+ (BOOL) addDelegate:delegate;
+ (BOOL) removeDelegate:delegate;

+ (void) shareDocumentUrl:(NSString *) documentUrl addCloseLink:(bool) closeLink;
+ (void) shareDocument:(NSData *) content mimeType:(NSString *)mimeType addCloseLink:(bool) closeLink;

- (AssistStatus)status;

@end






