//
//  JDMasterViewController.h
//  JpegDisplayTestByTatsuroUeda
//
//  Created by  on 12/07/03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JDMasterViewController : UITableViewController
{
    // ファイルパスの配列
    NSMutableArray*     _filePathArray;
}

// プロパティの定義
@property(nonatomic, retain) NSMutableArray* filePathArray;

// 「Documents」ディレクトリ内を走査して、ファイルを取得する
- (NSMutableArray*)scanDocumentsDirectory;
- (BOOL)isSupportedFile:(NSString *)filePath;

- (IBAction)showDownloadView:(id)sender;
@end
