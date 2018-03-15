//
//  ECSCheckboxFormItemViewController.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSCheckboxFormItemViewController.h"

#import "ECSDynamicLabel.h"
#import "ECSInjector.h"
#import "ECSTheme.h"
#import "ECSFormQuestionView.h"
#import "ECSLocalization.h"
#import "ECSFormItemCheckbox.h"
#import "ECSCheckboxTableViewCell.h"
#import "UIView+ECSNibLoading.h"

@interface ECSCheckboxFormItemViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *choiceTable;

@end

@implementation ECSCheckboxFormItemViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.choiceTable registerNib:[ECSCheckboxTableViewCell ecs_nib]
           forCellReuseIdentifier:ECSCheckboxTableViewCellIdentifier];
    
    if ([self.formItem.type isEqualToString:ECSFormTypeSingle]) {
        
        self.choiceTable.allowsMultipleSelection = NO;
        
    } else {
        
        self.choiceTable.allowsMultipleSelection = YES;
        
    }
    
    self.choiceTable.delegate   = self;
    self.choiceTable.dataSource = self;
    
    ECSTheme* theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    ECSFormQuestionView* questionView = [ECSFormQuestionView new];
    
    questionView.questionText = self.formItem.label;
    
    self.choiceTable.tableHeaderView = questionView;
    
    // Provide an initial size to avoid a constraint warning from Autolayout
    CGSize size = [questionView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    questionView.frame = CGRectMake(0, 0, questionView.frame.size.width, size.height);
    
    UIView* captionView = [UIView new];
    
    ECSDynamicLabel* captionLabel = [ECSDynamicLabel new];
    
    captionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [captionView addSubview:captionLabel];
    
    captionLabel.text       = ECSLocalizedString(ECSLocalizeSelectAllThatApplyKey, @"Select all that apply");
    captionLabel.font       = theme.captionFont;
    captionLabel.textColor  = theme.secondaryTextColor;
    
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
    
    self.choiceTable.tableFooterView        = captionView;
    self.choiceTable.estimatedRowHeight     = 44;
    self.choiceTable.rowHeight              = UITableViewAutomaticDimension;
    
    [self updateTableHeaderFooterSize];
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    [self updateTableHeaderFooterSize];
}

- (void)updateTableHeaderFooterSize {
    
    // Header sizing.
    UIView* tableHeader = self.choiceTable.tableHeaderView;
    
    [tableHeader layoutSubviews];
    
    CGSize size = [tableHeader systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    tableHeader.frame = CGRectMake(0, 0, size.width, size.height);
    
    self.choiceTable.tableHeaderView = tableHeader;
    
    // Footer sizing.
    UIView* tableFooter = self.choiceTable.tableFooterView;
    
    [tableFooter layoutSubviews];
    
    size = [tableFooter systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    tableFooter.frame = CGRectMake(0, 0, size.width, size.height);
    
    self.choiceTable.tableFooterView = tableFooter;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ECSFormItemCheckbox* item = (ECSFormItemCheckbox*)self.formItem;
    return item.options.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ECSCheckboxTableViewCell* cell = (ECSCheckboxTableViewCell*)[tableView dequeueReusableCellWithIdentifier:ECSCheckboxTableViewCellIdentifier
                                                                                                forIndexPath:indexPath];
    
    ECSFormItemCheckbox* formItem = (ECSFormItemCheckbox*)self.formItem;
    
    NSString* item = formItem.options[indexPath.row];
    
    cell.choiceText = item;
    
    NSArray *answerArray = [formItem.formValue componentsSeparatedByString:@","];
    
    cell.selected   = [answerArray containsObject:item];
    cell.frame      = CGRectMake(0, 0, tableView.frame.size.width, 0);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self tappedRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self tappedRowAtIndexPath:indexPath];
}

- (void)tappedRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ECSFormItemCheckbox* item = (ECSFormItemCheckbox*)self.formItem;
    
    NSString* answer = [item.options[indexPath.row] stringByReplacingOccurrencesOfString:@"," withString:@"&comma;"];
    
    NSArray *answerArray = [item.formValue componentsSeparatedByString:@","];
    
    NSMutableArray* mutableAnswers = [answerArray mutableCopy];
    
    if(!mutableAnswers) {
        mutableAnswers = [NSMutableArray new];
    }
    
    if ( [answerArray containsObject:answer] ) {
        
        [mutableAnswers removeObject:answer];   // deselect
        
    } else {
        
        [mutableAnswers addObject:answer];      // select
        
    }

    item.formValue = [mutableAnswers componentsJoinedByString:@","];

    [self.delegate formItemViewController:self
                          answerDidChange:nil
                              forFormItem:item];
}
@end
