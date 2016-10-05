//
//  iCommon.m
//  valetu
//
//  Created by imobile on 2016-09-23.
//  Copyright © 2016 imobile. All rights reserved.
//

#import "iCommon.h"
#import "ProfileViewController.h"

@implementation iCommon

+ (void) getUberETAWithCompletion: (CLLocation*) pickupLocation completion:  (void (^)(NSDictionary* uberData, NSString* string, BOOL status))completionBlock
{
    NSString *start_latitude = [NSString stringWithFormat:@"%f", pickupLocation.coordinate.latitude];
    NSString *start_longitude = [NSString stringWithFormat:@"%f", pickupLocation.coordinate.longitude];
    
    NSDictionary *params = @{@"start_latitude": start_latitude, @"start_longitude": start_longitude};
    
    SWGETRequest *getRequest = [[SWGETRequest alloc]init];
    getRequest.responseDataType = [SWResponseJSONDataType type];
    [getRequest startDataTaskWithURL:URL_UBER_ETA parameters:params  parentView:nil success:^(NSURLSessionDataTask *uploadTask, id responseObject) {
        NSArray* times = [responseObject objectForKey:@"times"];
        if (times != nil) {
            BOOL isAvaialbleUberX = NO;
            for (NSDictionary* uberData in times) {
                if ([[uberData objectForKey:@"display_name"] isEqualToString:@"uberX"]) {
                    completionBlock(uberData, @"Ok", YES);
                    isAvaialbleUberX = YES;
                    break;
                }
            }
            if (!isAvaialbleUberX) {
                completionBlock(nil, @"There is no available UberX", YES);
            }
        } else{
            completionBlock(nil, @"There is no available UberX", NO);
        }
        
    } failure:^(NSURLSessionTask *uploadTask, NSError *error) {
        completionBlock(nil, error.localizedDescription, NO);
    }];
}

+(void) loginWithFB:(UIViewController*) viewController  withCompletion: (void (^)(id result, BOOL status , NSString* message)) completion
{
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logOut];
        [FBSDKAccessToken setCurrentAccessToken:nil];
        [login logInWithReadPermissions:@[@"email", @"public_profile"]
                     fromViewController:viewController
                                handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                    [ProgressHUD dismiss];
                                    if (error || result.isCancelled) {
                                        completion(result, NO, error.localizedDescription);
                                    } else {
                                        
                                        [FBSDKAccessToken setCurrentAccessToken:result.token];

                                        [iCommon setShouldSkipLogin:YES];
                                        [VUser sharedModel].profileId = [FBSDKAccessToken currentAccessToken].userID;
                                        completion(result, YES, nil);
                                    }
                                }];
    
}

+ (void)fetchUserInfoWithCompletion: (void (^)(id result, BOOL status, NSString* message)) completion
{
    if ([FBSDKAccessToken currentAccessToken])
    {
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name, email"}];
        [request setGraphErrorRecoveryDisabled:YES];
        [ request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error)
             {
                 NSLog(@"resultis:%@",result);
                 [VUser sharedModel].userProfile = result;
                 [VUser sharedModel].username = [result objectForKey:@"name"];
                 [VUser sharedModel].email = [result objectForKey:@"email"];
                 [VUser sharedModel].username = [result objectForKey:@"name"];
                 NSString *token = [NSString stringWithFormat:@"%@", [FBSDKAccessToken currentAccessToken].userID];
                 [VUser sharedModel].profileId = token;
                 completion(nil, YES, @"Ok");
             }
             else
             {
                 NSLog(@"Error %@",error);
                 completion(nil, NO, error.localizedDescription);
             }
         }];
    } else {
        completion(nil, NO, nil);
    }
}

+(void) saveTokenWithCompletion: (void (^)(BOOL status , NSString* message)) completion
{
    NSDictionary* params = @{@"name": [VUser sharedModel].username, @"email": [VUser sharedModel].email, @"token": [FBSDKAccessToken currentAccessToken].userID};
    
    SWPOSTRequest *postRequest = [[SWPOSTRequest alloc] init];
    postRequest.responseDataType = [SWResponseJSONDataType type];
    
    //need to crate files array to upload
    
    [postRequest startDataTaskWithURL:WS_LOGIN parameters:params parentView:nil cachedData:^(NSCachedURLResponse *response, id responseObject) {
        NSLog(@"%@", responseObject);
    } success:^(NSURLSessionDataTask *uploadTask, id responseObject) {
        NSLog(@"%@", responseObject);
        if ([[responseObject objectForKey:@"status"] isEqualToString:@"Ok"]) {
            
            [VUser sharedModel].lastReview = [responseObject objectForKey:@"lastReview"];
            [VUser sharedModel].lastParking = [responseObject objectForKey:@"lastParking"];
            [VUser sharedModel].numberOfParkings = [responseObject objectForKey:@"numberOfParking"];
            [VUser sharedModel].numberOfReviews = [responseObject objectForKey:@"numberOfReviews"];
            completion(YES, SUCCESS);
        } else
        {
            completion(NO, ERROR_LOGIN);
        }
       
    } failure:^(NSURLSessionTask *uploadTask, NSError *error) {
        NSLog(@"%@", error);
        completion(NO, error.localizedDescription);
    }];
}

