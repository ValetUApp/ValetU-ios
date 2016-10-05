	//
//  MapViewController.m
//  valetu
//
//  Created by imobile on 2016-09-08.
//  Copyright © 2016 imobile. All rights reserved.
//

#import "MapViewController.h"
#import "DetailViewController.h"

@interface MapViewController ()<CLLocationManagerDelegate, GMSMapViewDelegate, PlaceSearchTextFieldDelegate, UITextFieldDelegate, EAIntroDelegate>
{
    CLLocationManager *locationManager;
    GMSMarker* myMarker;
    GMSMarker* selectedMarker;
    NSMutableSet *lotMarkerSet;
    
    UIButton *btnNav;
    UIButton *btnReturntoCar;

    BOOL isNavigationStart;
    __block  UBSDKRideRequestButton  *btnRideRequest;
    
    UIView *rootView;
    EAIntroView *_intro;
    
    BOOL isDetailViewShown;
}

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet MVPlaceSearchTextField *inputDest;
@property (weak, nonatomic) IBOutlet UIView *detailView;
@property (weak, nonatomic) IBOutlet UILabel *detailTitle;
@property (weak, nonatomic) IBOutlet UILabel *detailEST;
@property (weak, nonatomic) IBOutlet UIImageView *detailImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailviewBottomConstraint;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *starView;
@property (weak, nonatomic) IBOutlet UILabel *starValue;
@property (weak, nonatomic) IBOutlet UILabel *detailDistance;
@property (weak, nonatomic) IBOutlet UILabel *detailETA;
@property (weak, nonatomic) IBOutlet UILabel *pickuptime;
@property (weak, nonatomic) IBOutlet UIButton *btnViewmore;

@end

@implementation MapViewController
@synthesize ridesClient;
@synthesize builder;

- (void) setupDefault
{
    [self applyEffect];
    
    [self initView];
    [self initInputDestAfterViewAppear];
    [self setupFloatingButtons];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupDefault];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    NSUserDefaults* defaultUser = [NSUserDefaults standardUserDefaults];
    BOOL isFirstLaunch = [defaultUser boolForKey:@"First"];
    if (!isFirstLaunch) {
        [self showIntroView];
    } else
    {
        [self startStandardUpdates];
    }
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.navigationController.navigationBarHidden = YES;
    self.mapView.padding = UIEdgeInsetsMake(60, 0, 160, 0);
}

- (void) initView
{
    isDetailViewShown = YES;
    
    self.mapView.delegate = self;
    self.didFindMyLocation = NO;
    
    ridesClient = [[UBSDKRidesClient alloc] init];
    
    [self.mapView addObserver:self forKeyPath:@"myLocation" options:NSKeyValueObservingOptionNew context:nil];
    
    self.detailImage.layer.cornerRadius = 4;
    self.detailImage.clipsToBounds = YES;
    self.btnViewmore.layer.cornerRadius = 4;
    self.btnViewmore.clipsToBounds = YES;
    
    CALayer *maskLayer = [CALayer layer];
    maskLayer.frame = self.view.frame;
    maskLayer.shadowRadius = 5;
    maskLayer.shadowPath = CGPathCreateWithRoundedRect(CGRectInset(self.view.frame, 0, 20), 10, 10, nil);
    maskLayer.shadowOpacity = 1;
    maskLayer.shadowOffset = CGSizeZero;
    maskLayer.shadowColor = [UIColor whiteColor].CGColor;
    
    self.detailView.layer.mask = maskLayer;
}

- (void)applyEffect
{
    // gradient effect at the top
    UIView *upperView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.mapView.frame.size.width, 160.0f)];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = upperView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:255 green:255 blue:255 alpha:0.5] CGColor], (id)[[UIColor colorWithRed:255 green:255 blue:255 alpha:0] CGColor], nil];
    [upperView.layer insertSublayer:gradient atIndex:0];
    [self.mapView addSubview:upperView];
    
    // gradient effect at the bottom
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height-140, self.view.frame.size.width, 140)];
    CAGradientLayer *bottomGradient = [CAGradientLayer layer];
    bottomGradient.frame = bottomView.bounds;
    bottomGradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:255 green:255 blue:255 alpha:0] CGColor], (id)[[UIColor colorWithRed:255 green:255 blue:255 alpha:1] CGColor], nil];
    [bottomView.layer insertSublayer:bottomGradient atIndex:0];
    [self.mapView addSubview:bottomView];
}

