//
//  IMYInterpreterVideoCallViewController.m
//  iMuyun
//
//  Created by Lancy on 7/8/12.
//
//

#import "IMYInterpreterVideoCallViewController.h"
#import "IMYAppDelegate.h"

@interface IMYInterpreterVideoCallViewController ()
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) OTSession *session;
@property (nonatomic, strong) OTPublisher *publisher;
@property (nonatomic, strong) OTSubscriber *interpreterSubscriber;

@property (nonatomic, weak) NSString* apiKey;
@property (nonatomic, weak) NSString* token;
@property (nonatomic, weak) NSString* sessionId;

@property NSInteger callTime;
@property NSInteger hiddenTime;

@property BOOL isCallOut;

@property (nonatomic, strong) NSString* username;

- (void)initSessionAndBeginConnecting;
- (void)initPublisherAndBeginPublish;
- (void)showAlert:(NSString*)string;
- (void)updateSubscriber;

- (void)updateUserInterface;
- (void)showEndButton:(BOOL)toogle;

- (void)customUserInterface;


@end

@implementation IMYInterpreterVideoCallViewController
@synthesize timerLabel = _timerLabel;



static double widgetHeight = 240;
static double widgetWidth = 320;
static double stateViewHeight = 100;

static NSString* const kApiKey = @"16937882";
static NSString* const kToken = @"devtoken";
static NSString* const kSessionId = @"1_MX4wfn4yMDEyLTA3LTE1IDA2OjMzOjQzLjEzMzU1OSswMDowMH4wLjY0MjU1Mjg1MjU2NH4";
static NSString* const kUserName = @"lancy";

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // custom
    }
    return self;
}

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
    NSLog(@"Interpreter Video Call Controller did load");
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.username = [[[NSUserDefaults standardUserDefaults] valueForKey:@"myInfo"] valueForKey:@"username"];

    [self customUserInterface];
    
    self.callTime = 0;
    self.isCallOut = NO;
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimeLabel) userInfo:nil repeats:YES];

}

- (void)viewDidUnload
{
    NSLog(@"Interpreter Video Call Controller did unload");
    [self setAvatarImageView:nil];
    [self setStateLabel:nil];
    [self setEndButton:nil];
    [self setMyVideoView:nil];
    [self setInterpreterVideoView:nil];
    [self setStateView:nil];
    [self setTimerLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    IMYAppDelegate *delegate =  (IMYAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate setIsInCall:YES];
    [self updateUserInterface];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    IMYAppDelegate *delegate =  (IMYAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate setIsInCall:NO];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

#pragma mark - rotate interface

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    if ([self.session connectionCount] > 1 && interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown) {
        return YES;
    } else
        return NO;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration animations:^{
        if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
            [self.interpreterSubscriber.view setFrame:CGRectMake(-80, 0, 480, 360)];
            [self.interpreterVideoView setFrame:CGRectMake(0, 100, 320, 360)];
        } else
        {
            [self.interpreterSubscriber.view setFrame:CGRectMake(0, -30, 400 * 1.2, 300 * 1.2)];
            [self.interpreterVideoView setFrame:CGRectMake(0, 0, 480, 300)];
        }
    }];
}


#pragma mark - UI methods

- (void)customUserInterface
{
    // add border corner and shadow
    self.myVideoView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.myVideoView.layer.masksToBounds= NO;
    //    self.myVideoView.layer.cornerRadius= 5.0f;
    self.myVideoView.layer.borderWidth = 2.0f;
    
    self.myVideoView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.myVideoView.layer.shadowOffset = CGSizeMake(3, 3);
    self.myVideoView.layer.shadowOpacity = 0.5;
    self.myVideoView.layer.shadowRadius = 2.0;
    
    // add border corner and shadow
    self.interpreterVideoView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.interpreterVideoView.layer.masksToBounds= NO;
    //    self.interpreterVideoView.layer.cornerRadius= 5.0f;
    self.interpreterVideoView.layer.borderWidth = 2.0f;
    
    self.interpreterVideoView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.interpreterVideoView.layer.shadowOffset = CGSizeMake(3, 3);
    self.interpreterVideoView.layer.shadowOpacity = 0.5;
    self.interpreterVideoView.layer.shadowRadius = 2.0;
}


