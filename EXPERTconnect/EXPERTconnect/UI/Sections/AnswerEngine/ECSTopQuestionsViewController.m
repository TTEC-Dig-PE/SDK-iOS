//
//  ECSTopQuestionsViewController.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSTopQuestionsViewController.h"

#import "ECSAnswerEngineActionType.h"
#import "ECSListTableViewCell.h"
#import "ECSSectionHeader.h"
#import "ECSLocalization.h"

#import "UIView+ECSNibLoading.h"

@interface ECSTopQuestionsViewController ()

@end

static NSString *const ECSListCellId = @"ECSListCellId";

@implementation ECSTopQuestionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];
    
    [self.faqTableView registerNib:[ECSListTableViewCell ecs_nib]
            forCellReuseIdentifier:ECSListCellId];
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    ECSAnswerEngineActionType *answerEngineType = (ECSAnswerEngineActionType*)self.actionType;
    
    return answerEngineType.topQuestions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ECSListTableViewCell *cell = [self.faqTableView dequeueReusableCellWithIdentifier:ECSListCellId];
    
    ECSAnswerEngineActionType *answerEngineType = (ECSAnswerEngineActionType*)self.actionType;
    
    cell.titleLabel.text = answerEngineType.topQuestions[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ECSAnswerEngineActionType *answerEngineType = (ECSAnswerEngineActionType*)self.actionType;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (self.delegate)
    {
        [self.delegate controller:self didSelectQuestion:answerEngineType.topQuestions[indexPath.row]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 42.0f;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UINib *sectionNib = [UINib nibWithNibName:[[ECSSectionHeader class] description] bundle:[NSBundle bundleForClass:[ECSSectionHeader class]]];
    ECSSectionHeader *sectionHeader = [[sectionNib instantiateWithOwner:nil options:nil] objectAtIndex:0];
    
    sectionHeader.textLabel.text = ECSLocalizedString(ECSLocalizeFrequentlyAskedQuestionsKey, @"Frequently asked questions key") ;
    
    return sectionHeader;
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSNumber *animationTime = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey];
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:[animationTime floatValue] animations:^{
        [UIView setAnimationCurve:[animationCurve intValue]];
        UIEdgeInsets insets = self.faqTableView.contentInset;
        insets.bottom = insets.bottom + endFrame.size.height;
        self.faqTableView.contentInset = insets;
        self.faqTableView.scrollIndicatorInsets = insets;
    }];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSNumber *animationTime = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey];
    
    [UIView animateWithDuration:[animationTime floatValue] animations:^{
        [UIView setAnimationCurve:[animationCurve intValue]];
        UIEdgeInsets insets = self.faqTableView.contentInset;
        insets.bottom = 0;
        self.faqTableView.contentInset = insets;
        self.faqTableView.scrollIndicatorInsets = insets;
    }];
}

- (void)keyboardWillChangeFrame:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSNumber *animationTime = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey];
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:[animationTime floatValue] animations:^{
        [UIView setAnimationCurve:[animationCurve intValue]];
        UIEdgeInsets insets = self.faqTableView.contentInset;
        insets.bottom = endFrame.size.height;
        self.faqTableView.contentInset = insets;
        self.faqTableView.scrollIndicatorInsets = insets;
    }];
    
}

@end
