//
//  SPRecordItem.m
//  AudioRecorder2
//
//  Created by Азат on 16.03.15.
//  Copyright (c) 2015 Azat Minvaliev. All rights reserved.
//

#import "SPRecordItem.h"

@implementation SPRecordItem
- (id)initWithName:(NSDictionary*)item;
{
    self = [super init];
    
    if (self) {
        self.recordURL = [item objectForKey:@"URL"];
        self.recordAnnotation = [item objectForKey:@"annotation"];
        self.recordDate = [item objectForKey:@"recordDate"];
        self.recordTime = [item objectForKey:@"recordTime"];

    }
    
    return self;
}

@end
