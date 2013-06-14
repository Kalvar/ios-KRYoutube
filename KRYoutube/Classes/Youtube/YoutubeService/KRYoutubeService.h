//
//  YoutubeService.h
//  V1.0
//
//  Created by Kuo-Ming Lin ( Kalvar ; ilovekalvar@gmail.com ) on 2011/07/27.
//  Copyright (c) 2013年 Kuo-Ming Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KRYoutubeXMLParser.h"

static NSString *krYoutubeDeveloperKey = @"Your Youtube Developer Key";
static NSString *krYoutubeAccount      = @"Your Youtube Developer Email Account";
static NSString *krYoutubePassword     = @"Your Youtube Developer Password";
static NSString *krYoutubeSource       = @"The Source From Where, Ex : Your Name or Company";
//
static NSString *krYoutubeVideoURL            = @"video_url";
static NSString *krYoutubeVideoTitle          = @"video_title";
static NSString *krYoutubeVideoDescription    = @"video_description";
static NSString *krYoutubeVideoCategory       = @"video_category";
static NSString *krYoutubeVideoKeywords       = @"video_keywords";
static NSString *krYoutubeVideoIdKey          = @"video_videoid";
static NSString *krYoutubeVideoBuildTime      = @"video_time";
static NSString *krYoutubeVideoUploader       = @"video_uploader";
static NSString *krYoutubeVideoThumbnailPhoto = @"video_thumbphoto";
static NSString *krYoutubeVideoKind           = @"video_kind";

@protocol KRYoutubeServiceDelegate;
@class ASIHTTPRequest;

typedef enum _krYoutubeServicesExecutes
{
    krYoutubeServicesExecuteUpload = 0,
    krYoutubeServicesExecuteUpdate,
    krYoutubeServicesExecuteDelete,
    krYoutubeServicesExecuteNothing,
    krYoutubeServicesExecuteLogin
} krYoutubeServicesExecutes;

@interface KRYoutubeService : NSObject
{
    __weak id<KRYoutubeServiceDelegate> delegate;
    //Developer Key
    NSString *devKey;
    //Google Login Auth Value( Token )
    NSString *authToken;
    //Youtube 影片 Id
    NSString *videoId;
    //Youtube 影片設定：標題、說明、分類、關鍵字 ... 
    NSDictionary *videoConfigs;
    NSString *account;
    NSString *password;
    //Youtube Srouce
    NSString *source;
    BOOL isLogin;
    NSError *errors;
    //上傳進度
    UIProgressView *progress;
    //是否以同步模式進行
    BOOL useSync;
    //正在執行什麼動作
    krYoutubeServicesExecutes executing;
    //執行的時限( Seconds. )
    CGFloat timeout;
    //上傳的檔案名稱
    NSString *uploadFileName;
}

@property (nonatomic, weak) id<KRYoutubeServiceDelegate> delegate;
@property (nonatomic, strong) NSString *devKey;
@property (nonatomic, strong) NSString *authToken;
@property (nonatomic, strong) NSString *videoId;
@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, assign) BOOL isLogin;
@property (nonatomic, strong) NSError *errors;
@property (nonatomic, strong) UIProgressView *progress;
@property (nonatomic, assign) BOOL useSync;
@property (nonatomic, assign) krYoutubeServicesExecutes executing;
@property (nonatomic, assign) CGFloat timeout;
@property (nonatomic, strong) NSString *uploadFileName;

-(id)initWithAccount:(NSString *)_account password:(NSString *)_password source:(NSString *)_source;
-(void)uploadVideo:(NSString *)_videoPath progressView:(UIProgressView *)_uploadProgress;
-(void)updateVideo:(NSString *)_videoId progressView:(UIProgressView *)_uploadProgress;
-(void)deleteVideo:(NSString *)_videoId;
-(void)setVideoConfigs:(NSString *)title description:(NSString *)description category:(NSString *)category keywords:(NSString *)keywords;
-(void)setVideoConfigs:(NSDictionary *)_configs;
-(NSString *)setAtomXml:(NSString *)event;
-(CGFloat)getProgressFloatNumber;
-(NSString *)getProgressNumberString;
-(void)cancelRequest;
-(BOOL)connect;
-(NSMutableDictionary *)getVideoInfo;

@end

@protocol KRYoutubeServiceDelegate <NSObject>

@optional

-(void)krYoutubeServiceDidFinishUpload:(ASIHTTPRequest *)_asiHttpRequest infos:(NSDictionary *)_infos;
-(void)krYoutubeServiceDidFinishUpdate:(ASIHTTPRequest *)_asiHttpRequest infos:(NSDictionary *)_infos;
-(void)krYoutubeServiceDidFinishDelete:(ASIHTTPRequest *)_asiHttpRequest infos:(NSDictionary *)_infos;
-(void)krYoutubeServiceDidReceiveFailed:(ASIHTTPRequest *)_asiHttpRequest;
-(void)krYoutubeServiceDidCancelRequest;
-(void)krYoutubeServiceDidFailedCancelRequest;

@end
