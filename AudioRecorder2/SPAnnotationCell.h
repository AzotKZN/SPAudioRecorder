//
//  AnnotationCell.h
//  AudioRecorder2
//
//  Created by Азат on 31.03.15.
//  Copyright (c) 2015 Azat Minvaliev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPAnnotationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *currentAnnotationTime;
@property (weak, nonatomic) IBOutlet UILabel *currentAnnotationText;

@end
