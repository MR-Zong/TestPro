//
//  JBoImageTextLabel.h
//  CoreTextDemo
//
//  Created by kinghe005 on 14-4-16.
//  Copyright (c) 2014年 KingHe. All rights reserved.
//

#import <UIKit/UIKit.h>


@class JBoImageTextLabel;

/**自定义label代理
 */
@protocol JBoImageTextLabelDelegate <NSObject>

/**选中链接
 */
- (void)imageTextLabel:(JBoImageTextLabel*) label didSelectedURL:(NSURL*) url;

@end

/**自定义的label, 可显示富文本，链接识别，图文混排
 */
@interface JBoImageTextLabel : UIView

/**基本字体
 */
@property(nonatomic,retain) UIFont *font;

/*基本字体颜色
 */
@property(nonatomic,retain) UIColor *textColor;

/**文本内容
 */
@property(nonatomic,assign) NSString *text;

/**url 样式 默认蓝色字体加下划线
 */
@property(nonatomic,readonly) NSDictionary *urlAttributes;

/**对齐方式
 */
//@property(nonatomic,assign) JBoTextAlignment textAlignment;

/**字体样式 default is 'nil' 数组元素是 JBoOpenPlatformTextStyleInfo 对象
 */
@property(nonatomic,retain) NSArray *attributes;

/**url点击手势
 */
@property(nonatomic,readonly) UITapGestureRecognizer *tapGesture;

@property(nonatomic,assign) id<JBoImageTextLabelDelegate> delegate;

/**文字与边框的距离 default 5.0
 */
@property(nonatomic,assign) CGFloat textInset;

/** 最小行高度 default 24.0
 */
@property(nonatomic,assign) CGFloat minLineHeight;

/**文字与文字间的距离 default 1.0
 */
@property(nonatomic,assign) CGFloat wordInset;

/**内容是否垂直居中居中 default No
 */
@property(nonatomic,assign) BOOL verticalAlignmentCenter;

/**内容是否水平居中 default NO
 */
@property(nonatomic,assign) BOOL horizontalAlignmentCenter;

/**是否需要识别URL default is ‘YES’
 */
@property(nonatomic,assign) BOOL recognizeURL;

/**特殊显示 颜色 数组元素是UIColor对象 default is 'nil'
 */
@property(nonatomic,retain) NSArray *specialColorArray;

/**特殊显示的字符串 数组元素是 NSString对象 default is 'nil'
 */
@property(nonatomic,retain) NSArray *specialTextArray;


- (NSAttributedString*)getAttributedTextFromString:(NSString*) string;

@end
