//
//  JBoImageTextLabel.m
//  CoreTextDemo
//
//  Created by kinghe005 on 14-4-16.
//  Copyright (c) 2014年 KingHe. All rights reserved.
//

#import "JBoImageTextLabel.h"
#import <CoreText/CoreText.h>
//#import "JBoBasic.h"
//#import "NSString+customString.h"
//#import "JBoImageTextTool.h"
//#import "JBoOpenPlatformTextStyleInfo.h"

static NSString *const facePrefix = @"[/";
static NSString *const faceSuffix = @"]";
static NSString *const faceSpace = @" ";
static NSString *const faceImageName = @"face";
static NSString *const urlRegex = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";

//static NSString *const urlRegex = @"\\b(https?)://(?:(\\S+?)(?::(\\S+?))?@)?([a-zA-Z0-9\\-.]+)(?::(\\d+))?((?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";

#define _facePadding_ 3.0
#define _textPadding_ 5.0


#pragma mark-CTRunDelegateCallbacks

void RunDelegateDeallocCallback(void* refCon)
{
    
}

CGFloat RunDelegateGetAscentCallback(void* refCon)
{
//    NSString *imageName = (NSString*)refCon;
//    UIImage *image = [UIImage imageNamed:imageName];
//    return image.size.height;
    return 0;
}

CGFloat RunDelegateGetDescentCallback(void* refCon)
{
    return 0;
}

CGFloat RunDelegateGetWidthCallback(void* refCon)
{
    return [UIImage imageNamed:(NSString*) refCon].size.width + _facePadding_;
}

#pragma mark-JBoImageTextLabel

@interface JBoImageTextLabel ()<UIGestureRecognizerDelegate>

@property(nonatomic, copy) NSAttributedString *imageTextAttributedText;

@property(nonatomic,assign) CTFramesetterRef framesetter;
@property(nonatomic,retain) NSArray *urlArray;

//url正则表达式 搜索
@property(nonatomic,retain) NSRegularExpression *expression;



@end

@implementation JBoImageTextLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialization];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        [self initialization];
    }
    
    return self;
}

- (void)initialization
{
    self.clipsToBounds = YES;
    self.userInteractionEnabled = YES;
    
    self.textColor = [UIColor blackColor];
    self.font = [UIFont systemFontOfSize:17.0];
    self.expression = [NSRegularExpression regularExpressionWithPattern:urlRegex options:NSRegularExpressionCaseInsensitive error:nil];
//    self.textAlignment = JBoTextAlignmentLeft;
    self.recognizeURL = YES;
    self.wordInset = 1.0;
    self.minLineHeight = 24.0;
    self.textInset = _textPadding_;
    self.backgroundColor = [UIColor clearColor];
}

#pragma mark- property

- (void)setRecognizeURL:(BOOL)recognizeURL
{
    if(_recognizeURL != recognizeURL)
    {
        _recognizeURL = recognizeURL;
        if(_recognizeURL)
        {
            if(!_urlAttributes)
            {
                NSMutableDictionary *mutableLinkAttributes = [NSMutableDictionary dictionary];
                [mutableLinkAttributes setValue:(id)[[UIColor blueColor] CGColor] forKey:(NSString*)kCTForegroundColorAttributeName];
                [mutableLinkAttributes setValue:[NSNumber numberWithBool:YES] forKey:(NSString *)kCTUnderlineStyleAttributeName];
                
                _urlAttributes = [mutableLinkAttributes retain];
                
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
                tap.delegate = self;
                [self addGestureRecognizer:tap];
                _tapGesture = [tap retain];
                [tap release];
            }
        }
        else
        {
            [_urlAttributes release];
            _urlAttributes = nil;
            [_tapGesture release];
            _tapGesture = nil;
        }
    }
}

- (void)setFont:(UIFont *)font
{
    if(_font != font)
    {
        [_font release];
        _font = [font retain];
    }
}

- (void)setTextColor:(UIColor *)textColor
{
    if(_textColor != textColor)
    {
        [_textColor release];
        _textColor = [textColor retain];
    }
}

#pragma mark-内存管理

- (void)dealloc
{
    [_font release];
    [_textColor release];
    [_attributes release];
    
    [_urlAttributes release];
    [_imageTextAttributedText release];
    
    if(_framesetter)
        CFRelease(_framesetter);
    
    [_urlArray release];
    [_expression release];
    [_tapGesture release];
    
    [_specialColorArray release];
    [_specialTextArray release];
    
    [super dealloc];
}



