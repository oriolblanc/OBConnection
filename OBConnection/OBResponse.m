//
//  OBResponse.m
//  OBConnection
//
//  Created by Oriol Blanc on 20/04/11.
//  Copyright (c) 2012 Oriol Blanc. All rights reserved.
//

#import "OBResponse.h"
@interface OBResponse ()
- (id)initWithDictionary:(NSDictionary *)response headerFields:(NSDictionary *)headerFields;
- (id)initWithCode:(NSInteger)statusCode message:(NSString *)message body:(NSDictionary *)body headerFields:(NSDictionary *)headerFields;
@end

@implementation OBResponse
@synthesize statusCode = _statusCode;
@synthesize message = _message;
@synthesize body = _body;
@synthesize headerFields = _headerFields;

+ (OBResponse *)responseWithDictionary:(NSDictionary *)response
                          headerFields:(NSDictionary *)headerFields
{
    return [[[self alloc] initWithDictionary:response headerFields:headerFields] autorelease];
}

+ (OBResponse *)responseWithCode:(NSInteger)statusCode
                         message:(NSString *)message
                            body:(NSDictionary *)body
                    headerFields:(NSDictionary *)headerFields
{
    return [[[self alloc] initWithCode:statusCode message:message body:body headerFields:headerFields] autorelease];
}

- (id)initWithDictionary:(NSDictionary *)response headerFields:(NSDictionary *)headers
{
    if ((self = [super init]))
    {
        if (response != nil)
        {
            self.statusCode = OBResponseCodeNoError;
            self.body = response;
            self.headerFields = headers;
        }
        else
        {
            self.statusCode = OBResponseCodeGlobalError;
            self.body = response;
            self.message = nil;
        }
    }
    
    return self;
}

- (id)initWithCode:(NSInteger)code
           message:(NSString *)responsMessage
              body:(NSDictionary *)responseBody
      headerFields:(NSDictionary *)responseHeaders
{
    
    if ((self = [super init]))
    {
        if (code == OBResponseCodeUndefinedError)
            self.statusCode = OBResponseCodeGlobalError;
        else
            self.statusCode = code;
        
        self.message = responsMessage;
        self.body = responseBody;
        self.headerFields = responseHeaders;
    }
    
    return self;
}

#pragma mark - Memory Management

- (void)dealloc {
    [_message release];
    [_body release];
    [_headerFields release];
    
    [super dealloc];
}

@end