- (void) drawCircle: (CGPoint) point
{
    // Circle effect around the dropoff marker
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    [circleLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(point.x-56, point.y-56, 112, 112)] CGPath]];
    [circleLayer setStrokeColor:[[UIColor colorWithRed:255 green:255 blue:255 alpha:0.3] CGColor]];
//    [circleLayer setStrokeColor:[[UIColor redColor] CGColor]];
    [circleLayer setLineWidth:28.0f];
    [circleLayer setFillColor:[[UIColor clearColor] CGColor]];
    [[self.mapView layer] addSublayer:circleLayer];
}

- (void) showIntroView
{
    EAIntroPage *page1 = [EAIntroPage pageWithCustomViewFromNibNamed:@"FirstIntro"];
    EAIntroPage *page2 = [EAIntroPage pageWithCustomViewFromNibNamed:@"SecondIntro"];
    EAIntroPage *page3 = [EAIntroPage pageWithCustomViewFromNibNamed:@"ThirdIntro"];
    EAIntroPage *page4 = [EAIntroPage pageWithCustomViewFromNibNamed:@"ForthIntro"];
  
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1,page2,page3,page4]];
    SMPageControl *pageControl = [[SMPageControl alloc] init];
     CGFloat originY = intro.pageControlY;
    pageControl.enabled = NO;
    pageControl.pageIndicatorImage = [UIImage imageNamed:@"badgeNormal"];
    pageControl.currentPageIndicatorImage = [UIImage imageNamed:@"badgeActive"];
    [pageControl sizeToFit];
    intro.pageControl = (UIPageControl *)pageControl;
    
    intro.pageControlY = originY;
    
    [intro setDelegate:self];
    intro.tapToNext = YES;
    intro.skipButton.hidden = YES;
    intro.limitPageIndex = 3;
    page4.onPageDidAppear = ^{
        intro.scrollView.scrollEnabled = NO;
    //    intro.scrollView.restrictionArea = CGRectZero;
    };
    
    page4.onPageDidDisappear = ^{
        intro.scrollView.scrollEnabled = YES;
    //    intro.scrollView.restrictionArea = CGRectZero;
    };
    
    page3.onPageDidLoad = ^{
        intro.scrollView.scrollEnabled = YES;
    };
    
    UIButton *skipButton1 = (UIButton *)[page1.pageView viewWithTag:10];
    [skipButton1 addTarget:self action:@selector(skipIntro:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *skipButton2 = (UIButton *)[page2.pageView viewWithTag:12];
    [skipButton2 addTarget:self action:@selector(skipIntro:) forControlEvents:UIControlEventTouchDown];
    
    UIButton *skipButton3 = (UIButton *)[page3.pageView viewWithTag:14];
    [skipButton3 addTarget:self action:@selector(skipIntro:) forControlEvents:UIControlEventTouchDown];
    
    UIButton *nextButton1 = (UIButton *)[page1.pageView viewWithTag:11];
    [nextButton1 addTarget:self action:@selector(tapToNext:) forControlEvents:UIControlEventTouchDown];
    
    UIButton *nextButton2 = (UIButton *)[page2.pageView viewWithTag:13];
    [nextButton2 addTarget:self action:@selector(tapToNext:) forControlEvents:UIControlEventTouchDown];
    
    UIButton *nextButton3 = (UIButton *)[page3.pageView viewWithTag:15];
    [nextButton3 addTarget:self action:@selector(tapToNext:) forControlEvents:UIControlEventTouchDown];
    
    
    UIButton *prevButton4 = (UIButton *)[page4.pageView viewWithTag:16];
    [prevButton4 addTarget:self action:@selector(tapToPrev:) forControlEvents:UIControlEventTouchDown];
    
    UIButton *startButton4 = (UIButton *)[page4.pageView viewWithTag:17];
    [startButton4 addTarget:self action:@selector(skipIntro:) forControlEvents:UIControlEventTouchDown];
    [intro showInView:self.view animateDuration:0.3];
    _intro = intro;
}

- (IBAction) skipIntro: (id) sender
{
    [_intro skipIntroduction];
}

- (IBAction) tapToNext: (id) sender
{
    [_intro goToNext:nil];
}

- (IBAction) tapToPrev: (id) sender
{
    [_intro goToPrev:nil];
}

#pragma mark - EAIntroView delegate

- (void)introDidFinish:(EAIntroView *)introView wasSkipped:(BOOL)wasSkipped{
    NSLog(@"introDidFinish callback");
     NSUserDefaults* defaultUser = [NSUserDefaults standardUserDefaults];
    [defaultUser setBool:YES forKey:@"First"];
    [defaultUser synchronize];
    
    [self startStandardUpdates];
}

#pragma mark - <UBSDKModalViewControllerDelegate>

- (void)modalViewControllerDidDismiss:(UBSDKModalViewController *)modalViewController {
    NSLog(@"did dismiss");
}

- (void)modalViewControllerWillDismiss:(UBSDKModalViewController *)modalViewController {
    NSLog(@"will dismiss");
}

- (void) updateRideRequestButton
{
    [builder setPickupLocation:[Parkinglot sharedModel].pickupLocation];
    [builder setDropoffLocation:[Parkinglot sharedModel].dropoffLocation];
    
    UBSDKRideParameters *parameters = [builder build];
    
    [btnRideRequest setRideParameters:parameters];
    
    [iCommon getUberETAWithCompletion:[Parkinglot sharedModel].pickupLocation completion:^(NSDictionary *uberData, NSString *string, BOOL status) {
        NSInteger estimate = [[uberData objectForKey:@"estimate"] integerValue];
        NSUInteger m = (estimate / 60) % 60;
        //       NSUInteger s = estimate % 60;
        
        NSString* title = [NSString stringWithFormat:@"PICK UP TIME IS APPROXIMATELY %lu MINS", (unsigned long)m];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.pickuptime.text = title;
        });
    }];
}

