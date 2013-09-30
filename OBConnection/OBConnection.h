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
#import "OBCache.h"

// callback types
typedef void (^OBConnectionSuccessCallback)(id data, BOOL cached);

typedef void (^OBConnectionErrorCallback)(id data, NSError *error);

typedef id (^OBConnectionDataParsingBlock)(NSDictionary *data);

typedef BOOL (^OBConnectionResponseHandlerBlock)(NSDictionary *JSON, NSDictionary *headerFields);

typedef NSDictionary *(^OBConnectionBuildSecurityHeaderRequests)(void);

typedef NSString *(^OBConnectionBuildURLForResourceBlock)(NSString *resource, BOOL isAuthenticated);

@class OBRequest;

@interface OBConnection : NSObject

@property(nonatomic, copy) OBConnectionResponseHandlerBlock responseHandlerBlock;
@property(nonatomic, copy) OBConnectionBuildSecurityHeaderRequests buildSecurityHeaderRequestBlock;
@property(nonatomic, copy) OBConnectionBuildURLForResourceBlock buildURLForResourceBlock;

/**
 Whether the connections created with makeRequest:success:error should accept an invalid SSL certificate.
 */
@property(nonatomic) BOOL allowsInvalidSSLCertificate;

// **************************
//      Register 
// **************************

+ (void)registerWithBaseUrl:(NSURL *)baseUrl;

+ (void)registerWithBaseUrl:(NSURL *)baseUrl
       responseHandlerBlock:(OBConnectionResponseHandlerBlock)responseHandlerBlock;

+ (void)registerWithBaseUrl:(NSURL *)baseUrl
       responseHandlerBlock:(OBConnectionResponseHandlerBlock)responseHandlerBlock
allowingInvalidSSLCertificate:(BOOL)allowing;

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

+ (void)addOperation:(NSOperation *)theOperation;

+ (void)cancelAllConnections;



// **************************
//      setting up blocks
// **************************

// response handler
+ (void)setResponseHandlerBlock:(OBConnectionResponseHandlerBlock)responseHandlerBlock;

+ (OBConnectionResponseHandlerBlock)responseHandlerBlock;

// security header request
+ (void)setBuildSecurityHeaderRequests:(OBConnectionBuildSecurityHeaderRequests)buildSecurityHeaderRequestsBlock;

+ (OBConnectionBuildSecurityHeaderRequests)buildSecurityHeaderRequests;

// URL for certain resource
+ (void)setBuildURLForResourceBlock:(OBConnectionBuildURLForResourceBlock)buildURLForResourceBlock;

+ (OBConnectionBuildURLForResourceBlock)buildURLForResourceBlock;

@end
