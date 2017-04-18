//
//  YB_CTFrameParser.m
//  YB_CoreTextDemo
//
//  Created by HuaTuYiDongXueXi on 17/4/6.
//  Copyright © 2017年 youbinbin. All rights reserved.
//

#import "YB_CTFrameParser.h"
#import <CoreText/CoreText.h>
#import <objc/runtime.h>

@implementation YB_CTFrameParser

+(YB_CoreTextData *)parseTemplateFile:(NSString *)path config:(YB_CTFrameParserConfig *)config{
    NSMutableArray * imageArray = [NSMutableArray array];
    
    NSMutableArray * linkArray = [NSMutableArray array];

    NSAttributedString * content = [self loadTempLateFile:path config:config imageArray:imageArray linkArray:linkArray];
    
    YB_CoreTextData *data = [self parseAttributedContent:content config:config];
    data.imageArray = imageArray;
    data.linkArray = linkArray;
//    data.textFiledArray = textFieldArray;
    return data;
}

///遍历不同类型属性的字符串。
+ (NSAttributedString*)loadTempLateFile:(NSString*)path config:(YB_CTFrameParserConfig*)config imageArray:(NSMutableArray*)imageArray linkArray:(NSMutableArray*)linkArray{
    NSData * data = [NSData dataWithContentsOfFile:path];
    NSMutableAttributedString * result=[[NSMutableAttributedString alloc]init];
    if (data) {
        NSArray * array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        result=[self array:array config:config imageArray:imageArray linkArray:linkArray];
        
    }
    return result;
}
///中间便利方法。筛选不同 type  类确定不同的处理方法。
+(NSMutableAttributedString*)array:(NSArray*)array config:(YB_CTFrameParserConfig*)config imageArray:(NSMutableArray*)imageArray linkArray:(NSMutableArray*)linkArray{
    NSMutableAttributedString * result =[[NSMutableAttributedString alloc] init];
    if ([array isKindOfClass:[NSArray class]]) {
        for (NSDictionary * dic in array) {
            NSString * type = dic[@"type"];
            if ([type isEqualToString:@"txt"]) {
                NSAttributedString * as =[self parseAttributedContentFromNSDictionary:dic config:config];
                [result appendAttributedString:as];
                
            }else if([type isEqualToString:@"img"]){
                //创建coreTextImageData
                YB_CoreTextImageData * imageData=[[YB_CoreTextImageData alloc]init];
                imageData.name = dic[@"name"];
                imageData.position = [result length];
                [imageArray addObject:imageData];
                
                //创建空白占位符
                NSAttributedString * as = [self parseImageDataFromNSDictionary:dic[@"img"] config:config];
                [result appendAttributedString:as];
                
            }else if([type isEqualToString:@"link"]){
                //
                NSUInteger startPos = result.length;
                NSAttributedString * as = [self parseAttributedContentFromNSDictionary:dic config:config];
                [result appendAttributedString:as];
                //创建CoreTextLinkData
                NSUInteger length = result.length - startPos;
                NSRange linkRange = NSMakeRange(startPos, length);
                YB_CoreTextLinkData * linkData = [[YB_CoreTextLinkData alloc]init];
                linkData.title = dic[@"content"];
                linkData.url = dic[@"url"];
                linkData.range = linkRange;
                [linkArray addObject:linkData];
            }else if([type isEqualToString:@"textFiled"]){
                
                YB_CoreTextTextFiledData * data=[[YB_CoreTextTextFiledData alloc]init];
                data.position =(int)[result length];
                [imageArray addObject:data];
                //创建空白占位符
                NSAttributedString * as = [self parseImageDataFromNSDictionary:dic[@"textFiled"] config:config];
                [result appendAttributedString:as];
              
            }else if([type isEqualToString:@"underline"]){
                
                [result appendAttributedString:[self parseUnderlineFromNSDictionary:dic config:config]];
            }
        }
     
    }
       return result;
}




///数组。
+(YB_CoreTextData*)parseContentArray:(NSArray*)content config:(YB_CTFrameParserConfig*)config{
    NSMutableArray * imageArray = [NSMutableArray array];
    
    NSMutableArray * linkArray = [NSMutableArray array];

    NSAttributedString * contents = [self array:content config:config imageArray:imageArray linkArray:linkArray];
    
    YB_CoreTextData *data = [self parseAttributedContent:contents config:config];
    data.imageArray = imageArray;
    data.linkArray = linkArray;

    return data;
}


