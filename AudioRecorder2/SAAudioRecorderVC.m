//
//  SAAudioRecorderVC.m
//  AudioRecorder2
//
//  Created by Азат on 14.03.15.
//  Copyright (c) 2015 Azat Minvaliev. All rights reserved.
//

#import "SAAudioRecorderVC.h"
#import "SPAudioRecorderVC.h"
#import "SPAudioRcPlayer.h"
@interface SAAudioRecorderVC ()
@end

@implementation SAAudioRecorderVC

//-(id)init
//{
//    self = [super init];
//    if (self) {
//        self.recordsItems = [NSMutableArray array];
//    }
//    return self;
//}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Создать" style:UIBarButtonItemStylePlain target:self action:@selector(createNewAudio:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    if (!self.recordsItems)
        self.recordsItems = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)createNewAudio:(id)sender {
    SPAudioRecorderVC *audioRecorderVC = [[SPAudioRecorderVC alloc] initWithNibName:@"SPAudioRecorderVC" bundle:nil];
    audioRecorderVC.recordsItemsArray = [_recordsItems mutableCopy];
    audioRecorderVC.delegate = self;

    [self presentViewController:audioRecorderVC animated:YES completion:nil];
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.recordsItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    SPRecordItem *currentRecord = self.recordsItems[indexPath.row];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
    }

    cell.textLabel.text = [currentRecord.recordURL absoluteString];
        return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    
    SPAudioRcPlayer *playerView = [[SPAudioRcPlayer alloc] initWithNibName:@"SPAudioRcPlayer" bundle:nil];;
   
    SPRecordItem *currentRecord = self.recordsItems[indexPath.row];
    playerView.currentRecord = currentRecord;
    playerView.recordItemIndex = indexPath.row;
    
    playerView.delegate = self;
    
    [self.navigationController pushViewController:playerView animated:YES];

}

- (void)audioRecorderVCDidFinish:(SPAudioRecorderVC *)audioRecorderVC {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    if (audioRecorderVC!=nil) {
        [self.recordsItems addObject:audioRecorderVC];
        [self.tableView reloadData];
    }
    
}
@end
