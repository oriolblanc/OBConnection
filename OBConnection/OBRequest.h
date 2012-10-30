//
//  OBRequest.h
//  OBConnection
//
//  Created by Oriol Blanc on 20/04/11.
//  Copyright (c) 2012 Oriol Blanc. All rights reserved.
//

typedef enum {
    OBRequestMethodTypeMethodGET       = 100,
    OBRequestMethodTypeMethodPOST      = 200,
    OBRequestMethodTypeMultiForm       = 300,
} OBRequestMethodType;

@class OBRequestParameters;

@interface OBRequest : NSObject

@property (nonatomic, retain) NSString *resource;
@property (nonatomic, retain) OBRequestParameters *parameters;
@property (nonatomic, retain) OBRequestParameters *files;
@property (nonatomic, assign) OBRequestMethodType requestType;
@property (nonatomic, assign) BOOL isPublic;
@property (nonatomic, assign) BOOL retryLaterOnFailure;

+ (id)requestWithType:(OBRequestMethodType)_method
             resource:(NSString *)_resource
           parameters:(OBRequestParameters *)_parameters;

+ (id)requestWithType:(OBRequestMethodType)_method
             resource:(NSString *)_resource
           parameters:(OBRequestParameters *)_parameters
             isPublic:(BOOL)isPublic;

+ (id)requestWithType:(OBRequestMethodType)_type
             resource:(NSString *)_resource
           parameters:(OBRequestParameters *)_parameters
                files:(OBRequestParameters *)_files
             isPublic:(BOOL)_isPublic;

@end