#pragma mark - C delegate  CTRunDelegate 
static CGFloat ascentCallBack(void*ref){
    return [(NSNumber*)[(__bridge NSDictionary*)ref objectForKey:@"height"]floatValue];
}
static CGFloat descentCallBack(void*ref){
    return 0;
}
static CGFloat widthCallBack(void*ref){
    return [(NSNumber*)[(__bridge NSDictionary*)ref objectForKey:@"width"]floatValue];
}




///设置图片。属性字符串。
+ (NSAttributedString*)parseImageDataFromNSDictionary:(NSDictionary*)dict config:(YB_CTFrameParserConfig*)config{
    
    CTRunDelegateCallbacks callbacks;
    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascentCallBack;
    callbacks.getDescent = descentCallBack;
    callbacks.getWidth = widthCallBack;
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)(dict));
    
    // 使用0xFFFC作为空白的占位符
    unichar objectReplacementChar = 0xFFFC;
    NSString * content = [NSString stringWithCharacters:&objectReplacementChar length:1];
    NSDictionary * attributes = [self attributesWithConfig:config];
    NSMutableAttributedString * space = [[NSMutableAttributedString alloc] initWithString:content
                                                                               attributes:attributes];
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)space, CFRangeMake(0, 1),
                                   kCTRunDelegateAttributeName, delegate);
    CFRelease(delegate);
    
    return space;
}

///设置下划线。
+(NSAttributedString*)parseUnderlineFromNSDictionary:(NSDictionary *)dict
                                              config:(YB_CTFrameParserConfig*)config{
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesWithConfig:config]];
    // set color
    UIColor *color = dict[@"color"];
    if (color) {
        attributes[(id)kCTForegroundColorAttributeName] = (id)color.CGColor;
    }
    // set font size
    //    CGFloat fontSize = [dict[@"size"] floatValue];
    CGFloat fontSize=config.fontSize;
    if (fontSize > 0) {
        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
        attributes[(id)kCTFontAttributeName] = (__bridge id)fontRef;
        CFRelease(fontRef);
    }
    
    [attributes setValue:config.textColor forKey:NSUnderlineColorAttributeName];
    attributes[(id)kCTUnderlineStyleAttributeName]=(id)[NSNumber numberWithInt:kCTUnderlineStyleSingle];
    attributes[(id)kCTUnderlineColorAttributeName]=(id)color.CGColor;
    NSString *content = dict[@"content"];
    return [[NSAttributedString alloc] initWithString:content attributes:attributes];
}


///创建textField占位符。
+(NSAttributedString*)paresTextFieldDataFromNSDictionary:(NSDictionary*)dict config:(YB_CTFrameParserConfig*)config{
 
    CTRunDelegateCallbacks callbacks;
    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascentCallBack;
    callbacks.getDescent = descentCallBack;
    callbacks.getWidth = widthCallBack;
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)(dict));
    
    // 使用0xFFFC作为空白的占位符
    unichar objectReplacementChar = 0xFFFC;
    NSString * content = [NSString stringWithCharacters:&objectReplacementChar length:1];
    NSDictionary * attributes = [self attributesWithConfig:config];
    NSMutableAttributedString * space = [[NSMutableAttributedString alloc] initWithString:content
                                                                               attributes:attributes];
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)space, CFRangeMake(0, 1),
                                   kCTRunDelegateAttributeName, delegate);
    CFRelease(delegate);
    return space;
}

///获取单一属性的字符串。
+ (NSAttributedString *)parseAttributedContentFromNSDictionary:(NSDictionary *)dict config:(YB_CTFrameParserConfig*)config{
    NSMutableDictionary * attributes = [[self attributesWithConfig:config] mutableCopy];
    
    UIColor * color =[self getColor:dict[@"color"]];
    if (color) {
        attributes[(id)kCTForegroundColorAttributeName] = (id)color.CGColor;
    }
    
    //set font size
    CGFloat fontSize = [dict[@"size"] floatValue];
    if (fontSize>0) {
        CTFontRef fontref=CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
        attributes[(id)kCTFontAttributeName] = (__bridge id)fontref;
        CFRelease(fontref);
    }
    NSString * content = dict[@"content"];
    return [[NSAttributedString alloc] initWithString:content attributes:attributes];
}

 
///获取颜色值。
 + (UIColor *)getColor:(NSString *)hexColor {
    NSString *string = [hexColor substringFromIndex:1];//去掉#号
    unsigned int red,green,blue;
    NSRange range;
    range.length = 2;
    
    range.location = 0;
    /* 调用下面的方法处理字符串 */
    red = [self stringToInt:[string substringWithRange:range]];
    
    range.location = 2;
    green = [self stringToInt:[string substringWithRange:range]];
    range.location = 4;
    blue = [self stringToInt:[string substringWithRange:range]];
    
    return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green / 255.0f) blue:(float)(blue / 255.0f) alpha:1.0f];
}

