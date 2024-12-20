//
//  SGViewController.m
//  SafeGuardiOS
//
//  Created by Rajiv Singaseni on 12/18/2024.
//  Copyright (c) 2024 Rajiv Singaseni. All rights reserved.
//

#import "SGViewController.h"
#import <SafeGuardiOS/SGSecurityChecker.h>
#import <UIKit/UIKit.h>

@interface SGViewController ()
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *runAllChecksButton;
@end

@implementation SGViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
    [self setupSecurityChecker];
}

- (void)setupSecurityChecker {
    [SGSecurityChecker sharedInstance].alertHandler = ^(NSString *title, NSString *message, SGSecurityLevel level, void(^completion)(BOOL shouldQuit)) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                     message:message
                                                              preferredStyle:UIAlertControllerStyleAlert];
        
        NSString *buttonTitle = (level == SGSecurityLevelError) ? @"Quit" : @"Continue Anyway";
        UIAlertAction *action = [UIAlertAction actionWithTitle:buttonTitle
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
            completion(level == SGSecurityLevelError);
        }];
        
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    };
}

- (void)setupUI {
    // Title Label
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"Safe Guard Demo";
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightMedium];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.titleLabel];
    
    // Stack View
    self.stackView = [[UIStackView alloc] init];
    self.stackView.axis = UILayoutConstraintAxisVertical;
    self.stackView.spacing = 16;
    self.stackView.distribution = UIStackViewDistributionFillEqually;
    self.stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.stackView];
    
    // Add buttons
    NSArray *buttonTitles = @[
        @"CHECK ROOT STATUS",
        @"CHECK DEVELOPER OPTIONS",
        @"CHECK NETWORK SECURITY",
        @"CHECK MALWARE/TAMPERING",
        @"CHECK SCREEN MIRRORING",
        @"CHECK APP SPOOFING",
        @"CHECK KEY LOGGER DETECTION"
    ];
    
    SEL selectors[] = {
        @selector(checkRootStatus:),
        @selector(checkDeveloperOptions:),
        @selector(checkNetworkSecurity:),
        @selector(checkMalwareTampering:),
        @selector(checkScreenMirroring:),
        @selector(checkAppSpoofing:),
        @selector(checkKeyLoggerDetection:)
    };
    
    for (NSInteger i = 0; i < buttonTitles.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:buttonTitles[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor blackColor];
        button.layer.cornerRadius = 8;
        [button addTarget:self action:selectors[i] forControlEvents:UIControlEventTouchUpInside];
        [self.stackView addArrangedSubview:button];
        [NSLayoutConstraint activateConstraints:@[
            [button.heightAnchor constraintEqualToConstant:50]
        ]];
    }
    
    // Run All Checks Button
    self.runAllChecksButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.runAllChecksButton setTitle:@"RUN ALL CHECKS" forState:UIControlStateNormal];
    [self.runAllChecksButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.runAllChecksButton.backgroundColor = [UIColor systemRedColor];
    self.runAllChecksButton.layer.cornerRadius = 8;
    [self.runAllChecksButton addTarget:self action:@selector(runAllChecks:) forControlEvents:UIControlEventTouchUpInside];
    self.runAllChecksButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.runAllChecksButton];
    
    // Constraints
    [NSLayoutConstraint activateConstraints:@[
        // Title Label constraints
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        
        // Stack View constraints
        [self.stackView.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:40],
        [self.stackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.stackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        
        // Run All Checks Button constraints
        [self.runAllChecksButton.topAnchor constraintEqualToAnchor:self.stackView.bottomAnchor constant:20],
        [self.runAllChecksButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.runAllChecksButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.runAllChecksButton.heightAnchor constraintEqualToConstant:50]
    ]];
}

#pragma mark - Button Actions

- (void)runAllChecks:(id)sender {
    [[SGSecurityChecker sharedInstance] performAllSecurityChecks];
}

- (IBAction)checkRootStatus:(id)sender {
    [[SGSecurityChecker sharedInstance] checkRoot];
}

- (IBAction)checkDeveloperOptions:(id)sender {
    [[SGSecurityChecker sharedInstance] checkDeveloperOptions];
}

- (IBAction)checkNetworkSecurity:(id)sender {
    [[SGSecurityChecker sharedInstance] checkNetworkSecurity];
}

- (IBAction)checkMalwareTampering:(id)sender {
    [[SGSecurityChecker sharedInstance] checkSignature];
}

- (IBAction)checkScreenMirroring:(id)sender {
    [[SGSecurityChecker sharedInstance] checkScreenSharing];
}

- (IBAction)checkAppSpoofing:(id)sender {
    [[SGSecurityChecker sharedInstance] checkSpoofing];
}

- (IBAction)checkKeyLoggerDetection:(id)sender {
    // To be implemented
}

@end
