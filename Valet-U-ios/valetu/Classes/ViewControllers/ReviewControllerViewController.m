//
//  ReviewControllerViewController.m
//  valetu
//
//  Created by imobile on 2016-09-19.
//  Copyright © 2016 imobile. All rights reserved.
//

#import "ReviewControllerViewController.h"


typedef NS_ENUM(NSInteger, ReviewTableviewSection) {
    MapSection,
    AddressSection,
    InputSection,
    UploadSection,
};

@interface ReviewControllerViewController ()< UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RNGridMenuDelegate>
{
    NSString* inputReview;
    UIImage* uploadedImage;
}
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *estimatelabel;
@property (weak, nonatomic) IBOutlet UILabel *titlelabel;
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *starRatingView;
@property (weak, nonatomic) IBOutlet UILabel *parkingDate;
@property (weak, nonatomic) IBOutlet UITextField *reviewText;

@end

@implementation ReviewControllerViewController

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.title = @"Review";
    CGSize size = self.view.frame.size;
    self.contentSizeInPopup = CGSizeMake(size.width - 36, size.height - 90);
    self.landscapeContentSizeInPopup = CGSizeMake(550, 324);
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initTapGesture];
    
    CLLocationCoordinate2D pickuplocation = [Parkinglot sharedModel].pickupLocation.coordinate;
    
    self.mapView.camera = [GMSCameraPosition cameraWithTarget: pickuplocation zoom:11 bearing:0 viewingAngle:0];
    [self.mapView setMinZoom:3 maxZoom:20];
    
    GMSMarker*  pickupMarker = [GMSMarker markerWithPosition:pickuplocation];
    pickupMarker.map = self.mapView;

    pickupMarker.iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"badgeActive.png"]];
    
    [self.uploadButton addTarget:self action:@selector(uploadPhoto:) forControlEvents:UIControlEventTouchUpInside];
    
    NSDictionary* parkinglot = [Parkinglot getParkinglot:[Parkinglot sharedModel].selectedLocationId];
    self.titlelabel.text = [parkinglot objectForKey:@"address"];
    self.placeLabel.text = [parkinglot objectForKey:@"address"];
    self.estimatelabel.text = [parkinglot objectForKey:@"estimate"];
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    self.parkingDate.text = [dateFormatter stringFromDate:[NSDate date]];
    
    self.imageView.layer.cornerRadius = 5;
    self.imageView.clipsToBounds = YES;
    NSArray* reviews = [parkinglot objectForKey:@"reviews"];
    if([reviews count] > 0)
    {
        NSString *photoUrl = [WS_PHOTO_URL stringByAppendingString:[reviews[0] objectForKey:@"photo_url"]];
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:photoUrl]
                            placeholderImage:[UIImage imageNamed:@"logo"]
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                       uploadedImage = image;                                   }];
    } else
    {
        NSString *phtoUrl = [NSString stringWithFormat:GOOGLE_STREET_VIEW_API_BIG, [Parkinglot sharedModel].pickupLocation.coordinate.latitude, [Parkinglot sharedModel].pickupLocation.coordinate.longitude];
        
        [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:phtoUrl] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                uploadedImage = [UIImage imageWithData:data];
                self.imageView.image  = uploadedImage;
            });
        }] resume];
    }
    
   
}

- (IBAction)didRteParking:(id)sender {

    if ([self isEverythingRight]) {
        [self saveData];
    } else {
        [ProgressHUD showError:ERROR_LOGIN];
    }
}
- (IBAction)didTapClose:(id)sender {
    [self.popupController dismissWithCompletion:nil];
}

- (BOOL) isEverythingRight
{
    BOOL result = NO;
    
    if (uploadedImage != nil && self.starRatingView.value > 0) {
        result = YES;
    }
    return result;
}

- (void) saveData
{
     [Parkinglot sharedModel].userState = kStateNone;
    
    [ProgressHUD show:UPLOADING Interaction:NO];
    
//    NSData *imageData = UIImagePNGRepresentation(uploadedImage);
    NSData *imageData = UIImageJPEGRepresentation(uploadedImage, 0.33);
    [Parkinglot sharedModel].userState = kStateNone;
    NSDictionary* parkinglot = [Parkinglot getParkinglot:[Parkinglot sharedModel].selectedLocationId];
    NSString *parkinglot_id = [parkinglot objectForKey:@"id"];
    NSString *starValue = [NSString stringWithFormat:@"%ld", (long)self.starRatingView.value];
    NSString *token = [NSString stringWithFormat:@"%@", [VUser sharedModel].profileId];
    
    if (inputReview == nil)
    {
        inputReview = @"";
    }
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    
    [params setObject:parkinglot_id forKey:@"parkinglot_id"];
    [params setObject:starValue forKey:@"star"];
    [params setObject:inputReview forKey:@"review"];
    [params setObject:token forKey:@"token"];
    
   [iCommon saveReview:[parkinglot objectForKey:@"title"] imageData:imageData params:params WithCompletion:^(NSURLResponse * _Nullable response, id  _Nullable responseObject, NSError * _Nullable error) {
       if (error) {
           NSLog(@"Error: %@", error);
           [ProgressHUD showError:error.localizedDescription];
       } else {
           [ProgressHUD dismiss];
           dispatch_async(dispatch_get_main_queue(), ^{
               [self.popupController dismissWithCompletion:nil];
           });
       }
   }];

}

- (void) initTapGesture
{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(respondToTapGesture:)];
    
    [self.view addGestureRecognizer:tapRecognizer];
}

- (void) respondToTapGesture: (id) sender
{
    inputReview = self.reviewText.text;
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) uploadPhoto: (id) sender
{
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:nil      //  Must be "nil", otherwise a blank title area will appear above our two buttons
                                message:nil
                                preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* button0 = [UIAlertAction
                              actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleCancel
                              handler:^(UIAlertAction * action)
                              {
                                  //  UIAlertController will automatically dismiss the view
                              }];
    
    UIAlertAction* button1 = [UIAlertAction
                              actionWithTitle:@"Take photo"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  //  The user tapped on "Take a photo"
                                  UIImagePickerController *imagePickerController= [[UIImagePickerController alloc] init];
                                  imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                                  imagePickerController.delegate = self;
                                  imagePickerController.mediaTypes = (__bridge NSArray<NSString *> * _Nonnull)(kUTTypeImage);
                                  imagePickerController.allowsEditing = false;
                                  [self presentViewController:imagePickerController animated:YES completion:^{}];
                              }];
    
    UIAlertAction* button2 = [UIAlertAction
                              actionWithTitle:@"Choose Existing"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  //  The user tapped on "Choose existing"
                                  UIImagePickerController *imagePickerController= [[UIImagePickerController alloc] init];
                                  imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                  imagePickerController.delegate = self;
                                  imagePickerController.allowsEditing = false;
                                  [self presentViewController:imagePickerController animated:YES completion:^{}];
                              }];
    
    [alert addAction:button0];
    [alert addAction:button1];
    [alert addAction:button2];
    [self presentViewController:alert animated:YES completion:nil];

}

#pragma mark 

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    inputReview = textField.text;
}

#pragma mark imagepickerdelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo
{
    uploadedImage = image;
    self.imageView.image = uploadedImage;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