#pragma mark-绘制

- (void)setText:(NSString *)text
{
    self.imageTextAttributedText = [self getAttributedTextFromString:text];
    [self setNeedsDisplay];
}

- (NSString*)text
{
    return self.imageTextAttributedText.string;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);//设置字形变换矩阵为CGAffineTransformIdentity，也就是说每一个字形都不做图形变换
    
    //翻转
    // Inverts the CTM to match iOS coordinates (otherwise text draws upside-down; Mac OS's system is different)
    //    CGContextTranslateCTM(context, 0.0f, rect.size.height);
    //    CGContextScaleCTM(context, 1.0f, -1.0f);
    
    CGAffineTransform transform = CGAffineTransformMake(1, 0, 0, -1, 0, rect.size.height);
    CGContextConcatCTM(context, transform);
    
    CGFloat topInset = self.textInset;
    CGFloat leftInset = self.textInset;
    
    if(self.verticalAlignmentCenter || self.horizontalAlignmentCenter)
    {
        CGSize size = [JBoImageTextTool getHeightFromAttributedText:self.imageTextAttributedText contraintWidth:rect.size.width - self.textInset * 2];
        if(self.horizontalAlignmentCenter)
        {
            leftInset = (rect.size.width - size.width) / 2;
            leftInset = leftInset < self.textInset ? self.textInset : leftInset;
        }
        
        if(self.verticalAlignmentCenter)
        {
            topInset = (rect.size.height - size.height) / 2;
            topInset = topInset < self.textInset ? self.textInset : topInset;
        }
    }
    
    //开始绘制
    CGMutablePathRef path = CGPathCreateMutable();
    CGRect bounds = CGRectMake(leftInset, topInset, rect.size.width - leftInset * 2, rect.size.height - topInset * 2);
    CGPathAddRect(path, NULL, bounds);
    
    //文本框大小
    CTFrameRef frame = CTFramesetterCreateFrame(self.framesetter, CFRangeMake(0, 0), path, NULL);
    CTFrameDraw(frame, context);
    
    CFArrayRef lines = CTFrameGetLines(frame);

    if(lines == NULL)
    {
        if(path != NULL)
        {
            CFRelease(path);
        }
        
        if(frame != NULL)
        {
            CFRelease(frame);
        }
        return;
    }
    CGPoint lineOrigins[CFArrayGetCount(lines)];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), lineOrigins);
    
    for(int i = 0;i < CFArrayGetCount(lines);i ++)
    {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        //        CGFloat lineAscent;
        //        CGFloat lineDescent;
        //        CGFloat lineLeading;
        //
        //        //获取文字排版
        //        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
        //        NSLog(@"i =%d %f,%f,%f", i,lineAscent, lineDescent, lineLeading);
        
        //图片回调
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        CGPoint lineOrigin = lineOrigins[i];
        
        if(lineOrigin.x > self.textInset)
        {
            lineOrigin.x += _facePadding_;
        }
        
        for(int j = 0;j < CFArrayGetCount(runs);j ++)
        {
            CGFloat runAscent;
            CGFloat runDescent;
            
            CTRunRef run = CFArrayGetValueAtIndex(runs, j);
            NSDictionary *attributes = (NSDictionary*)CTRunGetAttributes(run);
            
            CGRect runRect;
            runRect.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &runAscent, &runDescent, NULL);
            
            runRect = CGRectMake(lineOrigin.x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL), lineOrigin.y - runDescent, runRect.size.width, runAscent + runDescent);
            
            NSString *imageName = [attributes objectForKey:faceImageName];
            if(imageName)
            {
                UIImage *image = [UIImage imageNamed:imageName];
                 //NSLog(@"%@,%@",image,imageName);
                if(image)
                {
                    CGRect imageDrawRect;
                    imageDrawRect.origin.x = runRect.origin.x + lineOrigin.x;
                    imageDrawRect.origin.y = lineOrigin.y + self.textInset - 1.0;
                    imageDrawRect.size = CGSizeMake(image.size.width, image.size.height);
                    
                   // NSLog(@"%@", NSStringFromCGRect(imageDrawRect));
                    
                    CGContextDrawImage(context, imageDrawRect, image.CGImage);
                }
            }
        }
    }
    
    if(path != NULL)
    {
        CFRelease(path);
    }
    
    if(frame != NULL)
    {
        CFRelease(frame);
    }
}

