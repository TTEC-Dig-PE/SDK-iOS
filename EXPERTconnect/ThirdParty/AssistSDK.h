#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

typedef enum DocType : NSUInteger {
    PDF,
    Image,
    Link,
    Unknown
} DocType;

@protocol AssistSDKDelegate <NSObject>
@optional
- (void) cobrowseActiveDidChangeTo:(BOOL)active;
@end


@interface AssistSDK : NSObject <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
}

+ (AssistSDK*) startSupport: (NSString*) server destination: (NSString*) target;

/*!
 * Starts an AssistSDK support session.
 * @param server The Assist Server to use for this session. This can be just the name (or IP address) of the server or a URL
 * without a path (The URL is just used to specify the protocol and port. An example is: https://demoserver.test.com:8443 ).
 * @param supportParameters A NSDictionary used to specify required and optional parameters to be used by the Assist SDK.
 * Currently, these parameters are (for full details please refer to the developer guide):
 * - destination: The destination of the call. This could be an agent or queue name. It can also be a full sip URL).
 * - tag: NSSet of tag numbers used to identify which element of the storyboard should be hidden from the screen sharing.
 * - correlationId: Used to map screensharing sessions that uses external audio/video.
 * - uui: A user to user header value to include in outbound SIP message for external correlation purposes
 * - acceptSelfSignedCerts: Indicates if we should accept self-signed security certificates or not. This takes the @NO or @YES objects. Absence of this
 *    attribute will automatically lead to the refusal of self-signed certificates.
 * - timeout: How long (approximatively) should we wait to establish the communication with the server before we give up in seconds. This argument should be expressed as a NSNumber, ideally of type float (for example it could be set with [NSNumber numberWithFloat:30.0]).
 * - username: Associate a specific username/id to the client (instead of creating an anonymous one).
 * - sessionToken: a pre-created session ID that will be used to establish connections
 */
+ (AssistSDK*) startSupport: (NSString*) server supportParameters: (NSDictionary*) config;

/*!
 * Ends the active Assist SDK support session if one is in progress. Otherwise has no affect.
 */
+ (void) endSupport;
@end
