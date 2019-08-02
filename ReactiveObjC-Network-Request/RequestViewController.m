//
//  ViewController.m
//  ReactiveObjC-Network-Request
//
//  Created by raxabizze on 2019/8/2.
//  Copyright © 2019 raxabizze. All rights reserved.
//

#import "RequestViewController.h"
#import "ReactiveObjC.h"
#import "RACReturnSignal.h"
#import "RequestViewModel.h"

@interface RequestViewController ()

@property (strong, nonatomic) IBOutlet UITextField *delayTextField;
@property (strong, nonatomic) IBOutlet UITextField *pageTextField;
@property (strong, nonatomic) IBOutlet UIButton *requestButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic, strong) RequestViewModel *viewModel;

@end

@implementation RequestViewController

- (RequestViewModel *)viewModel {
    if (!_viewModel){
        _viewModel = [[RequestViewModel alloc] init];
    }
    return _viewModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    RAC(self.viewModel, delay) = _delayTextField.rac_textSignal;
    RAC(self.viewModel, page) = _pageTextField.rac_textSignal;
    
    RAC(_requestButton, enabled) = [self.viewModel.isEnable not];
    RAC(_requestButton, hidden) = self.viewModel.isLoading;
    RAC(_indicator, animating) = self.viewModel.isLoading;
    RAC(_indicator, hidden) = [self.viewModel.isLoading not];
    
    [self.viewModel.loginCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        NSLog(@"Successful!!!!  %@", x);
    }];
    
    [[self.viewModel.mesage deliverOn:RACScheduler.mainThreadScheduler] subscribeNext:^(id  _Nullable x) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Message"
                                                                       message:x
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }];
    
    [[_requestButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [self.viewModel.loginCommand execute:@{@"account":self->_delayTextField.text,@"password":self->_pageTextField.text}];
    }];
}

@end
