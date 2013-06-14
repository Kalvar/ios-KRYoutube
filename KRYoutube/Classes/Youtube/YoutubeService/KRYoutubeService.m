//
//  YoutubeService.m
//  V1.0
//
//  Created by Kuo-Ming Lin ( Kalvar ; ilovekalvar@gmail.com ) on 2011/07/27.
//  Copyright (c) 2013年 Kuo-Ming Lin. All rights reserved.
//

#import "KRYoutubeService.h"
#import "ASIFormDataRequest.h"

static NSString *krYoutubeServiceGoogleLoginURL = @"https://www.google.com/youtube/accounts/ClientLogin";
static NSInteger krYoutubeSerivceProgressTag    = 9998;

@interface KRYoutubeService()
{
    NSString *_currentVideoId;
}

@property (nonatomic, strong) ASIHTTPRequest *_httpRequest;
@property (nonatomic, strong) NSString *_currentVideoId;
@property (nonatomic, strong) NSMutableDictionary *_videoInfo;

@end

@interface KRYoutubeService (fixPrivate)

-(void)_makeProgress;
-(void)_uploadDidFinishUpload:(ASIHTTPRequest *)_asiHttpRequest;
-(void)_uploadDidFinishUpdate:(ASIHTTPRequest *)_asiHttpRequest;
-(void)_uploadDidFinishDelete:(ASIHTTPRequest *)_asiHttpRequest;
-(void)_uploadDidReceiveFailed:(ASIHTTPRequest *)_asiHttpRequest;
-(NSString *)_loginAndGetAuthToken;
-(NSString *)_loginOnceAndGetUserName;

@end

@implementation KRYoutubeService (fixPrivate)

-(void)_makeProgress
{
    if( !self.progress )
    {
        progress               = [[UIProgressView alloc] initWithFrame:CGRectMake(-100.0f, -100.0f, 100.0f, 1.0f)];
        self.progress.progress = 0.0f;
        self.progress.tag      = krYoutubeSerivceProgressTag;
        //整個 Progress Bar 的底色
        self.progress.backgroundColor   = [UIColor clearColor];
        //讀取條的顏色
        self.progress.progressTintColor = [UIColor clearColor];
        //讀取條的下面底色
        self.progress.trackTintColor    = [UIColor clearColor];
    }
}

-(void)_uploadDidFinishUpload:(ASIHTTPRequest *)_asiHttpRequest
{
    NSError *error = [_asiHttpRequest error];
    if( !error )
    {
        self.errors = nil;
        //開始解析 XML 字串 : 使用二進位 Data 解析
        KRYoutubeXMLParser *youtubeXMLParser = [[KRYoutubeXMLParser alloc] init];
        [youtubeXMLParser parseData:[_asiHttpRequest responseData]];
        //設定 videoId
        self.videoId   = [youtubeXMLParser videoId];
        //發送 POST 至 PHP Server 儲存在 DB 裡 : 製作變數陣列
        self._videoInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           [youtubeXMLParser videoAddress],      krYoutubeVideoURL,
                           [youtubeXMLParser videoTitle],        krYoutubeVideoTitle,
                           [youtubeXMLParser videoDescription],  krYoutubeVideoDescription,
                           [youtubeXMLParser videoCategory],     krYoutubeVideoCategory,
                           [youtubeXMLParser videoKeywords],     krYoutubeVideoKeywords,
                           [youtubeXMLParser videoId],           krYoutubeVideoIdKey,
                           [youtubeXMLParser videoUploadTime],   krYoutubeVideoBuildTime,
                           [youtubeXMLParser videoUploader],     krYoutubeVideoUploader,
                           [youtubeXMLParser videoDefaultPhoto], krYoutubeVideoThumbnailPhoto,
                           @"youtube",                           krYoutubeVideoKind,
                           nil];
        if( [self.delegate respondsToSelector:@selector(krYoutubeServiceDidFinishUpload:infos:)] )
        {
            [self.delegate krYoutubeServiceDidFinishUpload:_asiHttpRequest infos:self._videoInfo];
        }
    }
    else
    {
        self.errors = error;
        if( [self.delegate respondsToSelector:@selector(krYoutubeServiceDidReceiveFailed:)] )
        {
            [self.delegate krYoutubeServiceDidReceiveFailed:_asiHttpRequest];
        }
    }
}

