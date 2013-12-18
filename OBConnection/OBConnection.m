//
//  OBConnection.m
//  OBConnection
//
//  Created by Oriol Blanc on 20/04/11.
//  Copyright (c) 2012 Oriol Blanc. All rights reserved.
//


#import "AFNetworkActivityIndicatorManager.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"

#import "OBCache.h"

#import "OBConnection.h"

@interface OBConnection ()
@property(nonatomic, retain) AFHTTPClient *client;
@property(nonatomic, assign) BOOL authenticated;
@property(nonatomic, strong) dispatch_queue_t connectionDispatchQueue;

- (void)makeRequest:(OBRequest *)wsRequest
            success:(OBConnectionSuccessCallback)successCallback
              error:(OBConnectionErrorCallback)errorCallback;

- (void)makeRequest:(OBRequest *)wsRequest
       withCacheKey:(NSString *)cacheKey
         parseBlock:(OBConnectionDataParsingBlock)parsingBlock
            success:(OBConnectionSuccessCallback)successCallback
              error:(OBConnectionErrorCallback)errorCallback;
@end

@implementation OBConnection
@synthesize client = _client;
@synthesize authenticated;
@synthesize responseHandlerBlock = _responseHandlerBlock;
@synthesize connectionDispatchQueue;

#pragma mark - Singleton

+ (OBConnection *)instance {
    static dispatch_once_t dispatchOncePredicate;
    static OBConnection *myInstance = nil;

    dispatch_once(&dispatchOncePredicate, ^{
        myInstance = [[self alloc] init];
        myInstance.connectionDispatchQueue = dispatch_queue_create("WebProxyDispatchQueue", DISPATCH_QUEUE_CONCURRENT);
        [myInstance setAuthenticated:NO];
        
        #if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        #endif
    });

    return myInstance;
}

+ (void)registerWithBaseUrl:(NSURL *)baseUrl {
    [self registerWithBaseUrl:baseUrl responseHandlerBlock:NULL];
}

+ (void)registerWithBaseUrl:(NSURL *)baseUrl
       responseHandlerBlock:(OBConnectionResponseHandlerBlock)responseHandlerBlock {
    [self registerWithBaseUrl:baseUrl responseHandlerBlock:responseHandlerBlock allowingInvalidSSLCertificate:NO];
}

+ (void)registerWithBaseUrl:(NSURL *)baseUrl
       responseHandlerBlock:(OBConnectionResponseHandlerBlock)responseHandlerBlock
allowingInvalidSSLCertificate:(BOOL)allowing {
    OBConnection *connection = [OBConnection instance];
    connection.responseHandlerBlock = responseHandlerBlock;
    connection.allowsInvalidSSLCertificate = allowing;
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseUrl];
    connection.client = client;
}

+ (void)makeRequest:(OBRequest *)wsRequest
            success:(OBConnectionSuccessCallback)successCallback
              error:(OBConnectionErrorCallback)errorCallback {
    [[self instance] makeRequest:wsRequest success:successCallback error:errorCallback];
}

+ (void)makeRequest:(OBRequest *)wsRequest
       withCacheKey:(NSString *)cacheKey
         parseBlock:(OBConnectionDataParsingBlock)parsingBlock
            success:(OBConnectionSuccessCallback)successCallback
              error:(OBConnectionErrorCallback)errorCallback {
    [[self instance] makeRequest:wsRequest withCacheKey:cacheKey parseBlock:parsingBlock success:successCallback error:errorCallback];
}

#pragma mark - Request

- (void)updateFormData:(id)formData obj:(id)obj key:(id)key
{
    NSData *imageData = nil;
    #if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
    if ([obj isKindOfClass:[UIImage class]]) {
        UIImage *image = (UIImage *) obj;
        imageData = UIImageJPEGRepresentation(image, 0.75);
    }
    #else
    if ([obj isKindOfClass:[NSImage class]]) {
        NSImage *image = (NSImage *) obj;
        imageData = [NSBitmapImageRep representationOfImageRepsInArray:[image representations] usingType: NSJPEGFileType properties:nil];
    }
    #endif
    
    if (imageData) {
        [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"%@", key] fileName:[NSString stringWithFormat:@"%@.JPG", key] mimeType:@"image/jpeg"];
    }
}

