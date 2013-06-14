//
//  YoutubeXMLParser.h
//  V1.0
//
//  Created by Kuo-Ming Lin ( Kalvar ; ilovekalvar@gmail.com ) on 2011/07/27.
//  Copyright (c) 2013年 Kuo-Ming Lin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KRYoutubeXMLParser : NSObject <NSXMLParserDelegate>
{
    //儲存解析上傳成功後的回傳值
    NSMutableArray *successedDataArray;
    //儲存解析修改成功後的回傳值
    NSMutableArray *modifiedDataArray;
    //儲存解析刪除成功後的回傳值
    NSMutableArray *deleteDataArray;
    //當前解析的 XML 屬性辭典陣列
    NSMutableDictionary *xmlAttributes;
    //當前解析的 XML 字串
    NSString *xmlElement;
    //影片 ID
    NSString *videoId;
    //影片標題
    NSString *videoTitle;
    //影片說明
    NSString *videoDescription;
    //影片分類
    NSString *videoCategory;
    //影片網址
    NSString *videoAddress;
    //影片預設小縮圖
    NSString *videoDefaultPhoto;
    //影片上傳時間
    NSString *videoUploadTime;
    //影片上傳者
    NSString *videoUploader;
    //影片關鍵字
    NSString *videoKeywords;
    //是否儲存當前 XML 字串
    BOOL isSaving;    
    //是否解析成功
    BOOL isParingSuccessed;    
    //XML Index
    int xmlIndex;
    
}

@property (nonatomic, strong) NSMutableArray *successedDataArray;
@property (nonatomic, strong) NSMutableArray *modifiedDataArray;
@property (nonatomic, strong) NSMutableArray *deleteDataArray;
@property (nonatomic, strong) NSMutableDictionary *xmlAttributes;
@property (nonatomic, strong) NSString *xmlElement;
@property (nonatomic, strong) NSString *videoId;
@property (nonatomic, strong) NSString *videoTitle;
@property (nonatomic, strong) NSString *videoDescription;
@property (nonatomic, strong) NSString *videoCategory;
@property (nonatomic, strong) NSString *videoAddress;
@property (nonatomic, strong) NSString *videoDefaultPhoto;
@property (nonatomic, strong) NSString *videoUploadTime;
@property (nonatomic, strong) NSString *videoUploader;
@property (nonatomic, strong) NSString *videoKeywords;
@property (nonatomic) BOOL isSaving;
@property (nonatomic) BOOL isParsingSuccessed;

//解析外部 XML 檔案
-(void)parseFile:(NSString *)filePathName :(NSString *) fileType;
//解析二進位 XML Data
-(void)parseData:(NSData *)xmlData;
//解析字串 XML Data ( or Binary )
-(void)parseString:(NSString *)xmlStringData;

@end
