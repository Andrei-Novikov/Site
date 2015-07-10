//
//  MainViewController.m
//  Site
//
//  Created by Navigator on 4/29/15.
//  Copyright (c) 2015 OrangeSoft_Brest. All rights reserved.
//

#import "MainViewController.h"
#import "MBProgressHUD.h"
#import "TableViewCell.h"

#define ENABLED YES

@interface MainViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UILabel* center_label;
@property (nonatomic, strong) IBOutlet UISwitch* switch_active;
@property (nonatomic, strong) IBOutlet UISwitch* switch_access;
@property (nonatomic, strong) UIAlertController* messageAlert;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize the refresh control.
    if (self.refreshControl == nil) {
        self.refreshControl = [[UIRefreshControl alloc] init];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:@"Обновление"];
        self.refreshControl.attributedTitle = attributedTitle;
        [self.refreshControl addTarget:self action:@selector(getLastState) forControlEvents:UIControlEventValueChanged];
    }else {
        [self.refreshControl endRefreshing];
    }

    self.center_label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0, 200.f, 40.f)];
    self.center_label.text = @"НЕОБХОДИМО ВВЕСТИ НАСТРОЙКИ";
    self.center_label.textAlignment = NSTextAlignmentCenter;
    self.center_label.numberOfLines = 2;
    self.center_label.lineBreakMode = NSLineBreakByWordWrapping;
    self.center_label.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.f];
    
    [self.center_label setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.tableView addSubview:self.center_label];
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.center_label
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.0
                                                                constant:0.0]];
    
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.center_label
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1.0
                                                                constant:0.0]];
    
    [self.center_label addConstraint:[NSLayoutConstraint constraintWithItem:self.center_label
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.0
                                                                   constant:40.0]];
    
    [self.center_label addConstraint:[NSLayoutConstraint constraintWithItem:self.center_label
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.0
                                                                   constant:200.0]];    
    
    [self updateViewConstraints];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tableView.rowHeight = 44.f;
    
    [self getLastState];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.tableView.contentOffset = CGPointZero;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([[K9ServerProvider shared] validateSettings]) {
        return 1;
    }
    return 0;
}

#pragma mark - Switch
- (void)getLastState
{
    self.tableView.userInteractionEnabled = NO;
    self.tableView.userInteractionEnabled = NO;
    
    if ([[K9ServerProvider shared] validateSettings]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.center_label.hidden = YES;
        self.tableView.scrollEnabled = YES;
        
        __weak typeof(self) weakSelf = self;
        [[K9ServerProvider shared] getStatus:nil completed:^(GetStateResponse *response, NSError *error) {
            if (![K9ServerProvider showServerError:error])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.switch_access.on = response.domain_data.user_enable.boolValue;
                    weakSelf.switch_active.on = response.domain_data.site_enable.boolValue;
                });
            }
            [weakSelf hideHUD];
        }];
    }
    else {
        self.center_label.hidden = NO;
        self.tableView.scrollEnabled = NO;
        [self hideHUD];
    }
}

- (void)hideHUD {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
        self.tableView.userInteractionEnabled = YES;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

- (IBAction)onSwitchActive:(id)sender
{
    if (ENABLED) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        SetActiveRequest* request = [SetActiveRequest new];
        request.enabled = [NSNumber numberWithBool:self.switch_active.isOn];
        
        __weak typeof(self) weakSelf = self;
        [[K9ServerProvider shared] setActive:request completed:^(SetActiveResponse *result, NSError *error) {
            if (!error) {
                weakSelf.switch_active.on = result.domain_data.site_enable.boolValue;
            }
            else {
                [weakSelf showServerErrorMessage:error];
            }
            [weakSelf hideHUD];
        }];
    }
}

- (IBAction)onSwitchAccess:(id)sender
{
    if (ENABLED) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        SetAccessRequest* request = [SetAccessRequest new];
        request.enabled = [NSNumber numberWithBool:self.switch_access.isOn];
        
        __weak typeof(self) weakSelf = self;
        [[K9ServerProvider shared] setAccess:request completed:^(SetAccessResponse *result, NSError *error) {
            if (!error) {
                weakSelf.switch_access.on = result.domain_data.user_enable.boolValue;
            }
            else {
                [weakSelf showServerErrorMessage:error];
            }
            [weakSelf hideHUD];
        }];
    }
}

- (void)showServerErrorMessage:(NSError*)error
{
    if (!self.messageAlert)
    {
        NSString* title = @"";
        NSString* message = @"";
        if (error.userInfo[@"K9ErrorUserInfo"])
        {
            NSDictionary* data = error.userInfo[@"K9ErrorUserInfo"][@"data"];
            if (data)
            {
                title = [NSString stringWithFormat:@"Ошибка сервера %@ - %@", data[@"status"], data[@"name"]];
                message = data[@"message"];
            }
            else if (error.userInfo[@"K9ErrorUserInfo"][@"status"] && error.userInfo[@"K9ErrorUserInfo"][@"message"])
            {
                title = [NSString stringWithFormat:@"Ошибка сервера %@ - %@", error.userInfo[@"K9ErrorUserInfo"][@"status"], error.userInfo[@"K9ErrorUserInfo"][@"name"]];
                message = error.userInfo[@"K9ErrorUserInfo"][@"message"];
            }
        }
        else {
            message = error.userInfo[@"NSLocalizedDescription"];
            title = @"Server error";
        }
        [self showAlertMessage:message title:title];
    }
}

- (void)showAlertMessage:(NSString*)message title:(NSString*)title
{
    self.messageAlert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         self.messageAlert = nil;
                                                     }];
    [self.messageAlert addAction:okAction];
    [self presentViewController:self.messageAlert animated:YES completion:^{
        
    }];
}

@end