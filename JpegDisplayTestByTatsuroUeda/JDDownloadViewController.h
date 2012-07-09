//
//  JDDownloadViewController.h
//  JpegDisplayTestByTatsuroUeda
//
//  Created by  on 12/07/05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JDDownloadViewController : UIViewController<UITextFieldDelegate>
{
    UITextField* _urlField;
}
@property (strong, nonatomic) IBOutlet UITextField *urlField;

- (IBAction)syncDownload:(id)sender;
- (IBAction)cancel:(id)sender;
- (NSString *)newFilePathWithURL:(NSURL *)url;

@end
