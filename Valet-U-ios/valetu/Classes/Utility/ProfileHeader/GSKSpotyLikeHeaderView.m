#import "GSKSpotyLikeHeaderView.h"

static const CGSize kUserImageSize = {.width = 120, .height = 120};
//static const CGFloat kMinHeaderImageHeight = 64;
static const CGFloat kNavigationTitleTop = 26;

@interface GSKSpotyLikeHeaderView ()

@property (nonatomic) UIView *navigationBar;
@property (nonatomic) UIView *backgroundImageView;
@property (nonatomic) UIView *blurredBackgroundImageView;
@property (nonatomic) UILabel *navigationBarTitle;
@property (nonatomic) UILabel *numberOfParkingsTitle;
@property (nonatomic) UILabel *numberOfParkings;
@property (nonatomic) UILabel *numberOfReviewsTitle;
@property (nonatomic) UILabel *numberOfReviews;
@property (nonatomic) UIButton *backButton;
@property (nonatomic) UIButton *menuButton;

@property (nonatomic) FBSDKProfilePictureView *userImageView; // redondear y fondo blanco
@property (nonatomic) UILabel *title;
@property (nonatomic) UILabel *parkingLabel;

@end

@implementation GSKSpotyLikeHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:187 blue:237 alpha:1];
        self.expansionMode = GSKStretchyHeaderViewExpansionModeImmediate;
        // You can specify wether the content view sticks to the top or the bottom of the header view if one of the previous properties is set to NO
        // In this case, when the user bounces the scrollView, the content will keep its height and will stick to the bottom of the header view
        self.contentAnchor = GSKStretchyHeaderViewContentAnchorBottom;
        [self setupNavigationBar];
        [self setupViews];

        [self setupViewConstraints];
        
        [self fillText];
    }
    return self;
}

- (void)setupNavigationBar {
    self.navigationBar = [[UIView alloc] init];
    self.navigationBar.clipsToBounds = YES;
    [self.contentView addSubview:self.navigationBar];
    
//    self.backgroundImageView = [[UIView alloc] init];
//    self.backgroundImageView.backgroundColor = [UIColor colorWithRed:0 green:187 blue:237 alpha:1];
//    [self.contentView addSubview:self.backgroundImageView];
//    
//    self.blurredBackgroundImageView = [[UIView alloc] init];
//    self.blurredBackgroundImageView.backgroundColor = [UIColor colorWithRed:0 green:187 blue:237 alpha:1];
//    [self.contentView addSubview:self.blurredBackgroundImageView];
    
    self.backButton = [[UIButton alloc] init];
    UIImageView *backIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"backChevron"]];
    [self.backButton addSubview:backIcon];
    [backIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(0));
        make.centerY.equalTo(self.backButton.mas_centerY);
        make.width.equalTo(@(12.5));
        make.height.equalTo(@(21));
    }];
    
    [self.backButton setTitle:@"Map" forState:UIControlStateNormal];
    self.backButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:17];
    [self.backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBar addSubview:self.backButton];
    
    [self.backButton.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0).offset(14);
        make.centerY.equalTo(self.backButton.mas_centerY);
        make.width.equalTo(@34);
    }];
    
    self.navigationBarTitle = [[UILabel alloc] init];
    self.navigationBarTitle.text = @"Profile";
    self.navigationBarTitle.textColor = [UIColor whiteColor];
    self.navigationBarTitle.textAlignment = NSTextAlignmentCenter;
    self.navigationBarTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    self.navigationBarTitle.font = [UIFont fontWithName:@"AvenirNext-Regular" size:19];
    [self.navigationBar addSubview:self.navigationBarTitle];
    
    self.menuButton = [[UIButton alloc] init];
    [self.menuButton setImage:[UIImage imageNamed:@"icMenuWhite.png"] forState:UIControlStateNormal];
    [self.menuButton addTarget:self action:@selector(menuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBar addSubview:self.menuButton];
}

