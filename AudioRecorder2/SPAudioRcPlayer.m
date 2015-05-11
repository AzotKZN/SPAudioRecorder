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
    
    self.audioFile = [EZAudioFile audioFileWithURL:_currentRecord.recordURL
                                       andDelegate:self];
    [self createWave];
    
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:_currentRecord.recordURL error:nil];
    player.delegate = self;

    NSTimeInterval currentTime =player.duration;

    NSInteger minutes = floor(currentTime/60);
    NSInteger seconds = trunc(currentTime - minutes * 60);
    _recordDuration.text = [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];
    
    _annotationDict = _currentRecord.recordAnnotation;
    [_annotationTableView reloadData];
    
    _recordDate.text = _currentRecord.recordDate;
    _recordTime.text = _currentRecord.recordTime;
    
    self.annotationTableView.backgroundColor = [UIColor clearColor];
    annotationTableView.allowsSelection = NO;
    [self.annotationTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Slider seting
-(void)setupAppearance {
    UIImage *minImage = [_notPlayingHistogram resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImage *maxImage = [_playedHistogram resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImage *thumbImage = [UIImage imageNamed:@"sliderPicker.png"];
    
    [[UISlider appearance] setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [[UISlider appearance] setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateNormal];
    
    _navigationSlider = [[UISlider alloc] initWithFrame:CGRectMake(10, 135, 260, 40)];
    _navigationSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [_navigationSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    _navigationSlider.maximumValue = player.duration;
    [self.view addSubview:_navigationSlider];
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

- (void)updateTime {
    NSTimeInterval currentTime =player.currentTime;
    
    NSInteger minutes = floor(currentTime/60);
    NSInteger seconds = trunc(currentTime - minutes * 60);
    _playTimer.text = [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];
}

- (void)updateSlider {
    _navigationSlider.value = player.currentTime;
    float xLabelPosition = [self xPositionFromSliderValue:self.navigationSlider];
    float yLabelPosition = _sliderCurrentTime.center.y;
    _sliderCurrentTime.text = _playTimer.text;
    _sliderCurrentTime.center = CGPointMake(xLabelPosition+18, yLabelPosition);
    }

- (IBAction)sliderChanged:(UISlider *)sender {
    // Fast skip the music when user scroll the UISlider
    if (player.playing){
    [player stop];
    [player setCurrentTime:_navigationSlider.value];
    [player prepareToPlay];
    [player play];
    }
    else
    {
    [player stop];
    [player setCurrentTime:_navigationSlider.value];
    }
}

- (float)xPositionFromSliderValue:(UISlider *)aSlider;
{
    float sliderRange = aSlider.frame.size.width - aSlider.currentThumbImage.size.width;
    float sliderOrigin = aSlider.frame.origin.x + (aSlider.currentThumbImage.size.width / 2.0);
    
    float sliderValueToPixels = (((aSlider.value-aSlider.minimumValue)/(aSlider.maximumValue-aSlider.minimumValue)) * sliderRange) + sliderOrigin;
    
    return sliderValueToPixels;
}

#pragma mark - Add annotation
- (IBAction)addAnnotation:(id)sender {
    NSTimeInterval currentTime = player.currentTime;
    
    NSInteger minutes = floor(currentTime/60);
    NSInteger seconds = trunc(currentTime - minutes * 60);
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Добавление аннотации"
                                                     message:[NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds]
                                                    delegate:self
                                           cancelButtonTitle:@"Отмена"
                                           otherButtonTitles:@"Сохранить!", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Сохранить!"])
    {
        NSString *annotationText = [alertView textFieldAtIndex:0].text;
        NSString *annotationTime = [alertView message];
        [self.annotationDict setObject:annotationText forKey:annotationTime];

        [_annotationTableView reloadData];
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
    
    
    UIImageView *aLine = [[UIImageView alloc] initWithFrame:CGRectMake(10, rect.size.height + 30, screenWidth - 30, 3)];
    [aLine setImage:[UIImage imageNamed:@"dottedLine.png"]];
    [cell.contentView addSubview:aLine];

    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *dictonarySortAllKeys =  [[_annotationDict allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];

    NSString *currentAnnotationTime = dictonarySortAllKeys[indexPath.row];
    NSInteger *tempIntTime = [self timeConvertToSeconds:currentAnnotationTime];
    float currentAnnTime = [[NSNumber numberWithInt: tempIntTime] floatValue];
    
    [player stop];
    [player setCurrentTime:currentAnnTime];
    [player prepareToPlay];
    [player play];
    UIImage *pauseBtnImg = [UIImage imageNamed:@"pauseButton.png"];
    [_playPauseButton setImage:pauseBtnImg forState:UIControlStateNormal];
    _playTimer.text = dictonarySortAllKeys[indexPath.row];
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

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *dictonarySortAllKeys =  [[_annotationDict allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_annotationDict removeObjectForKey:dictonarySortAllKeys[indexPath.row]];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
    }
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
