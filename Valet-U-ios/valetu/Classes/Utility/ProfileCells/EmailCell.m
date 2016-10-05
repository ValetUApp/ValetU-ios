//
//  EmailCellTableViewCell.m
//  ValetU
//
//  Created by imobile on 2016-09-30.
//  Copyright © 2016 imobile. All rights reserved.
//

#import "EmailCell.h"

@implementation EmailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
