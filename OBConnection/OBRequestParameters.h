//
//  OBRequestParameters.h
//  OBConnection
//
//  Created by Oriol Blanc on 20/04/11.
//  Copyright (c) 2012 Oriol Blanc. All rights reserved.
//

@interface OBRequestParameters : NSObject

@property (nonatomic, strong) NSDictionary *parametersDictionary;

+ (OBRequestParameters *)emptyRequestParameters;

@end
