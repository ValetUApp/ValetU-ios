//
//  BaseViewController.m
//  valetu
//
//  Created by imobile on 2016-09-08.
//  Copyright © 2016 imobile. All rights reserved.
//

#import "BaseViewController.h"
#import "ProfileViewController.h"
#import "ReviewControllerViewController.h"
#import "ReturnViewController.h"
#import "MapViewController.h"

@interface BaseViewController ()<CLLocationManagerDelegate, RNGridMenuDelegate>{
    CLLocationManager *locationManager;
    NSTimer* valetuScheduleTimer;
    NSTimer* valetuReturnScheduleTimer;
}

@end

@implementation BaseViewController

@synthesize selectedRoute;
@synthesize overviewPolyline;
@synthesize totalDuration;
@synthesize totalDistance;
@synthesize ridesClient;
@synthesize builder;


//-(BOOL)prefersStatusBarHidden{
//    return YES;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ridesClient = [[UBSDKRidesClient alloc] init];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) selectMenu: (id) sender {
    [self.view endEditing:YES];

    UIImage *profileImage = [UIImage imageNamed:@"Profile"];
    
    NSArray *menuItems = @[
                           [[RNGridMenuItem alloc] initWithImage:profileImage title:@"Profile"],
                           ];
    RNGridMenu *gridMenu = [[RNGridMenu alloc] initWithItems:menuItems];
    gridMenu.delegate = self;
    [gridMenu showInViewController:self center:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2)];
    
}

//------ grid menu delgate -------------------------------------------------------------------------------------------------------------------------------------------
- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [gridMenu dismissAnimated:NO];
    if ([item.title isEqualToString:@"Profile"])    [self viewProfile];
}

- (void) viewProfile
{
    self.navigationController.navigationBarHidden = NO;
    if ([iCommon shouldSkipLogin] && [FBSDKAccessToken currentAccessToken]) {
        [ProgressHUD show:CONFIRMING_LOGIN];
        [iCommon fetchUserInfoWithCompletion:^(id result, BOOL status, NSString *message) {
            if (status) {
                [iCommon saveTokenWithCompletion:^(BOOL status, NSString * _Nonnull message) {
                    if (status) {
                        [ProgressHUD dismiss];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self goToProfileView];
                        });
                    } else {
                        [ProgressHUD showError:message];
                    }
                }];
            } else
            {
                [ProgressHUD showError:message];
            }

        }];
    } else {
//        [ProgressHUD show:FB_LOGIN_MESSAGE];
        [iCommon loginWithFB: self withCompletion:^(id  _Nonnull result, BOOL status, NSString * _Nonnull message) {
            if (!status) {
                [ProgressHUD showError:message];
            } else {
                [ProgressHUD showSuccess:message];
                [iCommon fetchUserInfoWithCompletion:^(id  _Nonnull result, BOOL status, NSString * _Nonnull message) {
                    if (status) {
                        [iCommon saveTokenWithCompletion:^(BOOL status, NSString * _Nonnull message) {
                            if (status) {
                                [ProgressHUD dismiss];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self goToProfileView];
                                });
                            } else {
                                [ProgressHUD showError:message];
                            }
                        }];
                    } else
                    {
                        [ProgressHUD showError:message];
                    }
                }];
                
            }
        }];
    }
}

- (void) goToProfileView
{
    ProfileViewController *profileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileView"];
    [self.navigationController pushViewController:profileViewController animated:YES];
}




-(void) calculateTotalDistanceAndDuration
{
    id legs = [selectedRoute[0] objectForKey:@"legs"];
    
     totalDistanceInMeters = 0;
     totalDurationInSeconds = 0;
    
    for (id leg in legs) {
        totalDistanceInMeters  += [[[[leg objectForKey:@"distance"] objectForKey:@"distance" ] objectForKey:@"value" ] intValue];
        totalDurationInSeconds += [[[[leg objectForKey:@"duration"] objectForKey:@"duration" ] objectForKey:@"value" ] intValue];
    }
    
    
    double distanceInKilometers = totalDistanceInMeters / 1000.0;
    totalDistance = [NSString stringWithFormat:@"Total Distance: %f Km", distanceInKilometers];
    
    
    NSUInteger mins = totalDurationInSeconds / 60;
    NSUInteger hours = mins / 60;
    NSUInteger days = hours / 24;
    NSUInteger remainingHours = hours % 24;
    NSUInteger remainingMins = mins % 60;
    NSUInteger remainingSecs = totalDurationInSeconds % 60;
    
    totalDuration = [NSString stringWithFormat:@"Duration: %lu d, %lu h, %lu mins, %lu secs", (unsigned long)days, (unsigned long)remainingHours, (unsigned long)remainingMins, (unsigned long)remainingSecs ];
}

