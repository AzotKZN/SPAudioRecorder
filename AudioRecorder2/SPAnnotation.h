//
//  SPAnnotation.h
//  AudioRecorder2
//
//  Created by Азат on 24.03.15.
//  Copyright (c) 2015 Azat Minvaliev. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SPAudioRecorderVC.h"
@interface SPAnnotation : NSObject <UITableViewDataSource>
- (NSInteger) getItemTotalCount;
- (id) getItemIndexPath:(NSInteger *)indexPathRow;
@end
