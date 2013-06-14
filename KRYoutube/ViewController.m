//
//  ViewController.m
//  KRYoutube
//
//  Created by Kalvar on 13/6/5.
//  Copyright (c) 2013年 Kuo-Ming Lin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, weak) NSString *_youtubeVideoId;

@end

@implementation ViewController

@synthesize krYoutube;
@synthesize _youtubeVideoId;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma --mark
-(void)uploadVideoProgress
{
    CGFloat _uploadingProgress = [self.krYoutube getProgressFloatNumber];
    NSLog(@"Uploading Progress : %f", _uploadingProgress);
}

-(void)uploadVideo
{
    self.krYoutube.useSync = NO;
    NSString *_localFilePath = @"/usr/local/sample.avi";
    [self.krYoutube directUploadPath:_localFilePath
                               title:@"test and funny video."
                         description:@"welcome to watch this one."
                            category:krYoutubeCategoryOfPeople
                            keywords:@"sample, test, others"
                            progress:nil];
    
}

-(void)updateVideo
{
    [self.krYoutube directUpadteId:self._youtubeVideoId
                             title:@"update title"
                       description:@"update description"
                          category:krYoutubeCategoryOfEducation
                          keywords:@"happy open soure"
                          progress:nil];
}

-(void)deleteVideo
{
    [self.krYoutube deleteVideoWithId:self._youtubeVideoId progress:nil];
}

#pragma KRYoutubeDelegate
/*
 * @ 完成上傳檔案
 *   - Findish Upload Video.
 */
-(void)krYoutubeDidUploadFinishedVideoId:(NSString *)_videoId videoInfo:(NSMutableDictionary *)_videoInfo
{
    //To record the _videoId ( Youtube video unique ID ) then you can use it to update or delete video.
    self._youtubeVideoId = _videoId;
    NSLog(@"uploaded video info : %@", _videoInfo);
}

/*
 * @ 完成修改檔案
 *   - Finish Update Video Info.
 */
-(void)krYoutubeDidUpdateFinishedVideoId:(NSString *)_videoId videoInfo:(NSMutableDictionary *)_videoInfo
{
    
}

/*
 * @ 完成刪除檔案
 *   - Finish Delete Video.
 */
-(void)krYoutubeDidDeleteFinishedVideoId:(NSString *)_videoId videoInfo:(NSMutableDictionary *)_videoInfo
{
    
}

/*
 * @ 上傳失敗
 *   - Failed to Upload.
 */
-(void)krYoutubeDidFailToUploadErrors:(NSError *)_error
{
    
}

/*
 * @ 修改失敗
 *   - Failed to Update.
 */
-(void)krYoutubeDidFailToUpdateErrors:(NSError *)_error
{
    
}

/*
 * @ 刪除失敗
 *   - Failed to Delete.
 */
-(void)krYoutubeDidFailToDeleteErrors:(NSError *)_error
{
    
}

/*
 * @ 通用請求失敗
 *   - Received Error in Anytime.
 */
-(void)krYoutubeDidRecivedErrors:(NSError *)_error
{

}

/*
 * @ 取消請求
 *   - Cancel the Http Request.
 */
-(void)krYoutubeDidCancelRequest
{

}

/*
 * @ 取消失敗
 *   - OOPS, the Cancel is Failed.
 */
-(void)krYoutubeDidFailedCancelRequest
{
    
}


@end
