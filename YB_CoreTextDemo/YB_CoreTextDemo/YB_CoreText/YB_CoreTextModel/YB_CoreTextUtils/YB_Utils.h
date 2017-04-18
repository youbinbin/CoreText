//
//  YB_Utils.h
//  YB_CoreTextDemo
//
//  Created by HuaTuYiDongXueXi on 17/4/7.
//  Copyright © 2017年 youbinbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YB_CoreTextLinkData.h"
#import "YB_CoreTextData.h"

@interface YB_Utils : NSObject
///检测是否点击在连接上。
+ (YB_CoreTextLinkData*)touchLinkInView:(UIView*)view atPoint:(CGPoint)point data:(YB_CoreTextData*)data;


@end
