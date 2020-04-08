//
//  PLTask.h
//  PLTask
//
//  Created by pillar on 2020/4/8.
//  Copyright © 2020 pillar. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLTask : NSObject
@property (readonly) NSTask *task;
@property NSStringEncoding encoding;
@property (nonatomic, copy) void (^outputHandler)(NSString *txt);
@property (nonatomic, copy) void (^errortHandler)(NSString *txt);
@property (copy) void (^completionHandler)(PLTask *task);
@property (nonatomic ,copy) NSString *command;
- (instancetype)init;
- (void)launch;
- (void)write:(NSString *)input;
- (void)writeAndCloseInput:(NSString *)input;
- (BOOL)waitUntilExit:(NSString **)output error:(NSString **)error;
@end

@interface PLTask (ForwardedToNSTask)
@property NSString *currentDirectoryPath;
@property NSDictionary *environment;
@property (readonly) int processIdentifier;
@property (readonly) int terminationStatus;
@property (readonly) NSTaskTerminationReason terminationReason;
@property (readonly) BOOL isRunning;
@property id standardInput;
- (void)interrupt; // Not always possible. Sends SIGINT.
- (void)terminate; // Not always possible. Sends SIGTERM.
@end

NS_ASSUME_NONNULL_END
