//
//  PLTask.m
//  PLTask
//
//  Created by pillar on 2020/4/8.
//  Copyright © 2020 pillar. All rights reserved.
//

#import "PLTask.h"

@implementation PLTask
- (instancetype)init {
    self = [super init];
    if (self) {
        _task = [[NSTask alloc] init];
        _encoding = NSUTF8StringEncoding;
        _task.launchPath = [NSProcessInfo processInfo].environment[@"SHELL"];
    }
    return self;
}

- (void)setCommand:(NSString *)command {
    _command = [command copy];
    _task.arguments = @[@"-l",@"-c",command];
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector]) {
        return [super forwardingTargetForSelector:aSelector];
    } else {
        return _task;
    }
}

#pragma mark helper methods

+ (void)stopFileHandle:(id)standardoutputorerror {
    if (standardoutputorerror && [standardoutputorerror isKindOfClass:[NSPipe class]]) {
        [standardoutputorerror fileHandleForReading].readabilityHandler = nil;
    }
}
#pragma mark properties

// http://stackoverflow.com/a/16274586
- (void)setOutputHandler:(void (^)(NSString *))outputHandler
{
    [PLTask stopFileHandle:_task.standardOutput];
    _outputHandler = outputHandler;
    _task.standardOutput = [NSPipe pipe];
    __weak typeof(self)wSelf = self;
    [_task.standardOutput fileHandleForReading].readabilityHandler = ^(NSFileHandle *file)
    {
        NSData *data = [file availableData]; // this will read to EOF, so call only once
        NSString *output = [[NSString alloc] initWithData:data encoding:wSelf.encoding];
        wSelf.outputHandler(output);
    };
}

// http://stackoverflow.com/a/16274586
- (void)setErrorHandler:(void (^)(NSString *))errorHandler
{
    [PLTask stopFileHandle:_task.standardError];
    _errortHandler = errorHandler;
    _task.standardError = [NSPipe pipe];
    __weak typeof(self)wSelf = self;
    [_task.standardError fileHandleForReading].readabilityHandler = ^(NSFileHandle *file)
    {
        NSData *data = [file availableData]; // this will read to EOF, so call only once
        NSString *output = [[NSString alloc] initWithData:data encoding:wSelf.encoding];
        wSelf.errortHandler(output);
    };
}

- (void)write:(NSString *)input
{
    if (!_task.standardInput || ![_task.standardInput isKindOfClass:[NSPipe class]]) {
        _task.standardInput = [NSPipe pipe];
    }
    NSData *data = [input dataUsingEncoding:_encoding];
    [[_task.standardInput fileHandleForWriting] writeData:data];
}

- (void)writeAndCloseInput:(NSString *)input
{
    [self write:input];
    [[_task.standardInput fileHandleForWriting] closeFile];
}

- (int)waitUntilExit:(NSString **)output error:(NSString **)error
{
    [PLTask stopFileHandle:_task.standardOutput];
    NSPipe *outputPipe = [NSPipe pipe];
    _task.standardOutput = outputPipe;
    if (!_task.standardError) {
        _task.standardError = outputPipe;
    }
    if ([_task.standardInput isKindOfClass:[NSPipe class]]) {
        [[_task.standardInput fileHandleForWriting] closeFile];
    }
    
    if (!_task.isRunning) {
        @try {
            [_task launch];
        } @catch (NSException *exception) {
            if (error) {
                *error = exception.reason;
            }
            return [_task terminationStatus];
        }
    }
    [_task waitUntilExit];
    NSFileHandle *read = [outputPipe fileHandleForReading];
    NSData *dataRead = [read readDataToEndOfFile];
    NSString *stringRead = [[NSString alloc] initWithData:dataRead encoding:self.encoding];
    if (output) {
        *output = stringRead;
    }
    return [_task terminationStatus];
}
- (void)launch
{
    if (!_task.standardError) {
        _task.standardError = _task.standardOutput;
    }
    __weak PLTask *weakself = self;
    [_task setTerminationHandler:^(NSTask *thistask) {
        
        [PLTask stopFileHandle:thistask.standardOutput];
        [PLTask stopFileHandle:thistask.standardError];
        
        if (weakself.completionHandler) {
            weakself.completionHandler(weakself);
        }
    }];
    [_task launch];
}

- (void)launchAndWaitUntilExit {
    [self launch];
    [_task waitUntilExit];
}

@end
