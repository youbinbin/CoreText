//
//  YB_CTFrameParser.h
//  YB_CoreTextDemo
//
//  Created by HuaTuYiDongXueXi on 17/4/6.
//  Copyright © 2017年 youbinbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YB_CoreTextData.h"
#import "YB_CTFrameParserConfig.h"
#import "YB_CoreTextImageData.h"
#import "YB_CoreTextLinkData.h"
#import "YB_CoreTextTextFiledData.h"
@interface YB_CTFrameParser : NSObject

+ (YB_CoreTextData *)parseContent:(NSString *)content config:(YB_CTFrameParserConfig*)config;
///读取本地文件实现
+(YB_CoreTextData*)parseTemplateFile:(NSString*)path config:(YB_CTFrameParserConfig*)config;
///数组套字典形式数据。
+(YB_CoreTextData*)parseContentArray:(NSArray*)content config:(YB_CTFrameParserConfig*)config;

@end
