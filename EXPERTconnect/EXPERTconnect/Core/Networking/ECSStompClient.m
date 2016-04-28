//
//  ECSStompClient.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSStompClient.h"

#import "ECSChatMessage.h"

#import "ECSJSONSerializing.h"
#import "ECSJSONSerializer.h"
#import "ECSLog.h"
#import "ECSWebSocket.h"

static NSString * const kStompVersion = @"1.2";

static NSString * const kStompConnect = @"CONNECT";
static NSString * const kStompConnected = @"CONNECTED";
static NSString * const kStompSend = @"SEND";
static NSString * const kStompSubscribe = @"SUBSCRIBE";
static NSString * const kStompUnsubscribe = @"UNSUBSCRIBE";
static NSString * const kStompAck = @"ACK";
static NSString * const kStompNack = @"NACK";
static NSString * const kStompBegin = @"BEGIN";
static NSString * const kStompCommit = @"COMMIT";
static NSString * const kStompAbort = @"ABORT";
static NSString * const kStompDisconnect = @"DISCONNECT";
static NSString * const kStompMessage = @"MESSAGE";
static NSString * const kStompReceipt = @"RECEIPT";
static NSString * const kStompError = @"ERROR";

NSString *authToken; // Local stored copy of the authToken.

int         _clientHeartbeatInterval;
NSTimer *   _clientHeartbeatTimer;

@implementation ECSStompFrame

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.headers = [NSMutableDictionary new];
        _clientHeartbeatInterval = 0;
        _clientHeartbeatTimer = nil;
    }
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"CMD: %@\nHeaders: %@\nBody: %@", self.command, self.headers, self.body];
}

@end

@interface ECSStompClient() <ECSWebSocketDelegate>

@property (strong, nonatomic) ECSWebSocket *webSocket;
@property (strong, nonatomic) NSURL *hostURL;

@property (strong, nonatomic) NSMutableDictionary *subscribers;

@end

@implementation ECSStompClient

@synthesize authToken;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.subscribers = [NSMutableDictionary new];
        authToken = @"";
    }
    
    return self;
}

- (void)dealloc
{
    [_clientHeartbeatTimer invalidate]; 
    [self.subscribers removeAllObjects];
}

- (void)connectToHost:(NSString*)host
{
    self.hostURL = [NSURL URLWithString:host];
    self.webSocket = [[ECSWebSocket alloc] initWithURL:self.hostURL];
    self.webSocket.delegate = self;
    [self.webSocket open];
}

- (void)reconnect
{
    if (self.hostURL)
    {
        self.webSocket = [[ECSWebSocket alloc] initWithURL:self.hostURL];
        self.webSocket.delegate = self;
        [self.webSocket open];
    }
}
- (void)sendConnectToHost:(NSString*)host
{
    NSAssert(host, @"Host must not be nil");
    
    NSDictionary *headers = @{
                              @"accept-version": kStompVersion,
                              @"host": host,
                              @"heart-beat": @"20000,20000"
                              };
    self.connected = NO;
    [self sendCommand:kStompConnect withHeaders:headers andBody:nil];
}

- (void)disconnect
{
    [_clientHeartbeatTimer invalidate];
    self.connected = NO;
    [self sendCommand:kStompDisconnect withHeaders:nil andBody:nil];
}

- (void)setAuthToken:(NSString *)token {
    authToken = token;
}

- (void)subscribeToDestination:(NSString*)destination
            withSubscriptionID:(NSString*)subscriptionID
                    subscriber:(__weak id<ECSStompDelegate>)subscriber
{
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    headers[@"id"] = subscriptionID;
    headers[@"destination"] = destination;
    headers[@"ack"] = @"client";
    headers[@"persistent"] = @"true";
    if(authToken)
    {
        headers[@"x-humanify-auth"] = authToken;
    }
    
    self.subscribers[subscriptionID] = subscriber;
    [self sendCommand:kStompSubscribe withHeaders:headers andBody:nil];
}

- (void)unsubscribe:(NSString*)subscriptionID
{
    NSDictionary *headers = @{
                              @"id": subscriptionID,
                              };
    if (self.subscribers[subscriptionID])
    {
        [self.subscribers removeObjectForKey:subscriptionID];
    }
    
    [self sendCommand:kStompUnsubscribe withHeaders:headers andBody:nil];
}

- (void)sendAckForMessage:(NSString*)messageId andTransaction:(NSString*)transactionId
{
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] initWithDictionary:@{@"id": messageId}];
    if (transactionId)
    {
        headers[@"transaction"] = transactionId;
    }
    
    [self sendCommand:kStompAck withHeaders:headers andBody:nil];
}

