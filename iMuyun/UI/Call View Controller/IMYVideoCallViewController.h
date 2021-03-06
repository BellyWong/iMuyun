//
//  IMYViedoCallViewController.h
//  iMuyun
//
//  Created by lancy on 12-7-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Opentok/Opentok.h>
#import "IMYHttpClient.h"

typedef enum{
    IMYVideoCallStateNormal,
    IMYVideoCallStateCallOut,
    IMYVideoCallStateCallIn
} IMYVideoCallState;


@interface IMYVideoCallViewController : UIViewController<ASIHTTPRequestDelegate, OTSessionDelegate, OTPublisherDelegate, OTSubscriberDelegate>

// video call target
@property (strong, nonatomic) NSDictionary *
targetContact;
@property IMYVideoCallState videoCallState;

//UI
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *rejectButton;
@property (weak, nonatomic) IBOutlet UIButton *endButton;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;

@property (weak, nonatomic) IBOutlet UIView *stateView;

@property (weak, nonatomic) IBOutlet UIView *targetVideoView;
@property (weak, nonatomic) IBOutlet UIView *myVideoView;
@property (weak, nonatomic) IBOutlet UIView *interpreterVideoView;
- (IBAction)touchView:(id)sender;

- (IBAction)tapAceptButton:(id)sender;
- (IBAction)tapRejectButton:(id)sender;
- (IBAction)tapEndButton:(id)sender;



@end
