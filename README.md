# EXPERTconnect SDK for iOS

The EXPERTconnect SDK for iOS provides an easy-to-integrate solution for adding TTec's omnichannel technology and journey management to your native mobile iOS app. The complicated wiring of these CX features are wrapped up in simple, reliable packaging that makes integration and deployment more efficient. 

The SDK offers two branches of the same feature set: 

1. Our UI-packaged, "high level" solution can be used for rapid prototyping and extremely easy implementation. A complete mobile chat experience can be built using 5-10 lines of code. Although this high level feature set has a range of customization, ultimately the general layouts will be restricted to what is provided here. 

2. Our API-wrapped, "low level" solution offers a lower to the ground but still efficient feature set. By using a set of delegates and callback functions, your app can respond to channel events. This allows your app designers to retain complete control of the user experience. Because the design is left in your hands, this does require more implementation by your app team (such as implementing the chat window, the chat bubbles, the buttons, and the flow) but ultimately will provide a much mroe personalized experience for your app users.

We highly recommend using approach #1 (high level) for a rapid prototype to test fit our SDK, then transitioning to #2 (low level) as you find resources to build out your own personalized UI. Examples of both methods are provided in our integrator example app found here: 

https://github.com/humanifydev/SDK-iOS-integrator


### What is included in this repository

This repository includes the native iOS SDK (EXPERTconnect.framework) 

EXPERTconnect SDK: https://github.com/humanifydev/SDK-iOS/tree/master/EXPERTconnect

Release Notes: https://docs.google.com/document/d/1QNO8MH9b_T3K6y3shlNPH6PXnItqZRbSORNS60OaXhw

## SDK Installation

### CocoaPods

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
### Carthage

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

### Manually

If you prefer not to use any of the aforementioned dependency managers, you can integrate EXPERTconnect into your project manually.

#### Embedded Framework

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


# Using the EXPERTconnect SDK

## Low-level 
A term used for the API wrapper layer of chat code (no UI). 

### Starting a chat session
Starting a chat consists of constructing an ECSStompChatClient object, setting a delegate (usually your chat view controller), and invoking the startChatWithSkill function. 

    ECSStompChatClient *chatClient = [ECSStompChatClient new]; 
    chatClient.delegate = self; // to receive callback events. 
    
    [chatClient startChatWithSkill:@"MyAgentSkill" subject:"Warranty Chat" dataFields:nil]; 

The three parameters required are: 
* skill - The chat skill to connect with. Often a string provided by Humanify, such as "CustomerServiceReps" that contains a group of associates who recieve the chats.
* subject - This is displayed on the associate desktop client as text at the start of a chat.
* dataFields - These data fields can be used to provide extra information to the associate. Eg: { "userType": "student" }

### Sending Chat Messages
Assuming you have setup your ECSStompChatClient, connected, and subscribed to a Stomp channel...

    ECSStompChatClient *chatClient;
    
    [chatClient sendChatText:@"hello, world!" completion:^(NSString *response, NSString *error) {

        NSLog(@"Chat sent. Response=%@, Error=%@", response, error); 
    
    }];

### Sending Chat State Updates
Chat state updates can tell the associate if the user is typing a message or has stopped. Both messages are manually sent by the host app. We recommend sending ECSChatStateComoposing when the user begins typing a message, starting a timer, and sending an ECSChatStateTypingPaused after a certain length of time, or when the user has deleted all of the text in the text box. The completion block on this call is not often needed. 

    ECSStompChatClient *chatClient; 
    
    [chatClient sendChatState:ECSChatStateComposing completion:nil]; 

### Receiving Messages from the Associate
Messages will arrive via the ECSStompChatDelegate callbacks. 

    - (void)chatClient:(ECSStompChatClient *)stompClient didReceiveMessage:(ECSChatMessage *)message {
    
        if( [message isKindOfClass:[ECSChatTextMessage class]] ) {
        
            NSLog(@"This is a regular chat text message from an associate."); 
        
        }
    
    }
Message Types: 
* ECSChatTextMessage
* ECSChatAddParticipantMessage
* ECSChatRemoveParticipationMessage
* ECSChatURLMessage
* ECSSendQuestionMessage
* ECSChatAssociateInfoMessage

# Use Case Specific Functionality

## Getting Chat Skill Availability Details 
The details of a chat or callback skill (such as estimated wait, chatReady, queueOpen) can be retrieved using the "getDetailsForExpertSkill" function. Example: 

```objective-c
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

## Chat Persistence 
The integrator demo app does give an example of a persistent chat experience. By persistence, this means that the user can navigate to other views within the app and still remain connected to the chat. They can return later to see the updated messages.  

Example can be found on lines 185-285 of https://github.com/humanifydev/SDK-iOS-Integrator/blob/master/HumanifyDemo/ViewController.m 

In a nutshell, the navigation of the view can be overriden by either not using standard navigation bar controls (your app would be in control), or by overriding the left and right buttons yourself (as we have done in our demo app, seen on line 205-211). 

If you want to do a "navigate away", simply pop the ECSChatViewController object off the stack (but do NOT deallocate it). 

If you want to provide an "exit chat" behavior, issue the [ECSChatViewController endChatByUser] function. 

## Customizing the chat Navigation Bar Buttons

The integrator demo app also includes an example of customizing the top navigation bar buttons while using our high level (packaged UI) chat feature. The basic idea is that if the viewController we allocate detects navigation bar buttons already created by the host app (you), we will not touch the navigation bar area. 

In the integrator app, we have overriden these buttons to be a left "minimize chat" button and a right "exit chat" button. You can find the code here: 
https://github.com/humanifydev/SDK-iOS-Integrator/blob/master/HumanifyDemo/ViewController.m

The "minimize" button refers to the "chatBackPushed" function found at line 239. 

The "exit chat" button refers to "chatEndChatPushed" function found at line 253. 

From here, you can customize anything about the button as allowed by iOS - such as tintColor, image, font, etc.
