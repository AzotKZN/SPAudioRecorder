//
//  SPAudioRcPlayer.h
//  AudioRecorder2
//
//  Created by Азат on 19.03.15.
//  Copyright (c) 2015 Azat Minvaliev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SPRecordItem.h"
#import "EZAudio.h"
#import "EZAudioPlotGL.h"

@class SPAudioRcPlayerVC;
@protocol SPAudioRcPlayerVCDelegate <NSObject>

- (void)spAudioRcPlayerVCDidFinish:(SPAudioRcPlayerVC *)spAudioRcPlayerVC;

@end
@interface SPAudioRcPlayer : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView *annotationTableView;
}
@property (strong, nonatomic) SPRecordItem *currentRecord;
@property (strong, nonatomic) NSURL *recordItemURL;

@property (nonatomic, strong) NSMutableDictionary *annotationDict;
@property (strong, nonatomic) IBOutlet UITableView *annotationTableView;
@property (assign, nonatomic) int *recordItemIndex;
@property (nonatomic, strong) NSMutableDictionary* graphAnnotationDict;

@property (strong, nonatomic) IBOutlet UIButton *playPauseButton;
@property (strong, nonatomic)  IBOutlet UILabel *playTimer;
@property (strong, nonatomic) IBOutlet UILabel *recordDuration;

@property (weak, nonatomic) IBOutlet UILabel *recordTime;
@property (weak, nonatomic) IBOutlet UILabel *recordDate;

@property (weak, nonatomic) id<SPAudioRcPlayerVCDelegate> delegate;

//@property (weak, nonatomic) IBOutlet EZAudioPlotGL *audioPlot;
//@property (weak, nonatomic) IBOutlet EZAudioPlotGL *audioPlotV2;

@property (weak, nonatomic) IBOutlet UILabel *sliderCurrentTime;

@property (nonatomic, strong) UIImage *notPlayingHistogram;
@property (nonatomic, strong) UIImage *playedHistogram;

- (void)addGraphAnnotation:(NSString *)currentAnnotationTime;
@property (strong, nonatomic) IBOutlet UIView *histogramView;

@end



