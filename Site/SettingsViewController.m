//
//  SettingsViewController.m
//  Site
//
//  Created by Navigator on 4/29/15.
//  Copyright (c) 2015 OrangeSoft_Brest. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController () <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField* text_login;
@property (nonatomic, strong) IBOutlet UITextField* text_password;
@property (nonatomic, strong) IBOutlet UITextField* text_domens;
@property (nonatomic, strong) IBOutlet UITextField* text_active_url;
@property (nonatomic, strong) IBOutlet UITextField* text_access_url;
@property (nonatomic, strong) IBOutlet UITextField* text_status_url;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_LOGIN]) {
        self.text_login.text = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_LOGIN];
    }
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_PASSWORD]) {
        self.text_password.text = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_PASSWORD];
    }
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_DOMAINS]) {
        self.text_domens.text = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_DOMAINS];
    }
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_URL_ACTIVE]) {
        self.text_active_url.text = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_URL_ACTIVE];
    }
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_URL_ACCESS]) {
        self.text_access_url.text = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_URL_ACCESS];
    }
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_URL_STATUS]) {
        self.text_status_url.text = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_URL_STATUS];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tableView.rowHeight = 44.f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - TextField Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    
    NSString* text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField == self.text_login) {
        [[NSUserDefaults standardUserDefaults] setValue:text forKey:DEFAULTS_LOGIN];
    }
    else if (textField == self.text_password) {
        [[NSUserDefaults standardUserDefaults] setValue:text forKey:DEFAULTS_PASSWORD];
    }
    else if (textField == self.text_domens) {
        [[NSUserDefaults standardUserDefaults] setValue:text forKey:DEFAULTS_DOMAINS];
    }
    else if (textField == self.text_active_url) {
        [[NSUserDefaults standardUserDefaults] setValue:text forKey:DEFAULTS_URL_ACTIVE];
    }
    else if (textField == self.text_access_url) {
        [[NSUserDefaults standardUserDefaults] setValue:text forKey:DEFAULTS_URL_ACCESS];
    }
    else if (textField == self.text_status_url) {
        [[NSUserDefaults standardUserDefaults] setValue:text forKey:DEFAULTS_URL_STATUS];
    }
    
    return YES;
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
