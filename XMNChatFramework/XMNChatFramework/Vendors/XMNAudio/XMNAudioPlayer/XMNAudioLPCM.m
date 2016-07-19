//
//  XMNAudioLPCM.m
//  XMNAudioRecorderExample
//
//  Created by XMFraker on 16/6/29.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNAudioLPCM.h"

#include <libkern/OSAtomic.h>
typedef struct data_segment {
    void *bytes;
    NSUInteger length;
    struct data_segment *next;
} data_segment;

@interface XMNAudioLPCM () {
@private
    data_segment *_segments;
    BOOL _end;
    OSSpinLock _lock;
}
@end

@implementation XMNAudioLPCM
@synthesize end = _end;

#pragma mark - Life Cycle

- (instancetype)init {
    
    if (self = [super init]) {
        
        /** 保证线程安全 */
        _lock = OS_SPINLOCK_INIT;
    }
    return self;
}

- (void)dealloc {
    
    /** 是否所有内存 */
    while (_segments != NULL) {
        data_segment *next = _segments->next;
        free(_segments);
        _segments = next;
    }
}


#pragma mark - Methods

- (BOOL)readBytes:(void **)bytes length:(NSUInteger *)length {
    
    *bytes = NULL;
    *length = 0;
    
    OSSpinLockLock(&_lock);
    
    if (_end && _segments == NULL) {
        OSSpinLockUnlock(&_lock);
        return NO;
    }
    
    if (_segments != NULL) {
        *length = _segments->length;
        *bytes = malloc(*length);
        memcpy(*bytes, _segments->bytes, *length);
        
        data_segment *next = _segments->next;
        free(_segments);
        _segments = next;
    }
    
    OSSpinLockUnlock(&_lock);
    
    return YES;
}

- (void)writeBytes:(const void *)bytes length:(NSUInteger)length {
    
    OSSpinLockLock(&_lock);
    
    if (_end) {
        OSSpinLockUnlock(&_lock);
        return;
    }
    
    if (bytes == NULL || length == 0) {
        OSSpinLockUnlock(&_lock);
        return;
    }
    
    data_segment *segment = (data_segment *)malloc(sizeof(data_segment) + length);
    segment->bytes = segment + 1;
    segment->length = length;
    segment->next = NULL;
    memcpy(segment->bytes, bytes, length);
    
    data_segment **link = &_segments;
    while (*link != NULL) {
        data_segment *current = *link;
        link = &current->next;
    }
    
    *link = segment;
    
    OSSpinLockUnlock(&_lock);
}

#pragma mark - Setters

- (void)setEnd:(BOOL)end {
    
    /** 使用OSSpinLockLock 保证线程安全 */
    OSSpinLockLock(&_lock);
    if (end && !_end) {
        _end = YES;
    }
    OSSpinLockUnlock(&_lock);
}


@end
