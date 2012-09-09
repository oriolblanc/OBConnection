//
//  OBRequestParameters.m
//  OBConnection
//
//  Created by Oriol Blanc on 20/04/11.
//  Copyright (c) 2012 Oriol Blanc. All rights reserved.
//

#import "OBRequestParameters.h"

@interface OBRequestParameters ()
    @property (nonatomic, readonly) NSDictionary *parametersDictionary;
@end

@implementation OBRequestParameters
@synthesize parametersDictionary = _parametersDictionary;

+ (OBRequestParameters *)emptyRequestParameters
{
    OBRequestParameters *requestParameters = [[OBRequestParameters alloc] init];
    
    return [requestParameters autorelease];
}

- (id)init
{
    if ((self = [super init]))
    {
        _parametersDictionary = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init]))
    {
        _parametersDictionary = [[aDecoder decodeObjectForKey:@"parametersDictionary"] retain];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.parametersDictionary forKey:@"parametersDictionary"];
}

#pragma mark - Public methods

- (void)setValue:(id)value forKey:(NSString *)parameterName
{
    if (value)
    {
        [_parametersDictionary setValue:value forKey:parameterName];
    }
    else
    {
        NSLog(@"Tried to set a nil value for parameter %@", parameterName);
    }
}

- (NSString *)description
{
    return [_parametersDictionary description];
}

#pragma mark - Memory Mangement

- (void)dealloc
{
    [_parametersDictionary release];
    
    [super dealloc];
}

@end
