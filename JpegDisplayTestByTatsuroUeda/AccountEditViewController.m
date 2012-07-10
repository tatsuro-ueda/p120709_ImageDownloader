//
//  AccountEditViewController.m
//  JpegDisplayTestByTatsuroUeda
//
//  Created by  on 12/07/10.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AccountEditViewController.h"

@implementation AccountEditViewController
@synthesize userNameField = _userNameField;
@synthesize passwordField = _passwordField;
@synthesize authenticationChallenge = _authenticationChallenge;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        // メンバ変数を初期化する
        _authenticationChallenge = nil;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [self setUserNameField:nil];
    [self setPasswordField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

- (IBAction)logIn:(id)sender {
    
    // 認証を行う必要があるか
    NSURLAuthenticationChallenge *challenge;
    challenge = self.authenticationChallenge;
    
    if (challenge) {
        
        // 認証情報を作成する
        NSURLCredential *credential;
        
        credential = [NSURLCredential credentialWithUser:self.userNameField.text
                                                password:self.passwordField.text
                                             persistence:NSURLCredentialPersistenceNone];
        // 認証を行う
        [challenge.sender useCredential:credential
             forAuthenticationChallenge:challenge];
    }
    
    // モーダル終了処理
    // アニメーション中に「DownloadViewController」クラス内の
    // 「dismissModalViewControllerAnimated:」メソッドが
    // 呼ばれることを防止するために、ここではアニメーションしない
    [self dismissModalViewControllerAnimated:NO];
}

- (IBAction)cancel:(id)sender {
    
    // 認証をキャンセルする
    NSURLAuthenticationChallenge *challenge;
    challenge = self.authenticationChallenge;
    
    [challenge.sender cancelAuthenticationChallenge:challenge];
    
    // モーダル終了処理
    // アニメーション中に「DownloadViewController」クラス内の
    // 「dismissModalViewControllerAnimated:」メソッドが
    // 呼ばれることを防止するために、ここではアニメーションしない
    [self dismissModalViewControllerAnimated:NO];
}

// ソフトウェアキーボードの「Next」ボタン、もしくは「Go」ボタンがタップされたときの処理
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.userNameField]) {
        
        // ユーザー名入力フィールドのときは、パスワード入力フィールドに移動する
        [self.passwordField becomeFirstResponder];
        return NO;
    }
    else if ([textField isEqual:self.passwordField])
    {
        // パスワード入力フィールドのときは、
        // 「Log In」ボタンがタップされたときの処理を行う
        [self logIn:nil];
        return NO;
    }
    else {
        return YES; // デフォルトの処理を行う
    }
}
@end
