//
//  SPAudioRcPlayer.m
//  AudioRecorder2
//
//  Created by Азат on 19.03.15.
//  Copyright (c) 2015 Azat Minvaliev. All rights reserved.
//

#import "SPAudioRcPlayer.h"
#import "SAAudioRecorderVC.h"
#import "SPAnnotationCell.h"
#import <QuartzCore/QuartzCore.h>
@interface SPAudioRcPlayer (){
    AVAudioPlayer *player;
}

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic,strong) EZAudioFile *audioFile;

@property (nonatomic,strong) UISlider *navigationSlider;

@end


@implementation SPAudioRcPlayer
@synthesize audioPlot = _audioPlot;
@synthesize annotationTableView = _annotationTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Waveform color
    self.audioPlot.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    self.audioPlot.opaque = NO;

    self.audioPlot.plotType        = EZPlotTypeBuffer;
    // Fill
    self.audioPlot.shouldFill      = YES;
    // Mirror
    self.audioPlot.shouldMirror    = YES;
    
    self.audioPlot.color           = [UIColor colorWithRed:0 green:0 blue:0.604 alpha:1];
    self.audioPlot.gain = 4.0;
    //V2
    self.audioPlotV2.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    self.audioPlotV2.opaque = NO;
    
    self.audioPlotV2.plotType        = EZPlotTypeBuffer;
    // Fill
    self.audioPlotV2.shouldFill      = YES;
    // Mirror
    self.audioPlotV2.shouldMirror    = YES;
    
    self.audioPlotV2.color           = [UIColor colorWithRed:0.412 green:0.412 blue:0.412 alpha:1] /*#696969*/;
    self.audioPlotV2.gain = 4.0;
    //NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"mp3"];
    //NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    //_currentRecord.recordURL = soundFileURL;
    self.audioFile = [EZAudioFile audioFileWithURL:_currentRecord.recordURL andDelegate:self];
    
    [self createWave];
    
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:_currentRecord.recordURL error:nil];

    player.delegate = self;

    NSTimeInterval currentTime =player.duration;

    NSInteger minutes = floor(currentTime/60);
    NSInteger seconds = trunc(currentTime - minutes * 60);
    _recordDuration.text = [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];
    
    _annotationDict = _currentRecord.recordAnnotation;
    _graphAnnotationDict = [[NSMutableDictionary alloc] init];
    [_annotationTableView reloadData];
    
    _recordDate.text = _currentRecord.recordDate;
    _recordTime.text = _currentRecord.recordTime;
    
    self.annotationTableView.backgroundColor = [UIColor clearColor];
    annotationTableView.allowsSelection = NO;
    [self.annotationTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 2.0; //seconds
    lpgr.delegate = self;
    [self.annotationTableView addGestureRecognizer:lpgr];
    
    _sliderCurrentTime.userInteractionEnabled = YES;
    
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc]
                                        initWithTarget:self
                                        action:@selector(labelDragged:)];
    [_sliderCurrentTime addGestureRecognizer:gesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Slider setting
-(void)setupAppearance {
    
    UIImage *minImage = [UIImage imageWithContentsOfFile:_currentRecord.backImage];
    UIImage *maxImage = [UIImage imageWithContentsOfFile:_currentRecord.frontImage];

    UIImage *thumbImage = [[UIImage imageNamed:@"sliderPicker.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [[UISlider appearance] setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [[UISlider appearance] setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateNormal];
    
    float frameWidth = self.view.frame.size.width - 70;
    
    _navigationSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 141, frameWidth, 40)];
    _navigationSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [_navigationSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    //[_navigationSlider addSubview:_sliderCurrentTime];
    _navigationSlider.maximumValue = player.duration;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                  target:self
                                                selector:@selector(updateValueSliderAndTime)
                                                userInfo:nil
                                                 repeats:YES];
    

    [self.view addSubview:_navigationSlider];
    
    for (NSString* key in _annotationDict) {
        [self addGraphAnnotation:key];
    }
}

- (IBAction)playTapped:(id)sender {
    if (!player.playing) {
    NSURL *soundURL = _currentRecord.recordURL;
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:nil];
    player.delegate = self;
    UIImage *pauseBtnImg = [UIImage imageNamed:@"pauseButton.png"];
    [_playPauseButton setImage:pauseBtnImg forState:UIControlStateNormal];
    [player setCurrentTime:_navigationSlider.value];
    [player play];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                      target:self
                                                    selector:@selector(updateValueSliderAndTime)
                                                    userInfo:nil
                                                     repeats:YES];
    } else
    {
        UIImage *playBtnImg = [UIImage imageNamed:@"playButton.png"];
        [_playPauseButton setImage:playBtnImg forState:UIControlStateNormal];
        [player pause];
    }
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    UIImage *playBtnImg = [UIImage imageNamed:@"playButton.png"];
    [_playPauseButton setImage:playBtnImg forState:UIControlStateNormal];
}

