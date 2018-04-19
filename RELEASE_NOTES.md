
# Release 6.5.0
Apr 19, 2018

### PAAS-2663 - Carthage deployment now supported

Added support for Carthage. Carthage is a decentralized dependency manager (similar to CocoaPods) which provides a solution for easily incorporating iOS framework files into your project. 

See: https://github.com/humanifydev/SDK-iOS#carthage

# Release 6.4.0
Feb 23, 2018

### PAAS-2652 - Spanish (Mexico) localization strings updated

Localization - Updated strings for Mexico-Spanish. The changes apply to high level chat only.

### PAAS-2631 - Chat network recovery enhancements

Chat - Low level - The chat object (ECSStompChatClient) will now attempt to reconnect if it detects a network recovery and was previously connected to an active chat. This should happen automatically when the OS passes notification of a successful network recovery event. In addition, a new function callback was added to allow your app to run code when the chat object detects network loss or recovery.

See: https://github.com/humanifydev/SDK-iOS#reachability-event

### PAAS-2626 - API Check utility function

Added a new function that responds with the health of the API server. This can be used to test network reachability to the API server as well as the health of the server. This might be used to handle the rare scenario that the user still has network connection at the device but lost the ability to route to the API server. A response of false indicates the server is unreachable or unable to serve API responses.  

See: https://github.com/humanifydev/SDK-iOS#checking-health-of-api-server

### PAAS-2643 - Chat network recovery during server close fix

Chat - The chat should now automatically attempt to reconnect if it detects a WebSocket "close" event while a chat is active. A rare scenario where this could occur is if the server is restarted or shut down while a chat is in progress. The chat object will attempt to reconnect every 5 seconds with a backoff of adding 5 more seconds each retry.

# Release 6.3.2
Jan 18, 2018

### PAAS-2500 - Support for nested high level chat view

High Level Views - A new option facilitates the correct shifting of content above the keyboard when including a SDK high level view as a subview with other views below it. The new option suppresses any shifting of the content inside of the SDK's view. This would prevent double-shifting behaviors, which could cause gaps and content to be hidden behind other content. If your "outer" view already shifts any subviews upward, you would want to set the "shiftUpForKeyboard" boolean to NO.

See:
* Chat: https://github.com/humanifydev/SDK-iOS#customizing-the-view-behavior-for-keyboard-focus
* Forms: https://github.com/humanifydev/SDK-iOS#customizing-the-view-behavior-for-keyboard-focus-1

### PAAS-2505, 2594 - Added localizations

Localizations - Added support for Danish, Dutch, Finnish, Norwegian, Polish, Portuguese, and Swedish.

### PAAS-2520 - Retrieving chat history

Chat - Added a new function for retrieving chat transcripts. ConversationID is the only input parameter and is optional. If a value is present, the function will return the transcript for the given conversationID. If left blank (nil), the function will return all conversation history for the current journeyID. The output is a completion block with an array of Humanify SDK chat message objects (ECSChatTextMessage, ECSChatStateMessage, etc).

See: https://github.com/humanifydev/SDK-iOS#retrieving-chat-history

### PAAS-2599 - XCode build warnings

XCode - Corrected build warnings associated with building for iOS 9.x. The deployment target has been moved to 9.3.

# Release 6.3.0
Dec 7, 2017

Note: In this release, an entire new set of low level chat functions were added which are simpler and more powerful to use than the previous. The previous set of functions will continue to function, however going forward we will document using the new method. This documentation can be found in our implementation guides and example projects.

### PAAS-2531 - Chat network recovery enhancements

Chat - High Level - Corrected an issue where chat from the associate would stop arriving at the device. This would occur with the following steps: 1.) lose network (airplane mode, etc), 2.) background the app 3.) recover network 4.) foreground the app.

### PAAS-2302 - Chat message sending simplification