- (void)updateUserInterface
{
//    NSString *soundPath=[[NSBundle mainBundle] pathForResource:@"ring" ofType:@"caf"];
//    NSURL *soundUrl = [[NSURL alloc] initFileURLWithPath:soundPath];

    
    switch (self.videoCallState) {
        case IMYVideoCallStateNormal:
            [self.stateLabel setText:[NSString stringWithFormat:@"Comunication with Muyun Interperter"]];
//            [self.audioPlayer stop];
            
            [self.myVideoView setHidden:NO];

            break;
        case IMYVideoCallStateCallIn:
            break;
        case IMYVideoCallStateCallOut:
            [self.stateLabel setText:[NSString stringWithFormat:@"Calling Muyun Interpreter"]];
            self.isCallOut = YES;
            
            // play ring
//            self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
//            self.audioPlayer.numberOfLoops = -1;
//            [self.audioPlayer play];
            
            [self.myVideoView setHidden:YES];
            

            
            // request video call
            [[IMYHttpClient shareClient] requestInterpreterVideoCallWithUsername:self.username myLanguage:self.myLanguage targetLanguage:self.targetLanguage delegate:self];
            
            break;
        default:
            break;
    }
    
}


- (void)showEndButton:(BOOL)toogle
{
    [self.endButton setHidden:!toogle];
}


- (IBAction)tapEndButton:(id)sender {
    [self updateBalance];
    [self.session disconnect];
    [self setIsCallOut:NO];
    [self.audioPlayer stop];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)touchView:(id)sender {
    self.hiddenTime = 0;
    if (self.videoCallState == IMYVideoCallStateNormal && [self.endButton isHidden]) {
        [self setHiddenWithView:self.endButton toggle:NO animate:YES];
    }
}


#pragma mark - timer
- (void)updateTimeLabel
{
    self.hiddenTime += 1;
    if (self.hiddenTime == 5 && self.videoCallState == IMYVideoCallStateNormal) {
        [self setHiddenWithView:self.endButton toggle:YES animate:YES];
    }

    if (self.interpreterSubscriber != nil) {
        self.callTime += 1;
        [self.timerLabel setText:[NSString stringWithFormat:@"%02d:%02d", self.callTime / 60, self.callTime % 60]];
    }
    
    if (self.isCallOut) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSInteger balance = [[defaults valueForKey:@"balance"] intValue];
        NSInteger useOut = self.callTime / 60;
        
        if (useOut * 3 >= balance) {
            NSLog(@"User use out balance");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Your balance has reached 0." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [self tapEndButton:self];
        }
        //        } else if ((useOut + 1) * 3 >= balance) {
        //            NSLog(@"User balance is going to be 0 in 1 mins.");
        //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Your balance is going to reach 0 in 1 min." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //            [alert show];
        //        }
        
    }

}


#pragma mark - http methods

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSError *error;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[request responseData] options:kNilOptions error:&error];
    NSLog(@"Request finished, results: %@", result);
    if ([self isVisible]) {
        if ([[result valueForKey:@"requestType"] isEqualToString:@"interpreterVideoCall"]) {
            if ([[result valueForKey:@"message"] isEqualToString:@"accept"]) {
                NSLog(@"Interpreter accept video call.");
                self.sessionId = [result valueForKey:@"sessionId"];
                self.token = [result valueForKey:@"token"];
                self.videoCallState = IMYVideoCallStateNormal;
                [self updateUserInterface];
                [self initSessionAndBeginConnecting];
            } else {
                NSLog(@"Interpreter reject video call.");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Our interpreter is busy now, please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [self tapEndButton:nil];

            }
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"Request failed, %@", error);
    NSLog(@"Network Error.");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"There is something wrong with our server, please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [self tapEndButton:nil];

}


#pragma mark - Connecting methods
- (void)initSessionAndBeginConnecting
{
    NSLog(@"session begin conecting");
    self.session = [[OTSession alloc] initWithSessionId:self.sessionId delegate:self];
    [self.session connectWithApiKey:self.apiKey token:self.token];
}

