//
//  K9ServerProvider.m
//  knizniki
//
//  Created by Sania on 18.03.14.
//  Copyright (c) 2014 Orangesoft. All rights reserved.
//

#import "K9ServerProvider.h"
#import "K9AppDelegate.h"
//#import "K9ChatManager.h"

#define SERVER_PROVIDER_USE_AUTO_RESTORE_PRODUCTS false

@interface K9ServerProvider()
@property (nonatomic, strong) NSMutableSet* m_purchased;
@property (nonatomic, strong) NSMutableSet* m_purchasedBooksID;
@property (nonatomic, strong) NSMutableSet* m_purchasedNeedTest;
@property (nonatomic, strong) NSRecursiveLock* m_syncLock;
@property (nonatomic, assign) NSInteger m_internetNotAvailableCounter;
@property (nonatomic, strong) NSString* p_changePhoneNumber;
@property (nonatomic, strong) NSNumber* p_myUserID;
@property (nonatomic, strong) NSMutableDictionary* p_settings;
@end

#pragma mark -

@implementation K9ServerProvider
@synthesize m_purchased;
@synthesize m_purchasedNeedTest;
@synthesize m_purchasedBooksID;
@synthesize m_syncLock;
@synthesize m_phone, token, confirmation_token;
@synthesize m_internetNotAvailableCounter;
@synthesize p_changePhoneNumber;
#pragma mark -

+ (K9ServerProvider*)shared
{
    static K9ServerProvider* __instance = nil;
    static dispatch_once_t __onceToken;
    dispatch_once(&__onceToken, ^
                  {
                      __instance = [[K9ServerProvider alloc] init];
                  });
    return __instance;
}

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        //m_booksLoaded = [[NSUserDefaults standardUserDefaults] boolForKey:@"loaded"];
        m_canTryRestore = YES;
        m_needAutoRestore = YES;
        self.m_syncLock = [NSRecursiveLock new];
        self.token = @"";//SERVER_TOKEN_TEST;
        self.m_purchased = [NSMutableSet set];
        self.m_purchasedNeedTest = [NSMutableSet set];
        self.m_purchasedBooksID = [NSMutableSet set];
        m_timeForNextUpdate = UPDATE_TIME_STEP_MIN;
        m_providerQueue = dispatch_queue_create("Server Provider Thread", DISPATCH_QUEUE_SERIAL);
        
        self.m_internetNotAvailableCounter = -1;
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onProductInfoAvailable:) name:kProductFetchedNotification object:nil];
    }
    return self;
}

+ (BOOL)showServerError:(NSError*)error
{
    return [K9ServerProvider showServerError:error withDelegate:nil];
}

