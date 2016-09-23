//
//  ViewController.m
//  ForTwitter
//
//  Created by Embrace on 16/9/1.
//  Copyright © 2016年 http://navishealth.com. All rights reserved.
//

#import "ViewController.h"
#import <TwitterKit/TwitterKit.h>
#import "STTwitter.h"
#import <Accounts/Accounts.h>
#import "STTwitterAppOnly.h"
#import "MBProgressHUD.h"
//#define BaseScreenName @"Mr_ZhangJianhua"
//
//#define TWITTER_API_KEY @"6660cae11273a4b56d0292ea101924a102cca458"
//#define TWITTER_API_CONSOMERKEY @"ZKsuFFhycj33tAwS0IEoBEz8n"
//#define TWITTER_API_SECRET @"iOWSWU5ukiPhJ2PkGa9gBA8Z8Wr3dvK3YeKJpnPNmRb9Eip5mJ"

#define BaseScreenName @"NavisHealth"

#define TWITTER_API_KEY @"6660cae11273a4b56d0292ea101924a102cca458"
#define TWITTER_API_CONSOMERKEY @"w6Hro0KDi2TRDtU7qLmU36MVJ"
#define TWITTER_API_SECRET @"zvfJqKhyEybSVgqxBCXnLMsoEEc3TzucUY1CUMhSLGPiysmkGu"




// https://dev.twitter.com/docs/auth/implementing-sign-twitter
typedef void (^accountChooserBlock_t)(ACAccount *account, NSString *errorMessage);
@interface ViewController ()<TWTRTweetViewDelegate>
@property (nonatomic, strong) STTwitterAPI *twitter;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) NSArray *iOSAccounts;
@property (nonatomic, strong)   UITableView *ShowTweetTabView;
@property (nonatomic, strong) accountChooserBlock_t accountChooserBlock;

@end

@implementation ViewController

-(void)viewWillAppear:(BOOL)animated {
    [self dataLoadMethod];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

// One way: ************Show Tweets by TWitterKit ***********
//    [self showASingleTweet];
//    [self AddAButtonForshowTimeline];
//************End***********
    
    
    // Second Way: ************Show Tweets by STTwitter ***********
//    self.accountStore = [[ACAccountStore alloc] init];
//    [self setShowBtn];
//      [self setTweetTabView];
//************End ***********
  
    
    [self showTweetByAppOnly];
    [self setTweetTabView];
    

    
}


- (void)setShowBtn {
  
       UIButton *ShowBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [ShowBtn setTitle:@"Show More" forState:UIControlStateNormal];
//        [ShowBtn sizeToFit];
//        ShowBtn.center = self.view.center;
    ShowBtn.frame = CGRectMake(100, 20, 200, 30);
        [ShowBtn addTarget:self action:@selector(showTWeetTimeline) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:ShowBtn];
   }

-(void)setTweetTabView {
  
        CGRect frame = CGRectMake(10, 50, [UIScreen mainScreen].bounds.size.width - 20,  [UIScreen mainScreen].bounds.size.height-50);
        self.ShowTweetTabView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        _ShowTweetTabView.delegate = self;
        _ShowTweetTabView.dataSource = self;
    [self.view addSubview:_ShowTweetTabView];
  
}





- (void)showTWeetTimeline {
    __weak typeof(self) weakSelf = self;
    
    self.accountChooserBlock = ^(ACAccount *account, NSString *errorMessage) {
        
        NSString *status = nil;
        if(account) {
            status = [NSString stringWithFormat:@"Did select %@", account.username];
            
            [weakSelf loginWithiOSAccount:account];
        } else {
            status = errorMessage;
        }
        
//        weakSelf.loginStatusLabel.text = status;
    };
    
    [self chooseAccount];
    
    [_twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
        [_twitter getUserTimelineWithScreenName:@"NavisHealth" successBlock:^(NSArray *statuses) {
            NSLog(@"-- statuses: %@", statuses);
            //            self.getTimelineStatusLabel.text = [NSString stringWithFormat:@"%lu statuses", (unsigned long)[statuses count]];
            
            self.statuses = statuses;
            
            [self.ShowTweetTabView reloadData];
        } errorBlock:^(NSError *error) {
            NSLog(@"-- error: %@", error);
        }];
    } errorBlock:^(NSError *error) {
         NSLog(@"-- error: %@", error);
    }];
    
//    [_twitter verifyCredentialsWithSuccessBlock:^(NSString *bearerToken) {
//        
//        NSLog(@"Access granted with %@", bearerToken);
//        
//        [_twitter getUserTimelineWithScreenName:@"NavisHealth" successBlock:^(NSArray *statuses) {
//            NSLog(@"-- statuses: %@", statuses);
////            self.getTimelineStatusLabel.text = [NSString stringWithFormat:@"%lu statuses", (unsigned long)[statuses count]];
//            
//            self.statuses = statuses;
//            
//            [self.ShowTweetTabView reloadData];
//        } errorBlock:^(NSError *error) {
//            NSLog(@"-- error: %@", error);
//        }];
//        
//    } errorBlock:^(NSError *error) {
//        NSLog(@"-- error %@", error);
//    }];
//
    

}