Chat - The ECSStompChatClient object now offers a new, easier way to send chat message and chat state updates. Formerly, the urlSession() object's sendChatMessage and sendChatState were used. Now, the following two new functions in the ECSStompChatClient object are added:

See: https://github.com/humanifydev/SDK-iOS#sending-messages

### PAAS-2310 - Chat custom user data fields

Chat - Added the capability to add custom data fields to a chat start which will be displayed at the associate desktop console. The (optional) parameter accepts a dictionary of key-value pairs which will be displayed in the details portion of the associate desktop client.

See: https://github.com/humanifydev/SDK-iOS#starting-a-chat

# Release 6.2.2
Oct 29, 2017

### PAAS-2393 - Form/Survey accessibility enhancements

Forms - The high level form view has been updated to better support the iOS "voiceover" accessibility feature. The view should now read the display in order, highlight form fields as "buttons", and set focus to the question text when the user navigates to the next or previous item.

### PAAS-2437 - Chat network recovery enhancements

Chat - Corrected a situation where the ECSStompChatDelegate would send a "Processing error" to the delegate if the associate sent a string of messages rapidly. This is a server bug that will be fixed in a server patch and often only occurs under a barrage of messages from the associate client. The correction in the SDK is that the WebSocket will detect this error and automatically reconnect. This should be transparent to the user, and the error will no longer be passed to the delegate.

### PAAS-2459 - Chat image sending crash fix

Chat - Corrected a crash that could occur when sending an image to the associate.

# Release 6.2.0
Sep 29, 2017

### PAAS-2204

Chat - The way a transfer works has been enhanced. First, some older legacy messages are now suppressed in the SDK. These messages were not localized and were not customizable by the SDK. They have been replaced by SDK control messages. When a transfer occurs, the SDK will receive a "RemoveParticipant" message indicating the agent who is leaving the chat. Next, a channel state change of "queued" will occur, indicating the chat is now queued for the transfer agent to pick up.

This new state can be handled using the new "chatClient:didReceiveChannelStateMessage" delegate call from ECSStompChatClient. When the agent picks up, an "AddParticipant" message will arrive.

For the high-level chat UI, All three of these messages will be indicated in the chat with an in-line message (not in a chat bubble). These messages are customizable by adding the following keys to your app's Localizable.Strings (default values shown):
"ECSLocalizeChatJoin" = "You are connected with %1@.";
"ECSLocalizeChatLeave" = "%1@ has left the chat.";
"ECSLocalizeChatTransfer" = "The chat is being transferred...";

In addition, there are 4 string replacements that can occur in the ChatJoin and ChatLeave messages:
%1@ - Backwards compatible. Firstname if found, otherwise, full name.
firstname - Agent's first name
lastname - Agent's last name
userid - Agent's userID
Example:
"ECSLocalizeChatJoin" = "You are connected with [firstname] [lastname] ([userid]).";

### PAAS-2233, 2129

Chat - The high level chat UI now supports clickable hyperlink, addresses and phone numbers. Hyperlinks will launch in the device default browser, addresses will launch the native maps app to the given location, and a phone number will invoke the native call dialing dialog. These links will appear automatically as detected in a normal text message from the associate. Example message typed from an associate: "Hello, you can find us at 100 Cupertino Plaza, San Francisco CA, www.humanify.com, or call 555-555-1234".

### PAAS-2144

Chat - Chat messages from the client are now queued for sending to increase reliability of message ordering. Each chat message will wait for the previous message response before being sent. Other SDK API calls outside of chat message sending are not affected by this queuing (such as breadcrumbs, decisioning calls, etc). This behavior is enabled by default and can be disabled by calling the following line once before chat starts:

```objc
[EXPERTconnect shared].urlSession.useMessageQueuing = NO;
```

### PAAS-2321

