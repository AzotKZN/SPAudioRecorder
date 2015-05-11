//
//  SPRecordItem.h
//  AudioRecorder2
//
//  Created by Азат on 16.03.15.
//  Copyright (c) 2015 Azat Minvaliev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPRecordItem : NSObject
@property (nonatomic, strong) NSURL *recordURL;
@property (nonatomic, strong) NSMutableDictionary *recordAnnotation;
@property (nonatomic, strong) NSString *recordDate;
@property (nonatomic, strong) NSString *recordTime;

- (id)initWithName:(NSDictionary*)recordURL;

@end
