//
//  ZGDetailView.m
//  TestPro
//
//  Created by Zong on 15/12/16.
//  Copyright © 2015年 Zong. All rights reserved.
//

#import "ZGDetailView.h"


@interface ZGDetailView ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,weak) UITableView *tableView;

@property (nonatomic,weak) UIButton *leftBtn;

@property (nonatomic,weak) UIButton *rightBtn;

@property (nonatomic,strong) NSArray *tableDatas;

@end



@implementation ZGDetailView


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self initView];
    }
    return self;
}


- (void)initView
{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.leftBtn = leftBtn;
    leftBtn.frame = CGRectMake(0, 0, width * 0.5, 40);
    [leftBtn setTitle:@"详情" forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(leftBtnClick) forControlEvents:UIControlEventTouchUpInside];
    leftBtn.backgroundColor = [UIColor redColor];
    [self addSubview:leftBtn];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rightBtn = rightBtn;
    rightBtn.frame = CGRectMake(CGRectGetMaxX(self.leftBtn.frame), 0, width * 0.5, 40);
    [rightBtn setTitle:@"资讯" forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.backgroundColor = [UIColor blackColor];
    [self addSubview:rightBtn];
    
    
    CGFloat tableViewY = CGRectGetMaxY(self.leftBtn.frame);
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, tableViewY, width , height - tableViewY) style:UITableViewStylePlain];
    self.tableView = tableView;
    tableView.backgroundColor = [UIColor greenColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self addSubview:tableView];
    
    // 默认选择
    [self leftBtnClick];
}

#pragma mark - buttons Click
- (void)leftBtnClick
{
    self.tableDatas = @[@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m"];
    [self.tableView reloadData];
    NSLog(@"leftBtnClick");
    
}

- (void)rightBtnClick
{
    self.tableDatas = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M"];
    [self.tableView reloadData];
    NSLog(@"rightBtnClick");
}

#pragma mark - <UITableViewDataSource,UITableViewDelegate>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *detailCellID = @"detailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:detailCellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:detailCellID];
    }
    
    NSString *detailText = self.tableDatas[indexPath.row];
    cell.textLabel.text = detailText;
    
    return cell;
}

@end