-(void)_uploadDidFinishUpdate:(ASIHTTPRequest *)_asiHttpRequest
{
    NSError *error = [_asiHttpRequest error];
    if( !error )
    {
        self.errors = nil;
        KRYoutubeXMLParser *youtubeXMLParser = [[KRYoutubeXMLParser alloc] init];
        [youtubeXMLParser parseData:[_asiHttpRequest responseData]];
        self._videoInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           [youtubeXMLParser videoAddress],      krYoutubeVideoURL,
                           [youtubeXMLParser videoTitle],        krYoutubeVideoTitle,
                           [youtubeXMLParser videoDescription],  krYoutubeVideoDescription,
                           [youtubeXMLParser videoCategory],     krYoutubeVideoCategory,
                           [youtubeXMLParser videoKeywords],     krYoutubeVideoKeywords,
                           [youtubeXMLParser videoId],           krYoutubeVideoIdKey,
                           [youtubeXMLParser videoUploadTime],   krYoutubeVideoBuildTime,
                           [youtubeXMLParser videoUploader],     krYoutubeVideoUploader,
                           [youtubeXMLParser videoDefaultPhoto], krYoutubeVideoThumbnailPhoto,
                           @"youtube",                           krYoutubeVideoKind,
                           nil];
        if( [self.delegate respondsToSelector:@selector(krYoutubeServiceDidFinishUpdate:infos:)] )
        {
            [self.delegate krYoutubeServiceDidFinishUpdate:_asiHttpRequest infos:self._videoInfo];
        }
    }
    else
    {
        self.errors = error;
        if( [self.delegate respondsToSelector:@selector(krYoutubeServiceDidReceiveFailed:)] )
        {
            [self.delegate krYoutubeServiceDidReceiveFailed:_asiHttpRequest];
        }
    }

}

-(void)_uploadDidFinishDelete:(ASIHTTPRequest *)_asiHttpRequest
{
    NSError *error = [_asiHttpRequest error];
    if( !error )
    {
        self.errors     = nil;
        self._videoInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           self._currentVideoId, @"video_videoid",
                           @"youtube",           @"video_kind",
                           nil];
        if( [self.delegate respondsToSelector:@selector(krYoutubeServiceDidFinishDelete:infos:)] )
        {
            [self.delegate krYoutubeServiceDidFinishDelete:_asiHttpRequest infos:self._videoInfo];
        }
    }
    else
    {
        self.errors = error;
        if( [self.delegate respondsToSelector:@selector(krYoutubeServiceDidReceiveFailed:)] )
        {
            [self.delegate krYoutubeServiceDidReceiveFailed:_asiHttpRequest];
        }
    }
}

-(void)_uploadDidReceiveFailed:(ASIHTTPRequest *)_asiHttpRequest
{
    self.errors = [_asiHttpRequest error];
    if( [self.delegate respondsToSelector:@selector(krYoutubeServiceDidReceiveFailed:)] )
    {
        [self.delegate krYoutubeServiceDidReceiveFailed:_asiHttpRequest];
    }
}

/*
 * @ 取得 GoogleLogin 回傳的 Auth Token 值
 *   - 1. 設定 GoogleLogin 連線
 *   - 2. 取得回傳的 Google Token 值
 */
