//
//  GraphPageView.h
//  CorePlotExample
//
//  Created by Daniel Wickes on 6/5/14.
//  Copyright (c) 2014 Daniel Wickes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NimbusPagingScrollView.h"
#import "CorePlot-CocoaTouch.h"
#import "DreamCatcherDBHelper.h"

@interface GraphPageView : CPTGraphHostingView <NIPagingScrollViewPage, CPTPlotDataSource>
@property (nonatomic, retain) CPTGraph* graph;
@property NSMutableArray *xValues;
@property NSMutableArray *yValues;
- (id)init :(NSInteger)pageNumber;
@end
