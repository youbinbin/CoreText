//
//  YB_CoreTextView.h
//  YB_CoreTextDemo
//
//  Created by HuaTuYiDongXueXi on 17/3/30.
//  Copyright © 2017年 youbinbin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "YB_CoreTextData.h"
#import "YB_CTFrameParserConfig.h"
@interface YB_CoreTextView : UIView
@property (nonatomic,strong)YB_CTFrameParserConfig * config;
@property (nonatomic,strong)YB_CoreTextData * data;

@end

@interface YB_CTextField : UITextField

@end
