//
//  YB_CoreTextData.h
//  YB_CoreTextDemo
//
//  Created by HuaTuYiDongXueXi on 17/4/6.
//  Copyright © 2017年 youbinbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface YB_CoreTextData : NSObject
@property (nonatomic,assign) CTFrameRef ctFrame;
@property (nonatomic,assign) CGFloat height;
///图片还有输入框存储的数组。
@property (nonatomic,strong) NSArray * imageArray;

@property (nonatomic,strong)NSArray * linkArray;


@property (strong, nonatomic) NSAttributedString * content;
@end
