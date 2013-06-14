//
//  ViewController.h
//  KRYoutube
//
//  Created by Kalvar on 13/6/5.
//  Copyright (c) 2013年 Kuo-Ming Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KRYoutube.h"

@interface ViewController : UIViewController<KRYoutubeDelegate>
{
    
}

@property (nonatomic, strong) KRYoutube *krYoutube;

@end
