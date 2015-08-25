//
//  AuthorizationViewController.m
//  Site
//
//  Created by Navigator on 7/10/15.
//  Copyright (c) 2015 OrangeSoft_Brest. All rights reserved.
//

#import "AuthorizationViewController.h"
#import "MBProgressHUD.h"

@interface AuthorizationViewController () <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField* loginTextField;
@property (nonatomic, strong) IBOutlet UITextField* passTextField;
@property (nonatomic, strong) IBOutlet UISwitch* autologinSwitch;

@end

@implementation AuthorizationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.autologinSwitch setOn:[K9ServerProvider shared].autologin];
    if (self.autologinSwitch.isOn) {
        if ([K9ServerProvider shared].login) {
            self.loginTextField.text = [K9ServerProvider shared].login;
            
            if ([K9ServerProvider shared].password) {
                self.passTextField.text = [K9ServerProvider shared].password;
            }
        }
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

#pragma - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0) {
        [self hideKeyboard];
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        if ([self validateAutorization])
        {
            [[K9ServerProvider shared] setLogin:self.loginTextField.text];
            [[K9ServerProvider shared] setPassword:self.passTextField.text];
            [[K9ServerProvider shared] saveSettings];
         
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[K9ServerProvider shared] authorizationWithLogin:self.loginTextField.text password:self.passTextField.text completed:^(AuthorizationResponse *result, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!error && result.success.boolValue) {
                        [self performSegueWithIdentifier:@"authorization" sender:self];
                    }
                    else {
                        [self showMessageWithMessage:@"Ошибка логина" delegate:nil];
                    }                    
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
            }];
        }
    }    
}

- (BOOL)validateAutorization
{
    if (self.loginTextField.text.length == 0) {
        
        [self showMessageWithMessage:@"Введите логин" delegate:nil];
        return NO;
    }
    
    if (self.passTextField.text.length == 0) {
        [self showMessageWithMessage:@"Введите пароль" delegate:nil];
        return NO;
    }
    
    return YES;
}

- (void)showMessageWithMessage:(NSString*)message delegate:(id)delegate
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Внимание" message:message delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    });
}

- (IBAction)onAutoLoginSwith:(UISwitch*)sender
{
    if (sender == self.autologinSwitch) {
        [[K9ServerProvider shared] setAutologin:sender.isOn];
        [[K9ServerProvider shared] saveSettings];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"authorization"]) {
        return NO;
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self hideKeyboard];
}

- (void)hideKeyboard
{
    [self.loginTextField resignFirstResponder];
    [self.passTextField resignFirstResponder];
}

@end
