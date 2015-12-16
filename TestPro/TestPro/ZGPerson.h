//
//  ZGPerson.h
//  TestPro
//
//  Created by Zong on 15/12/14.
//  Copyright © 2015年 Zong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZGPerson : NSObject

@property (nonatomic,copy) NSString *name;

@property (nonatomic,assign) NSInteger age;

+ (instancetype)personWithName:(NSString *)name age:(NSInteger)age;
@end
