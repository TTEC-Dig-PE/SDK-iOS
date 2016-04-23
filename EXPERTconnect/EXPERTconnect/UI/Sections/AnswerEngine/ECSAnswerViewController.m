//
//  ECSAnswerViewController.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSAnswerViewController.h"

#import "ECSAnswerRatingView.h"
#import "ECSInjector.h"
#import "ECSListTableViewCell.h"
#import "ECSLocalization.h"
#import "ECSPhotoViewController.h"
#import "ECSPullDownView.h"
#import "ECSPullUpView.h"
#import "ECSSectionHeader.h"
#import "ECSTheme.h"
#import "ECSURLSessionManager.h"
#import "ECSWebTableViewCell.h"
#import "ECSWebViewController.h"

#import "NSBundle+ECSBundle.h"
#import "UIView+ECSNibLoading.h"
#import "UIViewController+ECSNibLoading.h"

static NSString *const ECSAnswerEngineNoAnswerString = @"ANSWER_ENGINE_NO_ANSWER";

static NSString *const ECSListCellId = @"ECSListCellId";
static NSString *const ECSWebCellId = @"ECSWebCellId";

typedef NS_ENUM(NSInteger, AnswerSections)
{
    AnswerSectionsAnswer,
    AnswerSectionsOthersAsked,
    AnswerSectionsCount
};

@interface ECSAnswerViewController () <UITableViewDataSource,
UITableViewDelegate, UIWebViewDelegate, UIScrollViewDelegate, ECSAnswerRatingDelegate>
{
    BOOL _triggeredNavigation;
}

@property (strong, nonatomic) ECSWebTableViewCell *webTableCell;

@property (strong, nonatomic) UIView *topOverscrollView;
@property (strong, nonatomic) UIView *bottomOverscrollView;


@end

@implementation ECSAnswerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _triggeredNavigation = NO;
     
    [self.tableView registerNib:[ECSListTableViewCell ecs_nib]
                     forCellReuseIdentifier:ECSListCellId];
    [self.tableView registerNib:[ECSWebTableViewCell ecs_nib]
         forCellReuseIdentifier:ECSWebCellId];
    
}

- (void)setEdgeInsets:(UIEdgeInsets)edgeInsets
{
    _edgeInsets = edgeInsets;
    
    self.tableView.scrollIndicatorInsets = edgeInsets;
    self.tableView.contentInset = edgeInsets;
    
    CGRect frame = self.bottomOverscrollView.frame;
    
    if (self.tableView.contentInset.bottom == 0)
    {
        frame.origin.y = MAX(self.tableView.contentSize.height,
                             CGRectGetHeight(self.tableView.frame) - self.tableView.contentInset.top);
    }
    else
    {
        frame.origin.y = MAX(self.tableView.contentSize.height,
                             CGRectGetHeight(self.tableView.frame) - self.tableView.contentInset.top - self.tableView.contentInset.bottom);
    }
    
    self.bottomOverscrollView.frame = frame;
}

- (void)setShowPullToNext:(BOOL)showPullToNext
{
    _showPullToNext = showPullToNext;
    
    if (showPullToNext && !self.bottomOverscrollView)
    {
        [self addBottomOverscroll];
    }
    else
    {
        [self.bottomOverscrollView removeFromSuperview];
        self.bottomOverscrollView = nil;
    }
}

- (void)setShowPullToPrevious:(BOOL)showPullToPrevious
{
    _showPullToPrevious = showPullToPrevious;
    
    if (showPullToPrevious && !self.topOverscrollView)
    {
        [self addTopOverscroll];
    }
    else
    {
        [self.topOverscrollView removeFromSuperview];
        self.topOverscrollView = nil;
    }
}

- (void)addTopOverscroll
{
    ECSPullDownView *pullDownView = [ECSPullDownView ecs_loadInstanceFromNib];
    
    pullDownView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                     UIViewAutoresizingFlexibleBottomMargin);
    CGRect frame = CGRectMake(0,
                              -CGRectGetHeight(pullDownView.frame),
                              CGRectGetWidth(self.view.frame),
                              CGRectGetHeight(pullDownView.frame));
    pullDownView.frame = frame;
    
    [self.tableView addSubview:pullDownView];
    self.topOverscrollView = pullDownView;
}

