//
//  OBRequest.m
//  OBConnection
//
//  Created by Oriol Blanc on 20/04/11.
//  Copyright (c) 2012 Oriol Blanc. All rights reserved.
//

#import "OBRequest.h"

#import "OBConnection.h"

#define kDefaultTimeout 60

@interface OBRequest ()
@property(nonatomic, retain) NSMutableDictionary *requestHeaderFields;

+ (id)requestWithIsPublic:(BOOL)_isPublic;
@end

@implementation OBRequest
@synthesize isPublic = _isPublic;
@synthesize retryLaterOnFailure = _retryLaterOnFailure;
@synthesize requestType = _requestType;
@synthesize resource = _resource;
@synthesize parameters = _parameters;
@synthesize files = _files;
@synthesize requestHeaderFields = _requestHeaderFields;

#pragma mark - Static constrictors

+ (id)requestWithIsPublic:(BOOL)_isPublic {
    return [[self alloc] initWithIsPublic:_isPublic];
}

+ (id)requestWithType:(OBRequestMethodType)_method
             resource:(NSString *)_resource
           parameters:(OBRequestParameters *)_parameters {
    return [[self alloc] initWithType:_method resource:_resource parameters:_parameters];
}

+ (id)requestWithType:(OBRequestMethodType)_method
             resource:(NSString *)_resource
           parameters:(OBRequestParameters *)_parameters
             isPublic:(BOOL)_isPublic {
    return [[self alloc] initWithType:_method resource:_resource parameters:_parameters isPublic:_isPublic];
}

+ (id)requestWithType:(OBRequestMethodType)_method
             resource:(NSString *)_resource
           parameters:(OBRequestParameters *)_parameters
                files:(OBRequestParameters *)_files
             isPublic:(BOOL)_isPublic {
    return [[self alloc] initWithType:_method resource:_resource parameters:_parameters files:_files isPublic:_isPublic];
}

#pragma mark - Instance constrictors

- (id)initWithType:(OBRequestMethodType)type
          resource:(NSString *)resource
        parameters:(OBRequestParameters *)parameters {
    return [self initWithType:type resource:resource parameters:parameters files:nil isPublic:NO];
}

- (id)initWithType:(OBRequestMethodType)type
          resource:(NSString *)resource
        parameters:(OBRequestParameters *)parameters
          isPublic:(BOOL)isPublic {
    if ((self = [self initWithIsPublic:isPublic])) {
        self.requestType = type;
        self.parameters = parameters;
        self.files = nil;

        [self buildURL:resource];
    }

    return self;
}

- (id)initWithType:(OBRequestMethodType)type
          resource:(NSString *)resource
        parameters:(OBRequestParameters *)parameters
             files:(OBRequestParameters *)files
          isPublic:(BOOL)isPublic {
    if ((self = [self initWithIsPublic:isPublic])) {
        self.requestType = type;
        self.parameters = parameters;
        self.files = files;

        [self buildURL:resource];
    }

    return self;
}

- (id)initWithIsPublic:(BOOL)isPublic {
    self = [super init];
    if (!self) {
        return nil;
    }

    self.isPublic = isPublic;
    self.retryLaterOnFailure = NO;
    self.timeoutInterval = kDefaultTimeout;
    self.requestHeaderFields = [NSMutableDictionary dictionary];

    return self;
}

- (void)buildURL:(NSString *)resource {
    NSString *buildUrl = nil;

    OBConnectionBuildURLForResourceBlock buildURLBlock = [OBConnection buildURLForResourceBlock];

    if (buildURLBlock != NULL)
    {
        buildUrl = buildURLBlock(resource, !self.isPublic);
    }
    else
    {
        buildUrl = resource;
    }
    
    self.resource = [buildUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        self.requestType = [aDecoder decodeIntForKey:@"requestType"];
        self.resource = [aDecoder decodeObjectForKey:@"resource"];
        self.parameters = [aDecoder decodeObjectForKey:@"parameters"];
        self.files = [aDecoder decodeObjectForKey:@"files"];
        self.isPublic = [aDecoder decodeBoolForKey:@"isPublic"];
        self.retryLaterOnFailure = [aDecoder decodeBoolForKey:@"retryLaterOnFailure"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt:self.requestType forKey:@"requestType"];
    [aCoder encodeObject:self.resource forKey:@"resource"];
    [aCoder encodeObject:self.parameters forKey:@"parameters"];
    [aCoder encodeObject:self.files forKey:@"files"];
    [aCoder encodeBool:self.isPublic forKey:@"isPublic"];
    [aCoder encodeBool:self.retryLaterOnFailure forKey:@"retryLaterOnFailure"];
}

#pragma mark -

- (NSString *)description {
    return [NSString stringWithFormat:@"[OBRequest] URL: %@  parameters: %@", self.resource, self.parameters];
}

@end