#pragma mark-private method

- (NSAttributedString*)getAttributedTextFromString:(NSString*) string
{
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] init];
    
    if(string == nil)
        return [attributedText autorelease];
    
    //获取表情
    [self faceRangeFromStr:string withAttributedText:attributedText];
    
    
    CTFontRef font = CTFontCreateWithName((CFStringRef)self.font.fontName, self.font.pointSize, NULL);
    [attributedText addAttribute:(NSString*)kCTFontAttributeName value:(id)font  range:NSMakeRange(0, attributedText.length)];
    [attributedText addAttribute:(NSString*)kCTKernAttributeName value:[NSNumber numberWithFloat:self.wordInset] range:NSMakeRange(0, attributedText.length)];
    [attributedText addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)self.textColor.CGColor range:NSMakeRange(0, attributedText.length)];
    CFRelease(font);
    
    //  NSLog(@"%@",attributedText.string);
    
    if(self.recognizeURL)
    {
        //获取url
        [self getUrlsFromString:attributedText.string];
        //设置url样式
        for(NSTextCheckingResult *result in self.urlArray)
        {
            //NSString *str = [content substringWithRange:result.range];
            [attributedText addAttributes:self.urlAttributes range:result.range];
        }
    }
    
    for(JBoOpenPlatformTextStyleInfo *info in self.attributes)
    {
        NSDictionary *attributes = [info attributesWithContentLength:attributedText.length isCoreText:YES];
        if(attributes)
        {
            [attributedText addAttributes:attributes range:info.textRange];
        }
    }
    
    //要特别显示的字符
    for(NSInteger i = 0;i < self.specialColorArray.count && i < self.specialTextArray.count; i ++)
    {
        NSString *specialText = [self.specialTextArray objectAtIndex:i];
        UIColor *specialColor = [self.specialColorArray objectAtIndex:i];
        
        if(specialText.length < string.length)
        {
            [attributedText addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)specialColor.CGColor range:[string rangeOfString:specialText]];
        }
    }
    
    
    //断落样式
    //换行模式
    CTParagraphStyleSetting lineBreadMode;
    CTLineBreakMode linkBreak = kCTLineBreakByCharWrapping;
    lineBreadMode.spec = kCTParagraphStyleSpecifierLineBreakMode;
    lineBreadMode.value = &linkBreak;
    lineBreadMode.valueSize = sizeof(CTLineBreakMode);
    
    //    CTParagraphStyleSetting direction;
    //    CTWritingDirection writeDirection = kCTWritingDirectionLeftToRight;
    //
    //    direction.spec = kCTParagraphStyleSpecifierBaseWritingDirection;
    //    direction.value = &writeDirection;
    //    direction.valueSize = sizeof(CTWritingDirection);
    
    //行距
//    CTParagraphStyleSetting lineSpaceMode;
//    CGFloat lineSpace = self.lineSpace;
//    lineSpaceMode.spec = kCTParagraphStyleSpecifierLineSpacingAdjustment;
//    lineSpaceMode.value = &lineSpace;
//    lineSpaceMode.valueSize = sizeof(CGFloat);
    
    //换行方式
    CTTextAlignment textAlignment;
    switch (self.textAlignment)
    {
        case JBoTextAlignmentLeft:
            textAlignment = kCTTextAlignmentLeft;
            break;
        case JBoTextAlignmentCenter :
            textAlignment = kCTTextAlignmentCenter;
            break;
        case JBoTextAlignmentJustified :
            textAlignment = kCTTextAlignmentJustified;
            break;
        case JBoTextAlignmentNatural :
            textAlignment = kCTTextAlignmentNatural;
            break;
        case JBoTextAlignmentRight :
            textAlignment = kCTTextAlignmentRight;
            break;
    }
    
    CTParagraphStyleSetting alignment;
    alignment.spec = kCTParagraphStyleSpecifierAlignment;
    alignment.valueSize = sizeof(textAlignment);
    alignment.value = &textAlignment;
    
    //最小行高度
    CTParagraphStyleSetting minLineHeightMode;
    CGFloat minLineHeight = self.minLineHeight;
    minLineHeightMode.spec = kCTParagraphStyleSpecifierMinimumLineHeight;
    minLineHeightMode.value = &minLineHeight;
    minLineHeightMode.valueSize = sizeof(CGFloat);
    
    CTParagraphStyleSetting setting[] = {lineBreadMode, alignment, minLineHeightMode};
    
    CTParagraphStyleRef style = CTParagraphStyleCreate(setting, 2);
    [attributedText addAttribute:(NSString*)kCTParagraphStyleAttributeName value:(id)style range:NSMakeRange(0, attributedText.length)];
    CFRelease(style);
    
    return [attributedText autorelease];
}

