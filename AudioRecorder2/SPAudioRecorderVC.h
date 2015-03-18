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
@class MyViewController;
@protocol MyViewControllerDelegate <NSObject>

- (void)myViewControllerDidFinish:(MyViewController *)myViewController;

@end
@interface SPAudioRecorderVC : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *recordPauseButton;
@property (strong, nonatomic) IBOutlet UILabel *recordLengthLabel;
@property (strong, nonatomic) IBOutlet SAAudioRecorderVC *object;

@property (nonatomic, strong) NSURL *recordURL;
@property (strong, nonatomic) NSMutableArray *recordsItemsArray;
@property (weak, nonatomic) id<MyViewControllerDelegate> delegate;
@end

