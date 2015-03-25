//
//  SPAnnotation.m
//  AudioRecorder2
//
//  Created by Азат on 24.03.15.
//  Copyright (c) 2015 Azat Minvaliev. All rights reserved.
//

#import "SPAnnotation.h"

@implementation SPAnnotation


- (NSInteger) getItemTotalCount:(NSArray *)object {
    //SPAudioRecorderVC *object = [[SPAudioRecorderVC alloc] init];
    //NSLog(@"%lu", (unsigned long)object.annotationArray.count);
    return 10;//object.annotationArray.count;
}

- (id) getItemIndexPath:(NSInteger *)indexPathRow {
    SPAudioRecorderVC *object = [[SPAudioRecorderVC alloc] init];
   // id *jkcjwjwef = object.annotationArray[indexPathRow];
    return nil;
}

@end