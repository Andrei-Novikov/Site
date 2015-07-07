//
//  TableViewCell.m
//  Site
//
//  Created by Navigator on 5/8/15.
//  Copyright (c) 2015 OrangeSoft_Brest. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell
@synthesize m_text;
@synthesize m_switch;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
