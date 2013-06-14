//
//  YoutubeXMLParser.m
//  V1.0
//
//  Created by Kuo-Ming Lin ( Kalvar ; ilovekalvar@gmail.com ) on 2011/07/27.
//  Copyright (c) 2013年 Kuo-Ming Lin. All rights reserved.
//

#import "KRYoutubeXMLParser.h"

@implementation KRYoutubeXMLParser

@synthesize successedDataArray, 
            modifiedDataArray, 
            deleteDataArray, 
            xmlAttributes,
            xmlElement;
@synthesize videoId, 
            videoTitle, 
            videoCategory, 
            videoDescription, 
            videoAddress, 
            videoDefaultPhoto, 
            videoUploadTime, 
            videoUploader, 
            videoKeywords;
@synthesize isSaving, 
            isParsingSuccessed;

//解析外部 XML 檔案
-(void)parseFile:(NSString *)filePathName :(NSString *)fileType
{
    //設定讀取此 APP 裡的檔案路徑 ( NSBundle 指的是此專案裡的實體檔案 )
	NSString *filePath = [[NSBundle mainBundle] pathForResource:filePathName ofType:fileType];  
    //讀取成二進位
	//NSData *fileData   = [[NSData dataWithContentsOfFile:filePath] dataUsingEncoding:NSUTF8StringEncoding]; 
	NSData *fileData   = [NSData dataWithContentsOfFile:filePath]; 
    //ASCII編碼
    //NSString *xmlFile  = [[NSString alloc] initWithData:fileData encoding:NSASCIIStringEncoding];
    //UTF-8編碼
    NSString *xmlFile  = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    [self parseString:xmlFile];
}

//解析二進位 XML Data
-(void)parseData:(NSData *)xmlData
{
    NSString *xmlFile = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    [self parseString:xmlFile];
}

//解析字串 XML Data ( 也可傳入二進位值 )
-(void)parseString:(NSString *)xmlStringData
{
    NSXMLParser *_xmlParser = [[NSXMLParser alloc] initWithData:[xmlStringData dataUsingEncoding:NSUTF8StringEncoding]];
    [_xmlParser setDelegate:self];
    self.xmlElement         = nil;
    self.isSaving           = YES;
    self.xmlAttributes      = [NSMutableDictionary dictionaryWithDictionary:0];
    self.isParsingSuccessed = [_xmlParser parse];
}

#pragma mark NSXMLParser Parsing Delegate
// 1). 開始對單一個 XML 元素進行解析 : 並初始化為空字串，才接受解析完成後的值
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    xmlElement = @"";
    if( [attributeDict count] > 0 )
    {
        [self.xmlAttributes setDictionary:attributeDict];
        self.isSaving = YES;
    }
    else
    {
        self.isSaving = NO;
    }
    
}

// 2). 將所有的 XML 元素連接起來
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    xmlElement = [xmlElement stringByAppendingString:string];
}

// 3). 對一個 XML 元素解析完成，將 xmlElement 加到 xmlElementsArray 
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    for( NSString * attrKey in self.xmlAttributes )
    {
        //開始取值
        if( [elementName isEqualToString:@"media:category"] )
        {
            //影片分類
            self.videoCategory = [NSString stringWithString:xmlElement];
        }
        else if( [elementName isEqualToString:@"media:credit"] )
        {
            //影片上傳者
            self.videoUploader = [NSString stringWithString:xmlElement];
        }
        else if( [elementName isEqualToString:@"media:description"] )
        {
            //影片說明
            self.videoDescription = [NSString stringWithString:xmlElement];
        }
        else if( [elementName isEqualToString:@"media:keywords"] )
        {
            //影片關鍵字
            self.videoKeywords = [NSString stringWithString:xmlElement];
        }
        else if( [elementName isEqualToString:@"media:player"] )
        {
            //影片網址
            self.videoAddress = [NSString stringWithString:(NSString *)[self.xmlAttributes objectForKey:@"url"]];
        }
        else if( [elementName isEqualToString:@"media:thumbnail"] && [[self.xmlAttributes objectForKey:attrKey] isEqualToString:@"default"] )
        {
            //影片預設圖片
            self.videoDefaultPhoto = [NSString stringWithString:(NSString *)[self.xmlAttributes objectForKey:@"url"]];
        }
        else if( [elementName isEqualToString:@"media:title"] )
        {
            //影片標題
            self.videoTitle = [NSString stringWithString:xmlElement];
        }
        else if( [elementName isEqualToString:@"yt:uploaded"] )
        {
            //影片上傳時間
            self.videoUploadTime = [NSString stringWithString:xmlElement];
        }
        else if( [elementName isEqualToString:@"yt:videoid"] )
        {
            //影片 ID
            self.videoId = [NSString stringWithString:xmlElement];
        }
    }
}

// 4). 對 XML 解析完畢，將相關資訊顥示於 UI
- (void)parserDidEndDocument:(NSXMLParser *)parser
{

    
}
@end
