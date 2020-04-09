//
//  ViewController.m
//  Demo
//
//  Created by 何宗柱 on 2020/4/9.
//  Copyright © 2020 pillar. All rights reserved.
//

#import "ViewController.h"
#import "PLTask.h"
@interface ViewController ()
@property (strong) PLTask *cTask;
@property (unsafe_unretained) IBOutlet NSTextView *scriptTextView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}
- (IBAction)run:(id)sender {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        PLTask *task = [PLTask new];
        
        _cTask = task;
        
        task.command = _scriptTextView.string;
        task.outputHandler = ^(NSString * _Nonnull txt) {
            NSLog(@"outputHandler: %@",txt);
        };
        task.errortHandler  = ^(NSString * _Nonnull txt) {
            NSLog(@"errortHandler: %@",txt);
        };
        task.completionHandler = ^(PLTask * _Nonnull txt) {
            NSLog(@"completionHandler: %@",txt);
        };
        [task launchAndWaitUntilExit];

        NSLog(@"你好啊？？");
    });
    

    
}
- (IBAction)stop:(id)sender {
    NSLog(@"%d",[_cTask isRunning]);
    [_cTask interrupt];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