+ (BOOL)showServerError:(NSError*)error withDelegate:(id<UIAlertViewDelegate>)delegate
{
    if (error)
    {
        if ([K9ServerManager isNetworkAvailable])
        {
            id responseBody = error.userInfo[ERROR_USER_INFO_KEY];
            if (responseBody)
            {
                if ([responseBody isKindOfClass:[NSDictionary class]])
                {
            //        LOG(@"Error: %@", [K9ServerManager convertDictionaryToString:(NSDictionary*)responseBody leftSymbols:@""]);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSDictionary* response = (NSDictionary*)responseBody;
                        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:STR(response[ERROR_FIELD_TITLE] ? response[ERROR_FIELD_TITLE] : response[ERROR_FIELD_ERRORS])
                                                                        message:STR(response[ERROR_FIELD_MESSAGE])
                                                                       delegate:delegate
                                                              cancelButtonTitle:ALERT_OK
                                                              otherButtonTitles:nil];
                        alert.tag = AlertTag_ServerError;
                        [alert show];
                    });
                    return YES;
                }
            }
            
            if (error)
            {
         //       LOG(@"Error: %@", error.localizedDescription);
                
                if (error.localizedRecoverySuggestion)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:ALERT_ATTENTION
                                                                        message:error.localizedRecoverySuggestion
                                                                       delegate:delegate
                                                              cancelButtonTitle:ALERT_OK
                                                              otherButtonTitles:nil];
                        alert.tag = AlertTag_ServerError;
                        [alert show];
                    });
                    
                    return YES;
                }
            }
            
            if (error.code == NSURLErrorCancelled) {
                return YES;
            }
        
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:ALERT_ATTENTION message:ALERT_SERVER_ERROR delegate:delegate cancelButtonTitle:ALERT_OK otherButtonTitles:nil];
                alert.tag = AlertTag_ServerError;
                [alert show];
            });
        }
        else
        {
            if ([K9ServerProvider shared].m_internetNotAvailableCounter < -INTERNET_NOT_AVAILABLE_SHOW_COUNT)
            {
                [K9ServerProvider shared].m_internetNotAvailableCounter = INTERNET_NOT_AVAILABLE_IGNORE_COUNT;
            }
            
            if ([K9ServerProvider shared].m_internetNotAvailableCounter < 0)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:ALERT_ATTENTION message:ALERT_INTENET_NOT_AVAILABLE delegate:delegate cancelButtonTitle:ALERT_OK otherButtonTitles:nil];
                    alert.tag = AlertTag_InternetNotAvailable;
                    [alert show];
                });
            }
            --[K9ServerProvider shared].m_internetNotAvailableCounter;
        }
        return YES;
    }
    return NO;
}

+ (NSString*)fileNameFromURL:(NSString*)url
{
    NSString* fileName = [url lastPathComponent];
    NSRange range = [fileName rangeOfString:@"?"];
    if (range.length > 0)
    {
        fileName = [fileName substringToIndex:range.location];
    }
    return fileName;
}

+ (NSString*)fontsDirectory
{
    return @"Fonts";
}

#pragma mark -
- (void)setActive:(SetActiveRequest*)request completed:(void(^)(SetActiveResponse* result, NSError* error))completed
{
    NSString* relativeURL = [NSString stringWithFormat:@"%@%@", self.domain, self.siteActivePath];
    [[K9ServerManager shared] postRequest:request
                              requestType:ServerManagerRequestType_JSON
                       requestRelativeURL:relativeURL
                               uploadData:nil
                            responseClass:[SetActiveResponse class]
                                 delegate:completed];
}

- (void)setAccess:(SetAccessRequest*)request completed:(void(^)(SetAccessResponse* result, NSError* error))completed
{
    NSString* relativeURL = [NSString stringWithFormat:@"%@%@", self.domain, self.userAccessPath];
    [[K9ServerManager shared] postRequest:request
                              requestType:ServerManagerRequestType_JSON
                       requestRelativeURL:relativeURL
                               uploadData:nil
                            responseClass:[SetAccessResponse class]
                                 delegate:completed];
}

- (void)getStatus:(GetStateRequest*)request completed:(void(^)(GetStateResponse* response, NSError* error))completed
{
    NSString* relativeURL = [NSString stringWithFormat:@"%@%@", self.domain, self.currentStatePath];
    [[K9ServerManager shared] postRequest:request
                              requestType:ServerManagerRequestType_JSON
                       requestRelativeURL:relativeURL
                               uploadData:nil
                            responseClass:[GetStateResponse class]
                                 delegate:completed];
}


//- (void)getSiteStateForDomain:(NSString*)domain completed:(void(^)(GetStateResponse* response, NSError* error))completed
//{
//    NSString* relativeURL = [NSString stringWithFormat:@"%@,%@", domain, [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_URL_STATUS]];
//    [[K9ServerManager shared] postRequest:nil
//                              requestType:ServerManagerRequestType_JSON
//                       requestRelativeURL:relativeURL
//                               uploadData:nil
//                            responseClass:[GetStateResponse class]
//                                 delegate:completed];
//    
//    
////    [[K9ServerManager shared] getRequest:nil
////                             requestType:ServerManagerRequestType_JSON
////                      requestRelativeURL:relativeURL
////                           responseClass:[GetStateResponse class]
////                                delegate:completed];
//}

