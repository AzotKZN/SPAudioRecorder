//
//  AppDelegate.h
//  AudioRecorder2
//
//  Created by Азат on 14.03.15.
//  Copyright (c) 2015 Azat Minvaliev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAAudioRecorderVC.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SAAudioRecorderVC *initialVC;
@property (strong, nonatomic) UINavigationController *navigationController;

@end

