//
//  SAAudioRecorderVC.h
//  AudioRecorder2
//
//  Created by Азат on 14.03.15.
//  Copyright (c) 2015 Azat Minvaliev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPRecordItem.h"

@class SAAudioRecorderVC;

@protocol SAAudioRecorderVCDelegate <NSObject>

- (void)SAAudioRecorderVCDidFinish:(SAAudioRecorderVC *)saAudioRecorderVC;

@end

@interface SAAudioRecorderVC : UIViewController <UITableViewDelegate, UITableViewDataSource> {
IBOutlet UITableView *tblRecord;
}
@property (nonatomic, retain) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *recordsItems;

@property (weak, nonatomic) id<SAAudioRecorderVCDelegate> delegate;
- (void) addObject:(SPRecordItem*) object;
@end
