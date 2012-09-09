//
//  OBResponse.h
//  OBConnection
//
//  Created by Oriol Blanc on 20/04/11.
//  Copyright (c) 2012 Oriol Blanc. All rights reserved.
//

typedef enum {
    OBResponseCodeUndefinedError        = 0,
    OBResponseCodeNoError               = 200,
    
    OBResponseCodeGlobalError           = 110,
    OBResponseCodeExpiredSession        = 111,
    OBResponseCodeInvalidParam          = 112,
    OBResponseCodeAuthenticationError   = 403,
    
    
    OBResponseCodeLogout                = 1000
} OBResponseCode;

@interface OBResponse : NSObject

@property (nonatomic, assign) NSInteger     statusCode;
@property (nonatomic, retain) NSString      *message;
@property (nonatomic, retain) NSDictionary  *body;
@property (nonatomic, retain) NSDictionary  *headerFields;

+ (OBResponse *)responseWithDictionary:(NSDictionary *)response
                          headerFields:(NSDictionary *)headerFields;

+ (OBResponse *)responseWithCode:(NSInteger)statusCode
                         message:(NSString *)message
                            body:(NSDictionary *)body
                    headerFields:(NSDictionary *)headerFields;

@end
