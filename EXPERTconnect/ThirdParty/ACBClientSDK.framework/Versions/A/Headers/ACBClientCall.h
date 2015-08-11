#import <Foundation/Foundation.h>

#import "ACBView.h"

/**
 Call status changes: they can only increase the value.

 Outgoing calls and incoming OFFER_REQUESTs:
 Setup --> MediaOpened (not notified to user) --> Connecting (not notified to user) --> MediaPending --> (Ringing) -->InCall -->Ended

 Incoming calls:
 Setup --> Alerting --> (not "Connecting") -- > MediaPending --> InCall --> Ended

 Beware: these values are in order of progress, so that it is possible to check that the status is somewhere between a min and a max (e.g. Setup and InCall).
 */
typedef enum
{
    /** Indicates the call is in a process of being setup. */
    ACBClientCallStatusSetup,
    /** Indicates the call is ringing/alerting locally - incoming call. */
    ACBClientCallStatusAlerting,
    /** Indicates the call is ringing on the remote side - outgoing call. */
    ACBClientCallStatusRinging,
    /** Indicates the call is connected and we're waiting for media streams to establish. */
    ACBClientCallStatusMediaPending,
    /** Indicates the call is in progress including media. */
    ACBClientCallStatusInCall,
    /** Indicates the dialled operation timed out. */
    ACBClientCallStatusTimedOut,
    /** Indicates the dialled number is busy. */
    ACBClientCallStatusBusy,
    /** Indicates the dialled number was unreachable. */
    ACBClientCallStatusNotFound,
    /** Indicates the call has errored. */
    ACBClientCallStatusError,
    /** Indicates the call has ended. */
    ACBClientCallStatusEnded
}
ACBClientCallStatus;

typedef enum
{
    /** Indicates that a general error has occurred when making an outgoing call. */
    ACBClientCallErrorDialFailure,
    /** Indicates that a general error has occurred with an established call. */
    ACBClientCallErrorCallFailure,
    /** Indicates that the call was in the wrong state when an answer has been received. */
    ACBClientCallErrorWrongStateWhenAnswerReceived,
    /** Indicates that a session description could not be created. */
    ACBClientCallErrorSessionDescriptionCreationError,
}
ACBClientCallErrorCode;


@class ACBClientCall;

/**
 The call's delegate.
 */
@protocol ACBClientCallDelegate <NSObject>

@required

/**
 A callback notification indicating that a new SDP offer has been received and has switched on or off audio
 and/or video streaming. The callback is not optional, as further action is required when audio or video are
 re-enabled, i.e. deciding whether to un-mute them, as they are automatically kept muted by the API.

 @param call The call that received the media change.
 */
- (void) callDidReceiveMediaChangeRequest:(ACBClientCall*)call;

/**
 A callback notification indicates the call has changed state.

 @param call The call
 @param status The status of the call
 */
- (void) call:(ACBClientCall*)call didChangeStatus:(ACBClientCallStatus)status;


@optional

/**
 Callback indicating that an outgoing call failed to dial.
 
 @param call The call that received the error.
 @param message A descriptive message for the error.
 */
- (void) call:(ACBClientCall*)call didReceiveDialFailure:(NSString *)message __deprecated;

/**
 Callback indicating that that an established call is reporting an error.
 
 @param call The call that received the error.
 @param message A descriptive message for the error.
 */
- (void) call:(ACBClientCall*)call didReceiveCallFailure:(NSString *)message __deprecated;

/**
 Callback indicating that an outgoing call failed to dial.
 
 @param call The call that received the error.
 @param error The error that has occurred.
 */
- (void) call:(ACBClientCall*)call didReceiveDialFailureWithError:(NSError*)error;

/**
 Callback indicating that that an established call is reporting an error.
 
 @param call The call that received the error.
 @param error The error that has occurred.
 */
- (void) call:(ACBClientCall*)call didReceiveCallFailureWithError:(NSError*)error;

/**
 Callback indicating that the application did not have permission to record the media required for the call.
 
 @param message A descriptive message for the error.
 */
- (void) call:(ACBClientCall*)call didReceiveCallRecordingPermissionFailure:(NSString *)message;

/**
 A callback notification indicates the remote party display name has changed.

 @param call The call
 @param name Remote display name
 */
- (void) call:(ACBClientCall*)call didChangeRemoteDisplayName:(NSString*)name;

/**
 A callback notification indicating that the local media stream was added.

 @param call The call
 */
- (void) callDidAddLocalMediaStream:(ACBClientCall *)call;

/**
 A callback notification indicating that the remote media stream was added.

 @param call The call
 */
- (void) callDidAddRemoteMediaStream:(ACBClientCall *)call;

/**
 A callback notification indicating that a new SDP offer has been received and will switch on or off audio
 and/or video streaming. The callback is optional, as no action is required when audio or video are
 still to be re-enabled; here the application has the chance to check the status of audio and video before the change

 @param call The call that will receive the media change.
 */
- (void) callWillReceiveMediaChangeRequest:(ACBClientCall*)call;

/**
 A callback notification to indicate that the current perceived quality of the incoming streams has changed.

 @param call The call.
 @param inboundQuality The quality of the stream between 0 and 100, where 100 is best quality.
 */
- (void) call:(ACBClientCall*)call didReportInboundQualityChange:(NSUInteger)inboundQuality;

@end

/**
 An object that represents a voice and/or video call.
 */
@interface ACBClientCall : NSObject

/** The delegate. */
@property (weak) id<ACBClientCallDelegate> delegate;
/** The call status. */
@property (readonly) ACBClientCallStatus status;
/** The remote address of the call. */
@property (nonatomic, readonly) NSString *remoteAddress;
/** The remote party's display name */
@property (nonatomic, readonly) NSString *remoteDisplayName;
/** The UIView for displaying the video streaming */
@property (strong) ACBView* videoView;
/** YES if the remote party SDP has audio */
@property (readonly) BOOL hasRemoteAudio;
/** YES if the remote party SDP has video */
@property (readonly) BOOL hasRemoteVideo;
/** custom call information... subject ot change */
@property (readonly) NSDictionary *information;

/**
 Answers an incoming call.

 @param audio Whether to use audio.
 @param video Whether to use video.
 */
- (void) answerWithAudio:(BOOL)audio video:(BOOL)video;

/**
 Enables or disables local streams.

 @param isAudioEnabled Whether local audio should be enabled.
 */
- (void) enableLocalAudio:(BOOL)isAudioEnabled;

/**
 Enables or disables local streams.

 @param isVideoEnabled Whether local video should be enabled.
 */
- (void) enableLocalVideo:(BOOL)isVideoEnabled;

/**
 Plays DTMF tones

 Use this method to send DTMF on an active call. Valid codes are 0-9, #, *, A, B, C and D.

 @param code The DTMF tone(s) to play.
 @param localPlayback Whether the tone sound should be echoed back to the user.
 */
- (void) playDTMFCode:(NSString*)code localPlayback:(BOOL)localPlayback;

/**
 Terminates a call

 Call this method to end a call.
 */
- (void) end;

/**
 Holds the call

 In order to place a call on hold, call this method once the call has a status of ACBClientCallStatusInCall.
 */
- (void) hold;

/**
 Resumes the held call

 After a call has been placed on hold, use this method to resume the call.
 */
- (void) resume;

@end
