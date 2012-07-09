//
//  JDDownloadViewController.m
//  JpegDisplayTestByTatsuroUeda
//
//  Created by  on 12/07/05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JDDownloadViewController.h"

@implementation JDDownloadViewController
@synthesize urlField = _urlField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    [self setUrlField:nil];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // URLを入力するテキストフィールドかどうかをチェックする
    // しかし、実際には、このオブジェクトをデリゲートに指定したテキストフィールドは
    // １つなので、このif文は常に成り立つ
    if ([textField isEqual:self.urlField]) 
    {
        // ソフトウェアキーボードを閉じる
        [self.urlField resignFirstResponder];
        
        return NO;
    }
    else 
    {
        return YES;
    }
}

// 同期ダウンロードボタンの処理
- (IBAction)syncDownload:(id)sender {
    
    // 入力されているURLを取得する
    NSURL* url = [NSURL URLWithString:self.urlField.text];
    NSLog(@"%@", url);
    
    // URLの構文が間違っているときなど、「NSURL」のインスタンスが
    // 作成できないときはエラーメッセージを表示する
    if (!url)
    {
        NSString *errMsg, *errTitle, *cancelButton;
        UIAlertView *alertView;
        
        // 表示する文字列
        errTitle = @"Error";
        errMsg = @"The URL is invalid.";
        cancelButton = @"OK";
        
        // アラートビューを表示する
        alertView = [[UIAlertView alloc] initWithTitle:errTitle 
                                               message:errMsg 
                                              delegate:nil
                                     cancelButtonTitle:cancelButton
                                     otherButtonTitles:nil];
        [alertView show];
        
        // 処理終了
        return;
    }
    
    // URLからダウンロードする
    NSError *error = nil;
    NSData *data;
    BOOL isSccessed = NO;
    
    data = [NSData dataWithContentsOfURL:url
                                 options:0
                                   error:&error];
//    NSLog(@"%@", data);    
    
    // ダウンロードに成功したらファイルに保存して、ダウンロード画面を閉じる
    if (data) {
        
        // ダウンロード成功
        // ファイル名を決定する
        NSString *filePath = [self newFilePathWithURL:url];
        NSLog(@"%@", filePath);
        
        // ファイルに保存する
        isSccessed = [data writeToFile:filePath
                               options:NSDataWritingAtomic
                                 error:&error];
    }
    
    // ファイルの保存まで成功したらダウンロード画面を閉じる
    if (isSccessed) {
        
        [self dismissModalViewControllerAnimated:YES];
    }
    else
    {
        // エラーメッセージを表示する
        NSString *errMsg, *errTitle, *cancelButton;
        UIAlertView *alertView;
        
        // 表示する文字列
        errTitle = @"Download Error";
        cancelButton = @"OK";
        errMsg = @"Couldn't download the file.";
        
        // エラー情報が取得できたときは、エラー情報からの文字列を追加する
        if (error) {
            
            errMsg = [errMsg stringByAppendingString:
                      [error localizedDescription]];
        }
        
        // アラートビューを表示する
        alertView = [[UIAlertView alloc] initWithTitle:errTitle
                                               message:errMsg
                                              delegate:nil
                                     cancelButtonTitle:cancelButton
                                     otherButtonTitles:nil];
        [alertView show];
    }
}

- (IBAction)cancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

// 新しいファイルのファイルパスを取得する
- (NSString *)newFilePathWithURL:(NSURL *)url
{
    // URLからベースになっているファイル名を取得する
    NSString *basename = [[[url path] lastPathComponent] stringByDeletingPathExtension];
    NSLog(@"%@", basename);
    
    // ファイル名が取得できなかったときは、固定の名前を使用する
    if ([basename length] == 0 || [basename isEqual:@"/"]) {
        
        basename = @"NewFile";
    }
    
    // 拡張子を取得する
    NSString *extension = [[url path] pathExtension];
    NSLog(@"%@", extension);
    
    // 「Documents」ディレクトリのパスを取得する
    NSString *docDirPath =
        [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                             NSUserDomainMask, 
                                             YES) lastObject];
    
    // ループさせながらユニークなファイル名を決定する
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSInteger counter = 1;
    NSString *newFilePath = nil;
    
    while (1) {
        
        NSString *tempFilePath;
        
        if (counter == 1) {
            
            // まずは連番をつけずに、元ファイルの名前をそのまま使用する
            tempFilePath = [docDirPath stringByAppendingPathComponent:basename];
            NSLog(@"%@", tempFilePath);
        }
        else
        {
            // 元ファイルの名前に連番を追加する
            tempFilePath = 
                [NSString stringWithFormat:@"%@%d", basename, counter];
            tempFilePath =
            [docDirPath stringByAppendingPathComponent:tempFilePath];
        }
        
        // 拡張子があれば追加する
        if ([extension length] > 0) {
            
            tempFilePath =
            [tempFilePath stringByAppendingPathExtension:extension];
            NSLog(@"%@", tempFilePath);
        }
        
        // ファイルが存在するかチェックする
        BOOL rt = [fileManager fileExistsAtPath:tempFilePath];
        NSLog(@"rt = %d", rt);
        if (![fileManager fileExistsAtPath:tempFilePath]) {
//        if (YES) {
            
//            break;
            return tempFilePath;
        }
        
        counter++;
        
    }
    return newFilePath;
}

@end