-(void)showTweetByAppOnly {
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIAppOnlyWithConsumerKey:TWITTER_API_CONSOMERKEY
                                                            consumerSecret:TWITTER_API_SECRET];
    
    [twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
        
        [twitter getUserTimelineWithScreenName:BaseScreenName
                                  successBlock:^(NSArray *statuses) {
                                      
                                      NSLog(@"Success:%@", statuses);
                                      
                                      self.statuses = statuses;
                                    [self.ShowTweetTabView reloadData];
                                      
                                      // ...
                                  } errorBlock:^(NSError *error) {
                                      // ...
                                  }];
        
    } errorBlock:^(NSError *error) {
        // ...
          [self dataUnloadMethod];
         NSLog(@"-- error %@", error);
    }];
}


- (void)chooseAccount {
    
    ACAccountType *accountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    ACAccountStoreRequestAccessCompletionHandler accountStoreRequestCompletionHandler = ^(BOOL granted, NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            if(granted == NO) {
                _accountChooserBlock(nil, @"Acccess not granted.");
                NSLog(@"Acccess not granted");
                return;
            }
            
            self.iOSAccounts = [_accountStore accountsWithAccountType:accountType];
            
            if([_iOSAccounts count] == 1) {
                ACAccount *account = [_iOSAccounts lastObject];
                _accountChooserBlock(account, nil);
            } else {
                UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Select an account:"
                                                                delegate:self
                                                       cancelButtonTitle:@"Cancel"
                                                  destructiveButtonTitle:nil otherButtonTitles:nil];
                for(ACAccount *account in _iOSAccounts) {
                    [as addButtonWithTitle:[NSString stringWithFormat:@"@%@", account.username]];
                }
                [as showInView:self.view.window];
            }
        }];
    };
    
#if TARGET_OS_IPHONE &&  (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0)
    if (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_6_0) {
        [self.accountStore requestAccessToAccountsWithType:accountType
                                     withCompletionHandler:accountStoreRequestCompletionHandler];
    } else {
        [self.accountStore requestAccessToAccountsWithType:accountType
                                                   options:NULL
                                                completion:accountStoreRequestCompletionHandler];
    }
#else
    [self.accountStore requestAccessToAccountsWithType:accountType
                                               options:NULL
                                            completion:accountStoreRequestCompletionHandler];
#endif
    
}
- (void)loginWithiOSAccount:(ACAccount *)account {
    
    self.twitter = nil;
    self.twitter = [STTwitterAPI twitterAPIOSWithAccount:account delegate:self];
    
    [_twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
        
//        _loginStatusLabel.text = [NSString stringWithFormat:@"@%@ (%@)", username, userID];
        NSLog(@"@%@ (%@) ",username, userID);
        
    } errorBlock:^(NSError *error) {
//        _loginStatusLabel.text = [error localizedDescription];
        NSLog(@"%@",[error localizedDescription]);
    }];
    
}



- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier {
    
    // in case the user has just authenticated through WebViewVC
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
    
    [_twitter postAccessTokenRequestWithPIN:verifier successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName) {
        NSLog(@"-- screenName: %@", screenName);
        
//        _loginStatusLabel.text = [NSString stringWithFormat:@"%@ (%@)", screenName, userID];
//        NSLog(@"  _loginStatusLabel.text : %@",  _loginStatusLabel.text);
        
        /*
         At this point, the user can use the API and you can read his access tokens with:
         
         _twitter.oauthAccessToken;
         _twitter.oauthAccessTokenSecret;
         
         You can store these tokens (in user default, or in keychain) so that the user doesn't need to authenticate again on next launches.
         
         Next time, just instanciate STTwitter with the class method:
         
         +[STTwitterAPI twitterAPIWithOAuthConsumerKey:consumerSecret:oauthToken:oauthTokenSecret:]
         
         Don't forget to call the -[STTwitter verifyCredentialsWithSuccessBlock:errorBlock:] after that.
         */
        
    } errorBlock:^(NSError *error) {
        
//        _loginStatusLabel.text = [error localizedDescription];
        NSLog(@"-- %@", [error localizedDescription]);
    }];
}

#pragma mark -- TabViewDelegate,datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"self.statuses.count :%lu",(unsigned long)self.statuses.count);
    return [self.statuses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"STTwitterTVCellIdentifier"];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"STTwitterTVCellIdentifier"];
    }
    
    NSDictionary *status = [self.statuses objectAtIndex:indexPath.row];
    
    NSString *text = [status valueForKey:@"text"];
    NSString *screenName = [status valueForKeyPath:@"user.screen_name"];
    NSString *dateString = [status valueForKey:@"created_at"];
//    NSString*id_str = [status valueForKey:@"id_str"];
    
    
    cell.textLabel.text = [NSString stringWithFormat:@"@%@ | %@", screenName, dateString];
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.text = text;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex == [actionSheet cancelButtonIndex]) {
        _accountChooserBlock(nil, @"Account selection was cancelled.");
        return;
    }
    
    NSUInteger accountIndex = buttonIndex - 1;
    ACAccount *account = [_iOSAccounts objectAtIndex:accountIndex];
    
    _accountChooserBlock(account, nil);
}

