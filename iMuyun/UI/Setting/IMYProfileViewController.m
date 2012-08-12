//
//  IMYProfileViewController.m
//  iMuyun
//
//  Created by Lancy on 12/8/12.
//
//

#import "IMYProfileViewController.h"

@interface IMYProfileViewController ()

@property BOOL newMedia;

- (void)initMyProfile;

@end

@implementation IMYProfileViewController
@synthesize photoImageView;
@synthesize nameTextField;
@synthesize companyTextField;
@synthesize languageTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self initMyProfile];
}

- (void)viewDidUnload
{
    [self setPhotoImageView:nil];
    [self setNameTextField:nil];
    [self setCompanyTextField:nil];
    [self setLanguageTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - TableView delegate
// use static table view

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancle" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Existing", nil];
        [actionSheet showInView:self.view];
    }
}

#pragma mark - UI Methods

- (void)initMyProfile
{
    NSDictionary *myInfo = [[NSUserDefaults standardUserDefaults] valueForKey:@"myInfo"];
    [self.nameTextField setText:[myInfo valueForKey:@"name"]];
    [self.companyTextField setText:[myInfo valueForKey:@"company"]];
    [self.languageTextField setText:[myInfo valueForKey:@"language"]];
    
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            NSLog(@"Tap take photo");
            if ([UIImagePickerController isSourceTypeAvailable:
                 UIImagePickerControllerSourceTypeCamera])
            {
                UIImagePickerController *imagePicker =
                [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.sourceType =
                UIImagePickerControllerSourceTypeCamera;
                [imagePicker setCameraDevice:UIImagePickerControllerCameraDeviceFront];
                imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *) kUTTypeImage,nil];
                imagePicker.allowsEditing = YES;
                [self presentModalViewController:imagePicker
                                        animated:YES];
                self.newMedia = YES;
            }
            break;
        case 1:
            NSLog(@"Tap choose existing");
            if ([UIImagePickerController isSourceTypeAvailable:
                 UIImagePickerControllerSourceTypeSavedPhotosAlbum])
            {
                UIImagePickerController *imagePicker =
                [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.sourceType =
                UIImagePickerControllerSourceTypePhotoLibrary;
                imagePicker.mediaTypes = [NSArray arrayWithObjects:
                                          (NSString *) kUTTypeImage,
                                          nil];
                imagePicker.allowsEditing = YES;
                [self presentModalViewController:imagePicker animated:YES];
                self.newMedia = NO;
            }
            break;
            
        default:
            break;
    }
}

#pragma mark - image picker controller delegate

-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info
                           objectForKey:UIImagePickerControllerMediaType];
    [self dismissModalViewControllerAnimated:YES];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info
                          objectForKey:UIImagePickerControllerEditedImage];
        
        [self.photoImageView setImage:image];
//        if (self.newMedia)
//            UIImageWriteToSavedPhotosAlbum(image,
//                                           self,
//                                           @selector(image:finishedSavingWithError:contextInfo:),
//                                           nil);
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
		// Code here to support video if enabled
	}
}
//-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
//{
//    if (error) {
//        UIAlertView *alert = [[UIAlertView alloc]
//                              initWithTitle: @"Save failed"
//                              message: @"Failed to save image"\
//                              delegate: nil
//                              cancelButtonTitle:@"OK"
//                              otherButtonTitles:nil];
//        [alert show];
//    }
//}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
