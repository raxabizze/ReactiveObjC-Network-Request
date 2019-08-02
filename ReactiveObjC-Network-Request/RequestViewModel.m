//
//  LoginViewModel.m
//  ReactiveObjC-Network-Request
//
//  Created by raxabizze on 2019/8/2.
//  Copyright © 2019 raxabizze. All rights reserved.
//

#import "RequestViewModel.h"
#import "ReactiveObjC.h"

//https://stackoverflow.com/a/9404207
//https://stackoverflow.com/a/42669357

//https://juejin.im/post/5a3360806fb9a0452a3c5fd7
//https://draveness.me/racscheduler

//https://www.jianshu.com/p/c650108264e1
@implementation RequestViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isLoading = [RACSubject subject];
        _mesage = [RACSubject subject];
        [self setUp];
    }
    return self;
}

- (void)setUp {
    
    _isEnable = [RACSignal combineLatest:@[RACObserve(self, delay), RACObserve(self, page)] reduce:^id _Nullable(NSString * account,NSString * password) {
        return @([account isEqual: @""] || [password isEqual: @""]);
    }];
    
    _loginCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [[[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            NSLog(@"Current Thread %@", [NSThread currentThread]);
            
            // MARK: - Get
            NSString *requestURL = [NSString stringWithFormat:@"https://reqres.in/api/users?delay=%@&page=%@",
                                    self->_delay, self->_page];
            NSString *result = [self getDataFrom:requestURL];
            
            // MARK: - Post
            // NSString *result = [self getDataFrom:@"https://reqres.in/api/users" withBody:[self makePostRequest]];
            
            // MARK: - Parse Json
            NSString *responseDate = [self parseJSON:result];
            
            [subscriber sendNext:responseDate];
            [subscriber sendCompleted];
            
            return [RACDisposable disposableWithBlock:^{
                NSLog(@"Return %@", result);
                [self->_mesage sendNext:result];
            }];
        }] subscribeOn:[RACScheduler scheduler]] deliverOn:RACScheduler.mainThreadScheduler];
    }];
    
    
    [[_loginCommand.executing skip:1] subscribeNext:^(NSNumber * _Nullable x) {
        NSLog(@"Subscribe Thread %@", [NSThread currentThread]);
        if ([x boolValue]) {
            [self->_isLoading sendNext:@YES];
        }else{
            [self->_isLoading sendNext:@NO];
        }
    }];
}

- (NSString *) parseJSON:(NSString *)jsonString {
    NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *jsonError;
    NSArray *jsonDataArray = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&jsonError];
    
    NSLog(@"jsonDataArray: %@",jsonDataArray);
    
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&jsonError];
    if(jsonObject !=nil){
        NSLog(@"%@", jsonObject[@"page"]);
        NSLog(@"%@", jsonObject[@"per_page"]);
        NSLog(@"%@", jsonObject[@"total"]);
        NSLog(@"%@", jsonObject[@"total_pages"]);
        return jsonObject[@"total"];
    }
    return @"";
}

- (NSData *) makePostRequest {
    //Make an NSDictionary that would be converted to an NSData object sent over as JSON with the request body
    NSDictionary *tmp = [[NSDictionary alloc] initWithObjectsAndKeys:
                         @"delay", @"3",
                         @"name", @"morpheus",
                         @"job", @"leader",
                         @"delay", @"3",
                         nil];
    NSError *error;
    return [NSJSONSerialization dataWithJSONObject:tmp options:0 error:&error];
}

- (NSString *) getDataFrom:(NSString *)url{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];
    
    return [self handleNetWorkRequest:request];
}

- (NSString *) getDataFrom:(NSString *)url withBody:(NSData *)body{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:body];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setURL:[NSURL URLWithString:url]];
    
    return [self handleNetWorkRequest:request];
}

-(NSString *) handleNetWorkRequest:(NSMutableURLRequest *)request {
    NSError *error = nil;
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] < 200 || [responseCode statusCode] > 299){
        [_mesage sendNext:@"Request Error!:!"];
        NSLog(@"Error getting %@, HTTP status code %li", request.URL, (long)[responseCode statusCode]);
        NSLog(@"%@", error);
        return nil;
    }
    
    return [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
}

@end
