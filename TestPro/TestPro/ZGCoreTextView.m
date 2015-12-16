//
//  ZGCoreTextView.m
//  TestPro
//
//  Created by Zong on 15/12/14.
//  Copyright © 2015年 Zong. All rights reserved.
//

#import "ZGCoreTextView.h"
#import <CoreText/CoreText.h>

@implementation ZGCoreTextView


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 2 将坐标系上下翻转,对于底层的绘制引擎来讲,屏幕的左下角是(0,0)坐标,而对于上层的UIKit来讲,左上角是(0, 0)坐标,所以我们为了之后的坐标系描述按UIKit 来做,现在这里做了一个坐标系的上下翻转,翻转之后,底层和上层的(0,0)坐标就是重合的了,// 如果将这些代码注释掉,就会发现,整个hello world 就会上下翻转
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    
    /* 创建绘制区域,CoreText本身支持各种文字排版的区域"
     
     "我们这里简单的将uiview的整个界面作为排版的区域"
     
     "为了加深理解,我们将该步骤的代码替换如下"
     
     "测试设置不同的绘制区域带来的界面变化"
     */
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, NULL, self.bounds);
    
    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:@"Hello World!"];
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef) attributeStr);
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, [attributeStr length]), path, NULL);
    
    CTFrameDraw(frame, context);
    
    CFRelease(frame);
    CFRelease(frameSetter);
    CFRelease(path);
    
}

@end