- (void)addBottomOverscroll
{
    ECSPullUpView *pullUpView = [ECSPullUpView ecs_loadInstanceFromNib];
    
    pullUpView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                   UIViewAutoresizingFlexibleTopMargin);
    
    CGRect frame = CGRectMake(0,
                              self.tableView.contentSize.height,
                              CGRectGetWidth(self.view.frame),
                              60.0f);
    if (self.tableView.contentInset.bottom == 0)
    {
        frame.origin.y = MAX(self.tableView.contentSize.height,
                             CGRectGetHeight(self.tableView.frame) - self.tableView.contentInset.top);
    }
    else
    {
        frame.origin.y = MAX(self.tableView.contentSize.height, CGRectGetHeight(self.tableView.frame) - self.tableView.contentInset.top - self.tableView.contentInset.bottom);
    }

    pullUpView.frame = frame;
    
    [self.tableView addSubview:pullUpView];
    self.bottomOverscrollView = pullUpView;
}

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL shouldNavigate = YES;
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        UIViewController *controller = nil;
        if ([request.URL.absoluteString hasSuffix:@"jpg"] ||
            [request.URL.absoluteString hasSuffix:@"png"] ||
            [request.URL.absoluteString hasSuffix:@"gif"] ||
            [request.URL.absoluteString hasSuffix:@"jpeg"])
        {
            ECSPhotoViewController *photoController = [ECSPhotoViewController ecs_loadFromNib];
            photoController.imagePath = request.URL.absoluteString;
            controller = photoController;
        }
        else
        {
            ECSWebViewController *webController = [ECSWebViewController ecs_loadFromNib];
            [webController loadRequest:request];
            controller = webController;
        }
        
        [self.navigationController pushViewController:controller animated:YES];
        shouldNavigate = NO;
    }
    
    return shouldNavigate;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.tableView reloadData];
}

