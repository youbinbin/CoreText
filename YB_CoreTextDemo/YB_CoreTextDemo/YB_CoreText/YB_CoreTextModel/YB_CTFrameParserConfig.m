//
//  YB_CTFrameParserConfig.m
//  YB_CoreTextDemo
//
//  Created by HuaTuYiDongXueXi on 17/4/6.
//  Copyright © 2017年 youbinbin. All rights reserved.
//

#import "YB_CTFrameParserConfig.h"

@implementation YB_CTFrameParserConfig
- (id)init {
    self = [super init];
    if (self) {
        _width =[UIScreen mainScreen].bounds.size.width-20;
        _fontSize = 16.0f;
        _lineSpace = 0.0f;
        _textColor = RGB(108, 108, 108);
    }
    return self;
}

@end
