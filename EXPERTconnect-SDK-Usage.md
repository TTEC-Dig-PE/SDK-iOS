# EXPERTconnect iOS SDK


The EXPERTconnect SDK provides access to the Humanify EXPERTconnect service including access to the answer engine service and chat features.

The SDK is built as an iOS 8 framework and is compatible with iOS 8 and later.

## Building the project

The demo and framework can be built using the top level Makefile.  The default make target will compile both the framework and the demo application.

## Integrating the SDK into your project

To integrate the SDK, you simply drag the EXPERTconnect.framework into your Xcode project.  

Once the framework is in your project, the EXPERTconnect SDK is initialized by providing a configuration to the SDK initialization function.  The configuration is controlled through the ECSConfiguration object.  ECSConfiguration specifies the following options:

* appName - The name of your application
* appVersion - The current version of your application.
* appId - The application ID provided by Humanify
* host - The host URL provided by Humanify
* clientID - The client ID for the application provided by Humanify
* clientSecret - The client secret provided by Humanify
* defaultNavigationContext - The default navigation context used by the default view controller
* defaultNavigationDisplayName - The default navigation display name for the default view controller.

An example of the initialization process is shown below:

        ECSConfiguration *configuration = [ECSConfiguration new];
    
        configuration.appName = @"EXPERTconnect Demo";
        configuration.appVersion = @"1.0";
        configuration.appId = @"12345";
        configuration.host = [self hostURLFromSettings];
        configuration.clientID = @"mktwebextc";
        configuration.clientSecret = @"secret123";
        configuration.defaultNavigationContext = @"personas";
        configuration.defaultNavigationDisplayName = @"Personas";
    
        [[EXPERTconnect shared] initializeWithConfiguration:configuration];

Once initialized, the default view controller is retrieved by calling the `landingViewController` function.  This returns the default view controller.  Typically, this view controller should be  set as the root view controller of a `UINavigationController`.

## Routing custom actions 

The EXPERTconnect SDK also provides the ability to retrieve any custom view controller based on a specified action.  Typically this will be used to jump to a specific place in the navigation hierarchy.  For example, to get the view controller for the technical help section of the EXPERTconnect system, you can request the default navigation view with the following code.

        #import <EXPERTconnect/ECSNavigationActionType.h>
        
        ECSNavigationActionType *navActionType = [ECSNavigationActionType new];
        navActionType.navigationContext = @"techHelpNavContext";
        navActionType.displayName = @"Technical Help";
        
        UIViewController *techHelpController = [[EXPERTconnect shared] viewControllerForActionType:navActionType];
        
 Additional action types are supported, but should generally not be required unless a specific custom implementation is required.
        
        
## Personalizing the experience

If your application has specific user information, you can specify your user's token and display name to allow Humanify to access additional information.  These are the following properties on the EXPERTconnect shared instance:

* userToken - The token for the current authenticated user.
* userDisplayName - The user display name for the current user.

## Personalizing the UI

The EXPERTconnect SDK is fully themable and localizable.  To customize the theme, you can subclass the `ECSTheme` class provided by the SDK and configure fonts and colors for the SDK.  Once the subclass is created, the default theme can be overridden by setting the theme property on the EXPERTconnect shared instance.

The SDK searches for localization strings and images first in the main bundle and then in the framework's bundle.  To override any of the images or localization strings, place an image or string with the same name in your main bundle.  All keys for localization strings can be found in `ECSLocalization.h`