- (void)sendNackForMessage:(NSString*)messageId andTransaction:(NSString*)transactionId
{
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] initWithDictionary:@{@"id": messageId}];
    if (transactionId)
    {
        headers[@"transaction"] = transactionId;
    }
    
    [self sendCommand:kStompNack withHeaders:headers andBody:nil];
}

- (void)startTransaction:(NSString*)transactionId
{
    NSDictionary *headers = @{
                              @"transaction": transactionId
                              };
    [self sendCommand:kStompBegin withHeaders:headers andBody:nil];
}

- (void)commitTransaction:(NSString*)transactionId
{
    NSDictionary *headers = @{
                              @"transaction": transactionId
                              };
    [self sendCommand:kStompCommit withHeaders:headers andBody:nil];
}

- (void)abortTransaction:(NSString*)transactionId
{
    NSDictionary *headers = @{
                              @"transaction": transactionId
                              };
    [self sendCommand:kStompAbort withHeaders:headers andBody:nil];
}

- (void)sendMessage:(NSString *)message
      toDestination:(NSString*)destination
        contentType:(NSString*)contentType
  additionalHeaders:(NSDictionary *)additionalHeaders
{
    NSAssert(destination, @"destination must exist");
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    headers[@"destination"] = destination;
    if (contentType)
    {
        headers[@"content-type"] = contentType;
    }
    if(authToken)
    {
        headers[@"x-humanify-auth"] = authToken;
    }
    
    if (additionalHeaders)
    {
        [headers addEntriesFromDictionary:additionalHeaders];
    }
    
    [self sendCommand:kStompSend withHeaders:headers andBody:message];
}

- (void)sendCommand:(NSString*)command withHeaders:(NSDictionary*)headers andBody:(NSString*)body
{
    NSMutableString *frame = [NSMutableString stringWithFormat:@"%@\n", command];
    if (headers)
    {
        NSMutableString *headerString = [NSMutableString new];
        for (NSString *key in headers.allKeys)
        {
            NSString *value = [self encodeStringEscapingCharacters:headers[key]];
            [headerString appendFormat:@"%@:%@\n", key, value];
        }
        [frame appendString:headerString];
    }
    
    [frame appendString:@"\n"];
    
    if (body)
    {
        [frame appendString:body];
    }
    
    [frame appendString:@"\x00"];
    
    ECSLogVerbose(@"STOMP:\n\n%@\n\n", frame);
    [self.webSocket send:frame];
}

#pragma mark - Websocket Callbacks

- (void)webSocketDidOpen:(ECSWebSocket *)webSocket
{
    ECSLogVerbose(@"Web socket did open");
    [self sendConnectToHost:self.hostURL.host];
}

- (void)webSocket:(ECSWebSocket *)webSocket didFailWithError:(NSError *)error
{
    ECSLogError(@"Chat connection failed with error %@", error);
    
    if (error.code == 57) { // "Socket is not connected."
        ECSLogError(@"Attempting to reconnect STOMP connection...");
        [self reconnect];
    }
}

- (void)webSocket:(ECSWebSocket *)webSocket didReceiveMessage:(id)message
{
    ECSLogVerbose(@"WS Message: %@", message);
    ECSStompFrame *frame = [self decodeFrame:message];
    
    ECSLogVerbose(@"Frame is: %@", frame);
    
    // TODO: Commented out until 5.3!!!
    // Check for, and update heart-beat if applicable
    if (frame.headers && frame.headers[@"heart-beat"]) {
        [self updateHeartbeatFromHeader:frame.headers[@"heart-beat"]];
    }
    
    if ([frame.command isEqualToString:kStompConnected])
    {
        self.connected = YES;
        if ([self.delegate respondsToSelector:@selector(stompClientDidConnect:)])
        {
            [self.delegate stompClientDidConnect:self];
        }
    }
    else if ([frame.command isEqualToString:kStompMessage])
    {
        [self processMessageFrame:frame];
    }
}

- (void)webSocket:(ECSWebSocket *)webSocket didReceivePong:(NSData *)pongPayload
{
    ECSLogVerbose(@"WS Pong: %@", pongPayload);
}