- (void)setAnswer:(ECSAnswerEngineResponse *)answer
{
    // Translate server codes into user friendly messages.
    if ([answer.answer isEqualToString:ECSAnswerEngineNoAnswerString])
    {
        answer.answer = ECSLocalizedString(ECSLocalizedAnswerNotFoundMessage, @"No answer found.");
    }
    
    _answer = answer;
    
    [self.tableView reloadData];
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return AnswerSectionsCount;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = 0;
    switch (section) {
        case AnswerSectionsAnswer:
            rowCount = 1;
            break;
        case AnswerSectionsOthersAsked:
            rowCount = self.answer.suggestedQuestions.count;
            break;
        default:
            break;
    }
    
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    switch (indexPath.section) {
        case AnswerSectionsAnswer:
        {
            if (!self.webTableCell)
            {
                self.webTableCell = [self.tableView dequeueReusableCellWithIdentifier:ECSWebCellId];
                self.webTableCell.webView.scalesPageToFit = NO;
                self.webTableCell.webView.delegate = self;
                [self.webTableCell.webView loadHTMLString:[self htmlStringForAnswer:self.answer.answer] baseURL:nil];
                
                if (![self.answer.requestRating boolValue])
                {
                    self.webTableCell.separator.alpha = 0.0f;
                }
                else
                {
                    self.webTableCell.separator.alpha = 1.0f;
                }

            }
            
            cell = self.webTableCell;
        }
            break;
        case AnswerSectionsOthersAsked:
        {
            ECSListTableViewCell *listCell = [self.tableView dequeueReusableCellWithIdentifier:ECSListCellId];
            listCell.titleLabel.text = self.answer.suggestedQuestions[indexPath.row];
            
            if (indexPath.row == [self.tableView numberOfRowsInSection:indexPath.section] - 1)
            {
                listCell.horizontalSeparatorVisible = NO;
            }
            
            cell = listCell;
        }
            
        default:
            break;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case AnswerSectionsAnswer:
            break;
        case AnswerSectionsOthersAsked:
        {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            NSString *question = self.answer.suggestedQuestions[indexPath.row];
            if (self.delegate)
            {
                [self.delegate askSuggestedQuestion:question];
            }
        }
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat estimatedHeight = 60.0f;
    switch (indexPath.section) {
        case AnswerSectionsAnswer:
            estimatedHeight = 200.0f;
            break;
            
        default:
            break;
    }
    
    return estimatedHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case AnswerSectionsAnswer:
            if (self.webTableCell)
            {
                return self.webTableCell.webView.scrollView.contentSize.height;
            }
            else
            {
                return UITableViewAutomaticDimension;
            }

            
        default:
            return UITableViewAutomaticDimension;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 30.0f;
    
    if ((section == AnswerSectionsOthersAsked) && (self.answer.suggestedQuestions.count == 0))
    {
        height = 0.0f;
    }
    
    return height;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UINib *sectionNib = [UINib nibWithNibName:[[ECSSectionHeader class] description] bundle:[NSBundle bundleForClass:[ECSSectionHeader class]]];
    ECSSectionHeader *sectionHeader = [[sectionNib instantiateWithOwner:nil options:nil] objectAtIndex:0];
    
    switch (section) {
        case AnswerSectionsAnswer:
            if ([self.answer.answerId intValue] == -1) {
                sectionHeader.textLabel.text = ECSLocalizedString(ECSLocalizedAnswerNotFoundTitle, @"No Answer Found");
            } else {
                sectionHeader.textLabel.text = ECSLocalizedString(ECSLocalizePossibleAnswer, @"Possible Answer");
            }
            break;
        case AnswerSectionsOthersAsked:
            if (self.answer.suggestedQuestions.count == 0)
            {
                sectionHeader = nil;
            }
            else
            {
                sectionHeader.textLabel.text = ECSLocalizedString(ECSLocalizeOthersAlsoAsked, @"Others also asked...");
            }
            break;
        default:
            break;
    }
    
    
    return sectionHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = 0.0f;
    if (section == AnswerSectionsAnswer && [self.answer.requestRating boolValue])
    {
        height = 60.0f;
    }
    
    return height;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footer = nil;
    if (section == AnswerSectionsAnswer && self.answer.requestRating.boolValue)
    {
        ECSAnswerRatingView *ratingView = [ECSAnswerRatingView ecs_loadInstanceFromNib];
        ratingView.delegate = self;
        ratingView.currentRating = self.answer.answerRating;
        footer = ratingView;
    }
    
    return footer;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Make offset 0 the top of the visible part of the scroll view.
    CGFloat adjustedZeroYOffset = scrollView.contentOffset.y + scrollView.contentInset.top;

    // Calculate how much of the table view is currently visible
    CGFloat tableViewViewableHeight = (CGRectGetHeight(self.tableView.frame) -
                                       self.tableView.contentInset.top -
                                       self.tableView.contentInset.bottom);
    
    if (adjustedZeroYOffset < -CGRectGetHeight(self.topOverscrollView.frame) - 20)
    {
        if (!_triggeredNavigation && self.delegate)
        {
            _triggeredNavigation = [self.delegate navigateToPreviousAnswer];
            
        }
    }
    else if (adjustedZeroYOffset > (CGRectGetMaxY(self.bottomOverscrollView.frame) - tableViewViewableHeight))
    {
        if (!_triggeredNavigation && self.delegate)
        {
            _triggeredNavigation = [self.delegate navigateToNextAnswer];
            
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_triggeredNavigation)
    {
        [self.delegate isReadyToRemoveFromParent:self];
    }
}

- (void)ratingSelected:(AnswerRating)rating
{
    self.answer.answerRating = rating;
    
    [self.delegate didRateAnswer:self.answer
                      withRating:rating];
    
}

- (NSString*)htmlStringForAnswer:(NSString*)answer
{
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    NSString *CSS = [theme.cssStyle copy];
    
    CSS = [CSS stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    CSS = [CSS stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSString *fullHTML = [NSString stringWithFormat:@"<html><style>%@</style><body>%@</body></html>", CSS, answer];
    
    return fullHTML;
}
@end