Chat - Added parameter "priority" on starting a low-level chat. This parameter will set the chat's priority as it comes to the server affecting how quickly it moves through the queue. Valid values are 1-10, or -1 to take the default priority configured by the server. The default value is 1 (low). The following static int values are defined by the SDK:
* kECSChatPriorityUseServerDefault = -1;
* kECSChatPriorityLow = 1;
*  kECSChatPriorityNormal = 5;
*  kECSChatPriorityHigh = 10;

### PAAS-2290

Chat - Corrected an issue that could cause WebSocket connections to remain open on the server after a chat concluded. This was caused by the SDK not issuing an "unsubscribe" when the associate was the one who ended the chat. Note that there is also a server config update that occurred around the same time that added a timeout to the hanging threads to reduce the overhead until the host apps are updated.

### PAAS-2273

Chat - An issue was corrected that would cause a reconnect attempt to fail if a previous reconnect had been attempted while the device could not connect to the server.

### PAAS-2374

Chat - Corrected an issue that would leave the chat in an unknown state if the client reconnected after a long period of being disconnected. This would typically occur when the user backgrounded the app or put the phone to sleep for an extended period of time (configurable on the server side, default 30 minutes). The SDK will now poll for the chat status after a short period (5 seconds) and if it finds that the chat was disconnected, it will issue a "disconnectedWithMessage" callback to delegates of ECSStompChatClient. The reason will be "idleTimeout" and the terminatedBy will be "system".

### PAAS-2316

Chat - High level chat will no longer send a "paused" chat state when the app resigns active. This is not a necessary step because the server should automatically handle a transition to the "inactive" state.

### PAAS-2315

Chat - High level - The chat window will no longer incorrectly show an "idle timeout warning" message when an associate is connected with the user. This would occur if the user waited in the queue long enough to trigger the idle timeout warning (default: 4 minutes) and was connected after that.


Low Level - The idle timeout warning will still be sent to you during the queued state. It is our recommendation to set an "answered" flag when an associate answers a chat, and ignore the idle timeout warnings that arrive before the answered flag is set.

# Release 6.1.2
Aug 16, 2017

### PAAS-2145

Chat - When using the low level code base, a new disconnect function is offered in the ECSStompChatClient and ECSStompCallbackClient objects. The old chatClientDisconnected function still exists for backwards compatibility.

See: https://github.com/humanifydev/SDK-iOS#disconnection

As an example, when an idle timeout occurs, the system should set terminatedBy=ECSTerminatedBySystem and disconnectReason=ECSDisconnectReasonIdleTimeout. When an associate (agent) ends a chat, terminatedBy = ECSTerminatedByAssociate and disconnectReason = ECSDisconnectReasonDisconnectByParticipant.

### PAAS-2151

Voice Callbacks - The last channelID for voice callbacks is now saved internally in the SDK and sent along with future form submits. This allows for post-call survey data to display on the Call Detail Report for voice callbacks.

### PAAS-2223

Chat - Corrected an issue that would cause the chat to disconnect if there was constant traffic on the WebSocket channel. The conditions for the disconnect are that chat messages are sent between the clients, spaced shorter than 20 seconds apart, for longer than 60 seconds. The SDK would report a disconnect with graceful=false to the low-level delegate, or display that the user is disconnected in the high level chat.

### PAAS-1961

Chat - Corrected an issue where the SDK would stop reconnecting to the WebSocket after multiple chats had been started and ended.

# Release 6.1.0
Jul 19, 2017

### PAAS-2116

Forms - The SDK will now send a previous chat channelID along with a form submit command. This ensures that the “Call Detail Report” will have the post-chat form data in the results. For reporting purposes, the form data will only be included in the report if the form is submitted within 5 minutes of the end of the conversation.

### PAAS-2064

Localization - Added translation strings for Portuguese-Brazil (pt-br) and Portuguese-Portugal (pt).

### PAAS-2083

