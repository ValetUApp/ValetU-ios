//
//  DetailViewController.m
//  valetu
//
//  Created by imobile on 2016-09-22.
//  Copyright © 2016 imobile. All rights reserved.
//

#import "DetailViewController.h"
#import "DetailCell.h"
#import "UIScrollView+EmptyDataSet.h"


static NSString *const detailCellReuseIdentifier = @"DetailCell";

@interface DetailViewController ()<UITableViewDelegate, UITableViewDataSource, GSKTwitterStretchyHeaderViewDelegate, UBSDKModalViewControllerDelegate, RNGridMenuDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
{
    __block  UBSDKRideRequestButton  *btnRideRequest;
    UBSDKRideParametersBuilder *builder;
}
@property (weak, nonatomic) IBOutlet FBSDKProfilePictureView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *updatedDate;
@property (weak, nonatomic) IBOutlet UITextView *reviewText;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *rideButton;
@property (weak, nonatomic) IBOutlet UILabel *pickupTime;

@end

@implementation DetailViewController
@synthesize stretchyHeaderView;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.tableFooterView = [UIView new];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50; //Set this to any value that works for you.
    
    self.userImageView.clipsToBounds = YES;
    self.userImageView.layer.cornerRadius = 24;
    
    // A little trick for removing the cell separators
    
    stretchyHeaderView = [[GSKTwitterStretchyHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 363)];
    stretchyHeaderView.delegate = self;
    stretchyHeaderView.manageScrollViewInsets = YES;

    [self.tableView addSubview:stretchyHeaderView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"DetailCell" bundle:nil] forCellReuseIdentifier:detailCellReuseIdentifier];
    [self updateRideRequest];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.tableView reloadData];
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    NSInteger top = scrollView.contentInset.top;
    NSInteger height = self.tableView.tableHeaderView.frame.size.height;
    return top - height; // FIXME: Magical number (Tab Bar Height)
  //  -self.tableView.tableHeaderView.frame.size.height/2.0f;
}

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIColor whiteColor];
}

- (UIImage *)buttonImageForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state
{
    return [UIImage imageNamed:@"f25B"];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"There is no one left their review. Be the first one to do it.";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Medium" size:13],
                                 NSForegroundColorAttributeName: [UIColor colorWithRed:146 green:146 blue:146 alpha:1]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"This allows you to share photos from your library and save photos to your camera roll.";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return YES;
}

- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView
{
    return YES;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return YES;
}

