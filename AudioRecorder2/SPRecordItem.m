//
//  SPRecordItem.m
//  AudioRecorder2
//
//  Created by Азат on 16.03.15.
//  Copyright (c) 2015 Azat Minvaliev. All rights reserved.
//

#import "SPRecordItem.h"

@implementation SPRecordItem
- (id)initWithName:(NSURL *)recordURL;
{
    self = [super init];
    
    if (self) {
        _recordURL = recordURL;
    }
    
    return self;
}

@end
