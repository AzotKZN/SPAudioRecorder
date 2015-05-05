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
@interface SPAudioRcPlayer (){
    AVAudioPlayer *player;
}

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic,strong) EZAudioFile *audioFile;

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
    self.audioFile = [EZAudioFile audioFileWithURL:_currentRecord.recordURL
                                       andDelegate:self];
    [self createWave];
    
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:_currentRecord.recordURL error:nil];
    player.delegate = self;

    NSTimeInterval currentTime =player.duration;

    NSInteger minutes = floor(currentTime/60);
    NSInteger seconds = trunc(currentTime - minutes * 60);
    _recordDuration.text = [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];
    _navigationSlider.maximumValue = player.duration;
    _annotationArray = _currentRecord.recordAnnotation;
    [_annotationTableView reloadData];
    
    _recordDate.text = _currentRecord.recordDate;
    _recordTime.text = _currentRecord.recordTime;
    
    [_navigationSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    self.annotationTableView.backgroundColor = [UIColor clearColor];
    [self.annotationTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        UIImage *playBtnImg = [UIImage imageNamed:@"playButton.png"];
        [_playPauseButton setImage:playBtnImg forState:UIControlStateNormal];
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
}

- (IBAction)sliderChanged:(UISlider *)sender {
    // Fast skip the music when user scroll the UISlider
    [player stop];
    [player setCurrentTime:_navigationSlider.value];
    NSLog(@"%f", _navigationSlider.value);
    [player prepareToPlay];
    [player play];
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
        [self.annotationArray addObject:@[annotationTime, annotationText]];
        
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
    return _annotationArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // NSArray *rowData = [_object getItemIndexPath:indexPath.row];
    
    static NSString *CellIdentifier = @"Cell";
    
    //поиск ячейки
    SPAnnotationCell *cell = (SPAnnotationCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //если ячейка не найдена - создаем новую
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SPAnnotationCell"owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.currentAnnotationTime.text = _annotationArray[indexPath.row][0];
    cell.currentAnnotationText.text = _annotationArray[indexPath.row][1];
    
    cell.backgroundColor = [UIColor clearColor];
    
    //делим на мультистроки
    cell.currentAnnotationText.lineBreakMode = NSLineBreakByWordWrapping;
    cell.currentAnnotationText.numberOfLines = 0;
    
    cell.backgroundColor = [UIColor clearColor];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    UIImageView *aLine = [[UIImageView alloc] initWithFrame:CGRectMake(10, cell.frame.size.height, screenWidth - 30, 3)];
    [aLine setImage:[UIImage imageNamed:@"dottedLine.png"]];
    [cell.contentView addSubview:aLine];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *currentAnnotationTime = _annotationArray[indexPath.row][0];
    NSInteger *tempIntTime = [self timeConvertToSeconds:currentAnnotationTime];
    float currentAnnTime = [[NSNumber numberWithInt: tempIntTime] floatValue];
    
    [player stop];
    [player setCurrentTime:currentAnnTime];
    [player prepareToPlay];
    [player play];
    UIImage *pauseBtnImg = [UIImage imageNamed:@"pauseButton.png"];
    [_playPauseButton setImage:pauseBtnImg forState:UIControlStateNormal];
    _playTimer.text = _annotationArray[indexPath.row][0];
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
    NSString *cellText = _annotationArray[indexPath.row][1];
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Thin" size:17.0f]};
    CGRect rect = [cellText boundingRectWithSize:CGSizeMake(320, CGFLOAT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:attributes
                                         context:nil];
    
    return rect.size.height + 40;
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
        [itemData setObject:_annotationArray forKey:@"annotation"];
        SPRecordItem* data = [[SPRecordItem alloc] initWithName:itemData];
        NSMutableArray* itemArray = object.recordsItems;
        [itemArray replaceObjectAtIndex:_recordItemIndex withObject:data];
    }
}

- (void) createWave {
    [self.audioFile getWaveformDataWithCompletionBlock:^(float *waveformData, UInt32 length) {
        self.audioPlot.plotType        = EZPlotTypeBuffer;
        [self.audioPlot updateBuffer:waveformData withBufferSize:length];
    }];

}

@end
