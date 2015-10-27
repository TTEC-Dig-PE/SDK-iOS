//
//  EXPERTconnect.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "EXPERTconnect.h"

#import "ECSCafeXController.h"
#import "ECSVoiceItManager.h"

#import "ECSURLSessionManager.h"
#import "ECSImageCache.h"
#import "ECSInjector.h"
#import "ECSTheme.h"
#import "ECSUserManager.h"
#import "ECSLocalization.h"

#import "NSBundle+ECSBundle.h"
#import "UIViewController+ECSNibLoading.h"
#import "ECSAnswerEngineViewController.h"   // TODO: Eliminate references to "specific" View Controllers!

#import "ECSWorkflowNavigation.h"
#import "ECSBreadcrumbsAction.h"
#import "ECSBreadcrumbsSession.h"
#import "ECSLog.h"

@interface EXPERTconnect ()
@property (nonatomic, strong) ECSWorkflow *workflow;
@end

static EXPERTconnect* _sharedInstance;

@implementation EXPERTconnect

+ (instancetype)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [EXPERTconnect new];
    });
    
    return _sharedInstance;
}

- (void)initializeWithConfiguration:(ECSConfiguration*)configuration
{
    NSAssert(configuration.host, @"You must specify the host when initializing the EXPERTconnect SDK.");
    
    // Log config for debugging:
    NSLog(@"Initialized SDK with configuration:\nhost: %@\ncafeXHost: %@\nappName: %@\nappVersion: %@\nappId: %@\nclientID: %@\ndefaultNavigationContext: %@", configuration.host, configuration.cafeXHost, configuration.appName, configuration.appVersion, configuration.appId, configuration.clientID, configuration.defaultNavigationContext);
    
    ECSURLSessionManager* sessionManager = [[ECSURLSessionManager alloc] initWithHost:configuration.host];
    [[ECSInjector defaultInjector] setObject:configuration forClass:[ECSConfiguration class]];
    [[ECSInjector defaultInjector] setObject:sessionManager
                                    forClass:[ECSURLSessionManager class]];
    [[ECSInjector defaultInjector] setObject:[ECSImageCache new] forClass:[ECSImageCache class]];
    [[ECSInjector defaultInjector] setObject:[ECSTheme new] forClass:[ECSTheme class]];
    [[ECSInjector defaultInjector] setObject:[ECSUserManager new] forClass:[ECSUserManager class]];
    [[ECSInjector defaultInjector] setObject:[ECSVoiceItManager new] forClass:[ECSVoiceItManager class]];

    //[self initializeVideoComponents];

    _userCallbackNumber = nil;
}

- (void)initializeVideoComponents
{
    ECSCafeXController *cafeXController = [[ECSInjector defaultInjector] objectForClass:[ECSCafeXController class]];
    
    // Do a login if there's no session:
    if (![cafeXController hasCafeXSession]) {
        [cafeXController setupCafeXSession];
    }
}

- (BOOL)authenticationRequired
{
    ECSUserManager *userManager = [[ECSInjector defaultInjector] objectForClass:[ECSUserManager class]];
    return ![userManager isUserAuthenticated];
}