- (CTFramesetterRef) framesetter
{
    @synchronized(self)
    {
        if(_framesetter)
            CFRelease(_framesetter);
        //NSLog(@"--%@",(CFAttributedStringRef) self.attributedText);
        _framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef) self.imageTextAttributedText);
    }
     
    return _framesetter;
}

- (void)setMinLineHeight:(CGFloat)minLineHeight
{
    _minLineHeight = minLineHeight;
}

- (void)getUrlsFromString:(NSString*) str
{
    if(str == nil || [str isEqual:[NSNull null]])
    {
        self.urlArray = [NSArray array];
        return;
    }
    
    NSArray *reuslts = [self.expression matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    //NSLog(@"%@",reuslts);
    self.urlArray = reuslts;
}

#pragma mark-tapGesture

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // NSLog(@"url tap");
    return [self urlAtPoint:[touch locationInView:self]] != nil;
}

- (void)handleTap:(UITapGestureRecognizer*) tap
{
   // NSLog(@"url tap");
    if(tap.state != UIGestureRecognizerStateEnded)
    {
        return;
    }
    
    NSTextCheckingResult *result = [self urlAtPoint:[tap locationInView:self]];
    
    //  NSLog(@"%@",result);
    if(!result || !self.delegate)
        return;
    
    if([self.delegate respondsToSelector:@selector(imageTextLabel:didSelectedURL:)])
    {
        [self.delegate imageTextLabel:self didSelectedURL:[NSURL URLWithString:[self.imageTextAttributedText.string substringWithRange:result.range]]];
    }
    
}

//获取点中的url
- (NSTextCheckingResult*)urlAtPoint:(CGPoint) point
{
    NSUInteger index = [self characterIndexAtPoint:point];
    //NSLog(@"index = %d",index);
    return [self urlAtCharacterIndex:index];
}

//判断是否点击到url
- (NSTextCheckingResult*)urlAtCharacterIndex:(NSInteger) index
{
    if(index == NSNotFound)
        return nil;
    for(NSTextCheckingResult *result in self.urlArray)
    {
        NSRange range = result.range;
        // NSLog(@"%@",result);
        if(range.location <= index && index <= (range.location + range.length - 1))
        {
            return result;
        }
    }
    return nil;
}

//计算点击在字体上的位置
- (NSUInteger)characterIndexAtPoint:(CGPoint) point
{
    //判断点击处是否在文本内
    if (!CGRectContainsPoint(self.bounds, point))
    {
        NSLog(@"CGRectContainsPoint");
        return NSNotFound;
    }
    
    CGRect textRect = self.bounds;
    
    if (!CGRectContainsPoint(textRect, point))
    {
        NSLog(@"limitedToNumberOfLines");
        return NSNotFound;
    }
    
    // Convert tap coordinates (start at top left) to CT coordinates (start at bottom left)
    point = CGPointMake(point.x, textRect.size.height - point.y);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, textRect);
    CTFrameRef frame = CTFramesetterCreateFrame(self.framesetter, CFRangeMake(0, [self.imageTextAttributedText length]), path, NULL);
    if (frame == NULL)
    {
        CFRelease(path);
        return NSNotFound;
    }
    
    CFArrayRef lines = CTFrameGetLines(frame);
    NSUInteger numberOfLines = CFArrayGetCount(lines);
    if (numberOfLines == 0)
    {
        CFRelease(frame);
        CFRelease(path);
        return NSNotFound;
    }
    
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), lineOrigins);
    
    NSUInteger lineIndex;
    for (lineIndex = 0; lineIndex < (numberOfLines - 1); lineIndex++)
    {
        CGPoint lineOrigin = lineOrigins[lineIndex];
        if (lineOrigin.y < point.y) {
            break;
        }
    }
    
    if (lineIndex >= numberOfLines)
    {
        CFRelease(frame);
        CFRelease(path);
        return NSNotFound;
    }
    
    CGPoint lineOrigin = lineOrigins[lineIndex];
    CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
    // Convert CT coordinates to line-relative coordinates
    CGPoint relativePoint = CGPointMake(point.x - lineOrigin.x, point.y - lineOrigin.y);
    CFIndex idx = CTLineGetStringIndexForPosition(line, relativePoint);
    
    // We should check if we are outside the string range
    CFIndex glyphCount = CTLineGetGlyphCount(line);
    CFRange stringRange = CTLineGetStringRange(line);
    CFIndex stringRelativeStart = stringRange.location;
    if ((idx - stringRelativeStart) == glyphCount)
    {
        CFRelease(frame);
        CFRelease(path);
        return NSNotFound;
    }
    
    CFRelease(frame);
    CFRelease(path);
    
    return idx;
}


