//
//  K9Consts.h
//  Beep
//
//  Created by Navigator on 17.04.14.
//  Copyright (c) 2014 OrangeSoft_Brest. All rights reserved.
//

//#ifndef _K9Consts_h
//#define _K9Consts_h
#define DEFAULT_ANIMATION_DURATION  0.45f
#define DEFAULT_ANIMATION_SPEED     0.6f
#define PRELOADED_IMAGES_DELTA      3

#define IMAGE_MAX_SIZE      1024.0f

#define DEFAULTS_PASSWORD           @"Password"
#define DEFAULTS_LOGIN              @"Login"
#define DEFAULTS_SETTINGS           @"settings"
#define DEFAULTS_DOMAINS            @"site_domains"
#define DEFAULTS_DOMAIN             @"site_domain"
#define DEFAULTS_URL_ACTIVE         @"site_active"
#define DEFAULTS_URL_ACCESS         @"site_access"
#define DEFAULTS_URL_STATUS         @"site_status"

#define ALERT_OK                    NSLocalizedString(@"OK", nil)
#define ALERT_DONE                  NSLocalizedString(@"Готово", @"Done")
#define ALERT_YES                   NSLocalizedString(@"ДА", @"YES")
#define ALERT_NO                    NSLocalizedString(@"НЕТ", @"NO")
#define ALERT_RETRY                 NSLocalizedString(@"Повтор", @"Repeat")
#define ALERT_CANCEL                NSLocalizedString(@"Отменить", @"Cancel")
#define ALERT_ATTENTION             NSLocalizedString(@"Внимание!", @"Attention!")
#define ALERT_THANKS                NSLocalizedString(@"Спасибо!", @"Thanks!")
#define ALERT_CONTINUE              NSLocalizedString(@"Продолжить",@"Continue")
#define ALERT_DELETE                NSLocalizedString(@"Удалить",@"Delete")
#define ALERT_ERROR                 NSLocalizedString(@"Ошибка",@"Error")
#define ALERT_SERVER_ERROR          NSLocalizedString(@"Нет связи с сервером. Попробуйте позже.", @"Нет связи с сервером. Попробуйте позже.")
#define ALERT_INTENET_NOT_AVAILABLE NSLocalizedString(@"Интернет не подключен!\nДля работы приложения необходимо наличие интернета.", @"Intenet not available")
#define ALERT_PHONE                 NSLocalizedString(@"Введите номер телефона", @"Enter phone number")
#define ALERT_PASSWORD              NSLocalizedString(@"Введите пароль", @"Enter password")

//#endif //_K9Consts_h

typedef enum{    
    AlertTag_ERRORS         = 1000,
    AlertTag_ServerError    = AlertTag_ERRORS,
    AlertTag_InternetNotAvailable,
}AlertTag;