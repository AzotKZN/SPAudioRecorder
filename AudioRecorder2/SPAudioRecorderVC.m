//
//  SPAudioRecorderVC.m
//  AudioRecorder2
//
//  Created by Азат on 15.03.15.
//  Copyright (c) 2015 Azat Minvaliev. All rights reserved.
//

#import "SPAudioRecorderVC.h"
#import "SPRecordItem.h"
#import "SAAudioRecorderVC.h"
#import "SPAnnotationCell.h"
@interface SPAudioRecorderVC () <SAAudioRecorderVCDelegate>
{
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
}

@property (nonatomic, strong) NSTimer *recordingTimer;
@property (nonatomic, strong) id object;
@property (strong, nonatomic) IBOutlet UILabel *todayDate;
@property (strong, nonatomic) IBOutlet UILabel *currentTime;


@end

@implementation SPAudioRecorderVC
@synthesize recordPauseButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Disable Stop/Play button when application launches
   // [stopButton setEnabled:NO];
    
    // Set the audio file
    NSString *uuidString = [[NSProcessInfo processInfo] globallyUniqueString];
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               (@"%@.mp3", uuidString),
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:nil];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
    
    _doneButton.enabled = NO;

    _annotationArray = [[NSMutableArray alloc] init];

    annotationTableView.allowsSelection = NO;
    
    NSDate *dateToday =[NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"d MMMM yyyy, cccc"];
    _todayDate.text = [format stringFromDate:dateToday];
    [format setDateFormat:@"в HH:mm"];
    _currentTime.text = [format stringFromDate:dateToday];
    
    self.annotationTableView.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Actions

- (IBAction)recordPauseTapped:(id)sender {
    // Stop the audio player before recording
    if (player.playing) {
        [player stop];
    }
    
    if (!recorder.recording) {
        _doneButton.enabled = YES;
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        // Start recording
        [recorder record];
        UIImage *pauseBtnImg = [UIImage imageNamed:@"pauseButton.png"];
        [_playPauseButton setImage:pauseBtnImg forState:UIControlStateNormal];
        _recordStatus.text = @"идет запись";
        _recordStatus.textColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1.0];
        //Start timer
        self.recordingTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(recordingTimerUpdate:) userInfo:nil repeats:YES];
        
        
    } else {
        
        // Pause recording
        [recorder pause];
        UIImage *playBtnImg = [UIImage imageNamed:@"playButton.png"];
        [_playPauseButton setImage:playBtnImg forState:UIControlStateNormal];
        _recordStatus.text = @"пауза";
        _recordStatus.textColor = [UIColor colorWithRed:0.435 green:0.443 blue:0.475 alpha:1.0];
    }
    
    [_doneButton setEnabled:YES];
}

- (IBAction)doneTapped:(id)sender {
    [recorder stop];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    [recordPauseButton setHidden:YES];
    [self.recordingTimer invalidate];
    
    self.recordURL = recorder.url;

    NSMutableDictionary *itemData = [NSMutableDictionary new];
    [itemData setObject:_recordURL forKey:@"URL"];
    [itemData setObject:_annotationArray forKey:@"annotation"];
    SPRecordItem* data = [[SPRecordItem alloc] initWithName:itemData];
    [self.recordsItemsArray addObject:data];

    [self.delegate audioRecorderVCDidFinish:data];
}

- (IBAction)cancelTapped:(id)sender {
    [self.delegate audioRecorderVCDidFinish:nil];
}

#pragma mark - AVAudioRecorderDelegate

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [recordPauseButton setTitle:@"Записывать" forState:UIControlStateNormal];
}

#pragma mark - AVAudioPlayerDelegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Готово!"
                                                    message: @"Проигрывание завершено!"
                                                   delegate: nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void) getRecordURL {
    self.recordURL = recorder.url;
}

- (void) recordingTimerUpdate:(id) sender
{
    NSTimeInterval currentTime = recorder.currentTime;
    
    NSInteger minutes = floor(currentTime/60);
    NSInteger seconds = trunc(currentTime - minutes * 60);

    self.recordLengthLabel.text = [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];
    self.recordLengthBottomLabel.text = _recordLengthLabel.text;
}
#pragma mark - Add annotation
- (IBAction)addAnnotation:(id)sender {
    NSTimeInterval currentTime = recorder.currentTime;
    
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
    
    return cell;
}

@end
