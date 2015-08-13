
#import <Foundation/Foundation.h>
#import <AVFoundation/AVCaptureDevice.h>
#import "ACBClientCall.h"

@class ACBClientPhone;

/** A set of possible resolutions. Not all may be supported on the user's device. */
typedef enum
{
    /** Automatic resolution. */
    ACBVideoCaptureResolutionAuto,
    /** CIF resolution. */
    ACBVideoCaptureResolution352x288,
    /** VGA resolution. */
    ACBVideoCaptureResolution640x480,
    /** 720p resolution. */
    ACBVideoCaptureResolution1280x720
}
ACBVideoCaptureResolution;

/**
 An  object that represents a resolution and frame rate. An NSArray of these objects is returned from the recommendedCaptureSettings method.
 */
@interface ACBVideoCaptureSetting : NSObject

/** The capture resolution. */
@property (readonly) ACBVideoCaptureResolution resolution;
/** The capture frame rate. */
@property (readonly) NSUInteger frameRate;

/**
 Converts a ACBVideoCaptureResolution enum into the width and height for that resolution. Note that this doesn't take orientation into account and will always return landscape values.
 
 @param resolution The resolution to convert.
 @return a CGSize containing the resolution's width and height
 */
+ (CGSize) sizeForVideoCaptureResolution:(ACBVideoCaptureResolution)resolution;

@end

/**
 The phone's delegate.
 */
@protocol ACBClientPhoneDelegate <NSObject>

@required

/**
 A notification to indicate an incoming call.
 
 @param phone The phone receiving the call.
 @param call The incoming call.
 */
- (void) phone:(ACBClientPhone*)phone didReceiveCall:(ACBClientCall*)call;

@optional

/**
 A notification that video is being captured at a specified resolution and frame-rate. Depending on the capabilities of the device, these settings may be different from the preferred resolution and framerate set on the phone.
 
 @param phone The phone object.
 @param settings The new capture settings.
 @param camera The capturing camera.
 */
- (void) phone:(ACBClientPhone*)phone didChangeCaptureSetting:(ACBVideoCaptureSetting*)settings forCamera:(AVCaptureDevicePosition)camera;

@end

/**
 An object that acts as the entry point for all voice and video calls.
 */
@interface ACBClientPhone : NSObject

/** The delegate. */
@property (weak) id<ACBClientPhoneDelegate> delegate;
/** An array of calls that are currently in progress. */
@property (readonly) NSArray* currentCalls;
/** The UIView for displaying the preview image */
@property (strong) ACBView* previewView;
/** The preferred capture resolution. If no preferred resolution is specified, the best SD resolution that the device is capable of will be chosen. */
@property ACBVideoCaptureResolution preferredCaptureResolution;
/** The preferred capture framerate. If no preferred frame rate is specified, the best frame rate that the device is capable of will be chosen. */
@property NSUInteger preferredCaptureFrameRate;

/**
 Creates a call to the given remote address.
 
 A call must be created with media e.g. audio or video or both.
 
 @param address The remote address.
 @param audio Whether to use audio.
 @param video Whether to use video.
 @param delegate The call delegate.
 @return ACBClientCall Successfully created call object
 */
- (ACBClientCall *) createCallToAddress:(NSString*)address audio:(BOOL)audio video:(BOOL)video delegate:(id<ACBClientCallDelegate>)delegate;

#if TARGET_OS_IPHONE
/**
 Sets the orientation of the video being sent.
 
 @param orientation The orientation of the video to be sent.
 */
- (void) setVideoOrientation:(UIInterfaceOrientation)orientation;
#endif

/**
 Sets the camera to use as the video source.
 
 @param camera The camera to use as the video source.
 */
- (void) setCamera:(AVCaptureDevicePosition)camera;
/**
 Returns an array of ACBVideoCaptureSetting objects that represent the recommended resolutions and frame-rates that the device is capable of. Settings are ordered from highest resolution to lowest resolution.
 
 @return recommended resolutions and frame-rates.
 */
- (NSArray*) recommendedCaptureSettings;

/**
 Requests the user's permission to access the microphone and/or camera.
 
 Microphone and camera permissions in iOS function at an application-level and not per-call. Therefore this method should typically be
 called before making or receiving calls.
 
 An individual alert will be displayed for each requested permission. The alert will be displayed the first time you call 
 this method. Subsequent calls will not display an alert unless you have reset your privacy settings in iOS Settings. This method 
 is asynchronous and will return before the alerts have been answered.
 
 This method defers to AVCaptureDevice requestAccessForMediaType - please see the iOS Developer Library for further information.
 
 @param audio request permission to use the microphone.
 @param video request permission to use the camera.
 */
+ (void)requestMicrophoneAndCameraPermission:(BOOL)audio video:(BOOL)video;

@end
