//
//  KRYoutube.m
//  V1.0
//
//  Created by Kuo-Ming Lin ( Kalvar ; ilovekalvar@gmail.com ) on 2011/07/27.
//  Copyright (c) 2013年 Kuo-Ming Lin. All rights reserved.
//

#import "KRYoutube.h"
#import "ASIFormDataRequest.h"

@interface KRYoutube ()
{
    KRYoutubeService *_krYoutubeService;
}

@property (nonatomic, strong) KRYoutubeService *_krYoutubeService;

@end

@interface KRYoutube (fixPrivate)

-(void)_initWithVars;
-(void)_setUserAccount:(NSString *)_account
              password:(NSString *)_password
                source:(NSString *)_source
               service:(krYoutubeServices)_service
              delegate:(id<KRYoutubeDelegate>)_delegate;

@end

@implementation KRYoutube (fixPrivate)

-(void)_initWithVars
{
    infos = [[NSMutableDictionary alloc] initWithCapacity:0];
}

//設定使用者帳密、影音來源、選擇影音服務平台
-(void)_setUserAccount:(NSString *)_account
              password:(NSString *)_password
                source:(NSString *)_source
               service:(krYoutubeServices)_service
              delegate:(id<KRYoutubeDelegate>)_delegate
{    
    self.useSync = YES;
    //正規化影音平台帳密
    if( [_account length] < 1 || [_password length] < 1 )
    {
        _account  = krYoutubeAccount;
        _password = krYoutubePassword;
    }
    //正規化影音來源
    if( [_source length] < 1 )
    {
        _source = krYoutubeSource;
    }
    //設定影音服務平台
    if( !self.service )
    {
        self.service = krYoutubeServiceOfYoutube;
    }
    self.delegate = _delegate;
    switch (self.service)
    {
        case krYoutubeServiceOfYoutube:
            _krYoutubeService = [[KRYoutubeService alloc] initWithAccount:_account
                                                                 password:_password
                                                                   source:_source];
            [_krYoutubeService setDevKey:krYoutubeDeveloperKey];
            [_krYoutubeService setDelegate:self];
            break;
        default:
            break;
    }
    //檢查連線
    [self checkLogged];
}

@end

@implementation KRYoutube

@synthesize delegate;
@synthesize isLogin;
@synthesize service;
@synthesize useSync;
@synthesize infos;
//
@synthesize _krYoutubeService;


-(id)initWithDelegate:(id<KRYoutubeDelegate>)_delegate
{
    self = [super init];
    if( self )
    {
        [self _setUserAccount:krYoutubeAccount
                     password:krYoutubePassword
                       source:krYoutubeSource
                      service:krYoutubeServiceOfYoutube
                     delegate:_delegate];
    }
    return self;
}

//初始化使用者帳密、影音來源、選擇影音服務平台
-(id)initWithUserAccount:(NSString *)_account
                password:(NSString *)_password
                  source:(NSString *)_source
                 service:(krYoutubeServices)_service
                delegate:(id<KRYoutubeDelegate>)_delegate
{
    self = [super init];
    if (self)
    {
        //設定服務器
        [self _setUserAccount:_account
                     password:_password
                       source:_source
                      service:_service
                     delegate:_delegate];
    }
    return self;
}

//檢查登入是否成功
-(BOOL)checkLogged
{
    BOOL _isLogin = NO;
    switch (self.service)
    {
        case krYoutubeServiceOfYoutube:
            _isLogin = [self._krYoutubeService connect];
            break;
        default:
            break;
    }
    self.isLogin = _isLogin;
    return _isLogin;
}

-(void)checkLoginStatus:(LoginCompleted)_compeleteHandler
{
    dispatch_queue_t queue = dispatch_queue_create("_checkLoginStatusQueue", NULL);
    dispatch_async(queue, ^(void) {
        [self checkLogged];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            _compeleteHandler(self.isLogin);
        });
    });
}

//影片資訊設定
-(NSDictionary *)setVideoConfigsWithTitle:(NSString *)_title
                              description:(NSString *)_description
                                 category:(NSString *)_category
                                 keywords:(NSString *)_keywords
{    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            _title,       @"title",
            _description, @"description",
            _category,    @"category", 
            _keywords,    @"keywords", 
            nil];
}