//截取后的字符串处理

+ (int)stringToInt:(NSString *)string {
    
    unichar hex_char1 = [string characterAtIndex:0]; /* 两位16进制数中的第一位(高位*16) */
    int int_ch1;
    if (hex_char1 >= '0' && hex_char1 <= '9')
        int_ch1 = (hex_char1 - 48) * 16;   /* 0 的Ascll - 48 */
    else if (hex_char1 >= 'A' && hex_char1 <='F')
        int_ch1 = (hex_char1 - 55) * 16; /* A 的Ascll - 65 */
    else
        int_ch1 = (hex_char1 - 87) * 16; /* a 的Ascll - 97 */
    unichar hex_char2 = [string characterAtIndex:1]; /* 两位16进制数中的第二位(低位) */
    int int_ch2;
    if (hex_char2 >= '0' && hex_char2 <='9')
        int_ch2 = (hex_char2 - 48); /* 0 的Ascll - 48 */
    else if (hex_char1 >= 'A' && hex_char1 <= 'F')
        int_ch2 = hex_char2 - 55; /* A 的Ascll - 65 */
    else
        int_ch2 = hex_char2 - 87; /* a 的Ascll - 97 */
    return int_ch1+int_ch2;
}


+(NSDictionary*)attributesWithConfig:(YB_CTFrameParserConfig*)config{

        CGFloat fontSize = config.fontSize;
        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
        CGFloat lineSpacing = config.lineSpace;
        const CFIndex kNumberOfSettings = 3;
        CTParagraphStyleSetting theSettings[kNumberOfSettings] = {
            { kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &lineSpacing },
            { kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &lineSpacing },
            { kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &lineSpacing }
        };
        
        CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, kNumberOfSettings);
        
        UIColor * textColor = config.textColor;
        
        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        dict[(id)kCTForegroundColorAttributeName] = (id)textColor.CGColor;
        dict[(id)kCTFontAttributeName] = (__bridge id)fontRef;
        dict[(id)kCTParagraphStyleAttributeName] = (__bridge id)theParagraphRef;
        
        CFRelease(theParagraphRef);
        CFRelease(fontRef);
    return dict;
}

///根据config 设置字符串为属性字符串。
+(YB_CoreTextData *)parseContent:(NSString *)content config:(YB_CTFrameParserConfig *)config{

    NSDictionary * attributes=[self attributesWithConfig:config];
    
    NSAttributedString *contentString =
    [[NSAttributedString alloc] initWithString:content
                                    attributes:attributes];
    
    return [self parseAttributedContent:contentString config:config];
}


///根据属性字符串创建data.
+ (YB_CoreTextData*)parseAttributedContent:(NSAttributedString*)content config:(YB_CTFrameParserConfig*)config{
    //创建CTFramesetterRef 实例。
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)content);
    
    //获得要绘制的区域的高度。
    CGSize restrictSize = CGSizeMake(config.width, CGFLOAT_MAX);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRangeMake(0, 0), nil, restrictSize, nil);
    CGFloat textHeiht = coreTextSize.height;
    
    //生成CTFrameRef 实例。
    CTFrameRef frame = [self createFrameWithFramesetter:frameSetter config:config height:textHeiht];
    
    ///将生成好的CTFrameRef 实例和计算好的绘制高度保存到 CoreTextData 实例中，最后返回CoreTextData 实例。
    YB_CoreTextData * data = [[YB_CoreTextData alloc]init];
    data.ctFrame = frame;
    data.height=textHeiht;
    data.content = content;
    
    //释放内存。
    CFRelease(frame);
    CFRelease(frameSetter);
    return data;
}


+(CTFrameRef)createFrameWithFramesetter:(CTFramesetterRef)framesetter config:(YB_CTFrameParserConfig*)config height:(CGFloat)height{
    CGMutablePathRef path =CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, config.width, height));
    CTFrameRef frame=CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CFRelease(path);
    return frame;
}

@end