- (void)updateValueSliderAndTime {
    NSTimeInterval currentTime =player.currentTime;
    
    NSInteger minutes = floor(currentTime/60);
    NSInteger seconds = trunc(currentTime - minutes * 60);
    _playTimer.text = [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];
    
    _navigationSlider.value = currentTime;

    float xLabelPosition = [self xPositionFromSliderValue:self.navigationSlider];
    float yLabelPosition = _sliderCurrentTime.center.y;
    _sliderCurrentTime.text = [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];;
    _sliderCurrentTime.center = CGPointMake(xLabelPosition+18, yLabelPosition);
}

- (IBAction)sliderChanged:(UISlider *)sender {
    // Fast skip the music when user scroll the UISlider
    if (player.playing){
    [player stop];
    [player setCurrentTime:_navigationSlider.value];
    [player prepareToPlay];
    [player play];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01f
                                                      target:self
                                                    selector:@selector(updateValueSliderAndTime)
                                                    userInfo:nil
                                                     repeats:YES];
    }
    else
    {
    [player stop];
    [player setCurrentTime:_navigationSlider.value];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01f
                                                      target:self
                                                    selector:@selector(updateValueSliderAndTime)
                                                    userInfo:nil
                                                     repeats:YES];
    }
}

- (float)xPositionFromSliderValue:(UISlider *)aSlider;
{
    float sliderRange = aSlider.frame.size.width - aSlider.currentThumbImage.size.width;
    float sliderOrigin = aSlider.frame.origin.x + (aSlider.currentThumbImage.size.width / 2.0);
    
    float sliderValueToPixels = (((aSlider.value-aSlider.minimumValue)/(aSlider.maximumValue-aSlider.minimumValue)) * sliderRange) + sliderOrigin;
    
    return sliderValueToPixels;
}

- (void)addGraphAnnotation:(NSString *)currentAnnotationTime {
    
    float fullTime = player.duration;
    float sliderWidth = self.view.frame.size.width - 70;
    NSArray *tempArray = [currentAnnotationTime componentsSeparatedByString:@":"];
    
    int annotationTime = [tempArray[0] integerValue] * 60 + [tempArray[1] integerValue];
    
    float xValue = sliderWidth/fullTime*annotationTime;
    UIImageView *imageHolder = [[UIImageView alloc] initWithFrame:CGRectMake(xValue, 17, 6, 6)];
    UIImage *image = [UIImage imageNamed:@"cellPoint.png"];
    imageHolder.image = image;
    
    [imageHolder setTag:([tempArray[0] integerValue] + [tempArray[1] integerValue])];
    
    [self.navigationSlider addSubview:imageHolder];
    [self.navigationSlider setNeedsDisplay];
    
}

