//
//  ECSRadioFormItemViewController.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSRadioFormItemViewController.h"

#import "UIView+ECSNibLoading.h"
#import "ECSInjector.h"
#import "ECSTheme.h"

#import "ECSFormItemRadio.h"
#import "ECSFormQuestionView.h"
#import "ECSDynamicLabel.h"
#import "ECSRadioTableViewCell.h"

@interface ECSRadioFormItemViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *choicesTable;

@end

@implementation ECSRadioFormItemViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.choicesTable registerNib:[ECSRadioTableViewCell ecs_nib]
            forCellReuseIdentifier:ECSRadioTableViewCellIdentifier];
    
    self.choicesTable.delegate = self;
    self.choicesTable.dataSource = self;
    
    ECSTheme* theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    ECSFormQuestionView* questionView = [ECSFormQuestionView new];
    
    questionView.questionText = self.formItem.label;
    self.choicesTable.tableHeaderView = questionView;
    // Provide an initial size to avoid a constraint warning from Autolayout
    CGSize size = [questionView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    questionView.frame = CGRectMake(0, 0, questionView.frame.size.width, size.height);
    
    
    UIView* captionView = [UIView new];
    ECSDynamicLabel* captionLabel = [ECSDynamicLabel new];
    captionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [captionView addSubview:captionLabel];
    captionLabel.text = [self defaultCaptionText];
    captionLabel.font = theme.captionFont;
    captionLabel.textColor = theme.secondaryTextColor;
    [captionView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-15-[label]"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:@{ @"label": captionLabel }]];
    [captionView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[label]-10-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:@{ @"label": captionLabel }]];
    // Provide an initial size to avoid a constraint warning from Autolayout
    size = [captionView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    captionView.frame = CGRectMake(0, 0, questionView.frame.size.width, size.height);
    
    [self updateTableHeaderFooterSize];
    
    self.choicesTable.tableFooterView = captionView;
    self.choicesTable.estimatedRowHeight = 44;
    self.choicesTable.rowHeight = UITableViewAutomaticDimension;
    
    ECSFormItemRadio *radioFormItem = (ECSFormItemRadio *)self.formItem;
    
    // mas - 24-May-2017 - This should re-select the user's answer if they move past this question, and click "previous" to come back to it. PAAS-1988
    if( self.formItem.formValue ) {
        
        int tempIndex = 0;
        for (NSString *optionText in radioFormItem.options) {
            if( optionText == self.formItem.formValue) {
                break;
            }
            tempIndex++;
        }
        
        [self.choicesTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:tempIndex inSection:0]
                                       animated:NO
                                 scrollPosition:UITableViewScrollPositionNone];
    }
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
 
    [self updateTableHeaderFooterSize];
    
    [self.view layoutIfNeeded];
}

- (void)updateTableHeaderFooterSize
{
    UIView* tableHeader = self.choicesTable.tableHeaderView;
    [tableHeader layoutSubviews];
    CGSize size = [tableHeader systemLayoutSizeFittingSize:CGSizeMake(CGRectGetWidth(self.choicesTable.frame), CGRectGetHeight(self.view.frame))];
    tableHeader.frame = CGRectMake(0, 0, size.width, size.height);
    
    self.choicesTable.tableHeaderView = tableHeader;
    
    UIView* tableFooter = self.choicesTable.tableFooterView;
    [tableFooter layoutSubviews];
    size = [tableFooter systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    tableFooter.frame = CGRectMake(0, 0, size.width, size.height);
    
    self.choicesTable.tableFooterView = tableFooter;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    ECSFormItemRadio* item = (ECSFormItemRadio*)self.formItem;
    return item.options.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ECSRadioTableViewCell* cell = (ECSRadioTableViewCell*)[tableView dequeueReusableCellWithIdentifier:ECSRadioTableViewCellIdentifier
                                                                                          forIndexPath:indexPath];
    
    ECSFormItemRadio* formItem = (ECSFormItemRadio*)self.formItem;
    NSString* item = formItem.options[indexPath.row];
    
    cell.choiceText = item;
    [cell setRadioSelected:[item isEqualToString:formItem.formValue]];
    cell.frame = CGRectMake(0, 0, tableView.frame.size.width, 0);
    
    return cell;
}

- (NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ECSFormItemRadio* item = (ECSFormItemRadio*)self.formItem;
    NSInteger index = [item.options indexOfObject:item.formValue];
    if(index != NSNotFound)
    {
        ECSRadioTableViewCell* cell = (ECSRadioTableViewCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        [cell setRadioSelected:NO];
    }
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Show the nice hilighting, but store selection state for ourselves
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ECSFormItemRadio* item = (ECSFormItemRadio*)self.formItem;
    item.formValue = item.options[indexPath.row];
    
    ECSRadioTableViewCell* cell = (ECSRadioTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell setRadioSelected:YES];
    
    
    [self.delegate formItemViewController:self answerDidChange:item.formValue forFormItem:item];
}

@end
