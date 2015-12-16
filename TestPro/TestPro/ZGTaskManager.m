//
//  ZGTaskManager.m
//  TestPro
//
//  Created by Zong on 15/12/16.
//  Copyright © 2015年 Zong. All rights reserved.
//

#import "ZGTaskManager.h"


static ZGTaskManager *taskManager =nil;

@interface ZGTaskManager ()

@property (nonatomic,strong) NSMutableArray *tasks;

@property (nonatomic,strong) NSTimer *timer;

@end

@implementation ZGTaskManager

+ (instancetype)shareTaskManager
{
    if (!taskManager) {
        taskManager = [[self alloc] init];
    }
    return taskManager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{

    static dispatch_once_t onceToken;
    if (!taskManager) {
        dispatch_once(&onceToken, ^{
            taskManager = [[ZGTaskManager alloc] init];
        });
    }
    
    return taskManager;
}

- (void)addTaskWithBlock:(Task)task
{
    if (task == nil) return;
    
    [self.tasks addObject:task];
    
    [self timer];
}


- (void)onTimer
{
    if (self.tasks.count > 0) {
        
        for (Task task in self.tasks) {
            
            if (!task) {
                if (!task()) {
                    [self.tasks removeObject:task];
                }
            }
        } 
        
    }else {
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark -lazyLoad
- (NSMutableArray *)tasks
{
    if (!_tasks){
        _tasks = [NSMutableArray array];
    }
    return _tasks;
}

- (NSTimer *)timer
{
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

@end