Chat - Added a missing customization for changing the "subject" field of a low-level chat integration. The subject field is displayed to the associate and also used in reporting. The default value is "help". To modify the subject, add the following code before your setupChatClientWithAction call:
```objc
self.action.subject = @"help";
```

### PAAS-2049

Chat - The default placeholder image displayed while an image is loading was changed to a graphic with no text on it. The previous default had english text which would not be translated when viewed on other languages.

# Release 6.0.0
Jun 19, 2017

### PAAS-1792

Localization - Added support for Spanish-Spain (es-ES) and Italian (it). Base Spanish (es) was also updated with minor language corrections.

### PAAS-1929

Chat - Inline Forms - A form will no longer be submitted if the close button in the navigation bar is touched by the user. The only way an inline form can be submitted is by finishing the form and clicking the "submit" button. Note that this only applies to the inline form feature during a live chat. This may not apply if you do not support this feature.

# Release 5.9.1
Jun 1, 2017

### PAAS-1988

Forms - Corrected issue that would cause a user's answer to not be displayed if they clicked "previous" and the previous question was an option list. Now the SDK should correctly maintain the user's answer and display it properly.



Forms - Corrected issue with the "slider" form type that would cause the "next" button to be disabled if the user selected the minimum or maximum value.

# Release 5.9.0
May 22, 2017

### PAAS-1651

Support for bitcode has been enabled. Existing integrations whose bitcode setting is disabled will still continue to work.

### PAAS-998

The SDK will now automatically handle journey and session creation. This reduces need for extra code and waiting for server responses to proceed. It is no longer necessary to call startJourney() and wait for a journey before calling API calls. This requires Humanify API version 5.8.0 or later. Ask your Humanify support representative if you are unsure which API version is on your production server instance.



Chat - Added additional customizations to the chat "send" button. The background color and tint color of the UIButton are now customizable using theme options. These additional customizations facilitate the use of a graphic button with a transparent background. To change these values, edit the following theme values before chat is invoked:

See: https://github.com/humanifydev/SDK-iOS#customizing-the-send-button

### PAAS-1879

Forms - The high level form view controller has been updated to include new delegate functions and member variables. The host app can now react when the user answers a question, submits a form, or add custom behavior when the user clicks "Close" to exit the form view. This is done via a new delegate called "ECSFormViewDelegate". To subscribe to these calls, add this delegate to the object invoking startSurvey(). Three new optional delegate functions will be available.

See: https://github.com/humanifydev/SDK-iOS#forms-and-surveys

### PAAS-1972

Forms - Corrected an issue that would cause all form elements to show "required" regardless of the required field from the form data. It should now correctly show either "required" or "optional".

### PAAS-1898

Corrected an issue where the user-agent header passed to the server was not reflecting the SDK's version but instead showing the integrator app's version. The new user-agent header will now show all of these versions. Example:
MyApp/1.0.0 EXPERTconnect/5.9.0 (iOS/10.3.0)

### PAAS-1915

Forms - Form submission from the high-level form view now contains the added data fields to properly display the form results to the Expert Desktop agent console. The form data will still show up using older versions of the SDK but the form fields will not have populated labels.

# Release 5.8.1
April 21, 2017

### PAAS-1878

Chat - The Chinese translation for the queue timeout error (key: ECSLocalizedChatQueueDisconnectMessage) was missing the Chinese translation. It is now translated to Chinese.

# Release 5.8.0
April 18, 2017

### PAAS-1413

Added a debugging callback that allows your app to integrate SDK level debugging into your debugging output of choice. To integrate, implement the following:

See: https://github.com/humanifydev/SDK-iOS#debugging

### PAAS-1703

Chat - Behavior has been improved when the network is interrupted while the user is in a chat session. A red bar will slide in from the top of the window when network loss is detected and will disappear automatically when connection is regained. While the SDK cannot detect a network and the user is on the chat view it will attempt to reconnect every 30 seconds until connected. In addition, if the user gets connected to a chat that has already timed out, a dialog will be shown alerting the user that the chat session has ended. The network error bar and this dialog are customizable as shown below.
The network error bar is customizable by modifying the SDK theme settings. Example:

