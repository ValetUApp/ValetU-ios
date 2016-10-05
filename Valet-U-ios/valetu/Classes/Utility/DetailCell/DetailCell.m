//
//  DetailCell.m
//  ValetU
//
//  Created by imobile on 2016-09-30.
//  Copyright © 2016 imobile. All rights reserved.
//

#import "DetailCell.h"

@implementation DetailCell
@synthesize profilePicture;
@synthesize username;
@synthesize updatedDate;
@synthesize reviewText;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    profilePicture.clipsToBounds = YES;
    profilePicture.layer.cornerRadius = 24;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) showInfo: (NSInteger) rowIndex
{
    NSDictionary* parkinglot = [Parkinglot getParkinglot:[Parkinglot sharedModel].selectedLocationId];
    NSArray* reviews = [parkinglot objectForKey:@"reviews"];
    NSDictionary* review = reviews[rowIndex];
    profilePicture.profileID = [review objectForKey:@"profileId"];
    username.text = [review objectForKey:@"name"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
//    NSLog(@"%@, %@", [[VUser sharedModel].lastReview objectForKey:@"updated_at"], [[VUser sharedModel].lastReview objectForKey:@"review"]);
    
    NSDate *updated_at=[dateFormat dateFromString:[review objectForKey:@"updated_at"]];
    [dateFormat setDateFormat:@"YYYY-MM-dd"];
    updatedDate.text = [dateFormat stringFromDate:updated_at];
    reviewText.text = [review objectForKey:@"review"];
}
- (IBAction)giveComment:(id)sender {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Leave a Comment"
                                          message:@"Happy Comment"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Leave a Comment";

     }];
    
    
    UIWindow* topWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    topWindow.rootViewController = [UIViewController new];
    topWindow.windowLevel = UIWindowLevelAlert + 1;
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *comment = alertController.textFields.firstObject;
                                   topWindow.hidden = YES;

                               }];
    [alertController addAction:okAction];
    [topWindow makeKeyAndVisible];
    [topWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

@end
