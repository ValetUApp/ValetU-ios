//
//  VComment.h
//  valetu
//
//  Created by imobile on 2016-09-28.
//  Copyright © 2016 imobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VComment : NSObject

@property (nonatomic) NSInteger commentId;
@property (nonatomic) NSString* comment;
@property (nonatomic) NSString* created_at;

@end