#pragma mark - Add annotation
- (IBAction)addAnnotation:(id)sender {
   // [self generateArrayAnnotation];

    NSTimeInterval currentTime = player.currentTime;
    
    NSInteger minutes = floor(currentTime/60);
    NSInteger seconds = trunc(currentTime - minutes * 60);
    NSString *time = [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];
    if ([_annotationDict objectForKey:time] == nil) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Добавление аннотации"
                                                         message: time
                                                        delegate:self
                                               cancelButtonTitle:@"Отмена"
                                               otherButtonTitles:@"Сохранить!", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
    } else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Аннотация на данном участке существует"
                                                         message: time
                                                        delegate:self
                                               cancelButtonTitle:@"Нет"
                                               otherButtonTitles:@"Изменить!", nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Сохранить!"])
    {
        NSString *annotationText = [alertView textFieldAtIndex:0].text;
        annotationText = [annotationText stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceCharacterSet]];
        NSString *annotationTime = [alertView message];
        if (![annotationText isEqual: @""]) {
            [self.annotationDict setObject:annotationText forKey:annotationTime];
            [_annotationTableView reloadData];
        }
    } else {
        if([title isEqualToString:@"Изменить!"]) {
            NSString *time = [alertView message];
            NSString *text = [_annotationDict objectForKey:time];
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Изменение аннотации"
                                                             message:[NSString stringWithFormat:@"%@", time]
                                                            delegate:self
                                                   cancelButtonTitle:@"Отмена"
                                                   otherButtonTitles:@"Сохранить!", nil];
            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            UITextField* textField = [alert textFieldAtIndex:0];
            textField.text = text;
            [alert show];
        }
    }
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *dictonarySortAllKeys =  [[_annotationDict allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_annotationDict removeObjectForKey:dictonarySortAllKeys[indexPath.row]];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
        
        NSArray *tempArray = [dictonarySortAllKeys[indexPath.row] componentsSeparatedByString:@":"];
        
        UIView *removeView;
        while((removeView = [self.view viewWithTag:([tempArray[0] integerValue] + [tempArray[1] integerValue])]) != nil) {
            [removeView removeFromSuperview];
        }
        
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _annotationDict.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    //поиск ячейки
    SPAnnotationCell *cell = (SPAnnotationCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //если ячейка не найдена - создаем новую
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SPAnnotationCell"owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }

    NSArray *dictonarySortAllKeys =  [[_annotationDict allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    cell.currentAnnotationTime.text = dictonarySortAllKeys[indexPath.row];
    cell.currentAnnotationText.text = [_annotationDict objectForKey:dictonarySortAllKeys[indexPath.row]];
    
    [self addGraphAnnotation:dictonarySortAllKeys[indexPath.row]];

    
    cell.backgroundColor = [UIColor clearColor];
    
    //делим на мультистроки
    cell.currentAnnotationText.lineBreakMode = NSLineBreakByWordWrapping;
    cell.currentAnnotationText.numberOfLines = 0;
    
    cell.backgroundColor = [UIColor clearColor];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    NSString *cellText = [_annotationDict objectForKey:dictonarySortAllKeys[indexPath.row]];

    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Thin" size:17.0f]};
    CGRect rect = [cellText boundingRectWithSize:CGSizeMake(320, CGFLOAT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:attributes
                                         context:nil];
    
    UIImageView *aLine = [[UIImageView alloc] initWithFrame:CGRectMake(10, rect.size.height + 27, screenWidth, 3)];
    [aLine setImage:[UIImage imageNamed:@"dottedLine.png"]];
    [cell.contentView addSubview:aLine];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *dictonarySortAllKeys =  [[_annotationDict allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];

    NSString *currentAnnotationTime = dictonarySortAllKeys[indexPath.row];
    NSInteger *tempIntTime = [self timeConvertToSeconds:currentAnnotationTime];
    float currentAnnTime = [[NSNumber numberWithInt:tempIntTime] floatValue];
    
    [player stop];
    [player setCurrentTime:currentAnnTime];
    [player prepareToPlay];
    [player play];
    UIImage *pauseBtnImg = [UIImage imageNamed:@"pauseButton.png"];
    [_playPauseButton setImage:pauseBtnImg forState:UIControlStateNormal];
    _playTimer.text = dictonarySortAllKeys[indexPath.row];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                  target:self
                                                selector:@selector(updateValueSliderAndTime)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)labelDragged:(UIPanGestureRecognizer *)gesture
{
    UILabel *label = (UILabel *)gesture.view;
    CGPoint translation = [gesture translationInView:label];
    
    // move label
    //label.center = CGPointMake(label.center.x + translation.x,label.center.y);
    
    float fullTime = player.duration;
    float sliderWidth = self.view.frame.size.width - 70;
    
    float xValue = translation.x/(sliderWidth/fullTime);
    
    _navigationSlider.value = _navigationSlider.value+xValue;// + translation.x;
    label.center = CGPointMake(label.center.x + translation.x, label.center.y);
    // reset translation
    [gesture setTranslation:CGPointZero inView:label];
    NSLog(@"%f", label.center);
    player.currentTime = _navigationSlider.value;
    //[NSLog(@"%f", translation.x)];
}
- (IBAction)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        CGPoint p = [gestureRecognizer locationInView:self.annotationTableView];
        
        NSIndexPath *indexPath = [self.annotationTableView indexPathForRowAtPoint:p];
        if (indexPath == nil) {
            NSLog(@"Лонгтап вне строк");
        } else {
            UITableViewCell *cell = [self.annotationTableView cellForRowAtIndexPath:indexPath];
            if (cell.isHighlighted) {
                NSLog(@"Лонгтап в секции %ld строчке %ld", (long)indexPath.section, (long)indexPath.row);
                
                SPAnnotationCell *currentCell = (SPAnnotationCell *)cell;
                
                NSString *time = currentCell.currentAnnotationTime.text;
                NSString *text = currentCell.currentAnnotationText.text;
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Изменение аннотации"
                                                                 message:[NSString stringWithFormat:@"%@", time]
                                                                delegate:self
                                                       cancelButtonTitle:@"Отмена"
                                                       otherButtonTitles:@"Сохранить!", nil];
                [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                UITextField* textField = [alert textFieldAtIndex:0];
                textField.text = text;
                [alert show];
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *dictonarySortAllKeys =  [[_annotationDict allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];

    NSString *cellText = [_annotationDict objectForKey:dictonarySortAllKeys[indexPath.row]];
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Thin" size:17.0f]};
    CGRect rect = [cellText boundingRectWithSize:CGSizeMake(320, CGFLOAT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:attributes
                                         context:nil];
    
    return rect.size.height + 30;
}

- (NSInteger *)timeConvertToSeconds:(NSString *)currentAnnotationTime {
    NSArray *subStrings = [currentAnnotationTime componentsSeparatedByString:@":"];
    NSString *minutes = [subStrings objectAtIndex:0];
    NSString *seconds = [subStrings objectAtIndex:1];
    
    NSInteger *secondsOfStart = [minutes integerValue]*60 + [seconds integerValue];
    
    return secondsOfStart;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.isMovingFromParentViewController || self.isBeingDismissed) {
        [player pause];
        SAAudioRecorderVC *object = [[SAAudioRecorderVC alloc] init];
        NSMutableDictionary *itemData = [NSMutableDictionary new];
        [itemData setObject:_currentRecord.recordURL forKey:@"URL"];
        [itemData setObject:_annotationDict forKey:@"annotation"];
        SPRecordItem* data = [[SPRecordItem alloc] initWithName:itemData];
        NSMutableArray* itemArray = object.recordsItems;
        [itemArray replaceObjectAtIndex:_recordItemIndex withObject:data];
    }
}

//рисуем гистограмму
- (void) createWave {
    [self.audioFile getWaveformDataWithCompletionBlock:^(float *waveformData, UInt32 length) {
        self.audioPlot.plotType        = EZPlotTypeBuffer;
        self.audioPlotV2.plotType        = EZPlotTypeBuffer;

        [self.audioPlot updateBuffer:waveformData withBufferSize:length];
        [self.audioPlotV2 updateBuffer:waveformData withBufferSize:length];

        _notPlayingHistogram = [self imageWithView:_audioPlot];
        _playedHistogram = [self imageWithView:_audioPlotV2];

        [self setupAppearance];
    }];
}

//делаем скриншот определенной области
- (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}
@end
