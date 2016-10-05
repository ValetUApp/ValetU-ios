//
//  DetailCell.h
//  ValetU
//
//  Created by imobile on 2016-09-30.
//  Copyright © 2016 imobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailCell : UITableViewCell

@property (weak, nonatomic) IBOutlet FBSDKProfilePictureView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *updatedDate;
@property (weak, nonatomic) IBOutlet UILabel *reviewText;
@property (retain, nonatomic) NSString* comment;

- (void) showInfo: (NSInteger) rowIndex;

@end