```objc
[EXPERTconnect shared].theme.chatNetworkErrorBackgroundColor = [UIColor redColor];
[EXPERTconnect shared].theme.chatNetworkErrorFont = [UIFont ...];
[EXPERTconnect shared].theme.chatNetworkErrorTextColor = [UIColor whiteColor];
```

Two new overridable strings have been added:
```objc
/* Displayed in a red bar at the top of the chat window when the network connection is lost. */
"ECSLocalizedChatQueueNetworkError" = "No internet connection.";

/* Dialog message displayed when user returns to a chat and it has timed out or disconnected. */
"ECSLocalizedChatQueueDisconnectMessage" = "Your chat request has timed out. Please try again.";
```

### PAAS-1772

Chat - The message displayed for "less than one minute remaining" in chat queue will now correctly be displayed only for estimated wait times of 60 seconds or less. Previously, rounding caused this message to be shown for an ETA of 90 seconds or less.

### PAAS-1767

Chat - The english strings for the dialog displayed when the user tries to exit the queue have been updated to have consistent capitalization and grammar. The word "leave" no longer has an uppercase L and now has a comma. Other localizations were already lowercased. 

New default values:
```objc
"ECSLocalizedLeaveQueueYes" = "Yes, leave";
"ECSLocalizedLeaveQueueNo" = "No, stay";
```

### PAAS-1761

Chat - The text displayed when the user tries to leave a chat queue was updated for the French language. A missing comma was added to the phrases "Non, rester" and "Oui, laisser".

### PAAS-1727

User Profile View - The email input field will no longer capitalize the first letter.

# Release 5.7.1
February 27, 2017

### PAAS-1677

Chat - The default estimated wait time strings have been updated to include the line "Please remain on this screen to keep your spot in queue." at the end. The string keys updated were:
* ECSLocalizeGenericWaitTime
* ECSLocalizeWaitTimeShort
* ECSLocalizeWaitTime
* ECSLocalizeWaitTimeLong

# Release 5.7.0
February 15, 2017

### PAAS-1603

Chat - a new dialog has been added to ask the user if they are sure they want to leave the chat queue. This dialog is displayed while the user is in the queue for a chat. The dialog has four new localized strings that can be overridden. The keys and default values are:

```objc
"ECSLocalizedLeaveQueueTitle" = "Leave Chat Queue?"
"ECSLocalizedLeaveQueueMessage" = "By leaving now, you will lose your place in the chat queue."
"ECSLocalizedLeaveQueueYes" = "Yes, Leave"
"ECSLocalizedLeaveQueueNo" = "No, stay"
```

### PAAS-1593

Chat - All three localized strings used to display an estimated wait message to the user now allow for the use of the estimated Wait time variable. These three localization strings can be added to your project to replace the default text provided by the SDK. To use the variable in your text string, add the following three character into your string: %1d.
Eg:

```objc
"ECSLocalizeWaitTimeShort" = "You'll be connected to an agent in less than %1d minute(s).";
"ECSLocalizeWaitTime" = "Your wait time is approximately %1d minute(s).";
"ECSLocalizeWaitTimeLong" = "Heavy chat volume. You wait time is approximately %1d minutes.";
```

### PAAS-1256

Agent Availability - The "getDetailsForSkill" function has been removed and replaced with the "getDetailsForExpertSkill". The new function encapsulates the response data into a data object for simpler parsing.

See: https://github.com/humanifydev/SDK-iOS/blob/master/README.md#getting-agent-availability

### PAAS-1108

Chat - When an agent sends an image the chat window will now display a placeholder until the image is fully loaded. Previously, it would appear that there was an empty message sent (no content).

Chat - Image thumbnails in the chat window are now a fixed size (160x160 pixels). Clicking the image will still show the full-size image.

