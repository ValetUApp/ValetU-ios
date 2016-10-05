//
//  iCommon.h
//  valetu
//
//  Created by imobile on 2016-09-23.
//  Copyright © 2016 imobile. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface iCommon : NSObject

+ (void) getUberETAWithCompletion: (CLLocation*) pickupLocation completion:  (void (^)(NSDictionary* uberData, NSString* string, BOOL status))completionBlock;

+(void) loginWithFB:(UIViewController*) viewController  withCompletion: (void (^)(id result, BOOL status , NSString* message)) completion;

+ (void)fetchUserInfoWithCompletion: (void (^)(id result, BOOL status, NSString* message)) completion;

+(void) saveTokenWithCompletion: (void (^)(BOOL status , NSString* message)) completion;

+ (void) startNavigation;

+ (BOOL)shouldSkipLogin;

+ (void)setShouldSkipLogin:(BOOL)shouldSkipLogin;

+ (void) saveReview:(NSString*) placeTitle imageData:(NSData*) imageData params:(NSDictionary*) params WithCompletion:(void(^)(NSURLResponse * _Nullable response, id  _Nullable responseObject, NSError * _Nullable error)) completion;

+(void) saveComment: (NSString*) review_id comment:(NSString*)comment withCompletion:(void(^)(BOOL status, NSString* message)) completion;

+(void) saveParkingWithCompletion: (void (^)(BOOL status , NSString* message)) completion;

@end

NS_ASSUME_NONNULL_END