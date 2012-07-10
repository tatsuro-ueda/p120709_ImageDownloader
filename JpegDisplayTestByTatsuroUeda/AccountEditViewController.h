//
//  AccountEditViewController.h
//  JpegDisplayTestByTatsuroUeda
//
//  Created by  on 12/07/10.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountEditViewController : UIViewController<UITextFieldDelegate>

// プロパティの定義
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (retain, nonatomic) NSURLAuthenticationChallenge* authenticationChallenge;

- (IBAction)logIn:(id)sender;
- (IBAction)cancel:(id)sender;
@end
