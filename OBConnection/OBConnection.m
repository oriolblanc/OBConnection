//
//  OBConnection.m
//  OBConnection
//
//  Created by Oriol Blanc on 20/04/11.
//  Copyright (c) 2012 Oriol Blanc. All rights reserved.
//


#import "AFNetworkActivityIndicatorManager.h"
#import "OBCache.h"
#define kSeparator @"p=0_Kr9z-$M"

#import "OBConnection.h"

@interface OBConnection ()
    @property (nonatomic, retain) AFHTTPClient *client;
    @property (nonatomic, assign) BOOL authenticated;
    @property (nonatomic, assign) id<OBConnectionDelegate> delegate;

    @property (nonatomic, copy) OBConnectionResponseHandlerBlock responseHandlerBlock;
    @property (nonatomic, assign) dispatch_queue_t connectionDispatchQueue;

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
@synthesize delegate = _delegate;
@synthesize responseHandlerBlock = _responseHandlerBlock;
@synthesize connectionDispatchQueue;

#pragma mark - Singleton

+ (OBConnection *)instance
{
    static dispatch_once_t dispatchOncePredicate;
    static OBConnection *myInstance = nil;
    
    dispatch_once(&dispatchOncePredicate, ^{
        myInstance = [[self alloc] init];
        myInstance.connectionDispatchQueue = dispatch_queue_create("WebProxyDispatchQueue", DISPATCH_QUEUE_CONCURRENT);
        [myInstance setAuthenticated:NO];
        
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
	});
    
    return myInstance;
}

+ (void)registerWithBaseUrl:(NSURL *)baseUrl delegate:(id<OBConnectionDelegate>)delegate
{
    [self registerWithBaseUrl:baseUrl delegate:delegate responseHandlerBlock:NULL];
}

+ (void)registerWithBaseUrl:(NSURL *)baseUrl
                   delegate:(id<OBConnectionDelegate>)delegate
       responseHandlerBlock:(OBConnectionResponseHandlerBlock)responseHandlerBlock
{
    OBConnection *connection = [OBConnection instance];
    connection.delegate = delegate;
    connection.responseHandlerBlock = responseHandlerBlock;
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseUrl];
    connection.client = client;
    [client release];
}


+ (void)makeRequest:(OBRequest *)wsRequest
            success:(OBConnectionSuccessCallback)successCallback
              error:(OBConnectionErrorCallback)errorCallback
{
    [[self instance] makeRequest:wsRequest success:successCallback error:errorCallback];
}

+ (void)makeRequest:(OBRequest *)wsRequest
       withCacheKey:(NSString *)cacheKey
         parseBlock:(OBConnectionDataParsingBlock)parsingBlock
            success:(OBConnectionSuccessCallback)successCallback
              error:(OBConnectionErrorCallback)errorCallback
{
    [[self instance] makeRequest:wsRequest withCacheKey:cacheKey parseBlock:parsingBlock success:successCallback error:errorCallback];
}

#pragma mark - Request

