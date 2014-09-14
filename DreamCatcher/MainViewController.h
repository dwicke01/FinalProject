//
//  MainViewController.h
//  DreamCatcher
//
//  Created by Daniel Wickes on 4/8/14.
//  Copyright (c) 2014 Daniel Wickes. All rights reserved.
//

#import "FlipsideViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SleepMonitor.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate>

@property SleepMonitor *monitor;

@end
