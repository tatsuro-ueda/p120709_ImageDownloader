//
//  JDDownloadViewController.h
//  JpegDisplayTestByTatsuroUeda
//
//  Created by  on 12/07/05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JDDownloadViewController : UIViewController<UITextFieldDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    long long       _downloadedFileSize;
    long long       _expectedFileSize;
    NSURLAuthenticationChallenge    *_challenge;
}

@property (strong, nonatomic) IBOutlet UITextField *urlField;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet UIButton *syncDownloadButton;
@property (strong, nonatomic) IBOutlet UIButton *asyncDownloadButton;
@property (strong, nonatomic) NSURLConnection *urlConnection;
@property (strong, nonatomic) NSFileHandle *downloadedFileHandle;
@property (strong, nonatomic) NSString *downloadedFilePath;

- (IBAction)syncDownload:(id)sender;
- (IBAction)cancel:(id)sender;
- (NSString *)newFilePathWithURL:(NSURL *)url;
- (IBAction)asyncDownload:(id)sender;
- (void)connectionDidFailed;

@end
