//
//   Copyright 2012 Square Inc.
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//

#import <Foundation/Foundation.h>
#import <Security/SecCertificate.h>

typedef NS_ENUM(NSInteger, ECSReadyState) {
    ECS_CONNECTING   = 0,
    ECS_OPEN         = 1,
    ECS_CLOSING      = 2,
    ECS_CLOSED       = 3,
};

typedef enum ECSStatusCode : NSInteger {
    ECSStatusCodeNormal = 1000,
    ECSStatusCodeGoingAway = 1001,
    ECSStatusCodeProtocolError = 1002,
    ECSStatusCodeUnhandledType = 1003,
    // 1004 reserved.
    ECSStatusNoStatusReceived = 1005,
    // 1004-1006 reserved.
    ECSStatusCodeInvalidUTF8 = 1007,
    ECSStatusCodePolicyViolated = 1008,
    ECSStatusCodeMessageTooBig = 1009,
} ECSStatusCode;

@class ECSWebSocket;

extern NSString *const ECSWebSocketErrorDomain;
extern NSString *const ECSHTTPResponseErrorKey;

#pragma mark - SRWebSocketDelegate

@protocol ECSWebSocketDelegate;

#pragma mark - SRWebSocket

@interface ECSWebSocket : NSObject <NSStreamDelegate>

@property (nonatomic, weak) id <ECSWebSocketDelegate> delegate;

@property (nonatomic, readonly) ECSReadyState readyState;
@property (nonatomic, readonly, retain) NSURL *url;

// This returns the negotiated protocol.
// It will be nil until after the handshake completes.
@property (nonatomic, readonly, copy) NSString *protocol;

// Protocols should be an array of strings that turn into Sec-WebSocket-Protocol.
- (id)initWithURLRequest:(NSURLRequest *)request protocols:(NSArray *)protocols;
- (id)initWithURLRequest:(NSURLRequest *)request;

// Some helper constructors.
- (id)initWithURL:(NSURL *)url protocols:(NSArray *)protocols;
- (id)initWithURL:(NSURL *)url;

// Delegate queue will be dispatch_main_queue by default.
// You cannot set both OperationQueue and dispatch_queue.
- (void)setDelegateOperationQueue:(NSOperationQueue*) queue;
- (void)setDelegateDispatchQueue:(dispatch_queue_t) queue;

// By default, it will schedule itself on +[NSRunLoop SR_networkRunLoop] using defaultModes.
- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
- (void)unscheduleFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;

// SRWebSockets are intended for one-time-use only.  Open should be called once and only once.
- (void)open;

- (void)close;
- (void)closeWithCode:(NSInteger)code reason:(NSString *)reason;

// Send a UTF8 String or Data.
- (void)send:(id)data;

// Send Data (can be nil) in a ping message.
- (void)sendPing:(NSData *)data;

@end

#pragma mark - ECSWebSocketDelegate

@protocol ECSWebSocketDelegate <NSObject>

// message will either be an NSString if the server is using text
// or NSData if the server is using binary.
- (void)webSocket:(ECSWebSocket *)webSocket didReceiveMessage:(id)message;

@optional

- (void)webSocketDidOpen:(ECSWebSocket *)webSocket;
- (void)webSocket:(ECSWebSocket *)webSocket didFailWithError:(NSError *)error;
- (void)webSocket:(ECSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
- (void)webSocket:(ECSWebSocket *)webSocket didReceivePong:(NSData *)pongPayload;

@end

#pragma mark - NSURLRequest (CertificateAdditions)

@interface NSURLRequest (CertificateAdditions)

@property (nonatomic, retain, readonly) NSArray *ECS_SSLPinnedCertificates;

@end

#pragma mark - NSMutableURLRequest (CertificateAdditions)

@interface NSMutableURLRequest (CertificateAdditions)

@property (nonatomic, retain) NSArray *ECS_SSLPinnedCertificates;

@end

#pragma mark - NSRunLoop (SRWebSocket)

@interface NSRunLoop (ECSWebSocket)

+ (NSRunLoop *)ECS_networkRunLoop;

@end