- (BOOL) emptyDataSetShouldAllowImageViewAnimate:(UIScrollView *)scrollView
{
    return YES;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view
{
    // Do something
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button
{
    // Do something
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController gsk_setNavigationBarTransparent:YES animated:NO];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void) updateRideRequest
{
    self.rideButton.layer.cornerRadius = 4;
    self.rideButton.clipsToBounds = YES;
    
    [iCommon getUberETAWithCompletion:[Parkinglot sharedModel].pickupLocation completion:^(NSDictionary *uberData, NSString *string, BOOL status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger estimate = [[uberData objectForKey:@"estimate"] integerValue];
            NSInteger m = (estimate / 60) % 60;
            self.pickupTime.text = [NSString stringWithFormat:@"PICK UP TIME IS APPROXIMATELY %lu MINS", (long)m];
        });
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSDictionary* parkinglot = [Parkinglot getParkinglot:[Parkinglot sharedModel].selectedLocationId];
    NSArray* reviews = [parkinglot objectForKey:@"reviews"];
    return [reviews count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailCell *cell = [tableView dequeueReusableCellWithIdentifier:detailCellReuseIdentifier];
    if (!cell) {
        [tableView registerClass:[DetailCell class] forCellReuseIdentifier:detailCellReuseIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:detailCellReuseIdentifier];
    }
    
    [cell showInfo:indexPath.row];
    
    [cell.contentView setNeedsLayout];
    [cell.contentView layoutIfNeeded];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 103;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}

- (void) _rideRequest
{
    builder = [[UBSDKRideParametersBuilder alloc] init];
    [builder setPickupLocation:[Parkinglot sharedModel].pickupLocation];
    [builder setDropoffLocation:[Parkinglot sharedModel].dropoffLocation];
    UBSDKRideParameters *parameters = [builder build];
    
    UBSDKLoginManager *loginManager = [[UBSDKLoginManager alloc] init];
    UBSDKRideRequestViewController *rideRequestViewController = [[UBSDKRideRequestViewController alloc] initWithRideParameters:parameters loginManager:loginManager];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController pushViewController:rideRequestViewController animated:YES];
}

- (IBAction) didRideRequest:(id)sender
{
    if ([iCommon shouldSkipLogin] || [FBSDKAccessToken currentAccessToken]) {
        [ProgressHUD show:CONFIRMING_LOGIN];
        [iCommon fetchUserInfoWithCompletion:^(id result, BOOL status, NSString *message) {
            if (status) {
                [iCommon saveParkingWithCompletion:^(BOOL status, NSString * _Nonnull message) {
                    if (status) {
                        [ProgressHUD dismiss];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self _rideRequest];
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
                                    [self _rideRequest];
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

- (void)footerTapped {
    
    NSLog(@"You've tapped the footer!");
}

- (void)headerView:(GSKTwitterStretchyHeaderView *)headerView didTapBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)headerView:(GSKTwitterStretchyHeaderView *)headerView
      didAddReview:(id)sender
{
     if ([iCommon shouldSkipLogin] && [FBSDKAccessToken currentAccessToken]) {
         [ProgressHUD show:CONFIRMING_LOGIN];
        [iCommon fetchUserInfoWithCompletion:^(id result, BOOL status, NSString *message) {
            if (status) {
                [iCommon saveTokenWithCompletion:^(BOOL status, NSString * _Nonnull message) {
                    if (status) {
                        [ProgressHUD dismiss];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self showReviewWindow];
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
                [VUser sharedModel].fbToken = [FBSDKAccessToken currentAccessToken];
                [iCommon fetchUserInfoWithCompletion:^(id  _Nonnull result, BOOL status, NSString * _Nonnull message) {
                    if (status) {
                        [iCommon saveTokenWithCompletion:^(BOOL status, NSString * _Nonnull message) {
                            if (status) {
                                [ProgressHUD dismiss];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self showReviewWindow];
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

- (void)headerView:(GSKTwitterStretchyHeaderView *)headerView
   didTapDirection:(id)sender
{
    [iCommon startNavigation];
}

- (void)headerView:(GSKTwitterStretchyHeaderView *)headerView
    didReturntoCar:(id)sender
{
    [Parkinglot sharedModel].userState = kParkinglotReview;
    
    ReturnViewController* returnViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ReturnView"];
    returnViewController.width = self.view.frame.size.width;
    returnViewController.height = self.view.frame.size.height;
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:returnViewController];
    popupController.transitionStyle = STPopupTransitionStyleFade;
    popupController.containerView.layer.cornerRadius = 4;
    popupController.navigationBarHidden = YES;
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

- (void)headerView:(GSKTwitterStretchyHeaderView *)headerView
    didMenuPressed:(id)sender
{
    [self.view endEditing:YES];
  
    UIImage *profileImage = [UIImage imageNamed:@"Profile"];
    
    NSArray *menuItems = @[
                           [[RNGridMenuItem alloc] initWithImage:profileImage title:@"Profile"],
                           ];
    RNGridMenu *gridMenu = [[RNGridMenu alloc] initWithItems:menuItems];
    gridMenu.delegate = self;
    [gridMenu showInViewController:self center:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2)];
}

- (void) showReviewWindow
{
    [Parkinglot sharedModel].userState = kParkinglotReview;
    
    ReviewControllerViewController* reviewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ReviewControler"];
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:reviewController];
    popupController.transitionStyle = STPopupTransitionStyleFade;
    popupController.containerView.layer.cornerRadius = 4;
    popupController.navigationBarHidden = YES;
    if (NSClassFromString(@"UIBlurEffect")) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        popupController.backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    }
    [popupController presentInViewController:self];
    
}

- (void) doAfterLogin
{
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
}

#pragma mark - <UBSDKModalViewControllerDelegate>

- (void)modalViewControllerDidDismiss:(UBSDKModalViewController *)modalViewController {
    NSLog(@"did dismiss");
}

- (void)modalViewControllerWillDismiss:(UBSDKModalViewController *)modalViewController {
    NSLog(@"will dismiss");
}

//------ grid menu delgate -------------------------------------------------------------------------------------------------------------------------------------------
- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [gridMenu dismissAnimated:NO];
    if ([item.title isEqualToString:@"Profile"])    [self viewProfile];
}


- (void) viewProfile{}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
