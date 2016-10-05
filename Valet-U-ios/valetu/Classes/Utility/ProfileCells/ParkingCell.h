//
//  ParkingCell.h
//  ValetU
//
//  Created by imobile on 2016-09-30.
//  Copyright © 2016 imobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParkingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet CircleImageView *parkingImage;
@property (weak, nonatomic) IBOutlet UILabel *parkingTitle;

- (void) displayData;
@end
