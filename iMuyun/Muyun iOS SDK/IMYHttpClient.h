//
//  IMYHttpClient.h
//  iMuyun
//
//  Created by lancy on 12-7-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@interface IMYHttpClient : NSObject





+ (IMYHttpClient *)shareClient;

//api
- (void)requestLoginWithUsername:(NSString *)username password:(NSString*) password delegate:(id)delegate;
- (void)requestRegisterWithUsername:(NSString *)username password:(NSString *)password language:(NSString *)language delegate:(id)delegate;
- (void)requestUserInfoWithUsername:(NSString *)username delegate:(id)delegate;
- (void)requestAddContactWithUsername:(NSString *)username targetUsername:(NSString *)targetUsername delegate:(id)delegate;

- (void)requestContactsWithUsername:(NSString *)username delegate:(id)delegate;
- (void)requestUpdateNoteWithUsername:(NSString *)username targetUsername:(NSString *)targetUsername note:(NSString *)note delegate:(id)delegate;
- (void)requestRecentsWithUsername:(NSString *)username delegate:(id)delegate;

- (void)requestVideoCallWithUsername:(NSString *)username callToUsername:(NSString *)callToUsername delegate:(id)delegate;
- (void)answerVideoCallWithUsername:(NSString *)username answerMessage:(NSString *)message delegate:(id)delegate;
- (void)requestEndVideoCallWithUsername:(NSString *)username delegate:(id)delegate;

- (void)requestSetFavoriteWithUsername:(NSString *)username favoriteUsername:(NSString *)favoriteUsername toggle:(NSString *)toggle delegate:(id)delegate;
- (void)requestDeleteRecentWithUsername:(NSString *)username recentUid:(NSString *)recentUid delegate:(id)delegate;
- (void)requestClearRecentsWithUsername:(NSString *)username delegate:(id)delegate;
- (void)requestUpdateMyInfoWithUsername:(NSString *)username myInfo:(NSDictionary *)myInfo delegate:(id)delegate;

- (void)requestInterpreterVideoCallWithUsername:(NSString *)username myLanguage:(NSString *)myLanguage targetLanguage:(NSString *)targetLanguage delegate:(id)delegate;

- (void)requestUploadAvatarWithUsername:(NSString *)username avatarImage:(UIImage *)avatarImage delegate:(id)delegate;

- (void)requestSendFeedBackWithUsername:(NSString *)username message:(NSString *)message deleagte:(id)delegate;

- (void)requestUserBalanceWithUsername:(NSString *)username delegate:(id)delegate;

- (void)requestaddBalanceWithUsername:(NSString *)username addBalance:(NSString *)addBalance delegate:(id)delegate;

@end
