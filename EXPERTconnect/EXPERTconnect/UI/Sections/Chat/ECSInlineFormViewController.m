//
//  ECSInlineFormViewController.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSInlineFormViewController.h"

#import "ECSFormItemRadio.h"
#import "ECSFormItemCheckbox.h"
#import "ECSFormItemRadio.h"
#import "ECSFormItemCheckbox.h"
#import "ECSCheckboxTableViewCell.h"
#import "ECSInjector.h"
#import "ECSRadioTableViewCell.h"
#import "ECSTheme.h"
#import "UIView+ECSNibLoading.h"

@interface ECSInlineFormViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (strong, nonatomic) ECSFormItem *formItem;
@end

@implementation ECSInlineFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.formItem = self.form.formData.firstObject;

    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    self.doneButton.tintColor = theme.primaryColor;
    
    if ([self.formItem isKindOfClass:[ECSFormItemRadio class]])
    {
        [self.tableView registerNib:[ECSRadioTableViewCell ecs_nib] forCellReuseIdentifier:ECSRadioTableViewCellIdentifier];
        self.tableView.allowsMultipleSelection = NO;
    }
    else if ([self.formItem isKindOfClass:[ECSFormItemCheckbox class]])
    {
        [self.tableView registerNib:[ECSCheckboxTableViewCell ecs_nib] forCellReuseIdentifier:ECSCheckboxTableViewCellIdentifier];
        self.tableView.allowsMultipleSelection = YES;
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonTapped:(id)sender {

    NSMutableArray *responses = [NSMutableArray new];
    for (NSIndexPath *indexPath in [self.tableView indexPathsForSelectedRows])
    {
        NSString *responseString = nil;
        if ([self.formItem isKindOfClass:[ECSFormItemRadio class]])
        {
            responseString = ((ECSFormItemRadio*)self.formItem).options[indexPath.row];
            break; // We really should only have 1 thing but just in case break out of the loop.
        }
        else if ([self.formItem isKindOfClass:[ECSFormItemCheckbox class]])
        {
            responseString = ((ECSFormItemCheckbox*)self.formItem).options[indexPath.row];
        }
        
        if (responseString)
        {
            [responses addObject:[responseString stringByReplacingOccurrencesOfString:@"," withString:@"&comma;"]];
        }
    }
    
    if (responses.count > 0)
    {
        self.formItem.formValue = [responses componentsJoinedByString:@","];
    }
    
    if (self.delegate)
    {
        [self.delegate formCompleteWithItem:self.form];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (CGFloat)preferredHeight
{
    CGFloat height = CGRectGetHeight(self.toolbar.frame);
    
    if ([self.formItem isKindOfClass:[ECSFormItemRadio class]])
    {
        height += ((ECSFormItemRadio*)self.formItem).options.count * 44.0f;
    }
    else if ([self.formItem isKindOfClass:[ECSFormItemCheckbox class]])
    {
        height += ((ECSFormItemCheckbox*)self.formItem).options.count * 44.0f;
    }
    
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.formItem isKindOfClass:[ECSFormItemRadio class]])
    {
        ECSFormItemRadio *radio = ((ECSFormItemRadio*)self.formItem);
        
        return radio.options.count;
    }
    else if ([self.formItem isKindOfClass:[ECSFormItemCheckbox class]])
    {
        ECSFormItemCheckbox *checkbox = ((ECSFormItemCheckbox*)self.formItem);
        
        return checkbox.options.count;
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if ([self.formItem isKindOfClass:[ECSFormItemRadio class]])
    {
        ECSRadioTableViewCell *radioCell = [self.tableView dequeueReusableCellWithIdentifier:ECSRadioTableViewCellIdentifier
                                                                                forIndexPath:indexPath];
        
        ECSFormItemRadio *radioItem = (ECSFormItemRadio*)self.formItem;
        NSString* item = radioItem.options[indexPath.row];
        radioCell.choiceText = item;
        [radioCell setRadioSelected:[item isEqualToString:self.formItem.formValue]];

        cell = radioCell;

    }
    else if ([self.formItem isKindOfClass:[ECSFormItemCheckbox class]])
    {
        ECSCheckboxTableViewCell *checkboxCell = [self.tableView dequeueReusableCellWithIdentifier:ECSCheckboxTableViewCellIdentifier
                                                                                forIndexPath:indexPath];
        ECSFormItemCheckbox *checkboxItem = (ECSFormItemCheckbox*)self.formItem;

        NSString* item = checkboxItem.options[indexPath.row];
        checkboxCell.choiceText = item;
        NSArray *answerArray = [self.formItem.formValue componentsSeparatedByString:@","];
        checkboxCell.checked = [answerArray containsObject:item];

        cell = checkboxCell;
    }
    
    return cell;
}

@end
