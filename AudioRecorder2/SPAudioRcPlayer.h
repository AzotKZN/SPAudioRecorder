//
//  SPAudioRcPlayer.h
//  AudioRecorder2
//
//  Created by Азат on 19.03.15.
//  Copyright (c) 2015 Azat Minvaliev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@class SPAudioRcPlayerVC;
@protocol SPAudioRcPlayerVCDelegate <NSObject>

- (void)spAudioRcPlayerVCDidFinish:(SPAudioRcPlayerVC *)spAudioRcPlayerVC;

@end
@interface SPAudioRcPlayer : UIViewController

@property (strong, nonatomic) NSURL *recordItemURL;
@property (strong, nonatomic) IBOutlet UIButton *playPauseButton;
@property (strong, nonatomic) IBOutlet UILabel *playTimer;
@property (strong, nonatomic) IBOutlet UILabel *recordDuration;
@property (strong, nonatomic) IBOutlet UISlider *navigationSlider;

@property (weak, nonatomic) id<SPAudioRcPlayerVCDelegate> delegate;
@end



