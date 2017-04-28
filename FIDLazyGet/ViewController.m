//
//  ViewController.m
//  FIDLazyGet
//
//  Created by Fidetro on 2017/4/19.
//  Copyright © 2017年 Fidetro. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>

@interface ViewController ()
@property (unsafe_unretained) IBOutlet NSTextView *leftTextView;
@property (unsafe_unretained) IBOutlet NSTextView *rightTextView;

@property (weak) IBOutlet NSButton *checkBoxSelfView;
@property (weak) IBOutlet NSButton *checkBoxSelf;
@property (weak) IBOutlet NSButton *checkBoxSelfContent;

@property (weak) IBOutlet NSButton *checkBoxLabelFont;
@property (weak) IBOutlet NSButton *checkBoxLabelTextColor;

@property (weak) IBOutlet NSButton *checkBoxButtonTitleNor;
@property (weak) IBOutlet NSButton *checkBoxButtonTitleSel;
@property (weak) IBOutlet NSButton *checkBoxButtonImageNor;
@property (weak) IBOutlet NSButton *checkBoxButtonImageSel;
@property (weak) IBOutlet NSButton *checkBoxButtonTitleColorNor;
@property (weak) IBOutlet NSButton *checkBoxButtonTitleColorSel;
@property (weak) IBOutlet NSButton *checkBoxButtonTitleFont;
@property (weak) IBOutlet NSButton *checkBoxButtonBgColor;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}
- (IBAction)clickAction:(id)sender {
        NSArray *classNames = [self matchString:self.leftTextView.string toRegexString:@"\\)(.+?)\\*"];
        NSArray *propertyNames = [self matchString:self.leftTextView.string toRegexString:@"\\*(.+?)\\;"];

    NSString *getStrings = [NSString string];
    for (NSInteger index = 0; index < classNames.count; index++) {
        NSString *className = classNames[index];
        NSString *propertyName = propertyNames[index];
        
        NSString *headString = [NSString stringWithFormat:@"- (%@ *)%@\r{\r    if(!_%@)\r    {\r",className,propertyName,propertyName];
        NSString *contentString = [NSString stringWithFormat:@"        _%@ = [[%@ alloc]init];\r",propertyName,className];
        contentString = [self isAddSubview:contentString propertyName:propertyName];
        contentString = [self setViewStyleWithContentString:contentString propertyName:propertyName className:className];
        
        NSString *footString = [NSString stringWithFormat:@"    }\r    return _%@;\r}",propertyName];

        getStrings = [NSString stringWithFormat:@"%@%@%@%@\r",getStrings,headString,contentString,footString];

    }
    self.rightTextView.string = getStrings;
    
}

- (NSString *)setViewStyleWithContentString:(NSString *)contentString propertyName:(NSString *)propertyName className:(NSString *)className{

    NSString *setCodeString = @"";
    
    if ([className isEqualToString:@"UIButton"]) {
        if (self.checkBoxButtonTitleNor.state == 1) {
        setCodeString = [NSString stringWithFormat:@"%@[_%@ setTitle:<#(nullable NSString *)#> forState:UIControlStateNormal];\r",setCodeString,propertyName];
        }
        if (self.checkBoxButtonTitleSel.state == 1) {
        setCodeString = [NSString stringWithFormat:@"%@[_%@ setTitle:<#(nullable NSString *)#> forState:UIControlStateSelected];\r",setCodeString,propertyName];
        }
        if (self.checkBoxButtonImageNor.state == 1) {
            setCodeString = [NSString stringWithFormat:@"%@[_%@ setImage:<#(nullable UIImage *)#> forState:UIControlStateNormal];\r",setCodeString,propertyName];
        }
        if (self.checkBoxButtonImageSel.state == 1) {
            setCodeString = [NSString stringWithFormat:@"%@[_%@ setImage:<#(nullable UIImage *)#> forState:UIControlStateSelected];\r",setCodeString,propertyName];
        }
        if (self.checkBoxButtonTitleColorNor.state == 1) {
            setCodeString = [NSString stringWithFormat:@"%@[_%@ setTitleColor:<#(nullable UIColor *)#> forState:UIControlStateNormal];\r",setCodeString,propertyName];
        }
        if (self.checkBoxButtonTitleColorSel.state == 1) {
            setCodeString = [NSString stringWithFormat:@"%@[_%@ setTitleColor:<#(nullable UIColor *)#> forState:UIControlStateSelected];\r",setCodeString,propertyName];
        }
        if (self.checkBoxButtonTitleFont.state == 1) {
            setCodeString = [NSString stringWithFormat:@"%@[_%@.titleLabel setFont:<#(UIFont * _Nullable)#>];\r",setCodeString,propertyName];
        }
        if (self.checkBoxButtonBgColor.state == 1) {
            setCodeString = [NSString stringWithFormat:@"%@[_%@ setBackgroundColor:<#(UIColor * _Nullable)#>];\r",setCodeString,propertyName];
        }
    }else if ([className isEqualToString:@"UILabel"]){
        if (self.checkBoxLabelFont.state == 1) {
            setCodeString = [NSString stringWithFormat:@"%@[_%@ setFont:<#(UIFont * _Nullable)#>];\r",setCodeString,propertyName];
        }
        if (self.checkBoxLabelTextColor.state == 1) {
            setCodeString = [NSString stringWithFormat:@"%@[_%@ setTextColor:<#(UIColor * _Nullable)#>];\r",setCodeString,propertyName];
        }
    }else{
        return contentString;
    }
    contentString = [NSString stringWithFormat:@"%@        %@",contentString,setCodeString];
    return contentString;
}



- (NSString *)isAddSubview:(NSString *)contentString propertyName:(NSString *)propertyName{
    NSString *superViewString;
    if (self.checkBoxSelf.state == 0 && self.checkBoxSelfView.state == 0 &&self.checkBoxSelfContent.state == 0) {
        return contentString;
    }else if (self.checkBoxSelf.state == 1){
        superViewString = @"        UIView *superView = self;";
    }else if (self.checkBoxSelfView.state == 1){
        superViewString = @"        UIView *superView = self.view;";
    }else if (self.checkBoxSelfContent.state == 1){
        superViewString = @"        UIView *superView = self.contentView;";
    }
    contentString = [NSString stringWithFormat:@"%@\r%@        [superView addSubview:_%@];\r",superViewString,contentString,propertyName];
    return contentString;
}

- (IBAction)selectAddViewAction:(NSButton *)sender {
    
    self.checkBoxSelf.state = 0;
    self.checkBoxSelfContent.state = 0;
}
- (IBAction)selectAddSelfAction:(NSButton *)sender {
    self.checkBoxSelfView.state = 0;
    
    self.checkBoxSelfContent.state = 0;
}
- (IBAction)selectAddSubviewContentAction:(NSButton *)sender {
    self.checkBoxSelfView.state = 0;
    self.checkBoxSelf.state = 0;
    
}



- (NSArray *)matchString:(NSString *)string toRegexString:(NSString *)regexStr
{
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSArray * matches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    
    
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSTextCheckingResult *match in matches) {
        
        for (int i = 1; i < [match numberOfRanges]; i++) {
            
            NSString *component = [string substringWithRange:[match rangeAtIndex:i]];
            component = [component stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //去除空格
            [array addObject:component];
            
        }
        
    }
    
    return array;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
