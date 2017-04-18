//
//  YB_CoreTextImageData.h
//  YB_CoreTextDemo
//
//  Created by HuaTuYiDongXueXi on 17/4/7.
//  Copyright © 2017年 youbinbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface YB_CoreTextImageData : NSObject
/**
 *  图片链接
 */
@property (nonatomic,copy)NSString * name;
/**
 *  坐标。
 */
@property (nonatomic,assign)NSUInteger position;

/**
 *  图片是否可以点击
 */
@property (nonatomic,assign)BOOL canClick;
// 此坐标是 CoreText 的坐标系，而不是UIKit的坐标系
@property (nonatomic,assign)CGRect imagePosition;

@end
