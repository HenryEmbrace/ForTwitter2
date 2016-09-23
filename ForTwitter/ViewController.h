//
//  ViewController.h
//  ForTwitter
//
//  Created by Embrace on 16/9/1.
//  Copyright © 2016年 http://navishealth.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STTwitter.h"
@interface ViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,STTwitterAPIOSProtocol,UIActionSheetDelegate>
@property (nonatomic, strong) NSArray *statuses;




- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verfier;

@end

