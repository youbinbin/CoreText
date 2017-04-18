//
//  YB_CoreTextData.m
//  YB_CoreTextDemo
//
//  Created by HuaTuYiDongXueXi on 17/4/6.
//  Copyright © 2017年 youbinbin. All rights reserved.
//

#import "YB_CoreTextData.h"
#import "YB_CoreTextImageData.h"
#import "YB_CoreTextTextFiledData.h"
@implementation YB_CoreTextData
-(void)setCtFrame:(CTFrameRef)ctFrame{
    if (_ctFrame!=ctFrame) {
        if (_ctFrame!=nil) {
            CFRelease(_ctFrame);
        }
        CFRetain(ctFrame);
        _ctFrame=ctFrame;
    }
}

-(void)dealloc{
    if (_ctFrame!=nil) {
        CFRelease(_ctFrame);;
        _ctFrame=nil;
    }
}


-(void)setImageArray:(NSArray *)imageArray{
    _imageArray=imageArray;
    [self fillImagePosition];
}
 
-(void)fillImagePosition{
    if (self.imageArray.count==0) {
        return;
    }
    NSArray * lines = (NSArray *) CTFrameGetLines(self.ctFrame);
    
    NSUInteger lineCount = [lines count];
    
    CGPoint lineOrigins[lineCount];
    
    CTFrameGetLineOrigins(self.ctFrame, CFRangeMake(0, 0), lineOrigins);
    int imageIndex = 0;
 
    id imageData = self.imageArray[0];
    for (int i=0 ;i<lineCount;i++) {
        if (imageData == nil) {
            break;
        }
        CTLineRef line = (__bridge CTLineRef)lines[i];
        NSArray * runObjArray = (NSArray*)CTLineGetGlyphRuns(line);
        for (id runObj in runObjArray) {
            
            
            CTRunRef run=(__bridge CTRunRef)runObj;
            NSDictionary * runAttributes = (NSDictionary *)CTRunGetAttributes(run);
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(id)kCTRunDelegateAttributeName];
            if (delegate == nil) {
                continue;
            }
            
            NSDictionary * metaDic = CTRunDelegateGetRefCon(delegate);
            
            if (![metaDic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            
            CGRect runBounds;
            CGFloat ascent;
            CGFloat descent;
            runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
            runBounds.size.height = ascent + descent;
            
            CGFloat xoffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
            
            if ([imageData isKindOfClass:[YB_CoreTextImageData class]]) {
                runBounds.origin.x = lineOrigins[i].x + xoffset;
                runBounds.origin.y = lineOrigins[i].y-4;
                runBounds.origin.y -= descent;
            }else if([imageData isKindOfClass:[YB_CoreTextTextFiledData class]]){
                runBounds.origin.x = lineOrigins[i].x + xoffset;
                runBounds.origin.y = lineOrigins[i].y-4;
                runBounds.origin.y -= descent;
            }
   
            
            CGPathRef pathRef = CTFrameGetPath(self.ctFrame);
            CGRect colRect = CGPathGetBoundingBox(pathRef);
            
            CGRect delegateBounds = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
            
            if ([imageData isKindOfClass:[YB_CoreTextImageData class]]) {
                YB_CoreTextImageData * data = (YB_CoreTextImageData*)imageData;
                data.imagePosition = delegateBounds;
            }else if([imageData isKindOfClass:[YB_CoreTextTextFiledData class]]){
                YB_CoreTextTextFiledData * data = (YB_CoreTextTextFiledData*)imageData;
                data.textFiledPosition = delegateBounds;
            }

            imageIndex++;
            
            if (imageIndex == self.imageArray.count) {
                imageData = nil;
                break;
            }else{
                imageData = self.imageArray[imageIndex];
            }
    
        }
    }
}

@end