- (ECSTheme *)theme
{
    return [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
}

- (void)setTheme:(ECSTheme *)theme
{
    [[ECSInjector defaultInjector] setObject:theme forClass:[ECSTheme class]];
}

-(NSString *)host
{
    ECSConfiguration *configuration = [[ECSInjector defaultInjector] objectForClass:[ECSConfiguration class]];
    return configuration.host;
}
-(void)setHost:(NSString *)theHost
{
    ECSConfiguration *configuration = [[ECSInjector defaultInjector] objectForClass:[ECSConfiguration class]];
    configuration.host = theHost;
    
    // Set the host in the session manager.
    ECSURLSessionManager *sessionManager = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    [sessionManager setHostName:theHost];
}

-(NSString *)clientID
{
    ECSConfiguration *configuration = [[ECSInjector defaultInjector] objectForClass:[ECSConfiguration class]];
    return configuration.clientID;
}

-(void)setClientID:(NSString *)theClientID
{
    ECSConfiguration *configuration = [[ECSInjector defaultInjector] objectForClass:[ECSConfiguration class]];
    configuration.clientID = theClientID;
    
    // Reset the auth token. This should make us fetch a new one.
    ECSURLSessionManager *sessionManager = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    sessionManager.authToken = nil;
}

- (void)setUserIntent:(NSString *)intent
{
    ECSUserManager *userManager = [[ECSInjector defaultInjector] objectForClass:[ECSUserManager class]];
    userManager.userIntent = intent;
}

- (NSString *)userIntent
{
    ECSUserManager *userManager = [[ECSInjector defaultInjector] objectForClass:[ECSUserManager class]];
    return userManager.userIntent;
}

- (ECSURLSessionManager *)urlSession
{
    return [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
}

- (NSString *)userToken
{
    ECSUserManager *userManager = [[ECSInjector defaultInjector] objectForClass:[ECSUserManager class]];
    return userManager.userToken;
}

- (void)logout {
    // In case the log has been wrapped by the host app, let's re-display configuration for the next log:
    ECSConfiguration *configuration = [[ECSInjector defaultInjector] objectForClass:[ECSConfiguration class]];
    ECSUserManager *userManager = [[ECSInjector defaultInjector] objectForClass:[ECSUserManager class]];
    
    // Log config for debugging:
    ECSLogVerbose(@"SDK Performing logout for user %@ with configuration:\nhost: %@\ncafeXHost: %@\nappName: %@\nappVersion: %@\nappId: %@\nclientID: %@\ndefaultNavigationContext: %@", [self userToken], configuration.host, configuration.cafeXHost, configuration.appName, configuration.appVersion, configuration.appId, configuration.clientID, configuration.defaultNavigationContext);
    
    // mas - 12-oct-15 - Call the lower level unauthenticate which destroys the keychain token as well.
    //[self setUserToken:nil];
    [userManager unauthenticateUser];
}

- (void)setUserToken:(NSString *)userToken
{
    ECSUserManager *userManager = [[ECSInjector defaultInjector] objectForClass:[ECSUserManager class]];
    userManager.userToken = userToken;
    
    if (!userToken || (userToken.length == 0))
    {
        [userManager unauthenticateUser];
    }
}

- (NSString *)userDisplayName
{
    ECSUserManager *userManager = [[ECSInjector defaultInjector] objectForClass:[ECSUserManager class]];
    return userManager.userDisplayName;
}

- (void)setUserDisplayName:(NSString *)userDisplayName
{
    ECSUserManager *userManager = [[ECSInjector defaultInjector] objectForClass:[ECSUserManager class]];
    userManager.userDisplayName = userDisplayName;
}

- (NSString*)EXPERTconnectVersion
{
    return [NSBundle ecs_bundleVersion];
}

- (UIViewController*)startChat:(NSString*)chatSkill withDisplayName:(NSString*)displayName withSurvey:(BOOL)shouldTakeSurvey
{
    // Nathan Keeney 9/1/2015 changed to ALLOW CafeX escalation (no change to vanilla chats):
    ECSVideoChatActionType *chatAction = [ECSVideoChatActionType new];
    chatAction.actionId = @"";
    chatAction.agentSkill = chatSkill;
    chatAction.displayName = displayName;
    chatAction.shouldTakeSurvey = shouldTakeSurvey;
    
    ECSCafeXController *cafeXController = [[ECSInjector defaultInjector] objectForClass:[ECSCafeXController class]];
    // Do a login if there's no session:
    if (![cafeXController hasCafeXSession]) {
        [cafeXController setupCafeXSession];
    }
    chatAction.cafexmode = @"videocapable,voicecapable,cobrowsecapable";
    chatAction.cafextarget = [cafeXController cafeXUsername];
    
    UIViewController *chatController = [self viewControllerForActionType:chatAction];
    
    return chatController;
}

- (UIViewController*)startVideoChat:(NSString*)chatSkill withDisplayName:(NSString*)displayName
{
    ECSCafeXController *cafeXController = [[ECSInjector defaultInjector] objectForClass:[ECSCafeXController class]];
    
    // Do a login if there's no session:
    if (![cafeXController hasCafeXSession]) {
        [cafeXController setupCafeXSession];
    }
    
    ECSVideoChatActionType *chatAction = [ECSVideoChatActionType new];
    chatAction.actionId = @"";
    chatAction.agentSkill = chatSkill;
    chatAction.displayName = displayName;
    chatAction.cafexmode = @"videoauto";
    chatAction.cafextarget = [cafeXController cafeXUsername];
    
    UIViewController *chatController = [self viewControllerForActionType:chatAction];
    
    return chatController;
}

- (UIViewController*)startVoiceChat:(NSString*)chatSkill withDisplayName:(NSString*)displayName
{
    ECSCafeXController *cafeXController = [[ECSInjector defaultInjector] objectForClass:[ECSCafeXController class]];
    
    // Do a login if there's no session:
    if (![cafeXController hasCafeXSession]) {
        [cafeXController setupCafeXSession];
    }
    
    ECSVideoChatActionType *chatAction = [ECSVideoChatActionType new];
    chatAction.actionId = @"";
    chatAction.agentSkill = chatSkill;
    chatAction.displayName = displayName;
    chatAction.cafexmode = @"voiceauto";
    chatAction.cafextarget = [cafeXController cafeXUsername];
    
    UIViewController *chatController = [self viewControllerForActionType:chatAction];
    
    return chatController;
}

- (UIViewController*)startVoiceCallback:(NSString*)callSkill withDisplayName:(NSString*)displayName
{
    ECSCallbackActionType *cbAction = [ECSCallbackActionType new];
    cbAction.actionId = @"";
    cbAction.agentSkill = callSkill;
    cbAction.displayName = displayName;
    
    UIViewController *cbController = [self viewControllerForActionType:cbAction];
    
    return cbController;
}

- (UIViewController*)startAnswerEngine:(NSString*)aeContext
{
    ECSAnswerEngineActionType *answerEngineAction = [ECSAnswerEngineActionType new];
    
    answerEngineAction.defaultQuestion = @"How do I get wireless Internet?";  // just an example, does nothing
    answerEngineAction.journeybegin = [NSNumber numberWithBool:YES];
    answerEngineAction.actionId = @"";
    answerEngineAction.answerEngineContext = aeContext;
    answerEngineAction.navigationContext = @"";
    
    UIViewController *answerEngineController = [self viewControllerForActionType:answerEngineAction];
    ((ECSAnswerEngineViewController *)answerEngineController).parentNavigationContext = @"";
    
    return answerEngineController;
}

- (UIViewController*)startSurvey:(NSString*)formName
{
    ECSFormActionType *formAction = [ECSFormActionType new];
    formAction.actionId = formName;  // kwashington: Can't load the Form Synchronously, so set the actionId to the formName so the ECSFormViewController can do that in viewDidLoad()
    formAction.navigationContext = @"personas";

    UIViewController *formController = [self viewControllerForActionType:formAction];
    
    return formController;
}

- (UIViewController*)startUserProfile
{
    ECSActionType *profileAction = [ECSActionType new];
    profileAction.type = ECSActionTypeProfile;
    profileAction.actionId = self.userDisplayName;
    
    UIViewController *profileController = [self viewControllerForActionType:profileAction];
    
    return profileController;
}

- (UIViewController*)startEmailMessage
{
    ECSMessageActionType *messageAction = [ECSMessageActionType new];
    messageAction.actionId = @"";
    messageAction.email = ECSLocalizedString(@"callcenter@humanify.com", @"callcenter@humanify.com");
    messageAction.messageHeader = ECSLocalizedString(@"Leave a Message", @"Leave a Message");
    messageAction.hoursText = ECSLocalizedString(@"The Call Center is open between the hours of 8:00 AM and 8:00 PM.", @"The Call Center is open between the hours of 8:00 AM and 8:00 PM.");
    messageAction.messageText = ECSLocalizedString(@"The call center is closed!", @"The call center is closed!");
    messageAction.emailSubject = ECSLocalizedString(@"Important Message", @"Important Message");
    messageAction.emailButtonText = ECSLocalizedString(@"Submit Message", @"Submit Message");
    
    return [self startEmailMessage:messageAction];
}

- (UIViewController*)startEmailMessage:(ECSActionType *)messageAction
{
    UIViewController *messageController = [self viewControllerForActionType:messageAction];
    return messageController;
}

- (UIViewController*)startSMSMessage
{
    ECSSMSActionType *smsAction = [ECSSMSActionType new];
    smsAction.actionId = @"";
    
    UIViewController *smsController = [self viewControllerForActionType:smsAction];
    
    return smsController;
}

- (UIViewController*)startWebPage:(NSString *)url
{
    ECSWebActionType *webAction = [ECSWebActionType new];
    webAction.actionId = @"";
    webAction.url = url;
    
    UIViewController *webController = [self viewControllerForActionType:webAction];
    
    return webController;
}

- (UIViewController*)startAnswerEngineHistory
{
    ECSActionType *aeAction = [ECSActionType new];
    aeAction.type = ECSActionTypeAnswerHistory;
    aeAction.actionId = @"";
    
    UIViewController *aeController = [self viewControllerForActionType:aeAction];
    
    return aeController;
}

- (UIViewController*)startChatHistory
{
    ECSActionType *chistAction = [ECSActionType new];
    chistAction.type = ECSActionTypeChatHistory;
    chistAction.actionId = @"";
    
    UIViewController *chistController = [self viewControllerForActionType:chistAction];
    
    return chistController;
}

- (UIViewController*)startSelectExpertChat
{
    ECSActionType *expertAction = [ECSActionType new];
    expertAction.type = ECSActionTypeSelectExpertChat;
    expertAction.actionId = @"";
    expertAction.displayName = @"Chat With an Expert";
    
    UIViewController *expertController = [self viewControllerForActionType:expertAction];
    
    return expertController;
}

- (UIViewController*)startSelectExpertVideo
{
    ECSActionType *expertAction = [ECSActionType new];
    expertAction.type = ECSActionTypeSelectExpertVideo;
    expertAction.actionId = @"";
    expertAction.displayName = @"VideoChat With an Expert";
    
    UIViewController *expertController = [self viewControllerForActionType:expertAction];
    
    return expertController;
}

- (UIViewController*)startSelectExpertAndChannel
{
    ECSActionType *expertAction = [ECSActionType new];
    expertAction.type = ECSActionTypeSelectExpertAndChannel;
    expertAction.actionId = @"";
    expertAction.displayName = @"Select an Expert";
    
    UIViewController *expertController = [self viewControllerForActionType:expertAction];
    
    return expertController;
}

- (void)voiceAuthRequested:(NSString *)username callback:(void (^)(NSString *))authCallback {
    // VoiceIT SDK. Call callback with response.
    ECSVoiceItManager *voiceItManager = [[ECSInjector defaultInjector] objectForClass:[ECSVoiceItManager class]];
    if ([voiceItManager isInitialized]) {
        [voiceItManager authenticateAction:authCallback];
    } else {
        [voiceItManager configure:username];
        [voiceItManager authenticateAction:authCallback];
    }
}

- (void)recordNewEnrollment {
    // VoiceIT SDK. Call callback with response.
    ECSVoiceItManager *voiceItManager = [[ECSInjector defaultInjector] objectForClass:[ECSVoiceItManager class]];
    if ([voiceItManager isInitialized]) {
        [voiceItManager recordNewEnrollment];
    } else {
        [voiceItManager configure:[self userToken]];
        [voiceItManager recordNewEnrollment];
    }
}

- (void)clearEnrollments {
    // VoiceIT SDK. Call callback with response.
    ECSVoiceItManager *voiceItManager = [[ECSInjector defaultInjector] objectForClass:[ECSVoiceItManager class]];
    if ([voiceItManager isInitialized]) {
        [voiceItManager clearEnrollments];
    } else {
        [voiceItManager configure:[self userToken]];
        [voiceItManager clearEnrollments];
    }
}


- (void) login:(NSString *) username withCompletion:(void (^)(ECSForm *, NSError *))completion
{
    [self setUserToken:username];

    ECSURLSessionManager* sessionManager = [[EXPERTconnect shared] urlSession];
    [sessionManager getFormByName:@"userprofile" withCompletion:^(ECSForm *form, NSError *error) {
        if (form && form.formData)
        {
            for (ECSFormItem *item in form.formData)
            {
                if ([item.metadata isEqualToString:@"profile.fullname"])
                {
                    self.userDisplayName = item.formValue;
                    break;
                }
            }
            
            completion(form, error);
        }
        else
        {
            completion(nil, error);
        }
    }];
}

-(void)recievedUnrecognizedAction:(NSString *)action {
    [self.workflow receivedUnrecognizedAction:action];
}

- (UIViewController *)viewControllerForActionType:(ECSActionType *)actionType
{
    return [ECSRootViewController ecs_viewControllerForActionType:actionType];
}

- (void)setDelegate:(id)delegate {
    _externalDelegate = delegate;
}

- (UIViewController*)landingViewController
{
    ECSConfiguration *configuration = [[ECSInjector defaultInjector] objectForClass:[ECSConfiguration class]];
    ECSNavigationActionType *navigationAction = [ECSNavigationActionType new];
    navigationAction.displayName = configuration.defaultNavigationDisplayName;
    navigationAction.navigationContext = configuration.defaultNavigationContext;
    
    return [ECSRootViewController ecs_viewControllerForActionType:navigationAction];
}

- (void)startWorkflow:(NSString *)workFlowName
           withAction:(NSString *)actionType
              delgate:(id <ECSWorkflowDelegate>)workflowDelegate
       viewController:(UIViewController *)viewController {
    
    ECSConfiguration *ecsConfiguration = [[ECSInjector defaultInjector] objectForClass:[ECSConfiguration class]];
    
    ECSActionType *action = [ECSActionType new];
    action.type = actionType;
    action.actionId = @"";
    
    ECSRootViewController *initialViewController = (ECSRootViewController *)[self viewControllerForActionType:action];
    
    if ([actionType isEqualToString:ECSActionTypeAnswerEngineString]) {
        initialViewController = (ECSRootViewController *)[self startAnswerEngine:ecsConfiguration.defaultAnswerEngineContext];
    }
    else if([actionType isEqualToString:ECSActionTypeFormString]) {
        initialViewController = (ECSRootViewController *)[self startSurvey:[EXPERTconnect shared].surveyFormName];
    }
    
    ECSWorkflowNavigation *navManager = [[ECSWorkflowNavigation alloc] initWithHostViewController:viewController];

    self.workflow = [[ECSWorkflow alloc] initWithWorkflowName:actionType
                                             workflowDelegate:workflowDelegate
                                            navigationManager:navManager];

    initialViewController.workflowDelegate = self.workflow;
    
    [navManager presentViewControllerInNavigationControllerModally:initialViewController
                                                          animated:YES
                                                        completion:nil];

}

- (void)startChatWorkflow:(NSString *)workFlowName
               withSkill:(NSString *)skillName
               withSurvey:(BOOL)shouldTakeSurvey
              delgate:(id <ECSWorkflowDelegate>)workflowDelegate
       viewController:(UIViewController *)viewController {

    ECSRootViewController *initialViewController = (ECSRootViewController *)[self startChat:skillName
                                                                            withDisplayName:@"Chat"
                                                                                 withSurvey:shouldTakeSurvey];
    
    ECSWorkflowNavigation *navManager = [[ECSWorkflowNavigation alloc] initWithHostViewController:viewController];
    
    self.workflow = [[ECSWorkflow alloc] initWithWorkflowName:workFlowName
                                             workflowDelegate:workflowDelegate
                                            navigationManager:navManager];
    
    initialViewController.workflowDelegate = self.workflow;
    
    [navManager presentViewControllerInNavigationControllerModally:initialViewController
                                                          animated:YES
                                                        completion:nil];
}

- (void) startJourneyWithCompletion:(void (^)(NSString *, NSError *))completion
{
    //[self setUserToken:username];
    
    ECSURLSessionManager* sessionManager = [[EXPERTconnect shared] urlSession];
    
    [sessionManager setupJourneyWithCompletion:^(ECSStartJourneyResponse *response, NSError* error) {
        if (response && !error)
        {
            // Set the global journeyID
            self.journeyID = response.journeyID;
            
            if( completion ) {
                completion(response.journeyID, error);
            }
            
        }
        else
        {
            if(completion) {
                completion(nil, error);
            }
        }
    }];
}

- (void) breadcrumbsAction:
          (NSString *)actionType
          actionDescription: (NSString *)actionDescription
               actionSource: (NSString *)actionSource
          actionDestination: (NSString *)actionDestination   {
    
    ECSLogVerbose(@"breadcrumbsAction:: calling with actionType : %@", actionType);
    
    if([self clientID] == Nil || [self journeyID] == Nil  || [self sessionID] == nil ) {
        
        ECSLogVerbose(@"breadcrumbsAction:: Ignore Action, Journey not initialized correctly : %@", actionType);
        return;
    }
    
    
    
    ECSURLSessionManager* sessionManager = [[EXPERTconnect shared] urlSession];
    
    
    ECSBreadcrumbsAction *journeyAction = [[ECSBreadcrumbsAction alloc] init];
    
    [journeyAction setTenantId:[self clientID]];
    [journeyAction setJourneyId:[self journeyID]];
    [journeyAction setSessionId:[self sessionID]];
    [journeyAction setActionType:actionType];
    [journeyAction setActionDescription:actionDescription];
    [journeyAction setActionSource:actionSource];
    [journeyAction setActionDestination:actionDestination];
    
    NSMutableDictionary *properties = [journeyAction getProperties];
    
    
    [sessionManager breadcrumbsAction:properties completion:^(NSDictionary *decisionResponse, NSError *error) {
        
        if( error )  {
            ECSLogError(@"breadcrumbsAction:: Error: %@", error.description);
        } else  {
            
     
            
            ECSBreadcrumbsAction *journeyActionRes = [[ECSBreadcrumbsAction alloc] initWithDic:decisionResponse];
            
            ECSLogVerbose(@"breadcrumbsAction:: Value of actionId is: %@", [journeyActionRes getId]);
            
            
            /*
            NSData *responseData = [NSJSONSerialization dataWithJSONObject:decisionResponse
                                                                   options:NSJSONWritingPrettyPrinted
                                                                     error:&error];
            
            NSString* responseJson = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            
            NSLog(@"Decision Response Json: %@", responseJson);
             */
        }
    }];
}



- (void) breadcrumbsSession:
                             (NSString *)deviceId
                phonenumber: (NSString *)phonenumber
                  osVersion: (NSString *)osVersion
                  ipAddress: (NSString *)ipAddress
                  geoLocation: (NSString *)geoLocation
                  resolution: (NSString *)resolution{
    
    ECSLogVerbose(@"breadcrumbsSession:: calling with journeyId : %@", [self journeyID]);
    
    ECSURLSessionManager* sessionManager = [[EXPERTconnect shared] urlSession];
    
    
    ECSBreadcrumbsSession *journeySession = [[ECSBreadcrumbsSession alloc] init];
    
    [journeySession setTenantId:[self clientID]];
    [journeySession setJourneyId:[self journeyID]];

    [journeySession setPlatform:@"iOS"];
    [journeySession setDeviceId:deviceId];
    [journeySession setPhonenumber:phonenumber];
    [journeySession setOSVersion:osVersion];
    [journeySession setIPAddress:ipAddress];
    [journeySession setGEOLocation:geoLocation];
    [journeySession setBrowserType:@"NA"];
    [journeySession setBrowserVersion:@"NA"];
    [journeySession setResolution:resolution];

    
    NSMutableDictionary *properties = [journeySession getProperties];
    
    
    [sessionManager breadcrumbsSession:properties completion:^(NSDictionary *decisionResponse, NSError *error) {
        
        if( error )  {
            ECSLogError(@"breadcrumbsSession:: Error: %@", error.description);
        } else  {
            
            
            
            ECSBreadcrumbsSession *journeySessionRes = [[ECSBreadcrumbsSession alloc] initWithDic:decisionResponse];
            
            ECSLogVerbose(@"breadcrumbsSession:: Value of sessionID is: %@", [journeySessionRes getSessionId]);
            
            // Set the global sessionId
            self.sessionID = [journeySessionRes getSessionId];

        }
    }];
}



/**
 Set the debug level.
     0 - None
     1 - Error
     2 - Warning
     3 - Debug
     4 - Verbose
 */
- (void)setDebugLevel:(int)logLevel {
    NSLog(@"EXPERTconnect SDK: Debug level set to %d", logLevel);
    ECSLogSetLogLevel(logLevel);
}

@end