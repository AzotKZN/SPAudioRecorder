//
//  SAAudioRecorderVC.m
//  AudioRecorder2
//
//  Created by Азат on 14.03.15.
//  Copyright (c) 2015 Azat Minvaliev. All rights reserved.
//

#import "SAAudioRecorderVC.h"
#import "SPAudioRecorderVC.h"

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
    //[[self navigationController] pushViewController:audioRecorderVC animated:YES];
    
}

- (void) addObject:(id)object
{
    [self.recordsItems addObject:object];
    [self.tableView reloadData];
    NSLog(@"%lu", (unsigned long)[self.recordsItems count]);
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Второй вызов %lu", (unsigned long)[self.recordsItems count]);

    // Return the number of rows in the section.
    return [self.recordsItems count];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    //SPRecordItem *currentRecord = [self.recordsItems objectAtIndex:indexPath.row];
    
    NSArray *currentRecord = [self.recordsItems objectAtIndex:indexPath.row];
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
    }
    
       // cell.textLabel.text = [currentRecord.recordURL absoluteString];;
    cell.textLabel.text = [currentRecord[indexPath.row] absoluteString];
        return cell;
}

- (void)myViewControllerDidFinish:(SPAudioRecorderVC *)myViewController {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.recordsItems addObject:myViewController.recordsItemsArray];
    [self.tableView reloadData];
    NSLog(@"Changed data: %@", self.recordsItems);
    // Respond to data
}

@end
