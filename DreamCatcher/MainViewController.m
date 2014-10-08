//
//  MainViewController.m
//  DreamCatcher
//
//  Created by Daniel Wickes on 4/8/14.
//  Copyright (c) 2014 Daniel Wickes. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property bool started;
@property (weak, nonatomic) IBOutlet UIButton *flipButton;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.started = NO;
    self.monitor = [[SleepMonitor alloc] init];
    
}

- (IBAction)startButton:(id)sender {
    if (self.started == NO)
    {
        [self.monitor start];
        [self.startButton setTitle:@"Stop" forState:UIControlStateNormal];
        self.started = YES;
        self.flipButton.enabled = NO;
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
    else
    {
        [self.monitor stop];
        [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
        self.started = NO;
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        self.flipButton.enabled = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
    }
}

@end
