//
//  TableViewCell.h
//  Site
//
//  Created by Navigator on 5/8/15.
//  Copyright (c) 2015 OrangeSoft_Brest. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel* m_text;
@property (nonatomic, strong) IBOutlet UISwitch* m_switch;
@end
