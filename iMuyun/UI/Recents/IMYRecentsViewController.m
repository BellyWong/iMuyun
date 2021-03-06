//
//  IMYRecentsViewController.m
//  iMuyun
//
//  Created by lancy on 12-7-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "IMYRecentsViewController.h"
#import "IMYHttpClient.h"
#import "IMYRecordCell.h"
#import "IMYContactDetailViewController.h"
#import "IMYVideoCallViewController.h"

@interface IMYRecentsViewController ()

@property (nonatomic, strong) NSMutableArray* allRecents;
@property (nonatomic, strong) NSMutableArray* missedRecents;

- (void)tapEditButton;
- (void)tapClearButton;

@end

@implementation IMYRecentsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
        

    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.editButtonItem setAction:@selector(tapEditButton)];

    
    // add observer
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults addObserver:self forKeyPath:@"allRecents" options:NSKeyValueObservingOptionNew context:NULL];
    
    // init data
    self.allRecents = [[NSMutableArray alloc] initWithArray:[defaults valueForKey:@"allRecents"]];
    [self getMissedResultFromAllRecents];
    
    // request recents
    NSString *myUserName = [[[NSUserDefaults standardUserDefaults] valueForKey:@"myInfo"] valueForKey:@"username"];
    [[IMYHttpClient shareClient] requestRecentsWithUsername:myUserName delegate:self];
        
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)viewDidUnload
{
    [self setRecentsTypeSegment:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self setAllRecents:nil];
    [self setMissedRecents:nil];
    
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"allRecents"];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([[defaults valueForKey:@"rencentsNeedToReload"] isEqualToString:@"Yes"]) {
        NSString *myUserName = [[[NSUserDefaults standardUserDefaults] valueForKey:@"myInfo"] valueForKey:@"username"];
        [[IMYHttpClient shareClient] requestRecentsWithUsername:myUserName delegate:self];
        
        [defaults setValue:@"No" forKey:@"rencentsNeedToReload"];
    }

    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - http methods

- (void)getMissedResultFromAllRecents
{
    NSMutableArray *missed = [[NSMutableArray alloc] init];
    for (NSDictionary *record in self.allRecents) {
        if ([[record valueForKey:@"type"] isEqualToString:@"missed"]) {
            [missed addObject:record];
        }
    }
    self.missedRecents = missed;
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSError *error;
    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:[request responseData] options:kNilOptions error:&error];
    NSLog(@"Request finished, results: %@", results);
    if ([[results valueForKey:@"requestType"] isEqualToString:@"recents"] ) {
        if (![self.allRecents isEqualToArray:[results valueForKey:@"records"]]) {
            NSLog(@"Results are different, will write to userdefaults buffer allRecents.");
            [[NSUserDefaults standardUserDefaults] setValue:[results valueForKey:@"records"] forKey:@"allRecents"];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            NSLog(@"Did write to user defaults buffer muyunContacts.");
        }
    }
    else if([[results valueForKey:@"requestType"] isEqualToString:@"deleteRecent"])
    {
        if ([[results valueForKey:@"message"] isEqualToString:@"success"]) {
            NSLog(@"Delete recents success");
        }
        else
        {
            NSLog(@"Delete recents fail");
        }
    }
    else if([[results valueForKey:@"requestType"] isEqualToString:@"clearRecent"])
    {
        if ([[results valueForKey:@"message"] isEqualToString:@"success"]) {
            NSLog(@"Clear recents success");
        }
        else
        {
            NSLog(@"Clear recents fail");
        }
    }

}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"Request Failed, %@", error);
}


#pragma mark - Observer methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqual:@"allRecents"]) {
        NSLog(@"Observe that userdefaults buffer allRecents change to: %@", [change objectForKey:NSKeyValueChangeNewKey]);
        if (![self.allRecents isEqual:[change objectForKey:NSKeyValueChangeNewKey]]) {
            NSLog(@"Change are different, will modify self.allRecents and self.missedRecents");
            
            if ([[change objectForKey:NSKeyValueChangeNewKey] isKindOfClass:[NSArray class]]) {
                self.allRecents = [[NSMutableArray alloc] initWithArray:[change objectForKey:NSKeyValueChangeNewKey]];
                [self getMissedResultFromAllRecents];

            } else
            {
                self.allRecents = nil;
                self.missedRecents = nil;
            }
            NSLog(@"Did modify self.allRecents and self.missedRecents.");

        }
        
    }
    
    /*
     Be sure to call the superclass's implementation *if it implements it*.
     NSObject does not implement the method.
     */