- (void)makeRequest:(OBRequest *)wsRequest
       withCacheKey:(NSString *)cacheKey
         parseBlock:(OBConnectionDataParsingBlock)parsingBlock
            success:(OBConnectionSuccessCallback)successCallback
              error:(OBConnectionErrorCallback)errorCallback {

    dispatch_async(self.connectionDispatchQueue, ^{
        if (cacheKey) {
            id cachedData = [OBCache cachedObjectForKey:cacheKey];
            if (cachedData) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if (successCallback != NULL)
                    {
                        successCallback(cachedData, YES);
                    }
                });
            }
        }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // run the request

            NSMutableURLRequest *request = nil;

            switch (wsRequest.requestType) {
                case OBRequestMethodTypeMethodGET:
                default: {
                    request = [self.client requestWithMethod:@"GET" path:wsRequest.resource parameters:[wsRequest.parameters parametersDictionary]];
                    break;
                }
                case OBRequestMethodTypeMultiForm: {
                    request = [self.client multipartFormRequestWithMethod:@"POST" path:wsRequest.resource parameters:[wsRequest.parameters parametersDictionary] constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {

                        [[wsRequest.files parametersDictionary] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                            [self updateFormData:formData obj:obj key:key];
                        }];
                    }];
                    break;
                }
                case OBRequestMethodTypeMethodPOST: {
                    request = [self.client requestWithMethod:@"POST" path:wsRequest.resource parameters:[wsRequest.parameters parametersDictionary]];
                    break;
                }
                case OBRequestMethodTypeMethodPUT: {
                    request = [self.client requestWithMethod:@"PUT" path:wsRequest.resource parameters:[wsRequest.parameters parametersDictionary]];
                    break;
                }
                case OBRequestMethodTypeMethodDELETE: {
                    request = [self.client requestWithMethod:@"DELETE" path:wsRequest.resource parameters:[wsRequest.parameters parametersDictionary]];
                    break;
                }
            }

        [request setTimeoutInterval:wsRequest.timeoutInterval];

            // we should authenticate the session for private requests
            NSMutableDictionary *allHeaders = [request.allHTTPHeaderFields mutableCopy];
            if (!wsRequest.isPublic) {
                
                if (self.buildSecurityHeaderRequestBlock != NULL)
                {
                    NSDictionary *securityHeader = self.buildSecurityHeaderRequestBlock();
                    if (securityHeader != nil) {
                        [allHeaders addEntriesFromDictionary:securityHeader];
                    }
                }
            }
            [request setAllHTTPHeaderFields:allHeaders];

            // do request
            AFHTTPRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSURLResponse *response, id JSON) {

                BOOL responseHandledWithoutErrors = (self.responseHandlerBlock != NULL) ? responseHandledWithoutErrors = self.responseHandlerBlock(JSON, [(NSHTTPURLResponse *) response allHeaderFields]) : YES;

                if (responseHandledWithoutErrors) {
                    if (successCallback) {
                        id parsedData = JSON;

                        if (parsingBlock) {
                            parsedData = parsingBlock(parsedData);
                        }

                        if (cacheKey) {
                            [OBCache cacheObject:parsedData forKey:cacheKey];
                        }

                        successCallback(parsedData, NO);
                    }
                }
                else {
                    if (errorCallback) {
                        errorCallback(JSON, nil); // @todo: Should create a proper NSError here
                    }
                }

            }                                                                                   failure:^(NSURLRequest *request, NSURLResponse *response, NSError *error, id JSON) {

                if (self.responseHandlerBlock != NULL)
                {
                    self.responseHandlerBlock(JSON, [(NSHTTPURLResponse *) response allHeaderFields]);
                }

                if (errorCallback) {
                    errorCallback(JSON, error);
                }

                BOOL errorDueToConnectionProblem = response == nil;
                if (wsRequest.retryLaterOnFailure && errorDueToConnectionProblem) {
                    //[[WebServiceRequestRetryQueue instance] addRequestToRetryQueue:wsRequest];
                }
            }];

            if (operation) {
                operation.allowsInvalidSSLCertificate = self.allowsInvalidSSLCertificate;
                #if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
                [operation setShouldExecuteAsBackgroundTaskWithExpirationHandler:NULL];
                #endif
                [self.client.operationQueue addOperation:operation];
            }
        });
    });
}

- (void)makeRequest:(OBRequest *)wsRequest
            success:(OBConnectionSuccessCallback)successCallback
              error:(OBConnectionErrorCallback)errorCallback {
    [self makeRequest:wsRequest withCacheKey:nil parseBlock:NULL success:successCallback error:errorCallback];
}

+ (void)invalidatePHPSessionCookie {
    NSHTTPCookie *phpSessionCookie = nil;

    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        if ([cookie.name isEqualToString:@"PHPSESSID"]) {
            phpSessionCookie = cookie;
            break;
        }
    }

    if (phpSessionCookie) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:phpSessionCookie];
        [[self instance] setAuthenticated:NO];
    }
}

+ (void)addOperation:(NSOperation *)theOperation {
    [[self instance].client.operationQueue addOperation:theOperation];
}

+ (void)cancelAllConnections {
    [[self instance].client.operationQueue cancelAllOperations];
}

#pragma mark - Setting up Blocks
#pragma mark - Response Handler

+ (void)setResponseHandlerBlock:(OBConnectionResponseHandlerBlock)responseHandlerBlock {
    [self instance].responseHandlerBlock = responseHandlerBlock;
}

+ (OBConnectionResponseHandlerBlock)responseHandlerBlock {
    return [self instance].responseHandlerBlock;
}

#pragma mark - Security Header Request
+ (void)setBuildSecurityHeaderRequests:(OBConnectionBuildSecurityHeaderRequests)buildSecurityHeaderRequestsBlock {
    [self instance].buildSecurityHeaderRequestBlock = buildSecurityHeaderRequestsBlock;
}

+ (OBConnectionBuildSecurityHeaderRequests)buildSecurityHeaderRequests {
    return [self instance].buildSecurityHeaderRequestBlock;
}

#pragma mark - URL For A Certain Resource

+ (void)setBuildURLForResourceBlock:(OBConnectionBuildURLForResourceBlock)buildURLForResourceBlock {
    [self instance].buildURLForResourceBlock = buildURLForResourceBlock;
}

+ (OBConnectionBuildURLForResourceBlock)buildURLForResourceBlock {
    return [self instance].buildURLForResourceBlock;
}


@end