- (void) getDirectionAtStart: (CLLocationCoordinate2D) startLocation toEnd: (CLLocationCoordinate2D) endLocation withCompletion:(void (^)(NSString* string, BOOL status))completionBlock
{
    CGFloat start_lat = startLocation.latitude;
    CGFloat start_lng = startLocation.longitude;
    CGFloat end_lat = endLocation.latitude;
    CGFloat end_lng = endLocation.longitude;
    
    NSString* urlForRoute = [NSString stringWithFormat:@"%@&origin=%f,%f&destination=%f,%f", DIRECTION_ROUTE_ENDPOINT, start_lat, start_lng, end_lat, end_lng];
    
    SWGETRequest *getRequest = [[SWGETRequest alloc]init];
    getRequest.responseDataType = [SWResponseJSONDataType type];
    [getRequest startDataTaskWithURL:urlForRoute parameters:nil  parentView:nil success:^(NSURLSessionDataTask *uploadTask, id responseObject) {
        NSString* status = [responseObject objectForKey:@"status"];
        if ([status isEqualToString:@"OK"]) {
            selectedRoute = [responseObject objectForKey:@"routes"];
            overviewPolyline = [selectedRoute[0] objectForKey:@"overview_polyline"];
            
            [self calculateTotalDistanceAndDuration];
            
            completionBlock(@"Success", YES);
        }
      
    } failure:^(NSURLSessionTask *uploadTask, NSError *error) {
        completionBlock(error.localizedDescription, NO);
    }];
}

- (void) getETAWithCompletion: (void (^)(NSDictionary* duration, NSString* string, BOOL status))completionBlock
{
    NSString* etaEndpoint = [NSString stringWithFormat:@"%@&origins=%f,%f&destinations=%f,%f", DISTANCE_MATRIX_ENDPOINT, [Parkinglot sharedModel].currentLocation.coordinate.latitude, [Parkinglot sharedModel].currentLocation.coordinate.longitude, [Parkinglot sharedModel].pickupLocation.coordinate.latitude, [Parkinglot sharedModel].pickupLocation.coordinate.longitude];
    
    SWGETRequest *getRequest = [[SWGETRequest alloc]init];
    getRequest.responseDataType = [SWResponseJSONDataType type];
    [getRequest startDataTaskWithURL:etaEndpoint parameters:nil  parentView:nil success:^(NSURLSessionDataTask *uploadTask, id responseObject) {
        NSString* status = [responseObject objectForKey:@"status"];
        if ([status isEqualToString:@"OK"]) {
            NSArray* rows = [responseObject objectForKey:@"rows"];
            NSArray* elements = [rows[0] objectForKey:@"elements"];
            NSDictionary* duration = [elements[0] objectForKey:@"duration"];
            
            if (duration == nil) {
                completionBlock(nil, @"Cannot calculate ETA", NO);
            } else {
                completionBlock(duration, @"Ok", YES);
            }
        } else{
           completionBlock(nil, @"Cannot calculate ETA", NO);
        }
        
    } failure:^(NSURLSessionTask *uploadTask, NSError *error) {
        completionBlock(nil, error.localizedDescription, NO);
    }];
}

