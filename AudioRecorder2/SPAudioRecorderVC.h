//
//  SPAudioRecorderVC.h
//  AudioRecorder2
//
//  Created by Азат on 15.03.15.
//  Copyright (c) 2015 Azat Minvaliev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface SPAudioRecorderVC : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *recordPauseButton;
@property (strong, nonatomic) IBOutlet UILabel *recordLengthLabel;

@end

