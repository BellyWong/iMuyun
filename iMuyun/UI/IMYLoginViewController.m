//
//  IMYLoginViewController.m
//  iMuyun
//
//  Created by lancy on 12-7-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "IMYLoginViewController.h"
#import "MBProgressHUD.h"
#import "SFHFKeychainUtils.h"

@interface IMYLoginViewController ()

@end

@implementation IMYLoginViewController
//@synthesize usernameTextField;
//@synthesize passwordTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoadt
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setUsernameTextField:nil];
    [self setPasswordTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)tapTheLoginButton:(id)sender {
    [[IMYHttpClient shareClient] requestLoginWithUsername:self.usernameTextField.text 
                                                 password:self.passwordTextField.text 
                                                 delegate:self];
    MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hub.labelText = @"Login...";
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSError *error;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[request responseData] options:kNilOptions error:&error];
    NSLog(@"%@", result);
    if ([[result valueForKey:@"requestType"] isEqualToString:@"login"]) {
        if ([[result valueForKey:@"message"] isEqualToString:@"success"]) {
            [[NSUserDefaults standardUserDefaults] setValue:[result valueForKey:@"myInfo"] forKey:@"myInfo"];
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSString *username = self.usernameTextField.text;
            NSString *password = self.passwordTextField.text;
            NSError *error;
            [SFHFKeychainUtils storeUsername:username andPassword:password forServiceName:@"iMuyun" updateExisting:TRUE error:&error];
            
            
//            [self performSegueWithIdentifier:@"login" sender:self];
            [self dismissModalViewControllerAnimated:YES];
        } else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    }
}

@end