#pragma mark STTwitterAPIOSProtocol

- (void)twitterAPI:(STTwitterAPI *)twitterAPI accountWasInvalidated:(ACAccount *)invalidatedAccount {
    if(twitterAPI != _twitter) return;
    NSLog(@"-- account was invalidated: %@ | %@", invalidatedAccount, invalidatedAccount.username);
}






#pragma mark --- Show Tweets by Fabric (Twitter Kit)

-(void) showASingleTweet {
        NSArray * arr = @[@"210462857140252672",@"738068696602546176"];
    
    
//        NSString *userID = [Twitter sharedInstance].sessionStore.session.userID;
//        NSLog(@"userID :%@", userID);
        [[[TWTRAPIClient alloc] init] loadTweetWithID:arr[0] completion:^(TWTRTweet *tweet, NSError *error) {
            if (tweet) {
                TWTRTweetView *tweetView1 = [[TWTRTweetView alloc] initWithTweet:tweet style:TWTRTweetViewStyleCompact];
    
    //            tweetView.center = CGPointMake(self.view.center.x, self.topLayoutGuide.length + tweetView.frame.size.height / 2);
                 tweetView1.frame = CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, 300);
                TWTRTweetView *tweetView2 = [[TWTRTweetView alloc] initWithTweet:tweet style:TWTRTweetViewStyleCompact];
    
                //            tweetView.center = CGPointMake(self.view.center.x, self.topLayoutGuide.length + tweetView.frame.size.height / 2);
                tweetView2.frame = CGRectMake([UIScreen mainScreen].bounds.size.width, 0,[UIScreen mainScreen].bounds.size.width, 300);
    
                UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 300)];
                scrollView.backgroundColor = [UIColor lightGrayColor];
                scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width *2, 100);
                scrollView.contentOffset = CGPointMake(0, 0);
                [scrollView addSubview:tweetView1];
                [scrollView addSubview:tweetView2];
    
    
    
    
    
                [self.view addSubview:scrollView];
            } else {
                NSLog(@"Tweet load error: %@", [error localizedDescription]);
            }
        }];
    
    
   }

- (void)AddAButtonForshowTimeline {
    // Add a button to the center of the view to show the timeline
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:@"Show Timeline" forState:UIControlStateNormal];
        [button sizeToFit];
        button.center = self.view.center;
        [button addTarget:self action:@selector(showTimeline) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
       [self showTimeline];

}
- (void)showTimeline {
    // Create an API client and data source to fetch Tweets for the timeline
    TWTRAPIClient *client = [[TWTRAPIClient alloc] init];
    TWTRCollectionTimelineDataSource *datasource = [[TWTRCollectionTimelineDataSource alloc] initWithCollectionID:@"393773266801659904" APIClient:client];
    TWTRTimelineViewController *controller = [[TWTRTimelineViewController alloc] initWithDataSource:datasource];
    // Create done button to dismiss the view controller
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissTimeline)];
    controller.navigationItem.leftBarButtonItem = button;
    // Create a navigation controller to hold the
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self showDetailViewController:navigationController sender:self];
}

- (void)dismissTimeline {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark ---
- (void) generateAPIKeyWithCompletionBlock:(void (^)(BOOL success, NSString* twitterOAuthToken, NSString *error))completion {
    //Network tasks should be in background thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        //Generate Bearer Token according to Twitter Documentation
        NSString* bearerToken = [NSString stringWithFormat:@"%@:%@", TWITTER_API_KEY , TWITTER_API_SECRET];
        bearerToken = [[bearerToken dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
        NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
        [request addValue:[NSString stringWithFormat:@"Basic %@",bearerToken] forHTTPHeaderField:@"Authorization"];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[@"grant_type=client_credentials" dataUsingEncoding:NSUTF8StringEncoding]];
        [request setURL:[NSURL URLWithString:@"https://api.twitter.com/oauth2/token"]];
        NSURLResponse *response;
        NSError* e;
        NSData* data = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:&response
                                                         error:&e];
        BOOL success = NO;
        NSString* twitterOAuthToken;
        if(!e && data){
            NSDictionary* answer = [NSJSONSerialization JSONObjectWithData:data options:0 error:&e];
            if(!e && [answer valueForKey:@"access_token"]){
                twitterOAuthToken = [answer valueForKey:@"access_token"];
                success = YES;
                NSLog(@"twitterOAuthToken :%@",twitterOAuthToken);
            }
        }
        if (completion){
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(success, twitterOAuthToken, e.description);
            });
        }
    });
}

#pragma mark --- MBProgressHUD
- (void) dataUnloadMethod
{
    [MBProgressHUD hideHUDForView:self.tabBarController.view animated:YES];
}
- (void) dataLoadMethod
{
    [MBProgressHUD showHUDAddedTo:self.tabBarController.view animated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --- Twitter 


@end
