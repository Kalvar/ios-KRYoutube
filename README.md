## Supports

KRYoutube can upload a video to youtube, and you can update information of video or delete it. KRYoutube use ASIHttpRequest framework to connect the HTTP protocol, but the ASIHttpRequest already stop their maintain that don't worry about it can't use fluently. If you use ARC that you need to remember to setup ASIHttpRequest to be " -fno-objc-arc " in the 「TARGETS > Build Phases」 setting page.

KRYoutube supports ARC.

## How To Get Started

``` objective-c
#import "KRYoutube.h"
//Please Remember to implement <KRYoutubeDelegate>

- (void)viewDidLoad
{
    [super viewDidLoad];
    /*
     * You need to go to KRYoutubeService.h to setup the krYoutubeDeveloperKey and your Acoount infomation first.
     */
    krYoutube = [[KRYoutube alloc] initWithDelegate:self];
}

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
 * @ Findish Upload Video.
 */
-(void)krYoutubeDidUploadFinishedVideoId:(NSString *)_videoId videoInfo:(NSMutableDictionary *)_videoInfo
{
    //To record the _videoId ( Youtube video unique ID ) then you can use it to update or delete video.
    self._youtubeVideoId = _videoId;
    NSLog(@"uploaded video info : %@", _videoInfo);
}

/*
 * @ Finish Update Video Info.
 */
-(void)krYoutubeDidUpdateFinishedVideoId:(NSString *)_videoId videoInfo:(NSMutableDictionary *)_videoInfo
{
    
}

/*
 * @ Finish Delete Video.
 */
-(void)krYoutubeDidDeleteFinishedVideoId:(NSString *)_videoId videoInfo:(NSMutableDictionary *)_videoInfo
{
    
}
```

## Version

V1.0

## LICENSE

MIT.

