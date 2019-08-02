//
//  LoginViewModel.h
//  ReactiveObjC-Network-Request
//
//  Created by raxabizze on 2019/8/2.
//  Copyright © 2019 raxabizze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReactiveObjC.h"

@class RACSignal,RACCommand;
@interface RequestViewModel : NSObject

@property (nonatomic, strong) NSString *delay;
@property (nonatomic, strong) NSString *page;
@property (nonatomic, strong) RACSubject *mesage;
@property (nonatomic, strong) RACSubject *isLoading;
@property (nonatomic, strong) RACSignal *isEnable;
@property (nonatomic, strong) RACCommand *loginCommand;
@end