- (void)sessionDidConnect:(OTSession *)session
{
    NSLog(@"session did connect");
    [self initPublisherAndBeginPublish];
}

- (void)sessionDidDisconnect:(OTSession*)session
{
    NSString* alertMessage = [NSString stringWithFormat:@"Session disconnected: (%@)", session.sessionId];
    NSLog(@"sessionDidDisconnect (%@)", alertMessage);
    //    [self showAlert:alertMessage];
}

- (void)initPublisherAndBeginPublish
{
    NSLog(@"publisher begin publish");
    self.publisher = [[OTPublisher alloc] initWithDelegate:self name:self.username];
    [self.session publish:self.publisher];
    //    [self.publisher.view setFrame:CGRectMake(0, widgetHeight + stateViewHeight, widgetWidth / 2, widgetHeight / 2)];
    //    [self.view addSubview:self.publisher.view];
    [self.publisher.view setFrame:CGRectMake(0, 0, 120, 90)];
    [self.myVideoView addSubview:self.publisher.view];
}

- (void)session:(OTSession *)session didReceiveStream:(OTStream *)stream
{
    NSLog(@"session didReceiveStream (%@)(%@)", stream.streamId, stream.name);
    
    if ([[stream name] isEqualToString:@"interpreter"]) {
        if (!self.interpreterSubscriber) {
            self.interpreterSubscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
        }
    } else if (![[stream name] isEqualToString:[self.publisher name]]) {
        if (!self.interpreterSubscriber) {
            self.interpreterSubscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
        }
    }
}

- (void)subscriberDidConnectToStream:(OTSubscriber*)subscriber
{
    NSLog(@"subscriberDidConnectToStream (%@)", subscriber.stream.connection.connectionId);
        [subscriber.view setFrame:CGRectMake(-80, 0, 480, 360)];
        [self.interpreterVideoView addSubview:subscriber.view];
    
}

- (void)session:(OTSession*)session didDropStream:(OTStream*)stream{
    NSLog(@"session didDropStream (%@)", stream.streamId);
    NSLog(@"_subscriber.stream.streamId (%@)", _interpreterSubscriber.stream.streamId);
    if ([[stream name] isEqualToString:@"interpreter"]) {
        self.interpreterSubscriber = nil;
        [self tapEndButton:self];
        
    }
//    else if (![[stream name] isEqualToString:[self.publisher name]]) {
//        self.subscriber = nil;
//    }
}


#pragma mark - error methods

- (void)showAlert:(NSString*)string {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message from video session"
                                                    message:string
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)publisher:(OTPublisher*)publisher didFailWithError:(OTError*) error {
    NSLog(@"publisher didFailWithError %@", error);
    //    [self showAlert:[NSString stringWithFormat:@"There was an error publishing."]];
}

- (void)subscriber:(OTSubscriber*)subscriber didFailWithError:(OTError*)error
{
    NSLog(@"subscriber %@ didFailWithError %@", subscriber.stream.streamId, error);
    //    [self showAlert:[NSString stringWithFormat:@"There was an error subscribing to stream %@", subscriber.stream.streamId]];
}

- (void)session:(OTSession*)session didFailWithError:(OTError*)error {
    NSLog(@"sessionDidFail");
    //    [self showAlert:[NSString stringWithFormat:@"There was an error connecting to session %@", session.sessionId]];
}

- (void)setHiddenWithView:(UIView *)view toggle:(BOOL)toggle animate:(BOOL)animate {
    if (toggle == YES) {
        [view setAlpha:1];
        [UIView animateWithDuration:0.5 animations:^{
            [view setAlpha:0];
        }completion:^(BOOL finish){
            [view setAlpha:1];
            [view setHidden:YES];
        }];
    } else {
        [view setHidden:NO];
    }
    
}

- (void)updateBalance
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger balance = [[defaults valueForKey:@"balance"] intValue];
    NSInteger useOut = self.callTime / 60;
    NSInteger new = balance - useOut * 3;
    [defaults setValue:[NSString stringWithFormat:@"%d", new] forKey:@"balance"];
}

- (BOOL)isVisible {
    return [self isViewLoaded] && self.view.window;
}


@end
