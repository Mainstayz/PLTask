//
//  main.m
//  PLTask
//
//  Created by pillar on 2020/4/8.
//  Copyright © 2020 pillar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLTask.h"
void test1() {
    PLTask *task = [PLTask new];
    task.command = @"ls";
    task.currentDirectoryPath = @"/Users";
    NSLog(@"%@",task.currentDirectoryPath);
    NSLog(@"%@",task.environment);
    NSString *output;
    NSString *error;
    if ([task waitUntilExit:NULL error:&error]) {
        NSLog(@"%@",output);
    } else {
        NSLog(@"%@",error);
    }
}


void test2() {
    PLTask *task = [PLTask new];
    task.command = @"ping www.baidu.com";
    task.outputHandler = ^(NSString * _Nonnull txt) {
        NSLog(@"1 %@",txt);
    };
    task.errortHandler = ^(NSString * _Nonnull txt) {
        NSLog(@"2 %@",txt);
    };
    task.completionHandler = ^(PLTask * this) {
        NSLog(@"3 %@",this);
    };
    [task launch];
    
    sleep(3);
    
    [task interrupt];
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSURL *url = [NSURL fileURLWithPath:@"/User"];
        NSLog(@"%@",url);
        NSLog(@"%@",[url path]);
        
    }
    return 0;
}
