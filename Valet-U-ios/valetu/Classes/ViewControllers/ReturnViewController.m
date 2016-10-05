//
//  ReturnViewController.m
//  valetu
//
//  Created by imobile on 2016-09-19.
//  Copyright © 2016 imobile. All rights reserved.
//

#import "ReturnViewController.h"


@interface ReturnViewController ()<CLLocationManagerDelegate, GMSMapViewDelegate, UBSDKModalViewControllerDelegate>
{
   __block UIButton *btnRideRequest;
    CLLocationManager *locationManager;
    __block GMSMarker* myMarker;
    NSMutableSet *lotMarkerSet;
    CGSize size;
}
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *estimateLabel;
@property (weak, nonatomic) IBOutlet UILabel *pickupTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *returntocarButton;

@end

@implementation ReturnViewController
@synthesize builder;
@synthesize ridesClient;
@synthesize width;
@synthesize height;

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    size  = self.view.frame.size;
    self.title = @"Return";
    self.contentSizeInPopup = CGSizeMake(size.width - 32, size.height - 108);
    self.landscapeContentSizeInPopup = CGSizeMake(450, 300);
    self.navigationController.navigationBarHidden = YES;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.popupController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self applyGradient];
    
    self.mapView.delegate = self;
    self.didFindMyLocation = NO;
    
    [self.mapView addObserver:self forKeyPath:@"myLocation" options:NSKeyValueObservingOptionNew context:nil];
    
    [self updateRideRequest];
    
    self.returntocarButton.layer.cornerRadius = 4;
    self.returntocarButton.clipsToBounds = YES;
    
    CLLocationCoordinate2D pickuplocation = [Parkinglot sharedModel].dropoffLocation.coordinate;
    CLLocationCoordinate2D dropofflocation = [Parkinglot sharedModel].pickupLocation.coordinate;
    
    self.mapView.camera = [GMSCameraPosition cameraWithTarget: pickuplocation zoom:11 bearing:0 viewingAngle:0];
    [self.mapView setMinZoom:3 maxZoom:20];
    
    GMSMarker*  pickupMarker = [GMSMarker markerWithPosition:pickuplocation];
    pickupMarker.map = self.mapView;
    GMSMarker*  dropoffMarker = [GMSMarker markerWithPosition:dropofflocation];
    dropoffMarker.map = self.mapView;
    
    pickupMarker.iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"badgeActive.png"]];
    dropoffMarker.iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icPlace.png"]];
    
    NSDictionary* parkinglot = [Parkinglot getParkinglot:[Parkinglot sharedModel].selectedLocationId];
    self.estimateLabel.text = [parkinglot objectForKey:@"estimate"];

    [self showRoute:pickuplocation dropOff:dropofflocation withMap:self.mapView];
    
   
}

- (void) applyGradient
{
    // gradient effect at the top
    UIView *upperView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.mapView.frame.size.width, 71.0f)];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = upperView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:255 green:255 blue:255 alpha:1] CGColor], (id)[[UIColor colorWithRed:255 green:255 blue:255 alpha:0] CGColor], nil];
    [upperView.layer insertSublayer:gradient atIndex:0];
    [self.mapView addSubview:upperView];
    
    // gradient effect at the bottom
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.mapView.frame.size.height-56, self.view.frame.size.width, 56)];
    CAGradientLayer *bottomGradient = [CAGradientLayer layer];
    bottomGradient.frame = bottomView.bounds;
    bottomGradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:255 green:255 blue:255 alpha:0] CGColor], (id)[[UIColor colorWithRed:255 green:255 blue:255 alpha:0.8] CGColor], nil];
    [bottomView.layer insertSublayer:bottomGradient atIndex:0];
    [self.mapView addSubview:bottomView];
}

- (void) updateRideRequest
{
    [iCommon getUberETAWithCompletion:[Parkinglot sharedModel].dropoffLocation completion:^(NSDictionary *uberData, NSString *string, BOOL status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger estimate = [[uberData objectForKey:@"estimate"] integerValue];
            NSInteger m = (estimate / 60) % 60;
            self.pickupTimeLabel.text = [NSString stringWithFormat:@"PICK UP TIME IS APPROXIMATELY %lu MINS", (long)m];
        });
    }];
}

- (void) _tapReturn
{
    builder = [[UBSDKRideParametersBuilder alloc] init];
    [builder setPickupLocation:[Parkinglot sharedModel].dropoffLocation];
    [builder setDropoffLocation:[Parkinglot sharedModel].pickupLocation];
    //  [builder setPickupLocation:location];
    UBSDKRideParameters *parameters = [builder build];
    
    // Setting up a RideRequestViewController
    UBSDKLoginManager *loginManager = [[UBSDKLoginManager alloc] init];
    UBSDKRideRequestViewController *rideRequestViewController = [[UBSDKRideRequestViewController alloc] initWithRideParameters:parameters loginManager:loginManager];
    
    self.popupController.navigationBarHidden = NO;
    self.navigationController.navigationBarHidden = NO;
    [STPopupNavigationBar appearance].barTintColor = [UIColor blackColor];
    [STPopupNavigationBar appearance].tintColor = [UIColor whiteColor];
    [STPopupNavigationBar appearance].barStyle = UIBarStyleDefault;
    [STPopupNavigationBar appearance].titleTextAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Bold" size:20],
                                                               NSForegroundColorAttributeName: [UIColor whiteColor] };
    
    [[UIBarButtonItem appearanceWhenContainedIn:[STPopupNavigationBar class], nil] setTitleTextAttributes:@{ NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-Bold" size:20] } forState:UIControlStateNormal];
    
    
    rideRequestViewController.contentSizeInPopup = CGSizeMake(size.width, size.height-66);
    rideRequestViewController.title = @"Return to Car";
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:rideRequestViewController];
    popupController.transitionStyle = STPopupTransitionStyleFade;
    [self.popupController.backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundViewDidTap)]];
    [popupController presentInViewController:self];
}

- (IBAction)didTapReturn:(id)sender
{
    if ([iCommon shouldSkipLogin] || [FBSDKAccessToken currentAccessToken]) {
        [ProgressHUD show:CONFIRMING_LOGIN];
        [iCommon fetchUserInfoWithCompletion:^(id result, BOOL status, NSString *message) {
            if (status) {
                [iCommon saveParkingWithCompletion:^(BOOL status, NSString * _Nonnull message) {
                    if (status) {
                        [ProgressHUD dismiss];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self _tapReturn];
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
                [iCommon fetchUserInfoWithCompletion:^(id result, BOOL status, NSString *message) {
                    if (status) {
                        [iCommon saveParkingWithCompletion:^(BOOL status, NSString * _Nonnull message) {
                            if (status) {
                                [ProgressHUD dismiss];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self _tapReturn];
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

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.mapView.padding = UIEdgeInsetsMake(60, 0, 160, 0);
}

- (void) backgroundViewDidTap
{
    [self.popupController popViewControllerAnimated:YES]; // Popup will be dismissed if there is only one view controller in the popup view controller stack
}

- (IBAction)didTapClose:(id)sender {
    [self.popupController dismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - <UBSDKModalViewControllerDelegate>

- (void)modalViewControllerDidDismiss:(UBSDKModalViewController *)modalViewController {
    NSLog(@"did dismiss");
}

- (void)modalViewControllerWillDismiss:(UBSDKModalViewController *)modalViewController {
    NSLog(@"will dismiss");
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
