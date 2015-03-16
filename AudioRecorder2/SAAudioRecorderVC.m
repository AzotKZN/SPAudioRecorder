//
//  SAAudioRecorderVC.m
//  AudioRecorder2
//
//  Created by Азат on 14.03.15.
//  Copyright (c) 2015 Azat Minvaliev. All rights reserved.
//

#import "SAAudioRecorderVC.h"
#import "SPRecordItem.h"
#import "SPAudioRecorderVC.h"

@interface SAAudioRecorderVC ()
@property (nonatomic, strong) NSMutableArray *recordItems;
@end

@implementation SAAudioRecorderVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Создать" style:UIBarButtonItemStylePlain target:self action:@selector(createNewAudio:)];
    self.navigationItem.rightBarButtonItem = doneButton;
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
   // UINavigationController *nav = segue.destinationViewController;
    SPAudioRecorderVC *audioRecorderVC = [[SPAudioRecorderVC alloc] initWithNibName:@"SPAudioRecorderVC" bundle:nil];
    
    [[self navigationController] pushViewController:audioRecorderVC animated:YES];
    
}

- (IBAction)done:(UIStoryboardSegue *)segue
{
    SPAudioRecorderVC *carDetailVC = segue.sourceViewController;
    SPRecordItem *car = [[SPRecordItem alloc] initWithName:carDetailVC.recordURL];
    [self.recordItems addObject:car];
    [self.tableView reloadData];
}



#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.recordItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RecordCell";
    
    SPRecordItem *currentCar = [self.recordItems objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = currentCar.recordURL;
    
    return cell;
}


@end
