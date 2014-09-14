//
//  GraphPageView.m
//  CorePlotExample
//
//  Created by Daniel Wickes on 6/5/14.
//  Copyright (c) 2014 Daniel Wickes. All rights reserved.
//

#import "GraphPageView.h"

@implementation GraphPageView

@synthesize pageIndex = _pageIndex;
@synthesize reuseIdentifier = _reuseIdentifier;

- (void)fillXAndYValues{
    DreamCatcherDBHelper *db = [DreamCatcherDBHelper getSharedInstance];
    NSMutableArray *data = [[NSMutableArray alloc]initWithArray:[db getData:[self pageIndex]]];
    self.xValues = [[NSMutableArray alloc]init];
    self.yValues = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < [data count]; i++)
    {
        if (i%2 == 0)
            [self.xValues addObject:[data objectAtIndex:i]];
        else
            [self.yValues addObject:[data objectAtIndex:i]];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYY:MM:dd"];
    float x1 = [[self.xValues objectAtIndex:0] floatValue];
    NSDate *xDate = [[NSDate alloc]initWithTimeIntervalSince1970:x1];
    NSString *formattedDateString = [dateFormatter stringFromDate:xDate];
    self.graph.title = formattedDateString;
}

- (float)findMin:(NSMutableArray*) arr
{
    float min = [[arr objectAtIndex:0] floatValue];
    
    for (NSNumber *n in arr)
    {
        if ([n floatValue] < min)
            min = [n floatValue];
    }
    return min;
}

- (float)findMax:(NSMutableArray*) arr
{
    float max = 0;
    
    for (NSNumber *n in arr)
    {
        if ([n floatValue] > max)
            max = [n floatValue];
    }
    return max;
}


- (id)init:(NSInteger) pageNumber{

    if ((self = [super initWithFrame:CGRectZero])) {

        [self fillXAndYValues];

        self.pageIndex = pageNumber;
        
        self.graph = [self makeGraph:0 :[self findMax:self.yValues] :[self findMin:self.xValues] :[self findMax:self.xValues] :self.frame];

        
        self.hostedGraph = self.graph;
        
        self.allowPinchScaling = YES;
        self.userInteractionEnabled = YES;
    }
    return self;
}


- (void)setPageIndex:(NSInteger)pageIndex {
    _pageIndex = pageIndex;
    [self fillXAndYValues];
    self.graph = [self makeGraph:0 :[self findMax:self.yValues] :[self findMin:self.xValues] :[self findMax:self.xValues] :self.frame];
    [self setNeedsLayout];
}

-(CPTGraph*) makeGraph :(float)yStart :(float)yLength :(float)xStart :(float)xLength :(CGRect)frame
{
    CPTGraph* graph = [[CPTXYGraph alloc] initWithFrame:frame];
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
    [plotSpace setYRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( yStart ) length:CPTDecimalFromFloat( yLength )]];
    [plotSpace setXRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( xStart ) length:CPTDecimalFromFloat( xLength-xStart )]];
    
    CPTScatterPlot* plot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    
    plot.dataSource = self;
    
    CPTMutableLineStyle *style = [plot.dataLineStyle mutableCopy];
    CPTColor *myColor = [CPTColor redColor];
    
    style.lineWidth = 1.0;
    style.lineColor = myColor;
    plot.dataLineStyle = style;
    
    [graph addPlot:plot toPlotSpace:graph.defaultPlotSpace];
    
    [graph.plotAreaFrame setPaddingLeft:40.0f];
    [graph.plotAreaFrame setPaddingBottom:40.0f];
    
    graph = [self configureAxes:graph];
    
    return graph;
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plotnumberOfRecords {
    return [self.xValues count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    if(fieldEnum == CPTScatterPlotFieldX)
    {
        // Return x value
        return [NSNumber numberWithFloat: [[self.xValues objectAtIndex:index] floatValue]];
    } else {
        // Return y value
        return [NSNumber numberWithFloat: [[self.yValues objectAtIndex:index] floatValue]];
    }
}

-(CPTGraph*)configureAxes :(CPTGraph*)graph {
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"hh:mma"];
    
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc]initWithDateFormatter:dateFormatter];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
    [numberFormatter setMaximumFractionDigits:2];
    [numberFormatter setMinimumFractionDigits:2];
    
    axisSet.yAxis.majorIntervalLength = [[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromDouble(.005)] decimalValue];
    
    axisSet.yAxis.labelFormatter = numberFormatter;
    axisSet.yAxis.minorTicksPerInterval = 1;
    axisSet.yAxis.minorTickLength = 5.0f;
    axisSet.yAxis.majorTickLength = 7.0f;
    axisSet.yAxis.labelOffset = 3.0f;
    axisSet.yAxis.orthogonalCoordinateDecimal = CPTDecimalFromFloat([self findMin:self.xValues]);
    axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyAutomatic;

    axisSet.xAxis.labelFormatter = timeFormatter;
    
    CPTMutableTextStyle *xAxisTextStyle = [CPTMutableTextStyle textStyle];
    xAxisTextStyle.color = [[CPTColor blackColor] colorWithAlphaComponent:1];
    xAxisTextStyle.fontName = @"Helvetica-Bold";
    xAxisTextStyle.fontSize = 7.0f;
    
    axisSet.xAxis.labelTextStyle = xAxisTextStyle;
    
    axisSet.xAxis.majorIntervalLength = CPTDecimalFromDouble(([self findMax:self.xValues]-[self findMin:self.yValues])/5);
    axisSet.xAxis.minorTicksPerInterval = 0;
    axisSet.xAxis.minorTickLength = 5.0f;
    axisSet.xAxis.majorTickLength = 7.0f;
    axisSet.xAxis.labelOffset = 3.0f;
    
    axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    
    return graph;
}

@end