- (void)processMessageFrame:(ECSStompFrame*)frame
{
    if (!frame.headers) {
        NSLog(@"ERROR: Missing frame headers! Frame=%@", frame);
        return;
    }
    
    NSString *subscription = frame.headers[@"subscription"];
    if (subscription)
    {
        id<ECSStompDelegate> subscriber = self.subscribers[subscription];
        
        if (subscriber && [subscriber respondsToSelector:@selector(stompClient:didReceiveMessage:)])
        {
            [subscriber stompClient:self didReceiveMessage:frame];
            NSString *messageId = frame.headers[@"message-id"];
            if (messageId)
            {
                [self sendAckForMessage:messageId andTransaction:frame.headers[@"transaction"]];
            }
        }
        else
        {
            NSString *messageId = frame.headers[@"message-id"];
            if (messageId)
            {
                [self sendNackForMessage:messageId andTransaction:frame.headers[@"transaction"]];
            }
        }
    }
    else
    {
        NSString *messageId = frame.headers[@"message-id"];
        if (messageId)
        {
            [self sendNackForMessage:messageId andTransaction:frame.headers[@"transaction"]];
        }
    }
}
#pragma mark - Frame encoding

- (ECSStompFrame*)decodeFrame:(NSString*)frameData
{
    NSArray *frameComponents = [frameData componentsSeparatedByString:@"\n"];
    
    ECSStompFrame *frame = [ECSStompFrame new];
    if (frameComponents.count > 0)
    {
        frame.command = [frameComponents[0] copy];
        
        int i = 1;
        for (i = 1; i < frameComponents.count ; i++)
        {
            NSString *component = frameComponents[i];
            if (component.length == 0)
            {
                break;
            }
            
            NSArray *headerComponents = [component componentsSeparatedByString:@":"];
            if (headerComponents.count == 2)
            {
                NSString *key = [self decodeStringWithEscapedCharacters:headerComponents[0]];
                NSString *value = [self decodeStringWithEscapedCharacters:headerComponents[1]];
                
                frame.headers[key] = value;
            }
            else
            {
                ECSLogWarn(@"Frame is missing header components.");
            }
            
        }
        
        i = i + 1; // Skip newline separator
        
        int j;
        NSMutableString *bodyString = [[NSMutableString alloc] init];
        for (j = i ; i < frameComponents.count ; i++) {
            [bodyString appendString:[frameComponents[i] stringByReplacingOccurrencesOfString:@"\x00" withString:@""]];
        }
        frame.body = [NSString stringWithString:bodyString];
        
        // Before the Spring 1.3.x upgrade, we expected the entire body JSON to be on one line (no linebreaks within). 
        /*if (i < frameComponents.count)
        {
            frame.body = [frameComponents[i] stringByReplacingOccurrencesOfString:@"\x00" withString:@""];;
        }*/
    }
    
    return frame;
}

- (NSString*)encodeStringEscapingCharacters:(NSString*)header
{
    NSString *encodedString = [header stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@":" withString:@"\\c"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];

    return encodedString;
}

- (NSString*)decodeStringWithEscapedCharacters:(NSString*)encocdedString
{
    NSString *decodedString = [encocdedString stringByReplacingOccurrencesOfString:@"\\c" withString:@":"];
    decodedString = [decodedString stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
    decodedString = [decodedString stringByReplacingOccurrencesOfString:@"\\r" withString:@"\r"];
    decodedString = [decodedString stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    
    return decodedString;
}

#pragma mark Client Heartbeating

-(void)updateHeartbeatFromHeader:(NSString *)theHeader
{
    // We have a heartbeat value to check.
    // Will look like:    0,0  or  5000,0  or  0,5000
    NSArray *parts = [theHeader componentsSeparatedByString:@","];
    
    // The second value indicates how often the server expects a heartbeat from the client.
    if(parts[1]) _clientHeartbeatInterval = [parts[0] intValue];
    
    // NOTE: This will test heartbeat regardless of server setting.
    //_clientHeartbeatInterval = 5000;
    
    // If server indicates it wants a heartbeat. Fire up the timer!
    if (_clientHeartbeatInterval > 0)
    {
        if(_clientHeartbeatTimer)
        {
            [_clientHeartbeatTimer invalidate];
        }
        _clientHeartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:(_clientHeartbeatInterval/1000)
                                                                 target:self
                                                               selector:@selector(doStompHeartbeat:)
                                                               userInfo:nil
                                                                repeats:YES];
    }
}

-(void)doStompHeartbeat:(NSTimer *)timer
{
    // Send a simple PING packet.
    if (self.webSocket.readyState == ECS_OPEN)
    {
        NSData *data = [NSData dataWithBytes:(unsigned char[]){0x0A} length:1];
        [self.webSocket sendPing:data];
    }
}

@end
