//
//  ViewController.m
//  TestPro
//
//  Created by Zong on 15/12/14.
//  Copyright © 2015年 Zong. All rights reserved.
//

#import "ViewController.h"
#import "ZGPerson.h"
#import "ZGEmotionFlowLayout.h"
#import "ZGCoreTextView.h"
#import "ZGDetailView.h"
#import "ZGTimerView.h"


static NSString *textCellID = @"textCell";


@interface ViewController () <UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic,weak) UITextView *tv;

@property (nonatomic,weak) ZGDetailView *detailView;

@property (nonatomic,weak) ZGTimerView *timerView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    
    ZGTimerView *timerView = [[ZGTimerView alloc] init];
    self.timerView = timerView;
    timerView.frame = self.view.bounds;
    timerView.backgroundColor  = [UIColor yellowColor];
    [self.view addSubview:timerView];
    
    
}

- (void)textTableView
{
    ZGDetailView *detailView = [[ZGDetailView alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 100)];
    self.detailView = detailView;
    detailView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:detailView];
}

- (void)subStringAtIndex
{
    NSString *str = @"abcde[fghijklmn";
    NSRange range = [str rangeOfString:@"["];
    NSString *forwardStr = [str substringToIndex:range.location];
    NSString *backStr = [str substringFromIndex:range.location];
    NSLog(@"forward %@,backStr %@",forwardStr,backStr);

}
- (void)textViewTest
{
    UITextView *tv = [[UITextView alloc] init];
    self.tv = tv;
    tv.backgroundColor = [UIColor redColor];
    tv.frame = CGRectMake(0, 50, 200, 300);
    [self.view addSubview:tv];
}


//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
////    self.tv.text = @"测试k";
////    self.tv.attributedText = [[NSAttributedString alloc] initWithString:@"测试"];
////    
////
////    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////        
////        NSLog(@"dispatch_after");
////    });
////    
////
////    NSLog(@"self.tv.attributedText %@",self.tv.attributedText);
//    
//    
//    ZGCoreTextView *coreTextView = [[ZGCoreTextView alloc] init];
//    coreTextView.frame = CGRectMake(0, 50, 100, 50);
//    coreTextView.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:coreTextView];
//
//}


- (void)collectionViewDidSelectTest
{
    ZGEmotionFlowLayout *flowLayout = [[ZGEmotionFlowLayout alloc] init];
    UICollectionView *collectionView =  [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor whiteColor];
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:textCellID];
    
    [self.view addSubview:collectionView];
}

#pragma mark - <UICollectionViewDataSource,UICollectionViewDelegate>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 21;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{

    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:textCellID forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255) / 255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1.0f];
    return cell;
}
//
//- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"indexPath.section %zd,indexPath.item %zd",indexPath.section,indexPath.item);
//}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
     NSLog(@"indexPath.section %zd,indexPath.item %zd",indexPath.section,indexPath.item);
}

- (void)sortAryTest
{
    ZGPerson *p1 = [ZGPerson personWithName:@"aa" age:56];
    ZGPerson *p2 = [ZGPerson personWithName:@"bb" age:34];
    ZGPerson *p3 = [ZGPerson personWithName:@"cc" age:18];
    ZGPerson *p4 = [ZGPerson personWithName:@"dd" age:24];
    ZGPerson *p5 = [ZGPerson personWithName:@"aa" age:16];
    
    NSArray *ary = @[p1,p2,p3,p4,p5];
    
    NSArray *sortAry = [ary sortedArrayUsingComparator:^NSComparisonResult(ZGPerson *p1, ZGPerson *p2) {
        return p1.age < p2.age;
    }];
    
    for (ZGPerson *p in sortAry) {
        NSLog(@"p.age %zd",p.age);
    }
}


- (void)filterAryTest
{
    ZGPerson *p1 = [ZGPerson personWithName:@"aa" age:56];
    ZGPerson *p2 = [ZGPerson personWithName:@"bb" age:34];
    ZGPerson *p3 = [ZGPerson personWithName:@"cc" age:18];
    ZGPerson *p4 = [ZGPerson personWithName:@"dd" age:24];
    ZGPerson *p5 = [ZGPerson personWithName:@"aa" age:16];
    
    NSArray *ary = @[p1,p2,p3,p4,p5];
    
    NSArray *filterAry = [ary filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",@"aa"]];
    
    NSLog(@"filterAry %@",filterAry);
    
    for (ZGPerson *p in filterAry) {
        NSLog(@"p.age %zd",p.age);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
