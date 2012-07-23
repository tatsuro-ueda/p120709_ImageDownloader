//
//  JDDetailViewController.m
//  JpegDisplayTestByTatsuroUeda
//
//  Created by  on 12/07/03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JDDetailViewController.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"

@interface JDDetailViewController ()
@end

@implementation JDDetailViewController

@synthesize imageView = _imageView;
@synthesize filePath = _filePath;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _filePath = nil;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // ナビゲーションバーのタイトルにファイル名を表示する
    self.title = _filePath.lastPathComponent;
    
    // 画像ファイルを読み込む
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:self.filePath];
    
    if (img) {
        
        // イメージビューにセットする
        self.imageView.image = img;
        
        // 念のため、再描画するように設定する
        [self.imageView setNeedsDisplay];
    }
    else {
        
        // 読み込みに失敗したときはエラーメッセージを表示する
        NSString *title = @"Error";
        NSString *buttonTitle = @"OK";
        NSString *msg = @"Couldn't load the image.";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:nil
                                              cancelButtonTitle:buttonTitle
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)upload:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://192.168.100.203:4567/"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSData *imageData = UIImageJPEGRepresentation([UIImage imageNamed:_filePath.lastPathComponent], 0.5);
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"/upload" parameters:nil constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFileData:imageData name:@"file" fileName:_filePath.lastPathComponent mimeType:@"image/jpeg"];
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    [operation setUploadProgressBlock:^(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite) {
//        NSLog(@"Sent %d of %d bytes", totalBytesWritten, totalBytesExpectedToWrite);
//    }];
    [operation start];
}
@end