- (void)makeRequest:(OBRequest *)wsRequest
       withCacheKey:(NSString *)cacheKey
         parseBlock:(OBConnectionDataParsingBlock)parsingBlock
            success:(OBConnectionSuccessCallback)successCallback
              error:(OBConnectionErrorCallback)errorCallback
{
    
    dispatch_async(self.connectionDispatchQueue, ^{
        if (cacheKey)
        {
            id cachedData = [OBCache cachedObjectForKey:cacheKey];
            if (cachedData)
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    successCallback(cachedData, YES);
                });
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // run the request
            
            NSMutableURLRequest *request = nil;
            
            switch (wsRequest.requestType) {
                case OBRequestMethodTypeMethodGET:
                default:
                {
                    request = [self.client requestWithMethod:@"GET" path:wsRequest.resource parameters:[wsRequest.parameters parametersDictionary]];
                    break;
                }
                case OBRequestMethodTypeMultiForm:
                {
                    errorCallback(nil,[NSError errorWithDomain:nil code:0 userInfo:[NSDictionary dictionaryWithObject:@"Type not implemented" forKey:@"userInfo"]]);
                    break;
                }
                case OBRequestMethodTypeMethodPOST:
                {
                    request = [self.client requestWithMethod:@"POST" path:wsRequest.resource parameters:[wsRequest.parameters parametersDictionary]];
                    break;
                }
            }
            
            // we should authenticate the session for private requests
            NSMutableDictionary *allHeaders = [[request.allHTTPHeaderFields mutableCopy] autorelease];
            if (!wsRequest.isPublic)
            {
                NSDictionary *securityHeader = [self.delegate connectionSecurityHeaderForPrivateRequest];
                
                if (securityHeader != nil)
                {
                    [allHeaders addEntriesFromDictionary:securityHeader];
                }
            }
            [request setAllHTTPHeaderFields:allHeaders];
            
            // do request
            AFHTTPRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSURLResponse *response, id JSON) {
                
                BOOL responseHandledWithoutErrors = (self.responseHandlerBlock != NULL) ? responseHandledWithoutErrors = self.responseHandlerBlock(JSON, [(NSHTTPURLResponse *)response allHeaderFields]) : YES;
                
                if (responseHandledWithoutErrors)
                {
                    if (successCallback)
                    {
                        id parsedData = JSON;
                        
                        if (parsingBlock)
                        {
                            parsedData = parsingBlock(parsedData);
                        }
                        
                        if (cacheKey)
                        {
                            [OBCache cacheObject:parsedData forKey:cacheKey];
                        }
                        
                        successCallback(parsedData, NO);
                    }
                }
                else
                {
                    if (errorCallback)
                    {
                        errorCallback(nil, nil); // @todo: Should create a proper NSError here
                    }
                }
                
            } failure:^(NSURLRequest *request, NSURLResponse *response, NSError *error, id JSON) {
                
                BOOL responseHandledWithoutErrors = (self.responseHandlerBlock != NULL) ? responseHandledWithoutErrors = self.responseHandlerBlock(JSON, [(NSHTTPURLResponse *)response allHeaderFields]) : YES;
                
                if (errorCallback)
                {
                    errorCallback(NULL, error);
                }
                
                BOOL errorDueToConnectionProblem = response == nil;
                if (wsRequest.retryLaterOnFailure && errorDueToConnectionProblem)
                {
                    //[[WebServiceRequestRetryQueue instance] addRequestToRetryQueue:wsRequest];
                }
            }];
            
            if (operation)
            {
                [self.client.operationQueue addOperation:operation];
            }
        });
    });
}

- (void)makeRequest:(OBRequest *)wsRequest
            success:(OBConnectionSuccessCallback)successCallback
              error:(OBConnectionErrorCallback)errorCallback
{
    [self makeRequest:wsRequest withCacheKey:nil parseBlock:NULL success:successCallback error:errorCallback];
}

+ (void)invalidatePHPSessionCookie
{
    NSHTTPCookie *phpSessionCookie = nil;
    
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
    {
        if ([cookie.name isEqualToString:@"PHPSESSID"])
        {
            phpSessionCookie = cookie;
            break;
        }
    }
    
    if (phpSessionCookie)
    {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:phpSessionCookie];
        [[[self class] instance] setAuthenticated:NO];
    }
}

+ (void)addOperation:(NSOperation *)theOperation
{
    [[self instance].client.operationQueue addOperation:theOperation];
}

+ (void)cancelAllConnections
{
    [[self instance].client.operationQueue cancelAllOperations];
}

#pragma mark - Memory Management

- (void)dealloc
{
    if (_responseHandlerBlock != NULL)
    {
        [_responseHandlerBlock release];
    }
    [_client release];
    dispatch_release(self.connectionDispatchQueue);
    
    [super dealloc];
}

@end
