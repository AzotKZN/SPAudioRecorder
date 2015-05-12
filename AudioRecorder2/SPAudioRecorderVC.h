//
//  SPAudioRecorderVC.h
//  AudioRecorder2
//
//  Created by Азат on 15.03.15.
//  Copyright (c) 2015 Azat Minvaliev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SAAudioRecorderVC.h"
#import "EZAudio.h"
@class AudioRecorderVC;
@protocol AudioRecorderVCDelegate <NSObject>

- (void)audioRecorderVCDidFinish:(SPRecordItem *)data;

@end
@interface SPAudioRecorderVC : UIViewController <UITableViewDelegate, UITableViewDataSource, EZMicrophoneDelegate>{
    
    IBOutlet UITableView *annotationTableView;
}
@property (strong, nonatomic) IBOutlet UIButton *recordButton;
@property (strong, nonatomic) IBOutlet UILabel *recordLengthLabel;
@property (strong, nonatomic) IBOutlet UILabel *recordLengthBottomLabel;
@property (strong, nonatomic) IBOutlet UILabel *recordStatus;
@property (strong, nonatomic) IBOutlet UILabel *currentDateLbl;
@property (strong, nonatomic) IBOutlet UILabel *currentTimeLbl;
@property (strong, nonatomic) IBOutlet UIButton *playPauseButton;


@property (nonatomic, strong) NSURL *recordURL;
@property (strong, nonatomic) NSMutableArray *recordsItemsArray;
@property (weak, nonatomic) id<AudioRecorderVCDelegate> delegate;

@property (strong, nonatomic) IBOutlet UITableView *annotationTableView;
@property (strong, nonatomic) IBOutlet UITextField *annotationTextField;
@property (strong, nonatomic) IBOutlet UIButton *addAnnotationButton;

@property (nonatomic, strong) NSMutableDictionary *annotationDict;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet EZAudioPlot *audioPlot;

@property (strong, nonatomic) IBOutlet UIButton *doneButton;

@property (nonatomic,strong) EZRecorder *recorder;
@property (nonatomic,strong) EZMicrophone *microphone;
@property (nonatomic,assign) BOOL isRecording;

@end