//    [super observeValueForKeyPath:keyPath
//                         ofObject:object
//                           change:change
//                          context:context];
}

#pragma mark - UI methods
- (IBAction)changeRecentsTypeSegmentValue:(id)sender {
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    NSLog(@"Did changed recents type segment controller");
}

- (void)tapClearButton
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *myUserName = [[defaults valueForKey:@"myInfo"] valueForKey:@"username"];
    [[IMYHttpClient shareClient] requestClearRecentsWithUsername:myUserName delegate:self];
    
    // clear user defaults buffer allRecents and reload table view
    [defaults setValue:nil forKey:@"allRecents"];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];

}

- (void)tapEditButton
{
    BOOL isEditing = [self.tableView isEditing];
    if (!isEditing) {
        NSLog(@"Table view will begin editing");        
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleBordered target:self action:@selector(tapClearButton)] animated:YES];
//        [self.navigationItem.leftBarButtonItem setTintColor:[UIColor redColor]];
        
        [self.navigationItem.rightBarButtonItem setTitle:@"Done"];
        [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleDone];
        
    } else
    {
        NSLog(@"Table view did end editing");
        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
        
        [self.navigationItem.rightBarButtonItem setTitle:@"Edit"];
        [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleBordered];
        
    }
    [self.tableView setEditing:!isEditing animated:YES];
    
    
}


#pragma mark - transform methods
- (NSString *)dateStringFromNSDate:(NSDate *)date
{
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc]init];
    [dayFormatter setLocale:[NSLocale currentLocale]];
    [dayFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dayFormatter setDoesRelativeDateFormatting:YES];
    
    return [dayFormatter stringFromDate:date];
}


- (NSString *)timeStringFromNSDate:(NSDate *)date
{
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc]init];
    [dayFormatter setLocale:[NSLocale currentLocale]];
    [dayFormatter setDateStyle:NSDateFormatterFullStyle];
    [dayFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dayFormatter setDoesRelativeDateFormatting:YES];
    return [dayFormatter stringFromDate:date];
}

- (NSString *)minutsStringFromTimeInterval:(NSTimeInterval)theTimeInterval
{
    NSDateComponents *dateComponets = [self dateComponetsFromTimeInterval:theTimeInterval];
    NSString *results = [NSString stringWithFormat:@"%02d:%02d", [dateComponets minute], [dateComponets second]];
    return results;
}

