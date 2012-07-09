//
//  JDMasterViewController.m
//  JpegDisplayTestByTatsuroUeda
//
//  Created by  on 12/07/03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JDMasterViewController.h"
#import "JDDetailViewController.h"

@implementation JDMasterViewController

// プロパティとメンバ変数の設定
@synthesize filePathArray = _filePathArray;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // メンバ変数を初期化する
    _filePathArray = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

// ビューが表示される直前に呼ばれるメソッド
- (void)viewWillAppear:(BOOL)animated
{
    // 親クラスの処理を呼び出す
    [super viewWillAppear:animated];
    
    // 「Documents」ディレクトリ内のファイルを検索する
    NSMutableArray* array = [self scanDocumentsDirectory];
    
    // メンバ変数に設定する
    self.filePathArray = array;
    
    // テーブルを再読み込みする
    [self.tableView reloadData];
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

#pragma mark Table View data source

// 「Documents」ディレクトリ内を走査して、ファイルを取得する
- (NSMutableArray*)scanDocumentsDirectory
{
    // 「Documents」ディレクトリのパスを取得する
    NSString* docDirPath;
    
    docDirPath = 
    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                         NSUserDomainMask, 
                                         YES) lastObject];
    
    // 内容を取得する
    NSArray* contents;
    
    contents = [[NSFileManager defaultManager]
                contentsOfDirectoryAtPath:docDirPath error:NULL];
    
    // ファイルパスの一覧を作成する
    NSMutableArray* filePathArray;
    
    filePathArray = [NSMutableArray arrayWithCapacity:0]; // なぜarrayWithCapacityなのかは不明

    for (int i = 0; i < contents.count; i++) {
        // 変数「path」に格納されているのは、ファイル名の部分だけなので、
        // 変数「docDirPath」に連結して、絶対パスを作成する
        NSString* path = [contents objectAtIndex:i];
        path = [docDirPath stringByAppendingPathComponent:path];
        
        // 配列に追加する
        [filePathArray addObject:path];
    }
    
    return filePathArray;
}

- (IBAction)showDownloadView:(id)sender {
}

// テーブルビューのセクション数を返す
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // このアプリケーションでは、セクションで区切らないので、常に「1」を返す
    return 1;
}

// テーブルビューの項目数を返す
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // 項目数はフォルダ内のファイル数となる
    return self.filePathArray.count;
}

// テーブルの項目を返す
-(UITableViewCell *)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // ここで識別子の文字列が重要。ストーリーボード上のセルのIdentifierと同じにする。
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    // 次の文は不要。もし書くと、ストーリーボードが生成したセルを上書きしてしまい、
    // ストーリーボード上で編集したセルの外見などが反映されない。
    //cell = [[UITableViewCell alloc] init];
    
    // 指定された位置に表示するファイルのファイルパスを取得する
    NSString* filePath =
    [self.filePathArray objectAtIndex:indexPath.row];
    
    // 表示名を取得する
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* fileName = [fileManager displayNameAtPath:filePath];
    
    // セルに設定して返す
    cell.textLabel.text = fileName;
    
    return cell;
}

// セルが選択されたときの処理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 選択された項目に対するファイルパスを取得する
    NSString *filePath = [self.filePathArray objectAtIndex:indexPath.row];
    
    // 選択されたファイルが開けるファイルかどうかを判定する
    if ([self isSupportedFile:filePath]) {
        
        // filePathをセグエに渡して遷移する
        [self performSegueWithIdentifier:@"showDetail" sender:filePath];
    }
}

- (BOOL)isSupportedFile:(NSString *)filePath
{
    // 判定処理簡略化のため、小文字に変換している
    NSString *extension = filePath.pathExtension.lowercaseString;
    
    if ([extension isEqual:@"jpg"] || 
        [extension isEqual:@"jpeg"] || 
        [extension isEqual:@"png"]) {
        
        return YES;
    }
    
    return NO;
}

// 次の文は不要。ストーリーボード上でセルから詳細ビューにコネクションを張っておけばよい。
// View Controllerから遷移先にコネクションを張った場合は必要かもしれない。
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [self performSegueWithIdentifier:@"hoge" sender:self];
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(NSString *)filePath
{
    // 複数のセグエを切り替えて使うには以下のようにする。
    // showDetailはセグエの識別子
    if ([segue.identifier isEqualToString:@"showDetail"]) {
    // 個別の処理
        JDDetailViewController *controller = segue.destinationViewController;
        
        // 遷移先のView Controllerに値を渡す
        // controller.testObject.text = @"hoge"
        // のように、プロパティのプロパティに値を入れようとしても入らないので注意。
        controller.filePath = filePath;
        //    NSLog(@"sender = %@", sender);
        NSLog(@"filePath = %@", filePath);
    }
}

@end
