# EXPERTconnect SDK for iOS

The EXPERTconnect SDK for iOS provides an easy-to-integrate solution for adding TTec's omnichannel technology and journey management to your native mobile iOS app. The complicated wiring of these CX features are wrapped up in simple, reliable packaging that makes integration and deployment more efficient. 

The SDK offers two branches of the same feature set: 

1. Our UI-packaged, "high level" solution can be used for rapid prototyping and extremely easy implementation. A complete mobile chat experience can be built using 5-10 lines of code. Although this high level feature set has a range of customization, ultimately the general layouts will be restricted to what is provided here. 

2. Our API-wrapped, "low level" solution offers a lower to the ground but still efficient feature set. By using a set of delegates and callback functions, your app can respond to channel events. This allows your app designers to retain complete control of the user experience. Because the design is left in your hands, this does require more implementation by your app team (such as implementing the chat window, the chat bubbles, the buttons, and the flow) but ultimately will provide a much mroe personalized experience for your app users.

We highly recommend using approach #1 (high level) for a rapid prototype to test fit our SDK, then transitioning to #2 (low level) as you find resources to build out your own personalized UI. Examples of both methods are provided in our integrator example app found here: 

https://github.com/humanifydev/SDK-iOS-integrator

# Table of Contents

   * [EXPERTconnect SDK for iOS](#expertconnect-sdk-for-ios)
   * [Table of Contents](#table-of-contents)
   * [Installation](#installation)
      * [CocoaPods](#cocoapods)
      * [Carthage](#carthage)
      * [Manually](#manually)
         * [Embedded Framework](#embedded-framework)
   * [Supported Localizations](#supported-localizations)
   * [Usage](#usage)
      * [Setup](#setup)
      * [Authentication](#authentication)
      * [Debugging](#debugging)
   * [Chat](#chat)
      * [High-Level Chat](#high-level-chat)
         * [Customizing the Send Button](#customizing-the-send-button)
      * [Low-Level Chat](#low-level-chat)
         * [Starting a Chat](#starting-a-chat)
         * [Sending Messages](#sending-messages)
         * [Chat User Typing/Paused Events](#chat-user-typingpaused-events)
         * [Receiving Messages](#receiving-messages)
            * [Chat Text Messages](#chat-text-messages)
            * [Chat State Messages](#chat-state-messages)
         * [Disconnection](#disconnection)
         * [Reachability Event](#reachability-event)
         * [Chat State Updates](#chat-state-updates)
            * [Connected](#connected)
            * [Agent Answered](#agent-answered)
            * [Participant Join](#participant-join)
            * [Participant Leave](#participant-leave)
      * [Use-case specific Chat Features](#use-case-specific-chat-features)
         * [Customizing the view behavior for keyboard focus](#customizing-the-view-behavior-for-keyboard-focus)
         * [Getting Chat Skill Details](#getting-chat-skill-details)
         * [Chat Persistence](#chat-persistence)
         * [Customizing the chat Navigation Bar Buttons](#customizing-the-chat-navigation-bar-buttons)
         * [Retrieving Chat History](#retrieving-chat-history)
   * [Decision Engine](#decision-engine)
   * [Breadcrumbs](#breadcrumbs)
   * [Answer Engine](#answer-engine)
      * [High-Level](#high-level)
   * [Forms and Surveys](#forms-and-surveys)
      * [High-Level](#high-level-1)
         * [Show/Hide Form Submitted View](#showhide-form-submitted-view)
         * [Customizing the view behavior for keyboard focus](#customizing-the-view-behavior-for-keyboard-focus-1)
      * [Form Delegate Callbacks](#form-delegate-callbacks)
         * [answeredFormItem](#answeredformitem)
         * [submittedForm](#submittedform)
         * [closedWithForm](#closedwithform)
   * [Voice Callback](#voice-callback)
      * [High-Level](#high-level-2)
   * [Utility Functions](#utility-functions)
      * [Checking health of API Server](#checking-health-of-api-server)



# Installation

## CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate EXPERTconnect into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/Humanifydev/SDK-iOS-specs.git'
platform :ios, '9.1'
use_frameworks!

target '<Your Target Name>' do
    pod 'EXPERTconnect', '~> 6.4.0'
end
```

Then, run the following command:

```bash
$ pod install
```
## Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate EXPERTconnect into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "humanifydev/SDK-iOS" ~> 6.4.2
```

Run `carthage update` to build the framework and drag the built `EXPERTconnect.framework` into your Xcode project from the `Carthage\Build\iOS` subfolder.

## Manually

If you prefer not to use any of the aforementioned dependency managers, you can integrate EXPERTconnect into your project manually.

### Embedded Framework

- Open up Terminal, `cd` into your top-level project directory, and run the following command "if" your project is not initialized as a git repository:

  ```bash
  $ git init
  ```

- Add EXPERTconnect as a git [submodule](http://git-scm.com/docs/git-submodule) by running the following command:

  ```bash
  $ git submodule add https://github.com/humanifydev/SDK-iOS.git
  ```
    > Alternatively, you may download the SDK from this repo or may have received it as a .zip file. Save the contents of the .zip file in a desired location for 3rd party SDKs. 

- Open the new `EXPERTconnect` folder, and drag the `EXPERTconnect.xcodeproj` into the Project Navigator of your application's Xcode project.

    > It should appear nested underneath your application's blue project icon. Whether it is above or below all the other Xcode groups does not matter.

- Select the `EXPERTconnect.xcodeproj` in the Project Navigator and verify the deployment target matches that of your application target.
- Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
- In the tab bar at the top of that window, open the "General" panel.
- Click on the `+` button under the "Embedded Binaries" section.
- You will see two different `EXPERTconnect.xcodeproj` folders each with two different versions of the `EXPERTconnect.framework` nested inside a `Products` folder.

    > It does not matter which `Products` folder you choose from, but it does matter whether you choose the top or bottom `EXPERTconnect.framework`.

- Select the top `EXPERTconnect.framework` for iOS 

  > The `EXPERTconnect.framework` is automagically added as a target dependency, linked framework and embedded framework in a copy files build phase which is all you need to build on the simulator and a device.

# Supported Localizations
* English
* French
* Spanish
* Spanish (Mexico, Spain)
* German
* Chinese (Simplified)
* Portuguese (Brazil, Portugal)
* Dutch
* Swedish
* Danish
* Polish (Poland)
* Finnish
* Norwegian (Bokmal)

# Usage

## Setup

First, import the EXPERTconnect header file: 
```objc
#import <EXPERTconnect/EXPERTconnect.h>
```

Next, in a place called before any of our API functions (chat, decision engine, etc), initialize the SDK. Below is an example of minimal configuration: 

```objc
ECSConfiguration *configuration = [ECSConfiguration new];

configuration.host          = @"https://ce03.api.humanify.com";
configuration.appName       = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
configuration.appVersion    = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
configuration.appId         = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];

[[EXPERTconnect shared] initializeWithConfiguration:configuration];
```

## Authentication

Since we are dealing with private chats and potentially user profile information authentication between the Humanify API and the SDKs requires an identity delegate token. Please ask for more information if you have not already setup your IDT server.  Next, the SDK needs a callback function from your app to call when it needs to fetch a new token (usually on the initial API call or when the token expires). 

In your object file containing the token refreshing code, add the delegate prototype: 
```objc
@interface ViewController () <ECSAuthenticationTokenDelegate>
```
Next, add the token fetching function:

```objc
-(void) fetchAuthenticationToken:(void (^)(NSString *, NSError *))completion {

    // Get token here (usually by HTTP request)
    NSString *myToken = @"testToken";

    completion(myToken, nil);
    
}
```

Finally, in your EXPERTconnect SDK initialization code, make sure to set this object as the delegate: 
```objc
[[EXPERTconnect shared] setAuthenticationTokenDelegate:self]; 
```

In addition, if you have a token already in code (usually by calling your own token fetching block outside of the SDK doing so), you can input the token directly into the SDK: 
```objc
[[EXPERTconnect shared] setUserIdentityToken:@"MyTokenABC123"]; 
```

## Debugging

The SDK offers a callback function for all debug logging with 5 levels of verboseness. It is extremely helpful to integrate our debug into your logging for the purpose of troubleshooting issues with the SDK. The following is a simple example of NSLogging() our debug. This configuration would also work with popular remote debug aggregators like Critterism. The debug level can be modified during runtime. 

```objc

// Options: ECSLogLevel[None|Debug|Error|Verbose|Warning]
[[EXPERTconnect shared] setDebugLevel:ECSLogLevelVerbose];
    
[[EXPERTconnect shared] setLoggingCallback:^(ECSLogLevel level, NSString *message) {
        
    NSLog(@"[HMN SDK]: (%ld): %@", (long)level, message);
    
}];
```

# Chat

The EXPERTconnect SDK's primary feature is simple chat integration. This is a "live chat" style of conversation where two or more participants are active in the chat as long as it is open. There is an idle timeout (configurable, often 5 minutes) when no activity occurs by the user to ensure agents/associates are freed up to help other customers. Chats can persist in the background and do store-and-forward messages in the event of things like network hiccups, but the chats do not persist longer than the idle timeout. 

A standard implementation of low level chat would include the following steps: 

* Initialize the SDK
* On chat button tap, start a new chat session and launch a chat view. 
* Ensure your view is a delegate to the EXPERTconnect SDK chat actions. 
* Show "Agent X has joined" when delegate fires participant join callback.  
* Display agent messages when delegate fires for recieved message. 
* When user hits return on message input, use provided function to send out user's message. 
* Show "Chat ended" when disconnect callback fires or user ends the chat. 

An example of this can be found in the ECDSimpleChatViewController.m file in the SDK-iOS-Integrator repo. 

## High-Level Chat

High level chat is simple to use and extremely quick to get a prototype up and running. The following is the only line of code needed to start a chat after the SDK is initialized: 
```objc
[[EXPERTconnect shared] startChat:demoChatSkill
                  withDisplayName:demoUserName
                       withSurvey:NO]; 
```
* chatSkill - The chat skill to connect with. Often a group of agents. E.G. "premiumGermanSpeakingSupport"
* displayName - This string is displayed in the navigationItem title. 
* withSurvey - deprecated. Formerly for post-chat surveys, which are now handled separately. 

### Customizing the Send Button

The background color and tint color of the UIButton are customizable using theme options. These additional customizations facilitate the use of a graphic button with a transparent background. To change these values, edit the following theme values before chat is invoked:

```objc
// Modify the image of the send button
[EXPERTconnect shared].theme.chatSendButtonImage = [UIImage imageNamed:@"blue_chat_button"];

// Modify the background color
[EXPERTconnect shared].theme.chatSendButtonBackgroundColor = [UIColor clearColor];

// Modify the tint color (text)
[EXPERTconnect shared].theme.chatSendButtonTintColor = [UIColor redColor]; 
```

## Low-Level Chat
A term used for the API wrapper layer of chat code (no UI). This implementation is a flexible, simple API wrapper that takes care of a lot of chat websocket related operations for you. A few things that are taken care of for you: 

* Network loss/Reconnection - The SDK will make all effort to keep the chat connected until it is either ended by the user or by the agent. The SDK will re-authenticate tokens if they expire, it will detect network loss and attempt reconnects, and it will maintain a poll for reconnection if for any reason the network stays broken. 
* Stomp/Websocket - The websocket layer is completely wrapped and maintained by the SDK. Offered to the integrator is a much simpler, flexible set of callback functions for various state changes and chat operations. 
* JSON to Objects - API responses are converted into Cocoa style objects with well-documented and useful fields. For example, receiving a chat message from the agent provides an ECSChatTextMessage object with "from" and "body" included. 

### Starting a Chat
Starting a chat consists of constructing an ECSStompChatClient object, setting a delegate (usually your chat view controller), and invoking the startChatWithSkill function. 

```objc
    ECSStompChatClient *chatClient = [ECSStompChatClient new]; 
    chatClient.delegate = self; // to receive callback events. 
    
    [chatClient startChatWithSkill:@"MyAgentSkill" 
                           subject:"Warranty Chat" 
                        dataFields:nil]; 
```

The three parameters required are: 
* skill - The chat skill to connect with. Often a string provided by Humanify, such as "CustomerServiceReps" that contains a group of associates who recieve the chats.
* subject - This is displayed on the associate desktop client as text at the start of a chat.
* dataFields - These data fields can be used to provide extra information to the associate. Eg: { "userType": "student" }

In addition, you could start a chat with custom data fields. The (optional) parameter accepts a dictionary of key-value pairs which will be displayed in the details portion of the associate desktop client. 

Example:

```objc
    ECSStompChatClient *chatClient = [ECSStompChatClient new]; 
    chatClient.delegate = self; // to receive callback events. 
    
    [chatClient startChatWithSkill:@"MyAgentSkill" 
                           subject:"Warranty Chat" 
                        dataFields:nil
                          priority:kECSChatPriorityUseServerDefault
                        dataFields:@{@"subject":@"math", @"membertype": @"student"}]; 
```

Additional Parameters:  
* priority - Higher priority values will be passed to associates faster than lower ones. 
  * kECSChatPriorityUseServerDefault 
  * kECSChatPriorityLow
  * kECSChatPriorityNormal
  * kECSChatPriorityHigh
* fields - These data fields can be used to provide extra information to the associate. Eg:{ "userType": "student" } 

### Sending Messages
Assuming you have setup your ECSStompChatClient, connected, and subscribed to a Stomp channel...

    ECSStompChatClient *chatClient;
    
    [chatClient sendChatText:@"hello, world!" completion:^(NSString *response, NSString *error) {

        NSLog(@"Chat sent. Response=%@, Error=%@", response, error); 
    
    }];

### Chat User Typing/Paused Events
Chat state updates can tell the associate if the user is typing a message or has stopped. Both messages are manually sent by the host app. We recommend sending ECSChatStateComoposing when the user begins typing a message, starting a timer, and sending an ECSChatStateTypingPaused after a certain length of time, or when the user has deleted all of the text in the text box. The completion block on this call is not often needed. 

    ECSStompChatClient *chatClient; 
    
    [chatClient sendChatState:ECSChatStateComposing completion:nil]; 

### Receiving Messages
Messages will arrive via the ECSStompChatDelegate callbacks. There are a couple of different kinds of messages you can receive, detailed below. 

#### Chat Text Messages
Chat text messages are regular text sent from an associate or agent. The relevant fields are "from" and "body". From contains who sent the message, and body contains the message itself.

```objc
// An associate has sent a regular chat text message. The from field contains the userID, which should 
// match an AddParticipant previously received.
- (void) chatReceivedTextMessage:(ECSChatTextMessage *)message {
    
    [self appendToChatLog:[NSString stringWithFormat:@"%@: %@", message.from, message.body]];
}
```

#### Chat State Messages
Chat state messages let the SDK know if the agent has begun typing a new message (ECSChatStateComposing) or has stopped (ECSChatStateTypingPaused).  

```objc
// A chat state message has arrrived. Typically used to detect when the agent has started typing and 
// display that to the user.
- (void) chatReceivedChatStateMessage:(ECSChatStateMessage *)stateMessage {
    
    if (stateMessage.chatState == ECSChatStateComposing) {
        
        NSLog(@"Agent is typing...");
        
    } else if (stateMessage.chatState == ECSChatStateTypingPaused) {
        
        NSLog(@"Agent has stopped typing.");
        
    }
}
```

### Disconnection
The SDK can tell you when the chat has been disconnected from the server side, whether by an agent ending the chat or some kind of issue. 

```objc
// The chat was disconnected from the serve side. Typically because the associated ended the chat 
// or an idle timeout has occurred.
- (void) chatDisconnectedWithMessage:(ECSChannelStateMessage *)message {
    
    if ( message.disconnectReason == ECSDisconnectReasonIdleTimeout ) {
        
        NSLog(@"Server has timed out this chat.");
        
    } else if ( message.disconnectReason == ECSDisconnectReasonDisconnectByParticipant ) {
        
        NSLog(@"%@", [NSString stringWithFormat:@"Chat was ended by: %@", message.terminatedByString]);
        
    } else {
        
        NSLog(@"Chat was ended for an unknown reason");
        
    }
    
    [self.chatClient disconnect];
}
```

### Reachability Event
The chat object (ECSStompChatClient) will attempt to reconnect if it detects a network recovery and was previously connected to an active chat. This should happen automatically when the OS passes notification of a successful network recovery event.  
In addition, a function callback was added to allow your app to run code when the chat object detects network loss or recovery.

```objc
- (void) chatReachabilityEvent:(bool)reachable {
  NSLog(@"Network is reachable? %d", reachable); 
}
```

### Chat State Updates

Various delegate functions are called for chat state updates. 

#### Connected
```objc
// The WebSocket has connected to the server. This may be when you flip your view to the chat screen
// or dislpay a message to the user "connecting..."
- (void) chatDidConnect {
    NSLog(@"WebSocket has connected to the server.");
}
```

#### Agent Answered
```objc
// The chat has entered the "answered" state. In many cases this callback is not be needed,
// but you could say "an associate is connecting...". 
// Soon after, an "AddParticipant" message should arrive.
- (void) chatAgentDidAnswer {
    
    NSLog(@"An agent is joining this chat...");
}
```

#### Participant Join
```objc
// An associate has joined the chat. This contains their userID, name, and avatarURL. 
// Here is where you would typically display "John has joined the chat."
- (void) chatAddedParticipant:(ECSChatAddParticipantMessage *)participant {
    
    NSLog(@"%@", [NSString stringWithFormat:@"%@ %@ (%@) has joined the chat.", participant.firstName, participant.lastName, participant.userId]);
}
```

#### Participant Leave
```objc
// An associate has left the chat. This contains their userID, name, and avatarURL. 
// Here is where you would typically display "John has left the chat." 
// This might occur during a transfer. During a normal "associate disconnected", 
// a disconnect would soon follow.
- (void) chatRemovedParticipant:(ECSChatRemoveParticipantMessage *)participant {
    
    NSLog(@"%@", [NSString stringWithFormat:@"%@ %@ (%@) has left the chat.", participant.firstName, participant.lastName, participant.userId]);
}
```

## Use-case specific Chat Features

### Customizing the view behavior for keyboard focus

This option facilitates the correct shifting of content above the keyboard when including a SDK high level view as a subview with other views below it. The new option suppresses any shifting of the content inside of the SDK's view. This would prevent double-shifting behaviors, which could cause gaps and content to be hidden behind other content. If your "outer" view already shifts any subviews upward, you would want to set the "shiftUpForKeyboard" boolean to NO.  

Example:  

```objc
ECSChatViewController *chatController; 
chatController.shiftUpForKeyboard = NO; 
```

### Getting Chat Skill Details 
The details of a chat or callback skill (such as estimated wait, chatReady, queueOpen) can be retrieved using the "getDetailsForExpertSkill" function. Example: 

```objc
  [[EXPERTconnect shared] getDetailsForExpertSkill:skillName
      completion:^(ECSSkillDetail *details, NSError *error)
  {
      NSLog(@"Estimated wait seconds: %@", details.estWait); 
  }
```
Example can be found on line 161 of https://github.com/humanifydev/SDK-iOS-Integrator/blob/master/HumanifyDemo/ViewController.m
  
The ECSSkillDetail object contains the following fields:
* active - Whether this skill queue is active or not.
* chatCapacity - Maximum capacity of agents this skill can contain.
* chatReady - Number of agents who are ready to accept chats.
* description - Text description of this skill
* estWait - The estimated wait time to get connected (seconds)
* inQueue - Is this particular user in the queue already?
* queueOpen - Is the queue open or closed?
* skillName - Name of the skill
* voiceCapacity - Maximum capacity of agents who can take voice calls.
* voiceReady - Current number of agents ready to accept calls.

### Chat Persistence 
The integrator demo app does give an example of a persistent chat experience. By persistence, this means that the user can navigate to other views within the app and still remain connected to the chat. They can return later to see the updated messages.  

Example can be found on lines 185-285 of https://github.com/humanifydev/SDK-iOS-Integrator/blob/master/HumanifyDemo/ViewController.m 

In a nutshell, the navigation of the view can be overriden by either not using standard navigation bar controls (your app would be in control), or by overriding the left and right buttons yourself (as we have done in our demo app, seen on line 205-211). 

If you want to do a "navigate away", simply pop the ECSChatViewController object off the stack (but do NOT deallocate it). 

If you want to provide an "exit chat" behavior, issue the ```objc[ECSChatViewController endChatByUser]``` function. 

Example: 
```objc
_chatController = (ECSChatViewController *)[[EXPERTconnect shared] startChat:demoChatSkill
                                                                 withDisplayName:demoUserName
                                                                  withSurvey:NO
                                                          withChannelOptions:@{@"userType":@"student"}];

 // OVERRIDING TOP NAVIGATION BUTTONS //
 // This code shows how you can override the top navigation bar buttons in the chat view with your own.

UIBarButtonItem *lButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(chatBackPushed:)];

UIBarButtonItem *rButton = [[UIBarButtonItem alloc] initWithTitle:@"End Chat"
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(chatEndChatPushed:)];

_chatController.navigationItem.leftBarButtonItem = lButton;
_chatController.navigationItem.rightBarButtonItem = rButton;
```

### Customizing the chat Navigation Bar Buttons

The integrator demo app also includes an example of customizing the top navigation bar buttons while using our high level (packaged UI) chat feature. The basic idea is that if the viewController we allocate detects navigation bar buttons already created by the host app (you), we will not touch the navigation bar area. 

In the integrator app, we have overriden these buttons to be a left "minimize chat" button and a right "exit chat" button. You can find the code here: 
https://github.com/humanifydev/SDK-iOS-Integrator/blob/master/HumanifyDemo/ViewController.m

The "minimize" button refers to the "chatBackPushed" function found at line 239. 

The "exit chat" button refers to "chatEndChatPushed" function found at line 253. 

From here, you can customize anything about the button as allowed by iOS - such as tintColor, image, font, etc.

### Retrieving Chat History
Added a new function for retrieving chat transcripts. ConversationID is the only input parameter and is optional. If a value is present, the function will return the transcript for the given conversationID. If left blank (nil), the function will return all conversation history for the current journeyID. The output is a completion block with an array of Humanify SDK chat message objects (ECSChatTextMessage, ECSChatStateMessage, etc).

Note: the current conversationID can be retrieved with:  
```objc
[EXPERTconnect shared].urlSession.conversation.conversationID; 
```
 
Example: 

```objc
NSString *conversationID = [EXPERTconnect shared].urlSession.conversation.conversationID; 

[[EXPERTconnect shared] 
    getTranscriptForConversation:conversationID
    withCompletion:^(NSArray *messages, NSError *error) { 
  if( ! error ) { 
    if( messages ) {  
          // Happy path. We have history data. 
      } else {
          // No history found.
      } 
  } else { 
    // An error retrieving history.  
  } 
}];
```

# Decision Engine

Humanify Decision Engine provides a method for rule processing from mobile apps & web. This enables complex use cases involving asking our servers questions based on a range of inputs, having the engine pull in data from a multitude of available sources, and returning a response (JSON) that can offer potential app behavior suggestions. 

For example, sending some user information may determine this is a "premium" user, and based on the configured rules, the decision engine will return "enable chat for this user" and "send this user to a premium chat skill". 

The way it works is by calling the makeDecision function with a NSDictionary object. The dictionary object is the array of key-value pair inputs to be processed by the server. The response will be in the form of a NSDictionary as well. Example below. 

This feature requires Humanify services to setup the rules on the server. 

```objc
NSDictionary *decisionDictionary = [[NSMutableDictionary alloc]
                                    initWithObjectsAndKeys:
                                    @"ce03", @"tenantId",
                                    @"HuSimple", @"projectServiceName",
                                    @"validateDE", @"eventId",
                                    @"hello ios world", @"inputString", nil];

[[[EXPERTconnect shared] urlSession] makeDecision:decisionDictionary
                                       completion:^(NSDictionary *decisionResponse, NSError *error) {
                                           
   if( !error ) {
       NSString *responseJson = [self JSONStringWithDictionary:decisionResponse];
       
       NSString *resp = [NSString stringWithFormat:@"Event was: %@.\nResponse is: %@",
                         decisionResponse[@"eventId"],
                         decisionResponse];
       
   } else {
       NSLog(@"Error: %@", error.description);
   }
}];
```

# Breadcrumbs

Sending breadcrumbs to Humanify allows the Humanify Journey Manager solution to track user behavior and provide a complete journey picture. This enables JM to make decisions and provide feedback on how to provide better or more specific customer support to this particular user. Breadcrumbs contain 4 data fields with no specific meaning in each, but typically the first and second fields are used to help categorize the breadcrumbs (e.g. "pageview" or "login" or "cart_operation"). 

Sent breadcrumbs provide an echo'ed response for validation, but it is optional to receive this. It is not unusual to send the breadcrumb and have NIL for completion, since no operation is disrupted by a breadcrumb failing to send. 

```objc
ECSBreadcrumb *myBreadcrumb = [[ECSBreadcrumb alloc] initWithAction:@"Data Field 1"
                                                        description:@"Data Field 2"
                                                             source:@"Data Field 3"
                                                        destination:@"Data Field 4"];

[[EXPERTconnect shared] breadcrumbSendOne:myBreadcrumb
                           withCompletion:^(ECSBreadcrumbResponse *response, NSError *error) {
    NSLog(@"Breadcrumb sent.");
}];
```

# Answer Engine

Answer Engine is a FAQ-style knowledge base UI and API feature. Humanify will plugin one of many supported knowledge base providers which can then feed this feature content. Most KB providers divide content up by "context", which is the first parameter of this function. Context is like grabbing a book from the library. All queries and top-10 displays will be pulled from this book (as opposed to the entire library). This is often used in scenarios where a user clicks "Help" or "FAQ" on a specific view of the app (such as "Warranty Information" or "Diet Needs"). 

## High-Level 

In the high level mode, the SDK will handle all of the API calls and all of the UI on the knowledge base view. There is a search box and users can click among the articles. Most pages have "related articles" and the view begins by showing a "top ten" articles. 

```objc
UIViewController *answerController = [[EXPERTconnect shared] startAnswerEngine:@"park"
                                                               withDisplayName:@"Humanify FAQ"];

[self.navigationController pushViewController:answerController animated:YES];
```

# Forms and Surveys

EXPERTconnect SDK provides a complete UI and API wrapper for displaying forms & surveys within your mobile app. These forms are configured on the Humanify servers using Form Designer (by our support team, or in the future, by you if desired). Once configured, it's a simple matter of providing the form name to the API and displaying the view. 

In low-level mode, the API will return form elements and submission data and you will have to display each element and call the API to submit the form at the end. 

## High-Level

Accessibility - The high level form view supports the iOS "voiceover" accessibility feature. The view should read the display in order, highlight form fields as "buttons", and set focus to the question text when the user navigates to the next or previous item.

```objc
ECSFormViewController *formsController;
formsController = (ECSFormViewController *)[[EXPERTconnect shared] startSurvey:demoFormName];
formsController.delegate = self;

[self.navigationController pushViewController:formsController animated:YES];
```

### Show/Hide Form Submitted View

```objc
// If true, will show the "form submitted" page after last question is answered. False will do nothing. Set to false if you want to customize the transition after the survey is answered straight on to another view. 
formsController.showFormSubmittedView; 
```

### Customizing the view behavior for keyboard focus

This option facilitates the correct shifting of content above the keyboard when including a SDK high level view as a subview with other views below it. The new option suppresses any shifting of the content inside of the SDK's view. This would prevent double-shifting behaviors, which could cause gaps and content to be hidden behind other content. If your "outer" view already shifts any subviews upward, you would want to set the "shiftUpForKeyboard" boolean to NO.  

Examples:  

```objc
ECSFormViewController *formController; 
formController.shiftUpForKeyboard = NO; 
```

## Form Delegate Callbacks

### answeredFormItem
```objc
- (void) ECSFormViewController:(ECSFormViewController *)formVC
              answeredFormItem:(ECSFormItem *)item
                       atIndex:(int)index {
    
    NSLog(@"User answered question %d with result: %@", index, item.formValue);
    
}
```

### submittedForm

```objc
/*!
 @brief User has submitted a form
 @discussion Invoked when the user has navigated forwad on the last question in the form, and the form has been submitted to the Humanify server. This can be used to perform actions after a form is completed.
 @param formVC The ViewController object
 @param form The form object containing each form element and potentially the user's answers to each item.
 @param name The form name
 @param error If an error occurred submitting the form
 */
- (void) ECSFormViewController:(ECSFormViewController *)formVC
                 submittedForm:(ECSForm *)form
                      withName:(NSString *)name
                         error:(NSError *)error {
    
    NSLog(@"User submitted the form.");
    
}
```

### closedWithForm

```objc
/*!
 @brief User has clicked close in the form submitted view
 @discussion Invoked when the user clicks the Close button on the form submitted view. If your code contains this function, the ViewController will perform no action after the user clicks close. The transitioning and navigation stack manipulation will be left up to you. This can be used to override behavior after a form is completed, such as moving straight into another high-level feature of the SDK.
 @param formVC The ViewController object
 @param form The form object containing each form element and potentially the user's answers to each item.
 @returns True - SDK will proceed to animate and dismiss the view. False - no further action. You will be responsible for transitions and navigation stack.
 */
- (bool) ECSFormViewController:(ECSFormViewController *)formVC
                closedWithForm:(ECSForm *)form {
    
    NSLog(@"User closed the form view.");
    
    return YES;
    
}
```

# Voice Callback

EXPERTconnect SDK provides the ability to setup a voice callback with the user. Once the user provides a phone number, they are put in queue (if no agent is available now) for a return call from an associate or agent. 

## High-Level

```objc
UIViewController *callbackController;
callbackController = [[EXPERTconnect shared] startVoiceCallback:@"myVoiceCallbackSkill"
                                                withDisplayName:@"Voice Callback Service"];

[self.navigationController pushViewController:callbackController animated:YES];
```

# Utility Functions

## Checking health of API Server

Sometimes, your app may want to test for direct connectivity to the Humanify servers and verify the API is responding correctly. The following function will allow you to do so: 

```objc
[[EXPERTconnect shared].urlSession validateAPI:^(bool success) { 
    if( success ) 
    { 
         // API is reachable and healthy.  
    } 
}];
```
