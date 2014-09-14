//
//  FlipsideViewController.h
//  DreamCatcher
//
//  Created by Daniel Wickes on 4/8/14.
//  Copyright (c) 2014 Daniel Wickes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "DreamCatcherDBHelper.h"
#import "SleepDataWrapper.h"
#import "CorePlot-CocoaTouch.h"
#import "NimbusPagingScrollView.h"
#import "NIPagingScrollView.h"
#import "GraphPageView.h"

@class FlipsideViewController;

@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

@interface FlipsideViewController : UIViewController <NIPagingScrollViewDataSource, NIPagingScrollViewDelegate>
{
}

@property (weak, nonatomic) id <FlipsideViewControllerDelegate> delegate;
@property NSMutableArray *allData;

- (IBAction)done:(id)sender;

@end