### PAAS-1415

Answer Engine History - The high level answer engine history view now displays items in the chronological order as viewed by the user regardless of journeyId. Previously, the items were sorted alphabetically.

### PAAS-1354

Chat - Corrected an issue that could cause message truncation if the SDK "chatBubbleHorizMargins" theme setting was set to a value other than "10". When this issue occurred, the truncation would typically chop off the last word or the last line in the chat message.

### PAAS-1551

Chat - Corrected a situation in which backgrounding or switching to another app on the device could cause a chat session to be disconnected with no notice to the user. Now, the session will be properly disconnected when the app is backgrounded and will reconnect upon the app returning to the foreground. Any messages sent from the agent should be received on reconnect, and the chat should resume as normal.

### PAAS-1605

Chat - A bug was fixed that would cause the chat client to see a disconnection message if a "notify" channel state was sent from the server. This "notify" message is not currently sent by Humanify API and is reserved for future capability.

### PAAS-1310

Chat - Corrected an issue where the user and agent avatar images could be flipped after a transfer to another agent occurred. Now, the user and the agent should correctly display their respective avatar image.

### PAAS-1364

Chat - Corrected an issue with chat escalation to voice callback where the SDK would miss the notification that the user had picked up the call if they picked up the call on another device.

### PAAS-407

Chat History - The "agent is typing" messages are now filtered from chat history.

# Release 5.6.0
November 2016

### PAAS-147

Added context parameter to new startJourney() function.

### PAAS-347

Corrected an issue where setting the configuration.host URL to a value that ends with a slash would cause some API calls to fail. URLs with and without a slash at the end are supported.

### PAAS-545

Voice Callback – Corrected an issue where the “stompClientDidDisconnect” delegate function would not be called while a voice callback Stomp channel was open.

### PAAS-608

High Level Chat – Chat will no longer send a “composing” state message each time the user interacts with the keyboard. Instead, it will send “composing” only once at the first interaction with the keyboard, after the user erases a message, or if the user resumes typing after the 15- second timer puts the state back to “paused.”

# Release 5.5.0
October 2016

### PAAS-91

Localization – Added localization for Chinese (simplified).

### PAAS-40

Voice Callback – Corrected an issue where the SDK would not properly send an error to the “didFailWithError” delegate function. In some situations, this could cause a crash.

### PAAS-218

Chat – The “user is typing” message will now correctly disappear from the agent console if the user closes the app or puts it in the background.

### PAAS-221

Chat – Chat disconnection after an agent transfer has been improved. Previously, certain situations would cause the user’s chat to appear active if the agent ended the chat after a transfer occurred.

### PAAS-236

Forms – Corrected a localization issue where the user would see “Enter an answer” in English on a form’s input text box. This placeholder is no longer displayed.

### PAAS-243

SDK – Corrected a crash that could occur if calling certain API calls from a thread other than the main UI thread.

### PAAS-677

Chat – Corrected the display issues for chat messages seen when using a device running iOS 10. Issues included large gaps between chat messages or clipped off text.

### PAAS-697

Chat – The default avatar image used if an agent or user is missing an avatar has been updated. The image used is a gray on dark gray silhouette. You can override it by adding an image asset to your .xcassets named “error_not_found”.

### PAAS-764

Chat – When using photo upload capabilities in chat on iOS, Apple requires permission descriptions in your project’s Info.plist. The following three keys should be added (example values).
NSCameraUsageDescription – “To allow sending photos to an expert”
NSMicrophoneUsageDescription – “To allow sending video to an expert”
NSPhotoLibraryUsageDescription – “To allow choosing a photo from your library to send to an expert”

### PAAS-789

SDK – The default image for a missing avatar or media file has been changed to a silhouette image. The default image can be overridden by adding an “error_not_found” media asset to your project.

# Release 5.4.0
July 24, 2016

