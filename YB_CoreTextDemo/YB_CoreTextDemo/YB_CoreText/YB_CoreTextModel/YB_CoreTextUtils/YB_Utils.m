//
//  YB_Utils.m
//  YB_CoreTextDemo
//
//  Created by HuaTuYiDongXueXi on 17/4/7.
//  Copyright © 2017年 youbinbin. All rights reserved.
//

#import "YB_Utils.h"

@implementation YB_Utils
+(YB_CoreTextLinkData *)touchLinkInView:(UIView *)view atPoint:(CGPoint)point data:(YB_CoreTextData *)data{

    CTFrameRef textFrame = data.ctFrame;
    CFArrayRef lines = CTFrameGetLines(textFrame);
    if (!lines) {
        return nil;
    }

    CFIndex count = CFArrayGetCount(lines);
    
    YB_CoreTextLinkData * foundLink = nil;
    
    //获取每一行origin的坐标。
    CGPoint origins[count];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
    
    //翻转坐标系。
    CGAffineTransform transForm = CGAffineTransformMakeTranslation(0, view.bounds.size.height);
    transForm = CGAffineTransformScale(transForm, 1.f, -1.f);
    
    for (int i=0; i<count; i++) {
        CGPoint linePoint = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        //获取每一行的CGRect 信息。
        CGRect flippedRect = [self getLineBounds:line point:linePoint];
        CGRect rect = CGRectApplyAffineTransform(flippedRect, transForm);
        
        if (CGRectContainsPoint(rect, point)) {
            //将点击的坐标转换成相对于多功能前行的坐标。
            CGPoint relativePoint = CGPointMake(point.x-CGRectGetMaxX(rect),
                                                point.y-CGRectGetMaxY(rect));
            
            //获得当前点击坐标的对应的字符串偏移。
            CFIndex idx =  CTLineGetStringIndexForPosition(line, relativePoint);
            //判断这个便宜是否在我们的链接列表中。
            foundLink = [self linkAtIndex:idx linkArray:data.linkArray];
            
            return foundLink;
        }
    }
    return nil;
}

+ (CGRect)getLineBounds:(CTLineRef)line point:(CGPoint)point{
    CGFloat ascent = 0.0f;
    CGFloat descent = 0.0f;
    CGFloat leading = 0.0f;
    CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    CGFloat height = ascent + descent;
    
    return CGRectMake(point.x, point.y-descent,width , height);
}

+(YB_CoreTextLinkData*)linkAtIndex:(CFIndex)i linkArray:(NSArray*)linkArray{
    YB_CoreTextLinkData * link = nil;
    for (YB_CoreTextLinkData * data in linkArray) {
        if (NSLocationInRange(i, data.range)) {
            link=data;
            break;
        }
    }
    return link;
}


@end
