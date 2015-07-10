//
//  AuthorizationViewController.m
//  Site
//
//  Created by Navigator on 7/10/15.
//  Copyright (c) 2015 OrangeSoft_Brest. All rights reserved.
//

#import "AuthorizationViewController.h"

@interface AuthorizationViewController ()

@property (nonatomic, strong) IBOutlet UITextField* loginTextField;
@property (nonatomic, strong) IBOutlet UITextField* passTextField;

@end

@implementation AuthorizationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tableView.rowHeight = 44.f;
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_LOGIN]) {
        self.loginTextField.text = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_LOGIN];
    }
     
     if ([[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_PASSWORD]) {
         self.passTextField.text = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_PASSWORD];
     }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        if ([self validateAutorization])
        {
            [self performSegueWithIdentifier:@"authorization" sender:self];
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
    
}

@end
