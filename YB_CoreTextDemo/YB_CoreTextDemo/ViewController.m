//
//  ViewController.m
//  YB_CoreTextDemo
//
//  Created by HuaTuYiDongXueXi on 17/3/30.
//  Copyright © 2017年 youbinbin. All rights reserved.
//

#import "ViewController.h"
#import "YB_CoreTextData.h"
#import "YB_CTFrameParserConfig.h"
#import "YB_CoreTextView.h"
#import "UIView+frameAdjust.h"
#import "YB_CTFrameParser.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet YB_CoreTextView *ctView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    YB_CTFrameParserConfig *config = [[YB_CTFrameParserConfig alloc] init];
    config.textColor = [UIColor redColor];
    config.width =self.view.width-30;
 
    NSArray * arrar =  @[@{@"type":@"txt",@"color":@"#FF9900",@"size":@16,@"content":@"按照以上原则，我们将`CTDisplayView`中的部分内容拆开。呵呵ads阿斯顿发放撒什么大师傅阿斯蒂芬说asdfasdfsdasdfasdfz真的"},
                         @{@"type":@"textFiled",@"textFiled":
                               @{@"width":[NSNumber numberWithFloat:100.0],
                                 @"height":[NSNumber numberWithFloat:[UIFont systemFontOfSize:20].pointSize]}},
                  
                         @{@"type":@"img",@"name":@"test",@"img":@{@"width":[NSNumber numberWithFloat:100],
                                                                   @"height":[NSNumber numberWithFloat:100]}
                           }                        ];
    YB_CoreTextData *data =[YB_CTFrameParser parseContentArray:arrar config:config];
    
    
    self.ctView.data = data;
    self.ctView.height = data.height;
    self.ctView.config=config;
    self.ctView.backgroundColor = [UIColor yellowColor];
 
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
