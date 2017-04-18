//
//  YB_CoreTextTextFiledData.h
//  YB_CoreTextDemo
//
//  Created by HuaTuYiDongXueXi on 17/4/11.
//  Copyright © 2017年 youbinbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface YB_CoreTextTextFiledData : NSObject
/**
 *  坐标。
 */
@property (nonatomic)int position;
// 此坐标是 CoreText 的坐标系，而不是UIKit的坐标系
@property (nonatomic,assign)CGRect textFiledPosition;
@end
