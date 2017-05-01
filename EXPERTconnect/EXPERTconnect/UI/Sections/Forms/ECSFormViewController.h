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

@protocol ECSFormViewDelegate;

/**
 Root view controller for displaying a form to the user. Handles logic for 
 retrieving and submiting forms, as well as transitioning between various Form Items
 */
@interface ECSFormViewController : ECSRootViewController

// Delegate view to receive events from the Form View Controller
@property (nonatomic, weak) id delegate;

@property (assign, nonatomic) bool showFormSubmittedView;

// Retrieves the current form's name.
- (NSString *) getFormName;

// Retrieves the current form, including any data input filled out by the user already.
- (ECSForm *) getForm;

@end


@protocol ECSFormViewDelegate <NSObject>

@optional


- (void) ECSFormViewController:(ECSFormViewController *)formVC
              answeredFormItem:(ECSFormItem *)item
                  atIndex:(int)index;

- (void) ECSFormViewController:(ECSFormViewController *)formVC
                 submittedForm:(ECSForm *)form
                      withName:(NSString *)name
                         error:(NSError *)error;

- (void) ECSFormViewController:(ECSFormViewController *)formVC
                closedWithForm:(ECSForm *)form;


//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
@end



