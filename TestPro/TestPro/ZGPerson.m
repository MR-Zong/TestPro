//
//  ZGPerson.m
//  TestPro
//
//  Created by Zong on 15/12/14.
//  Copyright © 2015年 Zong. All rights reserved.
//

#import "ZGPerson.h"

@implementation ZGPerson

+ (instancetype)personWithName:(NSString *)name age:(NSInteger)age
{
    ZGPerson *person = [[ZGPerson alloc] init];
    person.name = name;
    person.age = age;
    return person;
}
@end
