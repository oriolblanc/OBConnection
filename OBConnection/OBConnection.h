//
//  OBConnection.h
//  OBConnection
//
//  Created by Oriol Blanc on 20/04/11.
//  Copyright (c) 2012 Oriol Blanc. All rights reserved.
//

// import all required headers for use OBConnection library
#import "OBRequest.h"
#import "OBRequestParameters.h"
#import "OBResponse.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"


// callback types
typedef void (^OBConnectionSuccessCallback)(id data, BOOL cached);
typedef void (^OBConnectionErrorCallback)(OBResponse *response, NSError *error);
typedef id (^OBConnectionDataParsingBlock)(NSDictionary *data);
typedef BOOL (^OBConnectionResponseHandlerBlock)(NSDictionary *JSON, NSDictionary *headerFields);

@protocol OBConnectionDelegate <NSObject>
    - (void)setSessionCookie:(NSString *)cookie;
    - (NSString *)connectionBaseURL;
    - (NSString *)connectionBuildSecurityHeader;
    - (NSString *)connectionHeaderControl;
    - (NSDictionary *)connectionSecurityHeaderForPrivateRequest;
@end

@class OBRequest;

@interface OBConnection : NSObject

// **************************
//      Register 
// **************************

+ (void)registerWithBaseUrl:(NSURL *)baseUrl
                   delegate:(id<OBConnectionDelegate>)delegate;

+ (void)registerWithBaseUrl:(NSURL *)baseUrl
                   delegate:(id<OBConnectionDelegate>)delegate
       responseHandlerBlock:(OBConnectionResponseHandlerBlock)responseHandlerBlock;

// **************************
//      Request
// **************************

+ (void)makeRequest:(OBRequest *)wsRequest
            success:(OBConnectionSuccessCallback)successCallback
              error:(OBConnectionErrorCallback)errorCallback;

+ (void)makeRequest:(OBRequest *)wsRequest
       withCacheKey:(NSString *)cacheKey
         parseBlock:(OBConnectionDataParsingBlock)parsingBlock
            success:(OBConnectionSuccessCallback)successCallback
              error:(OBConnectionErrorCallback)errorCallback;


+ (void)invalidatePHPSessionCookie;

@end
