//
//  JDDetailViewController.h
//  JpegDisplayTestByTatsuroUeda
//
//  Created by  on 12/07/03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JDDetailViewController : UIViewController
//{
//    // イメージを表示するイメージビュー
//    UIImageView     *_imageView;
//    
//    // 表示するファイルのファイルパス
//    NSString        *_filePath;
//}

@property (strong) IBOutlet UIImageView *imageView;
@property (strong) NSString *filePath;

- (IBAction)upload:(id)sender;
@end