-(NSString *)_loginAndGetAuthToken
{
    //設定 GoogleLogin 的 URLRequest
    NSMutableURLRequest *_request = [[NSMutableURLRequest alloc] init];
    NSString *postUrlVars = [[NSString alloc]
                             initWithFormat:@"accountType=HOSTED_OR_GOOGLE&Email=%@&Passwd=%@&service=youtube&source=%@",
                             self.account,
                             self.password,
                             self.source];
    NSData *postData      = [postUrlVars dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength  = [NSString stringWithFormat:@"%u", [postData length]];
    [_request setURL:[NSURL URLWithString:krYoutubeServiceGoogleLoginURL]];
    [_request setHTTPMethod:@"POST"];
    [_request setValue:@"Close" forHTTPHeaderField:@"Connection"];
    //[_request setValue:@"Close" forHTTPHeaderField:@"Proxy-Connection"];
    [_request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [_request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [_request setHTTPBody:postData];
    //發送 HTTP POST
    NSData *_responseData = [NSURLConnection sendSynchronousRequest:_request returningResponse:nil error:nil];
    NSString *_authString = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
    _request = nil;
    return [NSString stringWithFormat:@"%@", _authString];
}

/*
 * @ 登入 Google 
 *   - 解析 GoogleLogin Auth String
 *   - 回傳 Youtube User Name
 *   - 同時記錄 Auth Token ( 一次連線只能用一次 )
 */
-(NSString *)_loginOnceAndGetUserName
{
    self.executing             = krYoutubeServicesExecuteLogin;
    NSDictionary *_parsedAuths = [self _parseLoginAuthString:[self _loginAndGetAuthToken]];
    NSString *_youtubeUserName = [NSString stringWithString:[_parsedAuths objectForKey:@"userName"]];
    self.authToken             = [_parsedAuths objectForKey:@"authToken"];
    self.isLogin               = ( [_youtubeUserName length] > 0 );
    return _youtubeUserName;
}

/*
 * @ 解析 GoogleLoing 回傳的 Auth Token 值
 */
-(NSDictionary *)_parseLoginAuthString:(NSString *)_authString
{
    if( !_authString || [_authString length] < 1 )
    {
        self.errors = [NSError errorWithDomain:nil
                                          code:101
                                      userInfo:[NSDictionary dictionaryWithObject:@"Failed to Login."
                                                                           forKey:@"description"]];
        return nil;
    }
    NSArray *_splits       = [_authString componentsSeparatedByString:@"\n"];
    NSArray *_auths        = [[_splits objectAtIndex:0] componentsSeparatedByString:@"="];
    NSString *_authToken   = [[_auths objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSArray *_youtubeUsers = [[_splits objectAtIndex:1] componentsSeparatedByString:@"="];
    NSString *_userName    = [[_youtubeUsers objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return [NSDictionary dictionaryWithObjectsAndKeys:
            _authToken, @"authToken",
            _userName,  @"userName",
            nil];;
}

@end

@implementation KRYoutubeService

@synthesize delegate;
@synthesize devKey,
            authToken,
            videoId, 
            account,
            password,
            source,
            isLogin;
@synthesize errors;
@synthesize progress;
@synthesize useSync;
@synthesize executing;
@synthesize timeout;
@synthesize uploadFileName;
//
@synthesize _httpRequest;
@synthesize _currentVideoId;
@synthesize _videoInfo;


-(id)initWithAccount:(NSString *)_account password:(NSString *)_password source:(NSString *)_source
{    
    self = [super init];
    if( self )
    {
        self.account         = [NSString stringWithFormat:@"%@", _account];
        self.password        = [NSString stringWithFormat:@"%@", _password];
        self.source          = [NSString stringWithFormat:@"%@", _source];
        self.devKey          = [NSString stringWithFormat:@"%@", krYoutubeDeveloperKey];
        self.useSync         = YES;
        self.errors          = nil;
        self.executing       = krYoutubeServicesExecuteNothing;
        self.timeout         = 300.0f;
        self.uploadFileName  = @"_sample.avi";
        self._currentVideoId = @"";
        _httpRequest         = [[ASIHTTPRequest alloc] initWithURL:nil];
        [self _makeProgress];
    }
    return self;
}

#pragma --mark Methods
/*
 * @ 上傳影音
 */
-(void)uploadVideo:(NSString *)_videoPath progressView:(UIProgressView *)_uploadProgress
{
    self.executing = krYoutubeServicesExecuteUpload;
    if( _uploadProgress )
    {
        self.progress = _uploadProgress;
    }
    NSString *_youtubeUserName = [self _loginOnceAndGetUserName];
    //檔案路徑
    NSData *_imageData = [NSData dataWithContentsOfFile:_videoPath];
    NSString *_atomXml = [NSString stringWithString:[self setAtomXml:@"upload"]];
    NSURL *_uploadURL  = [NSURL URLWithString:[NSString stringWithFormat: @"http://uploads.gdata.youtube.com/feeds/api/users/%@/uploads",
                                               _youtubeUserName]];
    [_httpRequest setURL:_uploadURL];
    //設定標頭
    [_httpRequest addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"GoogleLogin auth=\"%@\"", self.authToken]];
    [_httpRequest addRequestHeader:@"GData-Version" value:@"2"];
    [_httpRequest addRequestHeader:@"X-GData-Key" value:[NSString stringWithFormat:@"key=%@", self.devKey]];
    [_httpRequest addRequestHeader:@"Slug" value:self.uploadFileName];
    //設定 boundary
    NSString *boundary        = [[NSProcessInfo processInfo] globallyUniqueString];
    NSData *boundaryData      = [[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding];
    NSData *finalBoundaryData = [[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding];  
    [_httpRequest addRequestHeader:@"Content-Type" value:[NSString stringWithFormat:@"multipart/related; boundary=\"%@\"", boundary]];
    [_httpRequest setShouldStreamPostDataFromDisk:YES];
    [_httpRequest appendPostData:boundaryData];
    [_httpRequest appendPostData:[@"Content-Type: application/atom+xml; charset=UTF-8\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    //[_httpRequest appendPostData:[[self xmlPayloadWithTitle:@"_sampleApp" description:@"_testing"] dataUsingEncoding:NSUTF8StringEncoding]];
    [_httpRequest appendPostData:[_atomXml dataUsingEncoding:NSUTF8StringEncoding]];
    [_httpRequest appendPostData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [_httpRequest appendPostData:boundaryData];
    [_httpRequest appendPostData:[@"Content-Type: video/x-msvideo\r\nContent-Transfer-Encoding: binary\r\n\r\n"
                                  dataUsingEncoding:NSUTF8StringEncoding]];
    [_httpRequest appendPostData:_imageData];
    [_httpRequest appendPostData:finalBoundaryData];
    [_httpRequest setDelegate:self];
    [_httpRequest setDidFinishSelector:@selector(_uploadDidFinishUpload:)];
    [_httpRequest setDidFailSelector:@selector(_uploadDidReceiveFailed:)];
    [_httpRequest setTimeOutSeconds:self.timeout];
    if( self.progress )
    {
        self.progress.progress = 0.0f;
        [_httpRequest setUploadProgressDelegate:self.progress];
    }
    if( self.useSync )
    {
        [_httpRequest startSynchronous];
    }
    else
    {
        [_httpRequest startAsynchronous];
    }
}

/*
 * @ 更新影片資訊
 */
-(void)updateVideo:(NSString *)_videoId progressView:(UIProgressView *)_uploadProgress
{
    self.executing    = krYoutubeServicesExecuteUpdate;
    if( _uploadProgress )
    {
        self.progress = _uploadProgress;
    }
    self._currentVideoId = _videoId;
    self.videoId         = _videoId;
    NSString *youtubeUserName = [NSString stringWithString:[self _loginOnceAndGetUserName]];
    NSString *atomXml = [NSString stringWithString:[self setAtomXml:@"update"]];
    NSURL *uploadUrl  = [NSString stringWithFormat:@"http://gdata.youtube.com/feeds/api/users/%@/uploads/%@", youtubeUserName, _videoId];
    [_httpRequest setURL:uploadUrl];
    [_httpRequest setRequestMethod:@"PUT"];
    [_httpRequest addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"GoogleLogin auth=\"%@\"", self.authToken]];
    [_httpRequest addRequestHeader:@"GData-Version" value:@"2"];
    [_httpRequest addRequestHeader:@"X-GData-Key" value:[NSString stringWithFormat:@"key=%@", self.devKey]];
    [_httpRequest addRequestHeader:@"Content-Type" value:@"application/atom+xml; charset=UTF-8"];
    [_httpRequest addRequestHeader:@"Content-Length" value:[NSString stringWithFormat:@"%u", [atomXml length]]];
    [_httpRequest appendPostData:[atomXml dataUsingEncoding:NSUTF8StringEncoding]];
    [_httpRequest setDelegate:self];
    [_httpRequest setDidFinishSelector:@selector(_uploadDidFinishUpdate:)];
    [_httpRequest setDidFailSelector:@selector(_uploadDidReceiveFailed:)];
    [_httpRequest setTimeOutSeconds:self.timeout];
    if( self.progress )
    {
        self.progress.progress = 0.0f;
        [_httpRequest setUploadProgressDelegate:self.progress];
    }
    if( self.useSync )
    {
        [_httpRequest startSynchronous];
    }
    else
    {
        [_httpRequest startAsynchronous];
    }
}

/*
 * @ 刪除影片
 */
-(void)deleteVideo:(NSString *)_videoId
{
    self.executing       = krYoutubeServicesExecuteDelete;
    self._currentVideoId = _videoId;
    self.videoId         = _videoId;
    NSString *_userName  = [NSString stringWithString:[self _loginOnceAndGetUserName]];
    NSURL *uploadUrl = [NSString stringWithFormat:@"http://gdata.youtube.com/feeds/api/users/%@/uploads/%@", _userName, _videoId];
    [_httpRequest setURL:uploadUrl];
    [_httpRequest setRequestMethod:@"DELETE"];
    [_httpRequest addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"GoogleLogin auth=\"%@\"", self.authToken]];
    [_httpRequest addRequestHeader:@"GData-Version" value:@"2"];
    [_httpRequest addRequestHeader:@"X-GData-Key" value:[NSString stringWithFormat:@"key=%@", self.devKey]];
    [_httpRequest addRequestHeader:@"Content-Type" value:@"application/atom+xml; charset=UTF-8"];
    [_httpRequest setDelegate:self];
    [_httpRequest setDidFinishSelector:@selector(_uploadDidFinishDelete:)];
    [_httpRequest setDidFailSelector:@selector(_uploadDidReceiveFailed:)];
    [_httpRequest setTimeOutSeconds:self.timeout];
    if( self.progress )
    {
        self.progress.progress = 0.0f;
        [_httpRequest setUploadProgressDelegate:self.progress];
    }
    if( self.useSync )
    {
        [_httpRequest startSynchronous];
    }
    else
    {
        [_httpRequest startAsynchronous];
    }
}

/*
 * @ 設定影片資訊 ( 都須先在這裡設定相關文字資料 )
 *   - 上傳
 *   - 修改
 *   - 刪除
 */
-(void)setVideoConfigs:(NSString *)title description:(NSString *)description category:(NSString *)category keywords:(NSString *)keywords
{    
    self.videoConfigs = [NSDictionary dictionaryWithObjectsAndKeys:
                         title,        @"title",
                         description,  @"description",
                         category,     @"category",
                         keywords,     @"keywords",
                         nil];
}

-(void)setVideoConfigs:(NSDictionary *)_configs
{
    self.videoConfigs = [NSDictionary dictionaryWithDictionary:_configs];
}

/*
 * @ 設定影片的 Atom XML
 *   - 標題
 *   - 說明
 *   - 分類
 *   - 關鍵字
 */
-(NSString *)setAtomXml:(NSString *)event
{
    //額外的 XML 內容
    NSString *extraXmlContent = @"";
    //更新
    if( [event isEqualToString:@"update"] )
    {
        //更新內容需額外設定這些
        extraXmlContent = @" <yt:accessControl action=\"comment\" permission=\"allowed\"/>"
                           " <yt:accessControl action=\"commentVote\" permission=\"allowed\"/>"
                           " <yt:accessControl action=\"videoRespond\" permission=\"allowed\"/>"
                           " <yt:accessControl action=\"rate\" permission=\"allowed\"/>"
                           " <yt:accessControl action=\"list\" permission=\"allowed\"/>"
                           " <yt:accessControl action=\"embed\" permission=\"allowed\"/>"
                           " <yt:accessControl action=\"syndicate\" permission=\"allowed\"/>";
    }
    else
    {
        //上傳 upload
        extraXmlContent = @"";
    }
    //設定 Atom-Xml
    NSString *atomXml = [NSString stringWithFormat:
                         @"<?xml version=\"1.0\"?>"
                         " <entry xmlns=\"http://www.w3.org/2005/Atom\" "
                         "        xmlns:media=\"http://search.yahoo.com/mrss/\" xmlns:yt=\"http://gdata.youtube.com/schemas/2007\">"
                         "  <media:group>"
                         "    <media:title type=\"plain\"><![CDATA[%@]]></media:title>"
                         "    <media:description type=\"plain\"><![CDATA[%@]]></media:description>"
                         "    <media:category scheme=\"http://gdata.youtube.com/schemas/2007/categories.cat\">%@</media:category>"
                         "    <media:keywords>%@</media:keywords>"
                         "  </media:group>"
                         "  %@"
                         "</entry>", 
                         [videoConfigs objectForKey:@"title"], 
                         [videoConfigs objectForKey:@"description"],
                         [videoConfigs objectForKey:@"category"],
                         [videoConfigs objectForKey:@"keywords"],
                         extraXmlContent];
    return atomXml;
}

-(CGFloat)getProgressFloatNumber
{
    CGFloat _number = 0.0f;
    if( self.progress )
    {
        _number = [[NSString stringWithFormat:@"%.2f", self.progress.progress * 100] floatValue];
    }
    return _number;
}

-(NSString *)getProgressNumberString
{
    NSString *_number = @"0";
    if( self.progress )
    {
        _number = [NSString stringWithFormat:@"%.2f", self.progress.progress * 100];
    }
    return _number;
}

-(void)cancelRequest
{
    //同步狀態無法取消請求
    if( self.useSync )
    {
        if( [self.delegate respondsToSelector:@selector(krYoutubeServiceDidFailedCancelRequest)] )
        {
            [self.delegate krYoutubeServiceDidFailedCancelRequest];
        }
        return;
    }
    [self._httpRequest cancel];
    [self._httpRequest clearDelegatesAndCancel];
    if( [self.delegate respondsToSelector:@selector(krYoutubeServiceDidCancelRequest)] )
    {
        [self.delegate krYoutubeServiceDidCancelRequest];
    }
}

-(BOOL)connect
{
    [self _loginOnceAndGetUserName];
    return self.isLogin;
}

-(NSMutableDictionary *)getVideoInfo
{
    return self._videoInfo;
}

@end