- (void)authorizationWithLogin:(NSString*)login password:(NSString*)password completed:(void(^)(AuthorizationResponse* result, NSError* error))completed
{
    AuthorizationRequest* request = [AuthorizationRequest new];
    request.user = @"polesiepotolki";//login;
    request.pass = @"polesiepotolki";//password;
    [[K9ServerManager shared] postRequest:request
                              requestType:ServerManagerRequestType_JSON
                       requestRelativeURL:[[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_AUTHORIZATION]
                               uploadData:nil
                            responseClass:[AuthorizationResponse class]
                                 delegate:^(AuthorizationResponse* response, NSError *error) {
                                     if (!error)
                                     {
                                         [[K9ServerManager shared].HTTPsession.requestSerializer setValue:[NSString stringWithFormat:SERVER_HEADER_TOKEN_VALUE, response.data.access_token] forHTTPHeaderField:SERVER_HEADER_TOKEN_NAME];
                                     }
                                     if (completed) {
                                         completed(response, error);
                                     }
                                 }];
}

#pragma mark - Settings
- (void)loadSettings
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_SETTINGS]) {
        self.p_settings = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_SETTINGS]];
    }
}

- (void)saveSettings
{
    [[NSUserDefaults standardUserDefaults] setObject:self.p_settings forKey:DEFAULTS_SETTINGS];
}

- (BOOL)validateSettings
{
    if (self.domain.length && self.siteActivePath.length && self.userAccessPath.length && self.currentStatePath.length) {
        return YES;
    }    
    return NO;
}

- (void)setDomain:(NSString*)path
{
    [self.p_settings setValue:path forKey:DEFAULTS_DOMAIN];
}

- (NSString*)domain
{
    return [self.p_settings valueForKey:DEFAULTS_DOMAIN];
}

- (void)setSiteActivePath:(NSString*)path
{
    [self.p_settings setValue:path forKey:DEFAULTS_URL_ACTIVE];
}

- (NSString*)siteActivePath
{
    return [self.p_settings valueForKey:DEFAULTS_URL_ACTIVE];
}

- (void)setUserAccessPath:(NSString*)path
{
    [self.p_settings setValue:path forKey:DEFAULTS_URL_ACCESS];
}

- (NSString*)userAccessPath
{
    return [self.p_settings valueForKey:DEFAULTS_URL_ACCESS];
}

- (void)setCurrentState:(NSString*)path
{
    [self.p_settings setValue:path forKey:DEFAULTS_URL_STATUS];
}

- (NSString*)currentStatePath
{
    return [self.p_settings valueForKey:DEFAULTS_URL_STATUS];
}

- (void)setLogin:(NSString*)login
{
    [self.p_settings setValue:login forKey:DEFAULTS_LOGIN];
}

- (NSString*)login
{
    return [self.p_settings valueForKey:DEFAULTS_LOGIN];
}

- (void)setPassword:(NSString*)password
{
    [self.p_settings setValue:password forKey:DEFAULTS_PASSWORD];
}

- (NSString*)password
{
    return [self.p_settings valueForKey:DEFAULTS_PASSWORD];
}

- (void)setAutologin:(BOOL)autologin
{
    [self.p_settings setValue:@(autologin) forKey:DEFAULTS_AUTOLOGIN];
    if (!autologin) {
        [self.p_settings removeObjectForKey:DEFAULTS_LOGIN];
        [self.p_settings removeObjectForKey:DEFAULTS_PASSWORD];
    }
}

- (BOOL)autologin
{
    return [[self.p_settings valueForKey:DEFAULTS_AUTOLOGIN] boolValue];
}

@end