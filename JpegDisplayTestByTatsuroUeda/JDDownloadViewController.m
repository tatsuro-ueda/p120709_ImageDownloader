//
//  JDDownloadViewController.m
//  JpegDisplayTestByTatsuroUeda
//
//  Created by  on 12/07/05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JDDownloadViewController.h"
#import "AccountEditViewController.h"

@implementation JDDownloadViewController
@synthesize urlField = _urlField;
@synthesize progressView = _progressView;
@synthesize syncDownloadButton = _syncDownloadButton;
@synthesize asyncDownloadButton = _asyncDownloadButton;
@synthesize urlConnection = _urlConnection;
@synthesize downloadedFileHandle = _downloadedFileHandle;
@synthesize downloadedFilePath = _downloadedFilePath;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        // メンバ変数を初期化する
        _urlConnection = nil;
        _downloadedFileHandle = nil;
        _downloadedFilePath = nil;
        _downloadedFileSize = 0;
        _expectedFileSize = 0;
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
    [self setProgressView:nil];
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
//    NSLog(@"%@", url);
    
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
//        NSLog(@"%@", filePath);
        
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

// キャンセルボタンの処理
- (IBAction)cancel:(id)sender {
    
    // プロパティ「urlConnection」が「nil」でないときは、非同期接続中とみなす
    if (self.urlConnection) {
        
        // 接続処理をキャンセルする
        [self.urlConnection cancel];
        
        // 後処理を呼び出す
        [self connectionDidFailed];
    }
    else {
        
        // ビューコントローラを閉じる
        [self dismissModalViewControllerAnimated:YES];
    }
}

// 新しいファイルのファイルパスを取得する
// URLからファイル名を取得し、ローカルのDocumentsフォルダに格納するようなパスを返す
- (NSString *)newFilePathWithURL:(NSURL *)url
{
    // URLからベースになっているファイル名を取得する
    NSString *basename = [[[url path] lastPathComponent] stringByDeletingPathExtension];
//    NSLog(@"%@", basename);
    
    // ファイル名が取得できなかったときは、固定の名前を使用する
    if ([basename length] == 0 || [basename isEqual:@"/"]) {
        
        basename = @"NewFile";
    }
    
    // 拡張子を取得する
    NSString *extension = [[url path] pathExtension];
//    NSLog(@"%@", extension);
    
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
//            NSLog(@"%@", tempFilePath);
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
//            NSLog(@"%@", tempFilePath);
        }
        
        // ファイルが存在するかチェックする
        BOOL rt = [fileManager fileExistsAtPath:tempFilePath];
//        NSLog(@"rt = %d", rt);
        if (![fileManager fileExistsAtPath:tempFilePath]) {
//        if (YES) {
            
//            break;
            return tempFilePath;
        }
        
        counter++;
        
    }
    return newFilePath;
}

// 非同期ダウンロードボタンの処理
- (IBAction)asyncDownload:(id)sender {
    
    // 入力されているURLを取得する
    NSURL *url = [NSURL URLWithString:self.urlField.text];
    
    // URLの構文が間違っているときなど、「NSURL」のインスタンスが
    // 作成できないときはエラーメッセージを表示する
    if (!url) {
        
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
    // ソフトウェアキーボードを非表示にする
    [self.urlField resignFirstResponder];
    
    // ダウンロードしたファイルを書き込むファイルを作成する
    NSString *filePath = [self newFilePathWithURL:url];
    
    [[NSFileManager defaultManager] createFileAtPath:filePath
                                            contents:nil
                                          attributes:nil];
    self.downloadedFilePath = filePath;
    
    self.downloadedFileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    
    // 取得要求の作成
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
    // 接続開始
    self.urlConnection = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    
    // ダウンロード中はボタンは無効にする
    self.syncDownloadButton.enabled = NO;
    self.asyncDownloadButton.enabled = NO;
    
    // プログレスビューをリセットしてから表示する
    self.progressView.progress = 0;
    self.progressView.hidden = NO;
    
    // ファイルサイズをクリアする
    _expectedFileSize = _downloadedFileSize = 0;
}

// ダウンロード完了時に呼ばれるメソッド
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // ダウンロードが完了したので、ファイルハンドルを閉じる
    [self.downloadedFileHandle synchronizeFile];
    [self.downloadedFileHandle closeFile];
    self.downloadedFileHandle = nil;
    
    // ダウンロード画面を閉じる
    [self dismissModalViewControllerAnimated:YES];
    
    // 接続情報を破棄
    self.urlConnection = nil;
    self.downloadedFilePath = nil;
}

