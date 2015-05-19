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
@property (strong, nonatomic) IBOutlet NSURL *outputFileURL;
@property (strong, nonatomic) IBOutlet UILabel *recordingLengthLabel;
@property (strong, nonatomic) IBOutlet UILabel *recordingStatusLabel;
@property (nonatomic,strong) EZAudioFile *audioFile;


@end

@implementation SPAudioRecorderVC
@synthesize recordButton;
@synthesize microphone;
@synthesize outputFileURL;
@synthesize currentTime;
@synthesize todayDate;
#pragma mark - Initialization
-(id)init {
    self = [super init];
    if(self){
        [self initializeViewController];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        [self initializeViewController];
    }
    return self;
}

#pragma mark - Initialize View Controller Here
-(void)initializeViewController {
    // Create an instance of the microphone and tell it to use this view controller instance as the delegate
    self.microphone = [EZMicrophone microphoneWithDelegate:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.
    
    // Disable Stop/Play button when application launches
   // [stopButton setEnabled:NO];
    
    self.audioPlot.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    self.audioPlot.opaque = NO;
    // Waveform color
    self.audioPlot.color           = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
    // Plot type
    self.audioPlot.plotType        = EZPlotTypeRolling;
    // Fill
    self.audioPlot.shouldFill      = YES;
    // Mirror
    self.audioPlot.shouldMirror    = YES;
    self.audioPlot.gain = 4.0;


    // Set the audio file
    NSString *uuidString = [[NSProcessInfo processInfo] globallyUniqueString];
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               (@"%@.mp3", uuidString),
                               nil];
    outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
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

    annotationTableView.allowsSelection = NO;
    [self.annotationTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 2.0; //seconds
    lpgr.delegate = self;
    [self.annotationTableView addGestureRecognizer:lpgr];
    
    NSDate *dateToday =[NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"d MMMM yyyy, cccc"];
    todayDate.text = [format stringFromDate:dateToday];
    [format setDateFormat:@"в HH:mm"];
    currentTime.text = [format stringFromDate:dateToday];
    
    self.annotationTableView.backgroundColor = [UIColor clearColor];
    _playPauseButton.hidden = YES;
    
    self.annotationDict
    = [[NSMutableDictionary alloc] init];
    [self recordTapped:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Actions

- (IBAction)recordTapped:(id)sender {
    // Stop the audio player before recording

    if (!recorder.recording) {

        _playPauseButton.hidden = NO;
        _doneButton.enabled = YES;
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        // Start recording
        [recorder record];
        
        
        //Start the microphone
        self.microphone = [EZMicrophone microphoneWithDelegate:self];
        [self.microphone startFetchingAudio];
        
        UIImage *pauseBtnImg = [UIImage imageNamed:@"pauseButton.png"];
        [_playPauseButton setImage:pauseBtnImg forState:UIControlStateNormal];
        _recordStatus.hidden = YES;
        _recordingStatusLabel.hidden = NO;
        _recordingStatusLabel.text = @"идет запись";
        _recordStatus.hidden = YES;
        _recordLengthLabel.hidden = YES;
        _recordingLengthLabel.hidden = NO;
        self.currentDateLbl.textColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
        self.currentTimeLbl.textColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
        //Start timer
        self.recordingTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(recordingTimerUpdate:) userInfo:nil repeats:YES];
        recordButton.hidden = YES;
        _playPauseButton.hidden = NO;
        
        [_doneButton setEnabled:YES];
        NSLog(@"%f", recorder.currentTime);
        [UIApplication sharedApplication].idleTimerDisabled = YES; //Запрет на откл устройства
    }
    
}

- (IBAction)pauseTapped:(id)sender {
//    if (player.playing) {
//        [player stop];
//        _playPauseButton.hidden = NO;
//    }
//    
//    if (recorder.recording) {
        // Pause recording
        [recorder pause];
//        UIImage *playBtnImg = [UIImage imageNamed:@"playButton.png"];
//        [_playPauseButton setImage:playBtnImg forState:UIControlStateNormal];
        _playPauseButton.hidden = YES;
        _recordStatus.text = @"пауза";
        _recordingStatusLabel.hidden = YES;
        _recordingLengthLabel.hidden = YES;
        _recordStatus.hidden = NO;
        _recordLengthLabel.hidden = NO;
        _recordStatus.textColor = [UIColor colorWithRed:0.435 green:0.443 blue:0.475 alpha:1.0];
        recordButton.hidden = NO;
        self.currentDateLbl.textColor = [UIColor colorWithRed:0.569 green:0.569 blue:0.569 alpha:1]; /*#919191*/
        self.currentTimeLbl.textColor = [UIColor colorWithRed:0.569 green:0.569 blue:0.569 alpha:1]; /*#919191*/
        [self.microphone stopFetchingAudio];
        NSLog(@"%f", recorder.currentTime);
    [UIApplication sharedApplication].idleTimerDisabled = NO; //Запрет на откл устройства

//    } else {
//        _recordStatus.text = @"проигрывание";
//        recordButton.hidden = YES;
//        UIImage *pauseBtnImg = [UIImage imageNamed:@"pauseButton.png"];
//        [_playPauseButton setImage:pauseBtnImg forState:UIControlStateNormal];
//        [player play];
        
//             }
    
}

- (IBAction)doneTapped:(id)sender {
    [recorder stop];
    [self.microphone stopFetchingAudio];

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    [recordButton setHidden:YES];
    [self.recordingTimer invalidate];
    
    self.recordURL = recorder.url;
    NSLog(@"%f", recorder.currentTime);

    
    self.audioPlotV1.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    self.audioPlotV1.opaque = NO;
    
    self.audioPlotV1.plotType        = EZPlotTypeBuffer;
    // Fill
    self.audioPlotV1.shouldFill      = YES;
    // Mirror
    self.audioPlotV1.shouldMirror    = YES;
    
    self.audioPlotV1.color           = [UIColor colorWithRed:0.30 green:0.30 blue:0.78 alpha:1.0];//[UIColor colorWithRed:1.00 green:0.00 blue:0.00 alpha:1.0];
    self.audioPlotV1.gain = 4.0;
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

    self.audioFile = [EZAudioFile audioFileWithURL:_recordURL andDelegate:self];

    [self createWave];
    
}

- (IBAction)cancelTapped:(id)sender {
    [self.delegate audioRecorderVCDidFinish:nil];
}

//рисуем гистограмму
- (void) createWave {
    
    [self.audioFile getWaveformDataWithCompletionBlock:^(float *waveformData, UInt32 length) {
        self.audioPlotV1.plotType        = EZPlotTypeBuffer;
        self.audioPlotV2.plotType        = EZPlotTypeBuffer;
        
        [self.audioPlotV1 updateBuffer:waveformData withBufferSize:length];
        [self.audioPlotV2 updateBuffer:waveformData withBufferSize:length];
        
        UIImage* plotV2 =[self imageWithView:_audioPlotV2];
        UIImage* plotV1 = [self imageWithView:_audioPlotV1];

        NSMutableDictionary *itemData = [NSMutableDictionary new];
        [itemData setObject:_recordURL forKey:@"URL"];
        [itemData setObject:_annotationDict forKey:@"annotation"];
        [itemData setObject:currentTime.text forKey:@"recordTime"];
        [itemData setObject:todayDate.text forKey:@"recordDate"];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *uuidString = [[NSProcessInfo processInfo] globallyUniqueString];

        if (plotV1 != nil)
        {
            NSString* path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@backImage.png", uuidString]];
            NSData* data = UIImagePNGRepresentation(plotV1);
            [data writeToFile:path atomically:YES];
            [itemData setObject:path forKey:@"backImage"];
        }
        
        if (plotV2 != nil)
        {
            NSString* path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@frontImage.png", uuidString]];
            NSData* data = UIImagePNGRepresentation(plotV2);
            [data writeToFile:path atomically:YES];
            [itemData setObject:path forKey:@"frontImage"];
        }
        
        SPRecordItem* data = [[SPRecordItem alloc] initWithName:itemData];
        [self.recordsItemsArray addObject:data];
        
        [self.delegate audioRecorderVCDidFinish:data];
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


#pragma mark - AVAudioRecorderDelegate

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
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

    self.recordLengthLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    self.recordLengthBottomLabel.text = _recordLengthLabel.text;
    self.recordingLengthLabel.text = _recordLengthLabel.text;
}
#pragma mark - Add annotation
- (IBAction)addAnnotation:(id)sender {
    // [self generateArrayAnnotation];
    
    NSTimeInterval currentTime = recorder.currentTime;
    
    NSInteger minutes = floor(currentTime/60);
    NSInteger seconds = trunc(currentTime - minutes * 60);
    NSString *time = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
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
#pragma mark Histogram

#pragma mark - EZMicrophoneDelegate
#warning Thread Safety
// Note that any callback that provides streamed audio data (like streaming microphone input) happens on a separate audio thread that should not be blocked. When we feed audio data into any of the UI components we need to explicity create a GCD block on the main thread to properly get the UI to work.
-(void)microphone:(EZMicrophone *)microphone
 hasAudioReceived:(float **)buffer
   withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
    // Getting audio data as an array of float buffer arrays. What does that mean? Because the audio is coming in as a stereo signal the data is split into a left and right channel. So buffer[0] corresponds to the float* data for the left channel while buffer[1] corresponds to the float* data for the right channel.
    
    // See the Thread Safety warning above, but in a nutshell these callbacks happen on a separate audio thread. We wrap any UI updating in a GCD block on the main thread to avoid blocking that audio flow.
    dispatch_async(dispatch_get_main_queue(),^{
        // All the audio plot needs is the buffer data (float*) and the size. Internally the audio plot will handle all the drawing related code, history management, and freeing its own resources. Hence, one badass line of code gets you a pretty plot :)
        [self.audioPlot updateBuffer:buffer[0] withBufferSize:bufferSize];
    });
}

-(void)microphone:(EZMicrophone *)microphone
    hasBufferList:(AudioBufferList *)bufferList
   withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
    _isRecording = YES;
    // Getting audio data as a buffer list that can be directly fed into the EZRecorder. This is happening on the audio thread - any UI updating needs a GCD main queue block. This will keep appending data to the tail of the audio file.
    if( self.isRecording ){
        [self.recorder appendDataFromBufferList:bufferList
                                 withBufferSize:bufferSize];
    }
    
}


@end