//上傳影片
-(void)uploadVideoWithPath:(NSString *)_filePath
              videoConfigs:(NSDictionary *)_videoConfigs
                  progress:(UIProgressView *)_progressView
{
    if ( !self.isLogin )
    {
        return;
    }
    switch (self.service)
    {
        case krYoutubeServiceOfYoutube:
            //設定是否為同步動作
            self._krYoutubeService.useSync = self.useSync;
            //設定影片資訊
            [self._krYoutubeService setVideoConfigs:_videoConfigs];
            //進行上傳檔案
            [self._krYoutubeService uploadVideo:_filePath progressView:_progressView];
            break;
        default:
            break;
    } 
}

//修改影片
-(void)updateVideoWithId:(NSString *)_videoId
            videoConfigs:(NSDictionary *)_videoConfigs
                progress:(UIProgressView *)_progressView
{
    if ( !self.isLogin )
    {
        return;
    }
    dispatch_queue_t queue = dispatch_queue_create("krYoutubeUpdateVideoInfoQueue", NULL);
    dispatch_async(queue, ^(void) {
        switch (self.service)
        {
            case krYoutubeServiceOfYoutube:
                self._krYoutubeService.useSync = self.useSync;
                //設定影片資訊
                [self._krYoutubeService setVideoConfigs:_videoConfigs];
                //進行修改
                [self._krYoutubeService updateVideo:_videoId progressView:_progressView];
                break;
        }
        //dispatch_async(dispatch_get_main_queue(), ^(void) {});
    });
}

//刪除影片
-(void)deleteVideoWithId:(NSString *)_videoId progress:(UIProgressView *)_progressView
{    
    if ( !self.isLogin )
    {
        return;
    }
    switch (self.service)
    {
        case krYoutubeServiceOfYoutube:
            self._krYoutubeService.useSync = self.useSync;
            [self._krYoutubeService deleteVideo:_videoId];
            break;
        default:
            break;
    }
}

//直接上傳檔案
-(void)directUploadPath:(NSString *)_filePath
                  title:(NSString *)_title
            description:(NSString *)_description
               category:(NSString *)_category
               keywords:(NSString *)_keywords
               progress:(UIProgressView *)_progressView
{    
    NSDictionary *_configs = [self setVideoConfigsWithTitle:_title
                                                description:_description
                                                   category:_category
                                                   keywords:_keywords];
    
    [self uploadVideoWithPath:_filePath
                 videoConfigs:_configs
                     progress:_progressView];
}

//直接修改檔案
-(void)directUpadteId:(NSString *)_videoId
                title:(NSString *)_title
          description:(NSString *)_description
             category:(NSString *)_category
             keywords:(NSString *)_keywords
             progress:(UIProgressView *)_progressView
{    
    NSDictionary *_configs = [self setVideoConfigsWithTitle:_title
                                                description:_description
                                                   category:_category
                                                   keywords:_keywords];
    
    [self updateVideoWithId:_videoId
               videoConfigs:_configs
                   progress:_progressView];
}

/*
 * 取得 Progress 的上傳進度
 */
-(CGFloat)getProgressFloatNumber
{
    return [self._krYoutubeService getProgressFloatNumber];
}

-(NSString *)getProgressNumber
{
    return [self._krYoutubeService getProgressNumberString];
}

/*
 * 取消上傳、修改、刪除等請求
 */
-(void)cancelRequest
{
    //同步狀態無法取消請求
    if( self.useSync )
    {
        if( [self.delegate respondsToSelector:@selector(krYoutubeDidFailedCancelRequest)] ){
            [self.delegate krYoutubeDidFailedCancelRequest];
        }
        return;
    }
    //只有 Async 才能取消
    [self._krYoutubeService cancelRequest];
}

