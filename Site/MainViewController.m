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
@property (nonatomic, strong) UISwitch* switch_active;
@property (nonatomic, strong) UISwitch* switch_access;
@property (nonatomic, strong) NSArray* domains;
@property (nonatomic, strong) NSMutableDictionary* statuses;
@property (nonatomic, strong) UIAlertController* messageAlert;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.domains = [NSMutableArray array];
    self.statuses = [NSMutableDictionary dictionary];
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
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_DOMAINS]) {
        [self parseDomainString:[[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_DOMAINS]];
    }
    else {
        self.center_label.hidden = NO;
    }
    
    // Initialize the refresh control.
    if (self.refreshControl == nil) {
        self.refreshControl = [[UIRefreshControl alloc] init];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:@"Обновление"];
        self.refreshControl.attributedTitle = attributedTitle;
        [self.refreshControl addTarget:self action:@selector(getLastState) forControlEvents:UIControlEventValueChanged];
    }else {
        [self.refreshControl endRefreshing];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.tableView.contentOffset = CGPointZero;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.domains.count) {
        return 0;
    }
    return self.domains.count + 1;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"ОБЩИЕ НАСТРОЙКИ ДЛЯ ВСЕХ ДОМЕНОВ";
    }
    return [NSString stringWithFormat:@"ДОМЕН %@", self.domains[section - 1]];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    DomainData* domain;
    if (indexPath.section != 0) {
        domain = [self.statuses valueForKey:self.domains[indexPath.section - 1]];
    }
    else if (self.domains.count && self.statuses.count) {
        domain = [self.statuses valueForKey:self.domains[0]];
    }
        
    if (indexPath.row == 0) {
        cell.m_switch.on = (domain) ? domain.site_enable.boolValue : NO;
        [cell.m_switch addTarget:self action:@selector(onSwitchActive:) forControlEvents:UIControlEventValueChanged];
    }else {
        cell.m_switch.on = (domain) ? domain.user_enable.boolValue : NO;
        [cell.m_switch addTarget:self action:@selector(onSwitchAccess:) forControlEvents:UIControlEventValueChanged];
    }
    
    cell.m_text.text = (indexPath.row == 0) ? @"Активность сайта" : @"Доступ пользователям";
    cell.m_switch.tag = indexPath.section;
    
    return cell;
}

#pragma mark - Switch
- (void)getLastState
{
    self.tableView.userInteractionEnabled = NO;
    self.tableView.userInteractionEnabled = NO;
    
    if (ENABLED) {
        if (self.domains.count) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            self.center_label.hidden = YES;
            
            __block NSInteger counter = self.domains.count;
            self.statuses = [NSMutableDictionary dictionary];
            for (NSInteger index = 0; index < self.domains.count; ++index) {
                __block NSString* domain = self.domains[index];
                GetStateRequest* request = [GetStateRequest new];
                request.user = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_LOGIN];
                request.pass = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_PASSWORD];
                [[K9ServerProvider shared] getStatus:request domain:domain completed:^(GetStateResponse *response, NSError *error) {
                    if (![K9ServerProvider showServerError:error])
                    {
                        [self.statuses setValue:response.domain_data forKey:domain];
                    }
                    --counter;
                    if (!counter) {
                        [self hideHUD];
                    }
                }];
            }
        }else {
            self.center_label.hidden = NO;
            [self hideHUD];
        }
    }
}

- (void)hideHUD {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
        self.tableView.userInteractionEnabled = YES;
        self.tableView.userInteractionEnabled = YES;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

- (IBAction)onSwitchActive:(id)sender
{
    if (ENABLED) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        __block UISwitch* p_switch = (UISwitch*)sender;
        __weak typeof(self) weakSelf = self;
        if (p_switch.tag == 0) {
            __block NSInteger counter = self.domains.count;
            for (NSInteger index = 0; index < self.domains.count; ++index) {
                [self setActive:p_switch.isOn domain:index completed:^{
                    --counter;
                    if (!counter) {
                        [weakSelf hideHUD];
                    }
                }];
            }
        }else {
            [self setActive:p_switch.isOn domain:p_switch.tag - 1 completed:^{
                [weakSelf hideHUD];
            }];
        }
    }
}

- (void)setActive:(BOOL)status domain:(NSInteger)domain_index completed:(void(^)())completed
{
    SetActiveRequest* request = [SetActiveRequest new];
    request.user    = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_LOGIN];
    request.pass    = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_PASSWORD];
    request.enabled = [NSNumber numberWithBool:status];
    
    __block NSString* domain = self.domains[domain_index];
    
    [[K9ServerProvider shared] setActive:request domain:(NSString*)domain completed:^(SetActiveResponse *result, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                DomainData* domainData = self.statuses[domain];
                domainData.site_enable = result.domain_data.site_enable;
                [self.statuses setValue:domainData forKey:domain];
            }else {
                [self showServerErrorMessage:error];
            }
            
            if (completed) {
                completed();
            }
        });
    }];
}

- (IBAction)onSwitchAccess:(id)sender
{
    if (ENABLED) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        __block UISwitch* p_switch = (UISwitch*)sender;
        __weak typeof(self) weakSelf = self;
        if (p_switch.tag == 0) {
            __block NSInteger counter = self.domains.count;
            for (NSInteger index = 0; index < self.domains.count; ++index) {
                [self setAccess:p_switch.isOn domain:index completed:^{
                    --counter;
                    if (!counter) {
                        [weakSelf hideHUD];
                    }
                }];
            }
        }else {
            [self setAccess:p_switch.isOn domain:p_switch.tag - 1 completed:^{
                [weakSelf hideHUD];
            }];
        }
    }
}

- (void)setAccess:(BOOL)status domain:(NSInteger)domain_index completed:(void(^)())completed
{
    SetAccessRequest* request = [SetAccessRequest new];
    request.user    = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_LOGIN];
    request.pass    = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_PASSWORD];
    request.enabled = [NSNumber numberWithInt:(int)status];//numberWithBool:status];
    
    __block NSString* domain = self.domains[domain_index];
    
    [[K9ServerProvider shared] setAccess:request domain:(NSString*)domain completed:^(SetAccessResponse *result, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                DomainData* domainData = self.statuses[domain];
                domainData.user_enable = result.domain_data.user_enable;
                [self.statuses setValue:domainData forKey:domain];
            }else {
                [self showServerErrorMessage:error];
            }
            
            if (completed) {
                completed();
            }
        });
    }];
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
                title = [NSString stringWithFormat:@"Ошибка сервера %@", data[@"status"]];
                message = data[@"message"];
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

- (void)parseDomainString:(NSString*)domain_string
{
    if (domain_string.length) {
        self.domains = [domain_string componentsSeparatedByString: @","];
    }else {
        self.domains = [NSArray array];
    }
    [self getLastState];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end