+ (void) startNavigation
{
    //update user state
    [Parkinglot sharedModel].userState = kUserStartNavigation;
    if ([[UIApplication sharedApplication]
         canOpenURL:[NSURL URLWithString:@"waze://"]]) {
        
        // Waze is installed. Launch Waze and start navigation
        NSString *urlStr = [NSString stringWithFormat:@"waze://?ll=%f,%f&navigate=yes",
         [Parkinglot sharedModel].pickupLocation.coordinate.latitude, [Parkinglot sharedModel].pickupLocation.coordinate.longitude];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
        
    } else {
        // Waze is not installed. Launch AppStore to install Waze app
        [[UIApplication sharedApplication] openURL:[NSURL
                                                    URLWithString:@"https://itunes.apple.com/us/app/id323229106"]];
    }
}

+ (BOOL)shouldSkipLogin
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kShouldSkipLoginKey];
}

+ (void)setShouldSkipLogin:(BOOL)shouldSkipLogin
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:shouldSkipLogin forKey:kShouldSkipLoginKey];
    [defaults synchronize];
}

+ (void) saveReview:(NSString*) placeTitle imageData:(NSData*) imageData params:(NSDictionary*) params WithCompletion:(void (^)(NSURLResponse * _Nullable response, id  _Nullable responseObject, NSError * _Nullable error)) completion
{
    NSString *streetview = [NSString stringWithFormat:@"%@.jpeg", placeTitle];
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:WS_UPLOAD_REVIEW parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"fileToUpload" fileName:streetview mimeType:@"image/jpeg"];
    } error:nil];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:^(NSProgress * _Nonnull uploadProgress) {
                      // This is not called back on the main queue.
                      // You are responsible for dispatching to the main queue for UI updates
                      dispatch_async(dispatch_get_main_queue(), ^{
                          //Update the progress view
                          //  [progressView setProgress:uploadProgress.fractionCompleted];
                          NSLog(@"progress %f", uploadProgress.fractionCompleted);
                      });
                  }
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      completion(response, responseObject, error);
                  }];
    
    [uploadTask resume];
    

}

+(void) saveComment:(NSString*) review_id comment:(NSString*)comment withCompletion:(void(^)(BOOL status, NSString* message)) completion
{
    NSDictionary* params = @{@"user_id": [VUser sharedModel].userId, @"trip_id": review_id, @"comment": comment};
    
    SWPOSTRequest *postRequest = [[SWPOSTRequest alloc] init];
    postRequest.responseDataType = [SWResponseJSONDataType type];
    
    //need to crate files array to upload
    [postRequest startDataTaskWithURL:WS_SAVE_COMMENT parameters:params parentView:nil cachedData:^(NSCachedURLResponse *response, id responseObject) {
        NSLog(@"%@", responseObject);
    } success:^(NSURLSessionDataTask *uploadTask, id responseObject) {
        NSLog(@"%@", responseObject);
        if ([[responseObject objectForKey:@"status"] isEqualToString:@"Ok"]) {
            completion(YES, SUCCESS);
        } else {
            completion(NO, ERROR_LOGIN);
        }
    } failure:^(NSURLSessionTask *uploadTask, NSError *error) {
        NSLog(@"%@", error);
        completion(NO, error.localizedDescription);
    }];
}

+(void) saveParkingWithCompletion:  (void (^)(BOOL status , NSString* message)) completion
{
//    completion(true, @"Ok");
    NSDictionary* parkinglot = [Parkinglot getParkinglot:[Parkinglot sharedModel].selectedLocationId];
    NSString *parkinglot_id = [parkinglot objectForKey:@"id"];
    NSDictionary* params = @{@"parkinglot_id": parkinglot_id, @"token": [VUser sharedModel].profileId};
    
    NSLog(@"%@", [Parkinglot sharedModel].placeImage);
    
    NSString *streetview = @"filename";
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:WS_SAVE_PARKING parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:(NSData*)[Parkinglot sharedModel].placeImage name:@"fileToUpload" fileName:streetview mimeType:@"image/jpeg"];
    } error:nil];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:^(NSProgress * _Nonnull uploadProgress) {
                      // This is not called back on the main queue.
                      // You are responsible for dispatching to the main queue for UI updates
                      dispatch_async(dispatch_get_main_queue(), ^{
                          //Update the progress view
                          //  [progressView setProgress:uploadProgress.fractionCompleted];
                          NSLog(@"progress %f", uploadProgress.fractionCompleted);
                      });
                  }
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      completion(true, @"Ok");
                  }];
    
    [uploadTask resume];
}



@end
