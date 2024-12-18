//
//  SGViewController.h
//  SafeGuardiOS
//
//  Created by Rajiv Singaseni on 12/18/2024.
//  Copyright (c) 2024 Rajiv Singaseni. All rights reserved.
//

@import UIKit;

@interface SGViewController : UIViewController

- (IBAction)checkRootStatus:(id)sender;
- (IBAction)checkDeveloperOptions:(id)sender;
- (IBAction)checkNetworkSecurity:(id)sender;
- (IBAction)checkMalwareTampering:(id)sender;
- (IBAction)checkScreenMirroring:(id)sender;
- (IBAction)checkAppSpoofing:(id)sender;
- (IBAction)checkKeyLoggerDetection:(id)sender;

@end
