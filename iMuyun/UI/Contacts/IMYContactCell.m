//
//  IMYContactCell.m
//  iMuyun
//
//  Created by lancy on 12-7-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "IMYContactCell.h"

@implementation IMYContactCell
@synthesize nameLabel = _nameLabel;
@synthesize companyLabel = _companyLabel;
@synthesize avatarImageView = _avatarImageView;
@synthesize callButton = _callButton;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
//
//- (IBAction)tapTheCallButton:(id)sender
//{
//    NSLog(@"tap the call button to call someone");
//    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:[[[event touchesForView:sender] anyObject] locationInView:tableView]];
//}

@end