#pragma YoutubeService Delegate
//上傳成功
-(void)krYoutubeServiceDidFinishUpload:(ASIHTTPRequest *)_asiHttpRequest infos:(NSDictionary *)_infos
{
    if( [[self._krYoutubeService videoId] length] > 0 )
    {
        if( [self.delegate respondsToSelector:@selector(krYoutubeDidUploadFinishedVideoId:videoInfo:)] )
        {
            self.infos = [self._krYoutubeService getVideoInfo];
            [self.delegate krYoutubeDidUploadFinishedVideoId:[self._krYoutubeService videoId] videoInfo:self.infos];
        }
    }
    else
    {
        if( [self.delegate respondsToSelector:@selector(krYoutubeDidFailToUploadErrors:)] )
        {
            [self.infos removeAllObjects];
            [self.delegate krYoutubeDidFailToUploadErrors:[self._krYoutubeService errors]];
        }
    }
}

//修改成功
-(void)krYoutubeServiceDidFinishUpdate:(ASIHTTPRequest *)_asiHttpRequest infos:(NSDictionary *)_infos
{
    if( ![self._krYoutubeService errors] ){
        if( [self.delegate respondsToSelector:@selector(krYoutubeDidUpdateFinishedVideoId:videoInfo:)] )
        {
            self.infos = [self._krYoutubeService getVideoInfo];
            [self.delegate krYoutubeDidUpdateFinishedVideoId:[self._krYoutubeService videoId] videoInfo:self.infos];
        }
    }
    else
    {
        if( [self.delegate respondsToSelector:@selector(krYoutubeDidFailToUpdateErrors:)] )
        {
            [self.infos removeAllObjects];
            [self.delegate krYoutubeDidFailToUpdateErrors:[self._krYoutubeService errors]];
        }
    }
}

//刪除成功
-(void)krYoutubeServiceDidFinishDelete:(ASIHTTPRequest *)_asiHttpRequest infos:(NSDictionary *)_infos
{
    if( ![self._krYoutubeService errors] )
    {
        if( [self.delegate respondsToSelector:@selector(krYoutubeDidDeleteFinishedVideoId:videoInfo:)] )
        {
            self.infos = [self._krYoutubeService getVideoInfo];
            [self.delegate krYoutubeDidDeleteFinishedVideoId:[self._krYoutubeService videoId] videoInfo:self.infos];
        }
    }
    else
    {
        if( [self.delegate respondsToSelector:@selector(krYoutubeDidFailToDeleteErrors:)] )
        {
            [self.infos removeAllObjects];
            [self.delegate krYoutubeDidFailToDeleteErrors:[self._krYoutubeService errors]];
        }
    }
}

//請求失敗
-(void)krYoutubeServiceDidReceiveFailed:(ASIHTTPRequest *)_asiHttpRequest
{
    switch ( [self._krYoutubeService executing] )
    {
        case krYoutubeServicesExecuteUpload:
            if( [self.delegate respondsToSelector:@selector(krYoutubeDidFailToUploadErrors:)] )
            {
                [self.delegate krYoutubeDidFailToUploadErrors:[self._krYoutubeService errors]];
            }
            break;
        case krYoutubeServicesExecuteUpdate:
            if( [self.delegate respondsToSelector:@selector(krYoutubeDidFailToUpdateErrors:)] )
            {
                [self.delegate krYoutubeDidFailToUpdateErrors:[self._krYoutubeService errors]];
            }
            break;
        case krYoutubeServicesExecuteDelete:
            if( [self.delegate respondsToSelector:@selector(krYoutubeDidFailToDeleteErrors:)] )
            {
                [self.delegate krYoutubeDidFailToDeleteErrors:[self._krYoutubeService errors]];
            }
            break;
        default:
            break;
    }
    [self.infos removeAllObjects];
    if( [self.delegate respondsToSelector:@selector(krYoutubeDidRecivedErrors:)] )
    {
        [self.delegate krYoutubeDidRecivedErrors:[_asiHttpRequest error]];
    }
}

//取消請求
-(void)krYoutubeServiceDidCancelRequest
{
    [self.infos removeAllObjects];
    if( [self.delegate respondsToSelector:@selector(krYoutubeDidCancelRequest)] )
    {
        [self.delegate krYoutubeDidCancelRequest];
    }
}

//取消請求失敗
-(void)krYoutubeServiceDidFailedCancelRequest
{
    [self.infos removeAllObjects];
    if( [self.delegate respondsToSelector:@selector(krYoutubeDidFailedCancelRequest)] )
    {
        [self.delegate krYoutubeDidFailedCancelRequest];
    }
}

@end
