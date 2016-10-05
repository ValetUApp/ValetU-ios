	//
//  LastCommentCell.m
//  ValetU
//
//  Created by imobile on 2016-09-30.
//  Copyright © 2016 imobile. All rights reserved.
//

#import "LastCommentCell.h"

@implementation LastCommentCell
@synthesize updatedAtlabel;
@synthesize lastReviewText;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) displayData
{
    if ([VUser sharedModel].lastReview != nil && [[VUser sharedModel].lastReview count] > 0) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
         [dateFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
       
        
        NSLog(@"%@, %@", [[VUser sharedModel].lastReview objectForKey:@"updated_at"], [[VUser sharedModel].lastReview objectForKey:@"review"]);
        
        NSDate *updated_at=[dateFormat dateFromString:[[VUser sharedModel].lastReview objectForKey:@"updated_at"]];
         [dateFormat setDateFormat:@"YYYY-MM-dd"];
        updatedAtlabel.text = [dateFormat stringFromDate:updated_at];
        lastReviewText.text = [[VUser sharedModel].lastReview objectForKey:@"review"];
    } else {
        updatedAtlabel.text = @"";
        lastReviewText.text = @"";
    }
}

@end