- (void) fetchNearbyResult: (CLLocationCoordinate2D) location withCompletion: (void (^)(void))completionBlock
{
    NSString* lat = [NSString stringWithFormat:@"%lf", location.latitude ];
    NSString* lng = [NSString stringWithFormat:@"%lf", location.longitude ];
    NSDictionary *body = @{@"lat": lat, @"lng": lng};
    
    SWGETRequest *getRequest = [[SWGETRequest alloc]init];
    getRequest.responseDataType = [SWResponseJSONDataType type];
    [getRequest startDataTaskWithURL:WS_FETCH_NEARBY parameters:body  parentView:nil success:^(NSURLSessionDataTask *uploadTask, id responseObject) {
        //        NSLog(@"%@", responseObject);
        NSString* status = [responseObject objectForKey:@"status"];
        if ([status isEqualToString:@"Ok"]) {
            [Parkinglot sharedModel].nearbyplaces = [responseObject objectForKey:@"data"];
            if (completionBlock != nil) {
                completionBlock();
            }
        }
    } failure:^(NSURLSessionTask *uploadTask, NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void) postUberRequest:(NSDictionary*) uberData WithCompletion: (void (^)(NSDictionary* requestResponse, NSString* string, BOOL status))completionBlock
{
    NSString* authHeader = [NSString stringWithFormat:@"Bearer %@", [UBSDKTokenManager fetchToken].tokenString];
    
    SWPOSTRequest *postRequest = [[SWPOSTRequest alloc]init];
    [postRequest.request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [postRequest.request setValue:authHeader forHTTPHeaderField:@"Authorization"];
    postRequest.responseDataType = [SWResponseJSONDataType type];
    
    NSString *start_latitude = [NSString stringWithFormat:@"%f", [Parkinglot sharedModel].pickupLocation.coordinate.latitude];
    NSString *start_longitude = [NSString stringWithFormat:@"%f", [Parkinglot sharedModel].pickupLocation.coordinate.longitude];
    NSString *end_latitude = [NSString stringWithFormat:@"%f", [Parkinglot sharedModel].dropoffLocation.coordinate.latitude];
    NSString *end_longitude = [NSString stringWithFormat:@"%f", [Parkinglot sharedModel].dropoffLocation.coordinate.longitude];
    
    NSDictionary* params = @{@"start_latitude": start_latitude, @"start_longitude": start_longitude, @"end_latitude": end_latitude, @"end_longitude": end_longitude, @"product_id": [uberData objectForKey:@"product_id"]};
    
        [postRequest startDataTaskWithURL:URL_UBER_SANDBOX_REQUESTS parameters:params parentView:nil cachedData:^(NSCachedURLResponse *response, id responseObject) {
            NSLog(@"%@", responseObject);
        } success:^(NSURLSessionDataTask *uploadTask, id responseObject) {
            NSLog(@"%@", responseObject);
            completionBlock(responseObject, @"Ok", YES);
        } failure:^(NSURLSessionTask *uploadTask, NSError *error) {
            NSLog(@"%@", error);
            completionBlock(nil, error.localizedDescription, NO);
        }];
}

- (UIImage*) drawMarkerImage: (NSString*) estimate
{
    UIImage *image = [UIImage imageNamed:@"popupPakPrice"];
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    NSString *txt = estimate;
    UIColor *txtColor = [UIColor whiteColor];
    UIFont *titleFont = [UIFont fontWithName:@"Roboto-Bold" size:14];
    NSDictionary *attributes = @{NSFontAttributeName:titleFont, NSForegroundColorAttributeName:txtColor};
    
    CGRect txtRect = [txt boundingRectWithSize:CGSizeZero
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:attributes
                                       context:nil];
    
    [txt drawAtPoint:CGPointMake((image.size.width+14)/2 - txtRect.size.width/2, 2) withAttributes:attributes];
    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImg;
}

-(void) drawRoute: (GMSMapView*) mapView
{
    NSString* route =[self.overviewPolyline objectForKey:@"points"];
    
    GMSPath* path = [GMSPath pathFromEncodedPath:route];
    self.routePolyline = [GMSPolyline polylineWithPath:path];
    self.routePolyline.geodesic = YES;
    self.routePolyline.strokeWidth = 2.f;
    self.routePolyline.strokeColor = [UIColor redColor];
    self.routePolyline.map = nil;
    self.routePolyline.map = mapView;
}

- (void) showRoute: (CLLocationCoordinate2D) pickup_location dropOff: (CLLocationCoordinate2D) dropoff_location withMap: (GMSMapView*) mapView
{
    [self getDirectionAtStart:pickup_location toEnd:dropoff_location withCompletion:^(NSString *string, BOOL status) {
        if (status) {
            [self drawRoute: mapView];
        }
    }];
}



@end
