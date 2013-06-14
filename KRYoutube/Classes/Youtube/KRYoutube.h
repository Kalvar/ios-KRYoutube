//
//  KRYoutube.h
//  V1.0
//
//  Created by Kuo-Ming Lin ( Kalvar ; ilovekalvar@gmail.com ) on 2011/07/27.
//  Copyright (c) 2013年 Kuo-Ming Lin. All rights reserved.
//

#import "KRYoutubeService.h"

#define SERVICE_TYPE_YOUTUBE  @"YOUTUBE"

static NSString *krYoutubeDeveloperKey = @"Your Youtube Developer Key";
static NSString *krYoutubeAccount      = @"Your Youtube Developer Email Account";
static NSString *krYoutubePassword     = @"Your Youtube Developer Password";
static NSString *krYoutubeSource       = @"The Source From Where, Ex : Your Name or Company";

/*
 * @ Category supported after 2012.
 */
//電影與動畫
static NSString *krYoutubeCategoryOfFilm          = @"Film";
//各類交通工具
static NSString *krYoutubeCategoryOfAutos         = @"Autos";
//音樂
static NSString *krYoutubeCategoryOfMusic         = @"Music";
//寵物與動物
static NSString *krYoutubeCategoryOfAnimals       = @"Animals";
//運動
static NSString *krYoutubeCategoryOfSports        = @"Sports";
//旅行與活動
static NSString *krYoutubeCategoryOfTravel        = @"Travel";
//遊戲
static NSString *krYoutubeCategoryOfGames         = @"Games";
//喜劇
static NSString *krYoutubeCategoryOfComedy        = @"Comedy";
//人物與網誌
static NSString *krYoutubeCategoryOfPeople        = @"People";
//新聞與政治
static NSString *krYoutubeCategoryOfNews          = @"News";
//娛樂
static NSString *krYoutubeCategoryOfEntertainment = @"Entertainment";
//教育
static NSString *krYoutubeCategoryOfEducation     = @"Education";
//DIY 教學
static NSString *krYoutubeCategoryOfDIY           = @"Howto";
//非營利組織與行動主義
static NSString *krYoutubeCategoryOfNonprofit     = @"Nonprofit";
//科學與技術
static NSString *krYoutubeCategoryOfTech          = @"Tech";

@protocol KRYoutubeDelegate;
@class KRYoutubeService;

typedef void (^LoginCompleted)(BOOL isLogged);

typedef enum _krYoutubeServices
{
    krYoutubeServiceOfYoutube = 0
} krYoutubeServices;

@interface KRYoutube : NSObject<KRYoutubeServiceDelegate>
{
    __weak id <KRYoutubeDelegate> delegate;
    BOOL isLogin;
    krYoutubeServices service;
    UIProgressView *progress;
    BOOL useSync;
    NSMutableDictionary *infos;
}

@property (nonatomic, assign) krYoutubeServices service;
@property (nonatomic, weak) id<KRYoutubeDelegate> delegate;
@property (nonatomic, assign) BOOL isLogin;
@property (nonatomic, assign) BOOL useSync;
@property (nonatomic, strong) NSMutableDictionary *infos;

-(id)initWithDelegate:(id<KRYoutubeDelegate>)_delegate;

//初始化使用者帳密、影音來源、選擇影音服務平台
-(id)initWithUserAccount:(NSString *)_account 
                password:(NSString *)_password
                  source:(NSString *)_source
                 service:(krYoutubeServices)_service
                delegate:(id<KRYoutubeDelegate>)_delegate;

//檢查登入是否成功
-(BOOL)checkLogged;
-(void)checkLoginStatus:(LoginCompleted)_compeleteHandler;

//影片資訊設定
-(NSDictionary *)setVideoConfigsWithTitle:(NSString *)_title
                              description:(NSString *)_description
                                 category:(NSString *)_category
                                 keywords:(NSString *)_keywords;

//上傳影片
-(void)uploadVideoWithPath:(NSString *)_filePath
              videoConfigs:(NSDictionary *)_videoConfigs
                  progress:(UIProgressView *)_progressView;

//修改影片
-(void)updateVideoWithId:(NSString *)_videoId
            videoConfigs:(NSDictionary *)_videoConfigs
                progress:(UIProgressView *)_progressView;
    
//刪除影片
-(void)deleteVideoWithId:(NSString *)_videoId
                progress:(UIProgressView *)_progressView;

//直接上傳檔案
-(void)directUploadPath:(NSString *)_filePath
                  title:(NSString *)_title
            description:(NSString *)_description
               category:(NSString *)_category
               keywords:(NSString *)_keywords
               progress:(UIProgressView *)_progressView;

//直接修改檔案
-(void)directUpadteId:(NSString *)_videoId
                title:(NSString *)_title
          description:(NSString *)_description
             category:(NSString *)_category
             keywords:(NSString *)_keywords
             progress:(UIProgressView *)_progressView;

//上傳進度 %
-(CGFloat)getProgressFloatNumber;
-(NSString *)getProgressNumber;

//取消請求
-(void)cancelRequest;

@end


@protocol KRYoutubeDelegate <NSObject>

@optional
    /*
     * @ 完成上傳檔案
     */
    -(void)krYoutubeDidUploadFinishedVideoId:(NSString *)_videoId videoInfo:(NSMutableDictionary *)_videoInfo;
    /*
     * @ 完成修改檔案
     */
    -(void)krYoutubeDidUpdateFinishedVideoId:(NSString *)_videoId videoInfo:(NSMutableDictionary *)_videoInfo;
    /*
     * @ 完成刪除檔案
     */
    -(void)krYoutubeDidDeleteFinishedVideoId:(NSString *)_videoId videoInfo:(NSMutableDictionary *)_videoInfo;
    /*
     * @ 上傳失敗
     */
    -(void)krYoutubeDidFailToUploadErrors:(NSError *)_error;
    /*
     * @ 修改失敗
     */
    -(void)krYoutubeDidFailToUpdateErrors:(NSError *)_error;
    /*
     * @ 刪除失敗
     */
    -(void)krYoutubeDidFailToDeleteErrors:(NSError *)_error;
    /*
     * @ 通用請求失敗
     */
    -(void)krYoutubeDidRecivedErrors:(NSError *)_error;
    /*
     * @ 取消請求
     */
    -(void)krYoutubeDidCancelRequest;
    /*
     * @ 取消失敗
     */
    -(void)krYoutubeDidFailedCancelRequest;
    
@end