- (NSDateComponents *)dateComponetsFromTimeInterval:(NSTimeInterval)theTimeInterval
{
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    
    // Create the NSDates
    NSDate *date1 = [[NSDate alloc] init];
    NSDate *date2 = [[NSDate alloc] initWithTimeInterval:theTimeInterval sinceDate:date1];
    
    // Get conversion to months, days, hours, minutes
    unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit;
    
    NSDateComponents *conversionInfo = [sysCalendar components:unitFlags fromDate:date1  toDate:date2  options:0];
//    
//    NSLog(@"Conversion: %dmin %dhours %ddays %dmoths",[conversionInfo minute], [conversionInfo hour], [conversionInfo day], [conversionInfo month]);
    return conversionInfo;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if ([self.recentsTypeSegment selectedSegmentIndex] == 0) {
        return [self.allRecents count];
    } else {
        return [self.missedRecents count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"recordCell";
    IMYRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    NSDictionary *record;
    if ([self.recentsTypeSegment selectedSegmentIndex] == 0) {
        record = [self.allRecents objectAtIndex:indexPath.row];
    } else {
        record = [self.missedRecents objectAtIndex:indexPath.row];
    }
    
    UIImage *typeImage = [UIImage imageNamed:[record valueForKey:@"type"]];
    [cell.typeImageView setImage:typeImage];
    [cell.nameLabel setText:[[record valueForKey:@"contact"] valueForKey:@"name"]];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    
    NSDate *date = [dateFormat dateFromString:[record valueForKey:@"startTime"]];
    NSTimeInterval duration = [[record valueForKey:@"duration"] doubleValue];
    
    NSString *infoString = [NSString stringWithFormat:@"%@ ---- %@", [self minutsStringFromTimeInterval:duration], [self timeStringFromNSDate:date]];
    [cell.infoLabel setText:infoString];
        
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    IMYVideoCallViewController *videoCallViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"videoCallViewController"];
    NSDictionary *contact;
    if ([self.recentsTypeSegment selectedSegmentIndex] == 0) {
        contact = [[self.allRecents objectAtIndex:indexPath.row] valueForKey:@"contact"];
    } else {
        contact = [[self.missedRecents objectAtIndex:indexPath.row] valueForKey:@"contact"];
    }
    [videoCallViewController setTargetContact:contact];
    [videoCallViewController setVideoCallState:IMYVideoCallStateCallOut];
    [self presentModalViewController:videoCallViewController animated:YES];
    
    
}
- (IBAction)accessoryButtonTapped:(id)sender forEvent:(UIEvent *)event
{
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[[[event touchesForView:sender] anyObject] locationInView:self.tableView]];
    NSLog(@"accessory button tapped, index path = %@", indexPath);
    
    
    
    IMYContactDetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"contactDetail"];
    // ...
    // Pass the selected object to the new view controller.
    NSDictionary *contact;
    if ([self.recentsTypeSegment selectedSegmentIndex] == 0) {
        contact = [[self.allRecents objectAtIndex:indexPath.row] valueForKey:@"contact"];
    } else {
        contact = [[self.missedRecents objectAtIndex:indexPath.row] valueForKey:@"contact"];
    }
    
    [detailViewController setContact:contact];
    
    [self.navigationController pushViewController:detailViewController animated:YES];
    
}

//- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
//{
//    IMYContactDetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"contactDetail"];
//    // ...
//    // Pass the selected object to the new view controller.
//    NSDictionary *contact;
//    if ([self.recentsTypeSegment selectedSegmentIndex] == 0) {
//        contact = [[self.allRecents objectAtIndex:indexPath.row] valueForKey:@"contact"];
//    } else {
//        contact = [[self.missedRecents objectAtIndex:indexPath.row] valueForKey:@"contact"];
//    }
//    
//    [detailViewController setContact:contact];
//    
//    [self.navigationController pushViewController:detailViewController animated:YES];
//    
//
//}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([self.recentsTypeSegment selectedSegmentIndex] == 0) {
            // request to delete recent
            NSString *myUserName = [[[NSUserDefaults standardUserDefaults] valueForKey:@"myInfo"] valueForKey:@"username"];
            NSString *recentUid = [[self.allRecents objectAtIndex:indexPath.row] valueForKey:@"uid"];
            [[IMYHttpClient shareClient] requestDeleteRecentWithUsername:myUserName recentUid:recentUid delegate:self];
            
            // delete recent local
            [self.allRecents removeObjectAtIndex:indexPath.row];
            [[NSUserDefaults standardUserDefaults] setValue:self.allRecents forKey:@"allRecents"];
            [self getMissedResultFromAllRecents];

        } else {
            // request to delete recent
            NSString *myUserName = [[[NSUserDefaults standardUserDefaults] valueForKey:@"myInfo"] valueForKey:@"username"];
            NSDictionary *recent = [self.missedRecents objectAtIndex:indexPath.row];
            NSString *recentUid = [recent valueForKey:@"uid"];
            [[IMYHttpClient shareClient] requestDeleteRecentWithUsername:myUserName recentUid:recentUid delegate:self];

            // delete recent local
            for (NSInteger i = 0; i < self.allRecents.count; i++) {
                if ([[self.allRecents objectAtIndex:i] isEqual:recent]) {
                    [self.allRecents removeObjectAtIndex:i];
                    [[NSUserDefaults standardUserDefaults] setValue:self.allRecents forKey:@"allRecents"];
                    [self getMissedResultFromAllRecents];
                    break;
                }
            }
        }
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];

    }
}





@end
