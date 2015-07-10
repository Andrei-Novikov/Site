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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tableView.rowHeight = 44.f;
    self.text_domens.text     = [[K9ServerProvider shared] domain];
    self.text_access_url.text = [[K9ServerProvider shared] userAccessPath];
    self.text_active_url.text = [[K9ServerProvider shared] siteActivePath];
    self.text_status_url.text = [[K9ServerProvider shared] currentStatePath];
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
    
    if (textField == self.text_domens) {
        [[K9ServerProvider shared] setDomain:text];
    }
    else if (textField == self.text_active_url) {
        [[K9ServerProvider shared] setSiteActivePath:text];
    }
    else if (textField == self.text_access_url) {
        [[K9ServerProvider shared] setUserAccessPath:text];
    }
    else if (textField == self.text_status_url) {
        [[K9ServerProvider shared] setCurrentState:text];;
    }
    [[K9ServerProvider shared] saveSettings];
    
    return YES;
}

@end