- (void) initInputDestAfterViewAppear
{
    UIView *vwContainer = [[UIView alloc] init];
    [vwContainer setFrame:CGRectMake(0.0f, 0.0f, 50.0f, 45.0f)];
    [vwContainer setBackgroundColor:[UIColor clearColor]];
    
    UIImageView *icon = [[UIImageView alloc] init];
    [icon setImage:[UIImage imageNamed:@"icPlaceSmallRed.png"]];
    
    [vwContainer addSubview:icon];
    
    [icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(16));
        make.top.equalTo(@(13));
        make.width.equalTo(@(12));
        make.width.equalTo(@(18));
    }];
    
    //Optional Properties
    self.inputDest.leftViewMode = UITextFieldViewModeAlways;
    self.inputDest.leftView = vwContainer;
    [self.inputDest invalidateIntrinsicContentSize];
    self.inputDest.layer.cornerRadius = 8;
    self.inputDest.clipsToBounds = YES;
  //  self.inputDest.clearsOnBeginEditing = NO;
    
    self.inputDest.attributedPlaceholder = [[NSMutableAttributedString alloc] initWithString:@"Where do you want to park?" attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor], NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-DemiBold" size:14]}];
    self.inputDest.placeSearchDelegate                 = self;
    self.inputDest.strApiKey                           = @"AIzaSyCDi2dklT-95tEHqYoE7Tklwzn3eJP-MtM";
    self.inputDest.superViewOfList                     = self.view;  // View, on which Autocompletion list should be appeared.
    self.inputDest.maximumNumberOfAutoCompleteRows     = 5;
    self.inputDest.autoCompleteRegularFontName =  @"AvenirNext-Regular";
    self.inputDest.autoCompleteBoldFontName = @"AvenirNext-DemiBold";
    self.inputDest.autoCompleteTableCornerRadius=8.0;
    self.inputDest.autoCompleteRowHeight = 50;
    self.inputDest.autoCompleteTableCellTextColor=[UIColor colorWithWhite:0.131 alpha:1.000];
    self.inputDest.autoCompleteFontSize = 14;
    self.inputDest.autoCompleteTableBorderWidth = 0.0;
    self.inputDest.showTextFieldDropShadowWhenAutoCompleteTableIsOpen=YES;
    self.inputDest.autoCompleteShouldHideOnSelection=NO;
    self.inputDest.autoCompleteShouldHideClosingKeyboard=YES;
    self.inputDest.autoCompleteShouldSelectOnExactMatchAutomatically = YES;
    self.inputDest.autoCompleteTableFrame = CGRectMake(16, 88, self.inputDest.frame.size.width, 250.0);
}

