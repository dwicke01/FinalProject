//
//  FlipsideViewController.m
//  DreamCatcher
//
//  Created by Daniel Wickes on 4/8/14.
//  Copyright (c) 2014 Daniel Wickes. All rights reserved.
//

#import "FlipsideViewController.h"
static NSString* const kPageReuseIdentifier = @"GraphPageIdentifier";


@interface FlipsideViewController () <NIPagingScrollViewDataSource>
@property DreamCatcherDBHelper *helper;

@property (nonatomic, retain) IBOutlet NIPagingScrollView *pagingScrollView;

@end

@implementation FlipsideViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"In viewDidLoad");
    // iOS 7-only.
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    

    self.pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
    
    self.pagingScrollView.dataSource = self;
    self.pagingScrollView.delegate = self;
    
    
    [self.pagingScrollView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return NIIsSupportedOrientation(interfaceOrientation);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.pagingScrollView willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.pagingScrollView willAnimateRotationToInterfaceOrientation:toInterfaceOrientation
                                                            duration:duration];
}

#pragma mark - NIPagingScrollViewDataSource

- (NSInteger)numberOfPagesInPagingScrollView:(NIPagingScrollView *)pagingScrollView {
    DreamCatcherDBHelper *db = [DreamCatcherDBHelper getSharedInstance];
    int numPages = [db getNumPages];
    return numPages;
}

- (UIView<NIPagingScrollViewPage> *)pagingScrollView:(NIPagingScrollView *)pagingScrollView
                                    pageViewForIndex:(NSInteger)pageIndex {
    GraphPageView *page = [[GraphPageView alloc] init:pageIndex ];
    [page setPageIndex:pageIndex];
    
    return page;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}


#pragma mark - UIViewController lifecycle methods
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


@end
