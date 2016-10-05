//
//  VUser.m
//  valetu
//
//  Created by imobile on 2016-09-28.
//  Copyright © 2016 imobile. All rights reserved.
//

#import "VUser.h"

@implementation VUser

+ (VUser*)sharedModel
{
    static id sharedMyModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyModel = [[self alloc] init];
    });
    return sharedMyModel;
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}




@end
