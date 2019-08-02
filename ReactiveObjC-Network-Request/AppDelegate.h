//
//  AppDelegate.h
//  ReactiveObjC-Network-Request
//
//  Created by raxabizze on 2019/8/2.
//  Copyright © 2019 raxabizze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