- (IBAction)showMenu:(id) sender
{
    [self selectMenu: sender];
}

- (void)startStandardUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    
    if ([locationManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)]) {
        [locationManager setAllowsBackgroundLocationUpdates:YES];
    }
    
    // Set a movement threshold for new events.
    locationManager.distanceFilter = kCLLocationAccuracyBestForNavigation; // meters
    [locationManager requestAlwaysAuthorization];
}

#pragma mark - location manager

- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        self.mapView.myLocationEnabled = true;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    CLLocation* myLocation  = change[NSKeyValueChangeNewKey];
    [Parkinglot sharedModel].currentLocation = myLocation;
    
    if (!self.didFindMyLocation) {
        self.mapView.camera = [GMSCameraPosition cameraWithTarget:myLocation.coordinate  zoom:11 bearing:0 viewingAngle:0];
        
        self.mapView.settings.myLocationButton = true;
        self.mapView.settings.compassButton = YES;
        
        [self.mapView setMinZoom:3 maxZoom:20];
        
        self.didFindMyLocation = true;
        [self addCurrentMarker];
        [self loadViewIfNeeded];
    }
}

- (void) addCurrentMarker
{
    myMarker = [GMSMarker markerWithPosition:[Parkinglot sharedModel].currentLocation.coordinate];
    myMarker.flat = YES;
    myMarker.tracksViewChanges = YES;
    myMarker.appearAnimation = kGMSMarkerAnimationPop;
    myMarker.iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icPlace.png"]];
    myMarker.map = self.mapView;

}

- (GMSMarker*) createMarker: (NSInteger) i
{
    NSString* locationId = [[Parkinglot sharedModel].nearbyplaces[i] objectForKey:@"id"];
    NSString* estimate = [[Parkinglot sharedModel].nearbyplaces[i] objectForKey:@"estimate"];
    NSString* title = [[Parkinglot sharedModel].nearbyplaces[i] objectForKey:@"address"];
    CLLocationDegrees lat = [[[Parkinglot sharedModel].nearbyplaces[i] objectForKey:@"latitude"] doubleValue];
    CLLocationDegrees lng = [[[Parkinglot sharedModel].nearbyplaces[i] objectForKey:@"longitude"] doubleValue];
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(lat, lng);
    
    UIImage* resultImg = [self drawMarkerImage: estimate];
    
    GMSMarker *marker = [GMSMarker markerWithPosition:position];
     marker.userData = @{@"id": locationId, @"lat":[NSString stringWithFormat:@"%lf", position.latitude], @"lng": [NSString stringWithFormat:@"%lf", position.longitude], @"type": @"nearby", @"title": title};
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.iconView = [[UIImageView alloc] initWithImage:resultImg];
    marker.map = self.mapView;
    marker.flat = YES;
    [lotMarkerSet addObject:marker];
    return marker;
}

- (void) resetPlaceMarkers
{
    if (lotMarkerSet != nil && [lotMarkerSet count] > 1) {
        for (GMSMarker* marker in lotMarkerSet) {
            marker.map = nil;
        }
    }
}

- (void) createMultipleMarkers
{
    [self resetPlaceMarkers];
    
    NSUInteger cnt = [[Parkinglot sharedModel].nearbyplaces count];
    lotMarkerSet = [[NSMutableSet alloc] initWithCapacity:cnt];
    for (int i = 0; i < cnt; i++) {
        [self createMarker: i];
    }
}

- (void) updateDestMarker: (CLLocationCoordinate2D) position
{
    myMarker.position = position;
    myMarker.map = self.mapView;
}

- (void) setupFloatingButtons
{
    btnNav = [UIButton buttonWithType:UIButtonTypeCustom];
    btnNav.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [btnNav setBackgroundImage:[UIImage imageNamed:@"icNavigation.png"] forState:UIControlStateNormal];
    [btnNav addTarget:self action:@selector(didTapNavigation) forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:btnNav];
    btnNav.alpha = 0;
     btnNav.frame = CGRectMake(16, 116, 30.9, 30.9);
    
    btnReturntoCar = [UIButton buttonWithType:UIButtonTypeCustom];
    btnReturntoCar.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [btnReturntoCar setBackgroundImage:[UIImage imageNamed:@"icReturnToCar.png"] forState:UIControlStateNormal];
    [btnReturntoCar addTarget:self action:@selector(didTapReturntoCar) forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:btnReturntoCar];
    btnReturntoCar.alpha = 0;
    btnReturntoCar.frame = CGRectMake(86, 116, 30.9, 30.9);
}

