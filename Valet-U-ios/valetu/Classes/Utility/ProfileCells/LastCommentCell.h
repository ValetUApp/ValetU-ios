//
//  LastCommentCell.h
//  ValetU
//
//  Created by imobile on 2016-09-30.
//  Copyright © 2016 imobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LastCommentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *updatedAtlabel;
@property (weak, nonatomic) IBOutlet UILabel *lastReviewText;

- (void) displayData;
@end