- (void)setupViews {
    self.userImageView = [[FBSDKProfilePictureView alloc] init];
    self.userImageView.clipsToBounds = YES;
    self.userImageView.layer.cornerRadius = kUserImageSize.width / 2;
    self.userImageView.layer.borderColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.2].CGColor;
    self.userImageView.layer.borderWidth = 4;
    [self.contentView addSubview:self.userImageView];

    self.title = [[UILabel alloc] init];
    self.title.textColor = [UIColor whiteColor];
    self.title.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:18];
    [self.contentView addSubview:self.title];
    
    self.numberOfReviewsTitle = [[UILabel alloc] init];
    self.numberOfReviewsTitle.textColor = [UIColor whiteColor];
    self.numberOfReviewsTitle.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:14.4];
    [self.contentView addSubview:self.numberOfReviewsTitle];
    
    self.numberOfReviews = [[UILabel alloc] init];
    self.numberOfReviews.textColor = [UIColor whiteColor];
    self.numberOfReviews.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:18];
    [self.contentView addSubview:self.numberOfReviews];

    self.numberOfParkingsTitle = [[UILabel alloc] init];
    self.numberOfParkingsTitle.textColor = [UIColor whiteColor];
    self.numberOfParkingsTitle.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:14.4];
    [self.contentView addSubview:self.numberOfParkingsTitle];
    
    self.numberOfParkings = [[UILabel alloc] init];
    self.numberOfParkings.textColor = [UIColor whiteColor];
    self.numberOfParkings.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:18];
    [self.contentView addSubview:self.numberOfParkings];
    

}

- (void)setupViewConstraints {
//    [self.backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(@0);
//        make.left.equalTo(@0);
//        make.width.equalTo(self.contentView.mas_width);
//        make.height.equalTo(self.contentView.mas_height);
//    }];
//    
//    [self.blurredBackgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.backgroundImageView);
//    }];

    [self.navigationBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.height.equalTo(@64);
    }];
    
    [self.navigationBarTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.navigationBar.mas_centerX);
        make.top.equalTo(@0).offset(kNavigationTitleTop);
        make.width.equalTo(@164);
    }];
    
    [self.menuButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.navigationBarTitle.mas_centerY);
        make.right.equalTo(@(-12));
        make.height.equalTo(@24);
        make.width.equalTo(@24);
    }];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@12);
        make.centerY.equalTo(self.navigationBarTitle.mas_centerY);
        make.width.equalTo(@85);
    }];

    [self.userImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.top.equalTo(self.navigationBarTitle.mas_bottom).offset(16);
        make.width.equalTo(@(kUserImageSize.width));
        make.height.equalTo(@(kUserImageSize.height));
    }];

    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.top.equalTo(self.userImageView.mas_bottom).offset(16);
    }];
    
    [self.numberOfParkingsTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_centerX).offset(-13);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-32);
        make.width.greaterThanOrEqualTo(@49);
    }];
    
    [self.numberOfParkings mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.numberOfParkingsTitle.mas_centerX);
        make.top.equalTo(self.numberOfReviews.mas_top);
    }];
    
    [self.numberOfReviewsTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_centerX).offset(13);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-32);
        make.width.greaterThanOrEqualTo(@47);
    }];
    
    [self.numberOfReviews mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.numberOfReviewsTitle.mas_centerX);
        make.top.equalTo(self.title.mas_bottom).offset(24);
    }];
}

- (void) fillText
{
    self.userImageView.profileID = [VUser sharedModel].profileId;
    self.title.text = [VUser sharedModel].username;
    self.numberOfReviewsTitle.text = @"Reviews";
    self.numberOfParkingsTitle.text = @"Parkings";
    NSString* numberOfReviews = [VUser sharedModel].numberOfReviews == nil ? @"0" : [VUser sharedModel].numberOfReviews;
    NSString* numberOfParkings = [VUser sharedModel].numberOfParkings == nil ? @"0" : [VUser sharedModel].numberOfParkings;
    self.numberOfReviews.text = [NSString stringWithFormat:@"%@", numberOfReviews];
    self.numberOfParkings.text = [NSString stringWithFormat:@"%@", numberOfParkings];
}

- (void)didChangeStretchFactor:(CGFloat)stretchFactor {
    CGFloat alpha = 1;
    CGFloat blurAlpha = 1;
    if (stretchFactor > 1) {
        alpha = CGFloatTranslateRange(stretchFactor, 1, 1.12, 1, 0);
        blurAlpha = alpha;
    } else if (stretchFactor < 0.8) {
        alpha = CGFloatTranslateRange(stretchFactor, 0.2, 0.8, 0, 1);
    }

    alpha = MAX(0, alpha);
 //   self.userImageView.alpha = alpha;
    self.title.alpha = alpha;
    self.numberOfParkings.alpha = alpha;
    self.numberOfParkingsTitle.alpha = alpha;
    self.numberOfReviews.alpha = alpha;
    self.numberOfReviewsTitle.alpha = alpha;
}

#pragma mark - Callbacks

- (void)backButtonPressed:(id)sender {
    [self.delegate headerView:self didTapBackButton:sender];
}

- (void) menuButtonPressed: (id) sender
{
    [self.delegate headerView:self didMenuPressed:sender];
}


@end
