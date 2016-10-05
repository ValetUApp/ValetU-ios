//
//  ParkingCell.m
//  ValetU
//
//  Created by imobile on 2016-09-30.
//  Copyright © 2016 imobile. All rights reserved.
//

#import "ParkingCell.h"

@implementation ParkingCell
@synthesize parkingImage;
@synthesize parkingTitle;

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    parkingImage.clipsToBounds = YES;
    parkingImage.layer.cornerRadius = 35 / 2;
    parkingImage.layer.borderColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.2].CGColor;
    parkingImage.layer.borderWidth = 4;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) displayData
{
    if([VUser sharedModel].lastParking != nil && [[VUser sharedModel].lastParking count] > 0) {
        NSLog(@"%@", [VUser sharedModel].lastParking);
        NSString *imageUrl = [WS_PHOTO_URL stringByAppendingString:[[VUser sharedModel].lastParking objectForKey:@"photo_url"]];
        [self.parkingImage sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                             placeholderImage:[UIImage imageNamed:@"logo"]];
        
         parkingTitle.text = [[VUser sharedModel].lastParking objectForKey:@"parkingPlace"];
    } else {
        self.parkingImage.image = [UIImage imageNamed:@"logo"];
        parkingTitle.text = @"";
    }
}


@end
