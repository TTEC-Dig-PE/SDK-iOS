//
//  ECSFormViewController.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <EXPERTconnect/EXPERTconnect.h>

#import "ECSRootViewController.h"
#import "ECSInjector.h"
#import "ECSTheme.h"
#import "ECSButton.h"
#import "ECSLocalization.h"
#import "ECSURLSessionManager.h"
#import "ECSFormActionType.h"
#import "ECSForm.h"
#import "ECSFormItem.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ECSFormViewDelegate;

/**
 Root view controller for displaying a form to the user. Handles logic for 
 retrieving and submiting forms, as well as transitioning between various Form Items
 */
@interface ECSFormViewController : ECSRootViewController

/*!
 @brief ECSFormViewDelegate target object for passing question answered, form submitted, etc.
 */
@property (nonatomic, weak) id delegate;

/*!
 @brief Whether or not the submitted view is shown after form submission.
 */
@property (assign, nonatomic) bool showFormSubmittedView;

/*!
 @brief Get the form name displayed by this view controller.
 */
- (NSString *) getFormName;

/*!
 @brief Get the form data including any answers filled in by the user.
 */
- (ECSForm *) getForm;



@end


@protocol ECSFormViewDelegate <NSObject>

@optional

/*!
 @discussion Invoked when the user has navigated to the next question. This can be used to parse or react to a specific question being answered.
 @param formVC The ViewController object
 @param item The form item the user just navigated away from.
 @param index The index of the form item within the array of form elements.
*/
- (void) ECSFormViewController:(ECSFormViewController *)formVC
              answeredFormItem:(ECSFormItem *)item
                  atIndex:(int)index;

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
                         error:(NSError *)error;

/*!
 @brief User has clicked close in the form submitted view
 @discussion Invoked when the user clicks the Close button on the form submitted view. If your code contains this function, the ViewController will perform no action after the user clicks close. The transitioning and navigation stack manipulation will be left up to you. This can be used to override behavior after a form is completed, such as moving straight into another high-level feature of the SDK.
 @param formVC The ViewController object
 @param form The form object containing each form element and potentially the user's answers to each item.
 @returns True - SDK will proceed to animate and dismiss the view. False - no further action. You will be responsible for transitions and navigation stack.
 */
- (bool) ECSFormViewController:(ECSFormViewController *)formVC
                closedWithForm:(ECSForm *)form;

@end

NS_ASSUME_NONNULL_END