- (void) updateFloatingButtons
{
    CGPoint point = [self.mapView.projection pointForCoordinate:selectedMarker.position];
    btnReturntoCar.alpha = 1;
    btnNav.alpha = 1;
    CGPoint btnNavPos = CGPointMake(point.x - 89, point.y-48);
    CGPoint btnReturnPos = CGPointMake(point.x + 57, point.y-48);
    btnNav.frame = CGRectMake(btnNavPos.x, btnNavPos.y, 30.9, 30.9);
    btnReturntoCar.frame = CGRectMake(btnReturnPos.x, btnReturnPos.y, 30.9, 30.9);
}

- (void) didTapNavigation
{
    [iCommon startNavigation];
}

- (void) didTapReturntoCar
{
    [Parkinglot sharedModel].userState = kParkinglotReview;
    
    ReturnViewController* returnViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ReturnView"];
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:returnViewController];
    popupController.transitionStyle = STPopupTransitionStyleFade;;
    popupController.containerView.layer.cornerRadius = 4;
    popupController.containerView.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
    popupController.containerView.layer.shadowOffset = CGSizeMake(4, 4);
    popupController.containerView.layer.shadowOpacity = 1;
    popupController.containerView.layer.shadowRadius = 1.0;
    if (NSClassFromString(@"UIBlurEffect")) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        popupController.backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    }
    [popupController.backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundViewDidTap)]];
    [popupController presentInViewController:self];

}

- (void) backgroundViewDidTap
{
    [self.popupController dismiss];
}

#pragma mark - GMSMapViewDelegate

- (void) mapView:		(GMSMapView *) 	mapView
didTapAtCoordinate:		(CLLocationCoordinate2D) 	coordinate
{
 //   [self showDetailView];
        [self.view endEditing:YES];
}

- (BOOL) mapView:		(GMSMapView *) 	mapView
    didTapMarker:		(GMSMarker *) 	marker
{
    NSString* type = [marker.userData objectForKey:@"type"];
    if (type == nil) {
        return NO;
    }
    else if ([type isEqualToString:@"nearby"])
    {
        //update user state
        [Parkinglot sharedModel].userState = kUserSelectParkinglot;
        
        [Parkinglot sharedModel].selectedLocationId = [[marker.userData objectForKey:@"id"] integerValue];
        selectedMarker = marker;
        
        CLLocationDegrees latitide = [[marker.userData objectForKey:@"lat"] doubleValue];
        CLLocationDegrees longitude = [[marker.userData objectForKey:@"lng"] doubleValue];
//        CLLocationCoordinate2D pickup_location = CLLocationCoordinate2DMake(latitide, longitude);
        [Parkinglot sharedModel].pickupLocation = [[CLLocation alloc] initWithLatitude:latitide longitude:longitude];
        
//        [self showRoute:pickup_location dropOff:[Parkinglot sharedModel].dropoffLocation.coordinate withMap:self.mapView];
        
        [self updateDetailView:marker];
        
    //    [self updateFloatingButtons];
        
        [self showDetailView];
        
      //  [self loadViewIfNeeded];
    }
    
    return YES;
}

