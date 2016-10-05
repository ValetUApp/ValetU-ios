//
//  VUser.h
//  valetu
//
//  Created by imobile on 2016-09-28.
//  Copyright © 2016 imobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VComment.h"

@interface VUser : NSObject

@property (nonatomic) FBSDKProfile *fbProfile;
@property (nonatomic) FBSDKAccessToken *fbToken;
@property (nonatomic) NSDictionary* userProfile;

@property (nonatomic) NSString* userId;
@property (nonatomic) NSString* email;
@property (nonatomic) NSString* profileId;
@property (nonatomic) NSString* username;
@property (nonatomic) NSDictionary* lastParking;
@property (nonatomic) NSDictionary* lastReview;
@property (nonatomic) NSString* numberOfParkings;
@property (nonatomic) NSString* numberOfReviews;
@property (nonatomic) VComment* lastComment;


+(VUser*)sharedModel;

@end
