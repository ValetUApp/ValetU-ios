//
//  ProfileViewController.m
//  valetu
//
//  Created by imobile on 2016-09-26.
//  Copyright © 2016 imobile. All rights reserved.
//

#import "ProfileViewController.h"
#import "EmailCell.h"
#import "ParkingCell.h"
#import "LastCommentCell.h"

static NSString* const emailCellReuseIdentifier = @"emailCell";
static NSString* const parkingCellReuseIdentifier = @"parkingCell";
static NSString* const lastCellReuseIdentifier = @"lastCommentCell";

@interface ProfileViewController () <GSKSpotyLikeHeaderViewDelegate, RNGridMenuDelegate>

@end

@implementation ProfileViewController
@synthesize profileHeaderView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.tableView reloadData];
}

- (void) setupView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    // we have to set this flag before we add the header to the table view, otherwise it will change its insets immediately

    profileHeaderView = [[GSKSpotyLikeHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 326)];
    profileHeaderView.manageScrollViewInsets = YES;
    profileHeaderView.delegate = self;
    [self.tableView addSubview:profileHeaderView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"EmailCell" bundle:nil] forCellReuseIdentifier:emailCellReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"ParkingCell" bundle:nil] forCellReuseIdentifier:parkingCellReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"LastCommentCell" bundle:nil] forCellReuseIdentifier:lastCellReuseIdentifier];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 120; //Set this to any value that works for you.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    if (indexPath.row == 0) {
        height = 75;
    } else if(indexPath.row == 1) {
        height = 49;
    } else {
        height = 120;
    }
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 0) {
        EmailCell *cell = [tableView dequeueReusableCellWithIdentifier:emailCellReuseIdentifier];
        if (!cell) {
            [tableView registerClass:[EmailCell class] forCellReuseIdentifier:emailCellReuseIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:emailCellReuseIdentifier];
        }
        
        cell.myEmail.text = [VUser sharedModel].email;
        
        return cell;

    } else if(indexPath.row == 1) {
        ParkingCell *cell = [tableView dequeueReusableCellWithIdentifier:parkingCellReuseIdentifier];
        if (!cell) {
            [tableView registerClass:[ParkingCell class] forCellReuseIdentifier:parkingCellReuseIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:parkingCellReuseIdentifier];
        }
       
        [cell displayData];
        
        return cell;

    } else {
        LastCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:lastCellReuseIdentifier];
        if (!cell) {
            [tableView registerClass:[LastCommentCell class] forCellReuseIdentifier:lastCellReuseIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:lastCellReuseIdentifier];
        }
        
        [cell displayData];
        
        [cell.contentView setNeedsLayout];
        [cell.contentView layoutIfNeeded];

        return cell;
    }

   }

#pragma mark Profile delegate;

- (void)headerView:(GSKSpotyLikeHeaderView *)headerView
  didTapBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)headerView:(GSKSpotyLikeHeaderView *)headerView
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


@end
