//
//  SPAudioRcPlayer.m
//  AudioRecorder2
//
//  Created by Азат on 19.03.15.
//  Copyright (c) 2015 Azat Minvaliev. All rights reserved.
//

#import "SPAudioRcPlayer.h"

@interface SPAudioRcPlayer (){
    AVAudioPlayer *player;
}
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation SPAudioRcPlayer

- (void)viewDidLoad {
    [super viewDidLoad];

    NSURL *soundURL = _recordItemURL;
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:nil];

    NSTimeInterval currentTime =player.duration;

    NSInteger minutes = floor(currentTime/60);
    NSInteger seconds = trunc(currentTime - minutes * 60);
    _recordDuration.text = [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];
    _navigationSlider.maximumValue = player.duration;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playTapped:(id)sender {
    if (!player.playing) {
    NSURL *soundURL = _recordItemURL;
    NSLog(@"---%@",_recordItemURL);
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:nil];
    [player setDelegate:self];
    [_playPauseButton setTitle:@"ll" forState:UIControlStateNormal];
    [player play];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(updateTime)
                                                    userInfo:nil
                                                     repeats:YES];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                      target:self
                                                    selector:@selector(updateSlider)
                                                    userInfo:nil
                                                     repeats:YES];
    } else
    {
        [player pause];
        [_playPauseButton setTitle:@"►" forState:UIControlStateNormal];

    }
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"Finsh playing");
    [_playPauseButton setTitle:@"►" forState:UIControlStateNormal];
}

- (void)updateTime {
    NSTimeInterval currentTime =player.currentTime;
    
    NSInteger minutes = floor(currentTime/60);
    NSInteger seconds = trunc(currentTime - minutes * 60);
    _playTimer.text = [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];
}

- (void)updateSlider {
    _navigationSlider.value = player.currentTime;
}

@end
