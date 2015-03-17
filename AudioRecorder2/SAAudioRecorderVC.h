//
//  SAAudioRecorderVC.h
//  AudioRecorder2
//
//  Created by Азат on 14.03.15.
//  Copyright (c) 2015 Azat Minvaliev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPRecordItem.h"
@interface SAAudioRecorderVC : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *recordsItems;

- (void) addObject:(SPRecordItem*) object;
@end