### EC-2265

Chat – A timeout warning message will now be displayed to the user. The chat timeout is configurable but typically is set to five minutes. This warning message will appear one minute before the chat times out (at the four-minute mark in this example).
The message to the user is:
“Your chat will timeout in 60 seconds due to inactivity.”

### EC-2459

A configuration to override the device region has been added. If this configuration is set, the content returned from the Answer Engine will be pulled from the repository from the overridden region instead of the device’s region. For example, if you want users to see US content even if they are in Europe, set the value to “en-US”.
Example:
```objc
NSString *lang = [[NSLocale preferredLanguages] objectAtIndex:0]
NSString *locale = [NSString stringWithFormat:@”%@-CA”, lang];
[EXPERTconnect shared].overrideDeviceLocale = locale;
```

### EC-2695

Localization – Added localization for English - United Kingdom (en-GB) and German (de). Also updated translation text for French (fr).

### EC-2715

High level Chat – If the chat UIViewController is loaded in a Navigation View, the navigation bar button behavior can now be overridden. If your app sets the navigationItem.leftBarButtonItem or the navigationItem.rightBarButtonItem the Humanify chat window will now add its own default leftBarButton (a < sign that ends the chat). If your app wants one of the navigation buttons to end the current chat, send either the “ECSEndChatNotification” or “ECSEndChatWithDialogNotification” (asks “are you sure”) notification.

### EC-2916

Chat – The send button can now be customized to display either a graphic or a text string. The default is text using the word "Send" in the localization set by the device. Use the following theme settings to configure the button for graphics. If no image is selected, the default image (a simple paper airplane icon) will be used:
[EXPERTconnect shared].theme.chatSendButtonImage = [UIImage imageNamed:@"my_send_graphic"];
[EXPERTconnect shared].theme.chatSendButtonUseImage = YES; // NO for text.

### EC-2462

Chat – Reconnection behavior has been improved when using high-level chat. The chat window will first attempt to reconnect (up to three times) in the event of an intermittent network loss or network error. If the network on the device has changed to a bad state, a “Reconnect” button and message will be displayed in the chat. Finally, if the authentication has failed, the chat will properly attempt to get a new token before continuing. Previously, in some situations, an agent would type messages that never arrived at the end user’s device.

### EC-2463, 2478

High level Chat – The “no agents available” message is now localized in English, French, and Spanish. This message is displayed when using the high-level chat and no agents are currently available.
To customize this message, add a Localizable.Strings file to your project and add the following string inside for each language:
"ECSLocalizeNoAgents" = "No agents available to take your chat.";

### EC-2830

High level Chat – Critical error messages from the server will be displayed to the user as a generic error message. This message will be localized. Previously, a cryptic message from the server would be shown, and it was not localized.

### EC-2502				

Long agent names are now displayed properly in the chat window when an agent connects. Previously the agent’s name would be clipped off and end user would see, “You are connected with “

### EC-2458

Corrected issue where the last line of a chat message could be clipped off. This often occurred on an iPhone 5S with the accessibility option for larger text turned up to the maximum.

# Release 5.2.2
May 23, 2016							

### EC-2502

Long agent names are now displayed properly in the chat window when an agent connects. Previously the agent’s name would be clipped off and end user would see, “You are connected with “

### EC-2458

Corrected issue where the last line of a chat message could be clipped off. This often occurred on an iPhone 5S with the accessibility option for larger text turned up to the maximum.

### EC-2463

The “No agents available” response when starting a chat has been localized in English, French and Spanish.

# Release 5.2.2
April 10, 2016					

Added support for the arm7 architecture.

Corrected the issue where allocating the EXPERTConnect SDK as a standard object instead of its internal singleton initialization ( [EXPERTconnect shared] ) would not behave properly.

Corrected the issue where connecting to a chat on an environment using HTTPS / WSS secure protocols would not establish the chat connection.
