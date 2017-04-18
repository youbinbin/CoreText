//
//  YB_CoreTextView.m
//  YB_CoreTextDemo
//
//  Created by HuaTuYiDongXueXi on 17/3/30.
//  Copyright © 2017年 youbinbin. All rights reserved.
//

#import "YB_CoreTextView.h"
#import "YB_CoreTextImageData.h"
#import "YB_CoreTextLinkData.h"
#import "YB_CoreTextTextFiledData.h"
#import "YB_Utils.h"
@implementation YB_CoreTextView

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self=[super initWithCoder:aDecoder]) {
        
    }
    return self;
}

-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    if (self.data == nil) {
        return;
    }
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0,self.data.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    if (self.data) {
        CTFrameDraw(self.data.ctFrame, context);
    }
    
    for (id data in self.data.imageArray) {
        if ([data isKindOfClass:[YB_CoreTextImageData class]]) {
            YB_CoreTextImageData * imageData = (YB_CoreTextImageData*)data;
            
            UIImage *image = [UIImage imageNamed:imageData.name];
            //        SDImageCache * cache=[SDImageCache sharedImageCache];
            //        image=[cache imageFromDiskCacheForKey:imageData.name];
            if (image) {
                CGContextDrawImage(context, imageData.imagePosition, image.CGImage);
            }else{
                //            [self refreshImage:imageData.name];
            }
                ///添加输入框功能。
        }else if([data isKindOfClass:[YB_CoreTextTextFiledData class]]){
            YB_CoreTextTextFiledData * imageData = (YB_CoreTextTextFiledData*)data;
            CGRect rect=imageData.textFiledPosition;
            YB_CTextField * filed=[[YB_CTextField alloc]initWithFrame:CGRectMake(rect.origin.x+2,
                                                                             self.data.height-rect.origin.y-rect.size.height,
                                                                             rect.size.width-4,
                                                                             rect.size.height)];
            filed.font=[UIFont systemFontOfSize:_config.fontSize];
            
            filed.layer.borderColor=[UIColor blueColor].CGColor;
            filed.layer.borderWidth=1;
            
            filed.layer.cornerRadius=5;
            filed.clipsToBounds=YES;
            [self addSubview:filed];
        }
   
    }
 
    
    /**
     * 暂时去掉选中和复制等功能。
     */
    //    if (self.state == CTDisplayViewStateTouching || self.state == CTDisplayViewStateSelecting) {
    //        [self drawSelectionArea];
    //        [self drawAnchors];
    //    }
 

//    ///获取当前绘制画布的上下文
//    CGContextRef context=UIGraphicsGetCurrentContext();
//    
//    //2
//    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
//    CGContextTranslateCTM(context, 0, self.bounds.size.height);
//    CGContextScaleCTM(context,1.0, -1.0);
//
//    
//    ///3
//    CGMutablePathRef path=CGPathCreateMutable();
//    CGPathAddRect(path, NULL, self.bounds);
//    
//    ///4
//    NSAttributedString * attString=[[NSAttributedString alloc] initWithString:@"Hello World! "" 创建绘制的区域，CoreText 本身支持各种文字排版的区域，"
//                                    " 我们这里简单地将 UIView 的整个界面作为排版的区域。"
//                                    " 为了加深理解，建议读者将该步骤的代码替换成如下代码，"
//                                    " 测试设置不同的绘制区域带来的界面变化。"];
//    CTFramesetterRef framesetter=CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
//    CTFrameRef frame=CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [attString length]), path, NULL);
//    
//    // 步骤 5
//    CTFrameDraw(frame, context);
//    
//    // 步骤 6
//    CFRelease(frame);
//    CFRelease(path);
//    CFRelease(framesetter);
}



-(void)setUpEvents{
    UIGestureRecognizer * tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(userTapGestureDetected:)];
    [self addGestureRecognizer:tap];
    self.userInteractionEnabled=YES;
}
- (void)userTapGestureDetected:(UIGestureRecognizer*)recognizer{
    CGPoint point = [recognizer locationInView:self];
    for (YB_CoreTextImageData * imageData in self.data.imageArray) {
        //翻转坐标，因为imageData 中坐标是CoreText 的坐标系。
        CGRect imageRect = imageData.imagePosition;
        CGPoint imagePosition = imageRect.origin;
        imagePosition.y = self.bounds.size.height-imageRect.origin.y - imageRect.size.height;
        
        CGRect rect = CGRectMake(imagePosition.x, imagePosition.y, imageRect.size.width, imageRect.size.height);
        
        if (CGRectContainsPoint(rect, point)) {
                //在这里处理点击后的逻辑。
            
            return;
        }
    }
    
    YB_CoreTextLinkData * linkData = [YB_Utils touchLinkInView:self atPoint:point data:self.data];
    if(linkData){
        //在这里处理链接点击。
        return;
    }
}

@end

@implementation YB_CTextField

//控制编辑文本的位置
-(CGRect)editingRectForBounds:(CGRect)bounds
{
    //return CGRectInset( bounds, 10 , 0 );
    
    CGRect inset = CGRectMake(bounds.origin.x +5, bounds.origin.y, bounds.size.width -10, bounds.size.height);
    return inset;
}

// 修改文本展示区域，一般跟editingRectForBounds一起重写
- (CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect inset = CGRectMake(bounds.origin.x+5, bounds.origin.y, bounds.size.width-10, bounds.size.height);//更好理解些
    return inset;
}

@end