#pragma mark-图片筛选

//筛选表情

- (void)faceRangeFromStr:(NSString*) str withAttributedText:(NSMutableAttributedString*) attributedText
{
    if(str == nil || [str isEqual:[NSNull null]])
        return;
    
    NSRange prefixRange = [str rangeOfString:facePrefix];
    NSRange suffixRange = [str rangeOfString:faceSuffix];
    
    if(prefixRange.location != NSNotFound && suffixRange.location != NSNotFound && suffixRange.location > prefixRange.location)
    {
       // NSLog(@"表情");
        NSString *forwordStr = [str substringToIndex:prefixRange.location];
       // NSLog(@"forwordStr = %@",forwordStr);
        if(forwordStr.length > 0)
        {
            NSAttributedString *text = [[NSAttributedString alloc] initWithString:forwordStr];
            [attributedText appendAttributedString:text];
            [text release];
        }
        
       // NSLog(@"%@",attributedText.string);
        //获取表情名称
        NSRange faceRange = NSMakeRange(prefixRange.location, suffixRange.location - prefixRange.location + suffixRange.length);
        NSString *faceName = [str substringWithRange:faceRange];
      //  NSLog(@"faceName = %@",faceName);
        
        // 通过faceName 获取表情图片名称
        NSString *imageName = [self getImageNameFromStr:faceName];
        
      //  NSLog(@"imageName = %@",imageName);
        //设定图片绘制代理
        CTRunDelegateCallbacks imageCallBack;
        imageCallBack.version = kCTRunDelegateVersion1;
        imageCallBack.dealloc = RunDelegateDeallocCallback;
        imageCallBack.getAscent = RunDelegateGetAscentCallback;
        imageCallBack.getDescent = RunDelegateGetDescentCallback;
        imageCallBack.getWidth = RunDelegateGetWidthCallback;
        
        CTRunDelegateRef runDelegate = CTRunDelegateCreate(&imageCallBack, imageName);
        
        if(runDelegate != NULL)
        {
            //设定图片属性
            NSMutableAttributedString *image = [[NSMutableAttributedString alloc] initWithString:faceSpace];
            [image addAttribute:(NSString*)kCTRunDelegateAttributeName value:(id)runDelegate range:NSMakeRange(0, faceSpace.length)];
            [image addAttribute:faceImageName value:imageName range:NSMakeRange(0, faceSpace.length)];
            
            [attributedText appendAttributedString:image];
            [image release];
            
            CFRelease(runDelegate);
        }
        
        NSString *backStr = [str substringFromIndex:suffixRange.location + suffixRange.length];
       // NSLog(@"%@",attributedText.string);
        if(backStr.length > 0)
        {
            [self faceRangeFromStr:backStr withAttributedText:attributedText];
        }
    }
    else
    {
       // NSLog(@"结束");
        NSAttributedString *text = [[NSAttributedString alloc] initWithString:str];
        [attributedText appendAttributedString:text];
        [text release];
    }
}

//获取图片名称
- (NSString*)getImageNameFromStr:(NSString*) str
{
    NSString *imageName = [str stringByReplacingOccurrencesOfString:facePrefix withString:@""];
    imageName = [imageName stringByReplacingOccurrencesOfString:faceSuffix withString:@""];
    return imageName;
}

@end