// 読み込み失敗時に呼ばれるメソッド
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // エラーメッセージを表示する
    NSString *errMsg, *errTitle, *cancelButton;
    UIAlertView *alertView;
    
    // 表示する文字列
    errTitle = @"Download Error";
    cancelButton = @"OK";
    errMsg = @"Couldn't download the file. ";
    
    // エラー情報が取得できたときは、エラー情報からの文字列を追加する
    if (error) {
        
        errMsg = [errMsg stringByAppendingString:[error localizedDescription]];
    }
    
    // アラートビューを表示する
    alertView = [[UIAlertView alloc] initWithTitle:errTitle
                                           message:errMsg
                                          delegate:nil
                                 cancelButtonTitle:cancelButton
                                 otherButtonTitles:nil];
    [alertView show];
    
    // 後処理を呼び出す
    [self connectionDidFailed];
}

// レスポンスを受け取った直後に呼ばれるメソッド
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // もし、「response」が「NSHTTPURLResponse」ならば
    // HTTPのステータスコードもチェックする
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        
        // HTTPのステータスコードが400以上ならエラー扱いとする
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        
        if (statusCode >= 400) {
            
            // HTTPのステータスコードとエラーメッセージを渡す
            NSError *error;
            NSString *errStr;
            NSDictionary *userInfo = nil;
            
            errStr = [NSHTTPURLResponse localizedStringForStatusCode:statusCode];
            if (errStr) {
                
                // 「NSError」クラスの「localizedDescription」メソッドで
                // 取得されるエラーメッセージを設定する
                userInfo = [NSDictionary dictionaryWithObject:errStr 
                                                       forKey:NSLocalizedDescriptionKey];
            }
            error = [NSError errorWithDomain:@"HTTPErrorDomain" 
                                        code:statusCode
                                    userInfo:userInfo];
            [self connection:connection
            didFailWithError:error];
            
            return;
        }
    }
    // ダウンロードするファイルのファイルサイズを取得する
    _expectedFileSize = response.expectedContentLength;
}

// データ受信時に呼ばれるメソッド
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // 受信したデータをファイルに書き込む
    [self.downloadedFileHandle writeData:data];
    
    // ダウンロードするファイルのファイルサイズが取得できていたら
    // プログレスビューを更新する
    _downloadedFileSize += data.length;
    
    if (_expectedFileSize > 0) {
        
        self.progressView.progress = (double)_downloadedFileSize / (double)_expectedFileSize;
    }
}

// 接続処理失敗時の後処理を行う
- (void)connectionDidFailed
{
    // ダウンロードが失敗したので、ファイルを閉じる
    [self.downloadedFileHandle synchronizeFile];
    [self.downloadedFileHandle closeFile];
    self.downloadedFileHandle = nil;
    
    // 中途半端になっているので、ファイルも削除する
    [[NSFileManager defaultManager] removeItemAtPath:self.downloadedFilePath
                                               error:NULL];
    
    // ダウンロードに関する情報を破棄する
    self.urlConnection = nil;
    self.downloadedFilePath = nil;
    
    // URLを入力し直して、ダウンロードできるようボタンを有効化する
    self.syncDownloadButton.enabled = YES;
    self.asyncDownloadButton.enabled = YES;
    
    // プログレスビューを非表示
    self.progressView.hidden = YES;
}

// 認証情報が要求されたときに呼ばれるメソッド
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    // 認証の失敗回数を取得する
    NSInteger count = challenge.previousFailureCount;
    
    if (count == 0) {
        
        // 最初の認証要求なのでアカウント入力画面を表示する
        NSString *method;
        method = challenge.protectionSpace.authenticationMethod;
        
        // HTTPベーシック認証のみ対応する
        if ([method isEqualToString:NSURLAuthenticationMethodHTTPBasic]) {
            
            // アカウント入力画面を表示する
            NSLog(@"Authentication Required");
            _challenge = challenge;
            [self performSegueWithIdentifier:@"authentication" sender:self];
//            AccountEditViewController *accountView;
//            
//            accountView = [[AccountEditViewController alloc] initWithNibName:nil
//                                                                      bundle:nil];
//            accountView.authenticationChallenge = challenge;
//            [self presentModalViewController:accountView animated:YES]
        }
        else {
            
            // 対応していない認証方法なのでキャンセルして、エラーメッセージを表示する
            [challenge.sender cancelAuthenticationChallenge:challenge];
            
            // エラーメッセージを表示する
            NSString *title = @"Authentication Error";
            NSString *msg = @"The authentication method is not supported.";
            
            UIAlertView *alertView;
            
            alertView = [[UIAlertView alloc] initWithTitle:title
                                                   message:msg
                                                  delegate:nil
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil];
            [alertView show];
        }
    }
    else {
        
        // 既に失敗しているのでキャンセルして、エラーメッセージを表示する
        [challenge.sender cancelAuthenticationChallenge:challenge];
        
        // エラーメッセージを表示する
        NSString *title = @"Authentication Error";
        NSString *msg = @"User Name or Password is invalid";
        UIAlertView *alertView;
        
        alertView = [[UIAlertView alloc]initWithTitle:title
                                              message:msg
                                             delegate:nil
                                    cancelButtonTitle:@"OK"
                                    otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    AccountEditViewController *controller = segue.destinationViewController;
    controller.authenticationChallenge = _challenge;
}
@end