- (void) updateDetailView: (GMSMarker*) marker
{
    int i = 0;
    for (GMSMarker* marker in lotMarkerSet) {
         NSString* estimate = [[Parkinglot sharedModel].nearbyplaces[i] objectForKey:@"estimate"];
         marker.iconView = [[UIImageView alloc] initWithImage:[self drawMarkerImage: estimate]];
        i++;
    }
    
    marker.iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btnParkHere.png"]];
    self.detailTitle.text = [marker.userData objectForKey:@"title"];
    NSDictionary* parkinglot = [Parkinglot getParkinglot:[Parkinglot sharedModel].selectedLocationId];
    self.detailEST.text = [NSString stringWithFormat:@"%@ Uber", [parkinglot objectForKey:@"estimate"]];
    double star = [[parkinglot objectForKey:@"star"] doubleValue];
  
    self.starView.value = star;//;
    self.starValue.text = [NSString stringWithFormat:@"%.1f", star];
    self.detailETA.text = [NSString stringWithFormat:@"%d min", [[parkinglot objectForKey:@"duration"] intValue] / 60];
    self.detailDistance.text = [NSString stringWithFormat:@"%@", [parkinglot objectForKey:@"distance"]];
    NSArray* reviews = [parkinglot objectForKey:@"reviews"];
    if([reviews count] > 0)
    {
        NSString *photoUrl = [WS_PHOTO_URL stringByAppendingString:[reviews[0] objectForKey:@"photo_url"]];
        [self.detailImage sd_setImageWithURL:[NSURL URLWithString:photoUrl]
                            placeholderImage:[UIImage imageNamed:@"logo"]
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                       [Parkinglot sharedModel].placeImage = UIImageJPEGRepresentation(image, 0.33);
                                   }];
    } else {
        NSString *photoUrl = [NSString stringWithFormat:GOOGLE_STREET_VIEW_API_SMALL, [Parkinglot sharedModel].pickupLocation.coordinate.latitude, [Parkinglot sharedModel].pickupLocation.coordinate.longitude];
        
        [self.detailImage sd_setImageWithURL:[NSURL URLWithString:photoUrl]
                            placeholderImage:[UIImage imageNamed:@"logo"]
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     [Parkinglot sharedModel].placeImage = UIImageJPEGRepresentation(image, 0.33);
                                   }];
    }
}

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture {
    [self hideDetailView];
}

- (void)mapView:(GMSMapView *)mapView
idleAtCameraPosition:(GMSCameraPosition *)cameraPosition {
    self.mapView = mapView;
    
    if ([Parkinglot sharedModel].selectedLocationId < 0) {
        [self hideDetailView];
    } else {
        [self showDetailView];
    }
}

#pragma mark - Direction API

-(void)placeSearch:(MVPlaceSearchTextField*)textField ResponseForSelectedPlace:(GMSPlace*)responseDict{
    [self.view endEditing:YES];
  
    CLLocationCoordinate2D myLocation = responseDict.coordinate;
    [self updateDestMarker:myLocation];
    [Parkinglot sharedModel].dropoffLocation = [[CLLocation alloc] initWithLatitude:myLocation.latitude longitude:myLocation.longitude];
    GMSCameraUpdate *newDest = [GMSCameraUpdate setTarget:myLocation];
    [self.mapView animateWithCameraUpdate:newDest];
    
    [Parkinglot sharedModel].selectedLocationId = -1;
    
    [ProgressHUD show:FINDNEARBYPARKINGLOTS Interaction:NO];
    [self fetchNearbyResult:myLocation withCompletion:^{
//        CGPoint point = [self.mapView.projection pointForCoordinate:[Parkinglot sharedModel].dropoffLocation.coordinate];
//        [self drawCircle:point];
        [self createMultipleMarkers];
        [ProgressHUD dismiss];
    }];
}
-(void)placeSearchWillShowResult:(MVPlaceSearchTextField*)textField{
    
  }

-(void)placeSearchWillHideResult:(MVPlaceSearchTextField*)textField{
    
  }

-(void)placeSearch:(MVPlaceSearchTextField*)textField ResultCell:(UITableViewCell*)cell withPlaceObject:(PlaceObject*)placeObject atIndex:(NSInteger)index
{
}

#pragma mark - Detail view

- (void) hideDetailView
{
    if (!isDetailViewShown) {
        isDetailViewShown = NO;
        return;
    }
    
    [UIView animateWithDuration:.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.detailviewBottomConstraint.constant = -173;
        self.detailView.alpha = 0;
        btnReturntoCar.alpha = 0;
        btnNav.alpha = 0;
        
    }completion:^(BOOL finished) {
           [self loadViewIfNeeded];
    }];

}

- (void) showDetailView
{
    if ([Parkinglot sharedModel].selectedLocationId < 0 && isDetailViewShown) {
        isDetailViewShown = YES;
        return;
    }

    [UIView animateWithDuration:.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.detailviewBottomConstraint.constant = 0;
        self.detailView.alpha = 1;
        [self updateFloatingButtons];
        btnReturntoCar.alpha = 1;
        btnNav.alpha = 1;
    }completion:^(BOOL finished) {
         [self loadViewIfNeeded];
    }];
}

- (IBAction)gotoDetailViewController:(id)sender
{
    DetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    [self.navigationController pushViewController:detailViewController animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
