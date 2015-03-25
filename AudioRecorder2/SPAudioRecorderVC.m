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
#import "SPAnnotation.h"
@interface SPAudioRecorderVC () <SAAudioRecorderVCDelegate>
{
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
}

@property (nonatomic, strong) NSTimer *recordingTimer;
@property (nonatomic, strong) id object;


@end

@implementation SPAudioRecorderVC
@synthesize recordPauseButton;
UIBarButtonItem *doneButton;
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
    
    doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Готово" style:UIBarButtonItemStylePlain target:self action:@selector(doneTapped:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    doneButton.enabled = NO;
    
    //_object = [[SAAudioRecorderVC alloc] init];
    
    _object = [[SPAnnotation alloc] init];
    _annotationArray = [[NSMutableArray alloc] init];

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
        doneButton.enabled = YES;
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        // Start recording
        [recorder record];
        [recordPauseButton setTitle:@"ll" forState:UIControlStateNormal];
        
        //Start timer
        self.recordingTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(recordingTimerUpdate:) userInfo:nil repeats:YES];
        
        
    } else {
        
        // Pause recording
        [recorder pause];
        [recordPauseButton setTitle:@"●" forState:UIControlStateNormal];
    }
    
    [doneButton setEnabled:YES];
}

- (IBAction)doneTapped:(id)sender {
    [recorder stop];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    [recordPauseButton setHidden:YES];
    [self.recordingTimer invalidate];
    
    self.recordURL = recorder.url;
    //SPRecordItem* data = [[SPRecordItem alloc] initWithName:itemData];
    NSMutableDictionary *itemData = [NSMutableDictionary new];
    [itemData setObject:_recordURL forKey:@"URL"];
    [itemData setObject:_annotationArray forKey:@"annotation"];
    SPRecordItem* data = [[SPRecordItem alloc] initWithName:itemData];
    [self.recordsItemsArray addObject:data];
   // [self.recordsItemsArray addObject:_recordURL];
   // NSLog(@"%@", data);
   [self.delegate audioRecorderVCDidFinish:data];
}

#pragma mark - AVAudioRecorderDelegate

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    [recordPauseButton setTitle:@"Записывать" forState:UIControlStateNormal];
   // [stopButton setEnabled:NO];
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
    //return [_object getItemTotalCount:_annotationArray];
    // Return the number of rows in the section.
    NSLog(@"%lu", (unsigned long)_annotationArray.count);
    return _annotationArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   // NSArray *rowData = [_object getItemIndexPath:indexPath.row];
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
   }
    cell.textLabel.text = _annotationArray[indexPath.row][0];
    
    cell.detailTextLabel.text = _annotationArray[indexPath.row][1];

    return cell;
}
@end
