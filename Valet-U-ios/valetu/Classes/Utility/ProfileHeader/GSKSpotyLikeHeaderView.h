#import <GSKStretchyHeaderView/GSKStretchyHeaderView.h>

@protocol GSKSpotyLikeHeaderViewDelegate;

@interface GSKSpotyLikeHeaderView : GSKStretchyHeaderView
@property (weak, nonatomic) id<GSKSpotyLikeHeaderViewDelegate> delegate;
@end

@protocol GSKSpotyLikeHeaderViewDelegate <NSObject>

- (void)headerView:(GSKSpotyLikeHeaderView *)headerView
  didTapBackButton:(id)sender;

- (void)headerView:(GSKSpotyLikeHeaderView *)headerView
    didMenuPressed:(id)sender;

@end
