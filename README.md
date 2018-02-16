# Humanify iOS SDK & Test Harness

This repository includes the native iOS SDK (EXPERTconnect.framework) as well as the EXPERTconnect Test Harness app. These are two XCode projects within the same XCode workspace. 

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
    pod 'EXPERTconnect', '~> 6.3.2'
end
```

Then, run the following command:

```bash
$ pod install
```

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

## Low-levelChat
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






## SDK Internal Development Notes

### Schemes
There are three schemes in the workspace: 
* ExpertConnect - used for running unit tests mostly.  
* ExpertConnectDemo - Builds the Test Harness (automatically compiles in the SDK as well). 
* ECSUniveral - When "archive" is used, this builds the releasable .framework files. It outputs three files -- (iphoneos, iphonesimulator, and iphoneuniversal). iphoneos and iphoneuniversal are copied into the SDK-iOS-Integrator repo. 

### Building EXPERTconnect.framework
Select the "ECSUniversal" scheme, then Product-->Archive. WARNING: Currently, when archiving the "ECSUniversal" .framework files, the output contains an error. Each of the EXPERTconnect.framework files in the Finder folder that pops up at the end of the process must be modified. Expand one of these EXPERTconnect.framework files, and find the "EXPERTconnect.framework" file within it. Delete this. Basically, the build scripts are inadvertantly placing a copy of the framework inside itself. This causes problems when uploading to the app store (obviously). 

### Building TestHarness for HockeyApp 
Select the "ExpertConnectDemo" scheme, then Product-->Archive. Once the archive shows up in the organizer window, select it (usually the top one) and choose "Export...". Choose "Save for Enterprise Deployment", team is "TeleTech Holdings, Inc." (currently our only Enterprise Apple Account). Then save to a location on disk. This will be the .ipa file you drag-drop into HockeyApp here: https://rink.hockeyapp.net/manage/apps/196433

### Unit Testing
To run the unit tests, select the "ExpertConnect" scheme, then Product-->Test. 

### Features
Some commonly used features of the SDK: 
* Chat
* Voice Callback
* Forms
* Answer Engine
* Breadcrumbs
* Decisioning

## CocoaPods
New version release process: 
1. Make sure that a new tag is created in GitHub for each release that is only the release number. AKA a tag named "6.1.2". This is so CocoaPods knows there is a new version. 
2. Run lint on the build. From the base SDK-iOS folder, Run the following command: 
pod lib lint EXPERTconnect.podspec --swift-version=3.0
3. Push the new build: 
pod repo push Humanify EXPERTconnect.podspec

Note: If you get an issue or "pod already up to date", try adding --verbose to the push command to see what is wrong. 
If you see "The repo `humanify` at `../../.cocoapods/repos/Humanify` is not clean try: 

    cd ~/.cocoapods/repos/Humanify
    git status (will probably say untracked files present)
    git add .
    git commit "Adding podspec file for SDK x.x.x"
    git push

To use the pod in a project, in your Podfile: 

    source 'https://github.com/Humanifydev/SDK-iOS-specs.git'
    
In the target: 

    pod 'EXPERTconnect', '~> 6.2.0'


