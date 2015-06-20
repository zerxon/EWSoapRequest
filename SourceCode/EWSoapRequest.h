//
//  SoapObject.h
//  SoapObject
//
//  Created by wallace-leung on 15/5/8.
//  Copyright (c) 2015年 Zerxon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLReader.h"

typedef void(^EWSoapSuccessBlock)(NSHTTPURLResponse *response, NSDictionary *dictionary);
typedef void(^EWSoapFailureBlock)(NSHTTPURLResponse *response, NSError *error);

@interface EWSoapRequest : NSObject

@property(nonatomic, assign) NSTimeInterval timeout;
@property(nonatomic, strong) NSString *nameSpace;

+ (instancetype)shareInstance;

- (void)requestUrl:(NSString *)url
            action:(NSString *)action
            params:(NSDictionary *)params
           success:(EWSoapSuccessBlock)success
           failure:(EWSoapFailureBlock)failure;

@end