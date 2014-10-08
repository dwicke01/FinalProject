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
    
    for (NSNumber* x in self.xValues)
        NSLog(@"%f", [x doubleValue]);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYY:MM:dd"];
    double x1 = [[self.xValues objectAtIndex:0] doubleValue];
    NSDate *xDate = [[NSDate alloc]initWithTimeIntervalSince1970:x1];
    NSString *formattedDateString = [dateFormatter stringFromDate:xDate];
    self.graph.title = formattedDateString;
}

- (double)findMin:(NSMutableArray*) arr
{
    double min = [[arr objectAtIndex:0] floatValue];
    
    for (NSNumber *n in arr)
    {
        if ([n doubleValue] < min)
            min = [n doubleValue];
    }
    return min;
}

- (double)findMax:(NSMutableArray*) arr
{
    double max = 0;
    
    for (NSNumber *n in arr)
    {
        if ([n doubleValue] > max)
            max = [n doubleValue];
    }
    return max;
}


- (id)init:(NSInteger) pageNumber{

    if ((self = [super initWithFrame:CGRectZero])) {

        [self fillXAndYValues];

        self.pageIndex = pageNumber;
        double adjustment = MAX([self yAxisIntervalLength]/5, .0005);
        
        [self makeGraph:0 :[self findMax:self.yValues]+adjustment:[(NSNumber*)[self.xValues objectAtIndex:0] doubleValue] :[(NSNumber*)[self.xValues objectAtIndex:[self.xValues count]-1] doubleValue]  :self.frame];

        
        self.hostedGraph = self.graph;
        
        self.allowPinchScaling = YES;
        self.userInteractionEnabled = YES;
    }

    return self;
}


- (void)setPageIndex:(NSInteger)pageIndex {
    _pageIndex = pageIndex;
    
    [self fillXAndYValues];
    
    if (self.graph == nil)
    {
        double adjustment = MAX([self yAxisIntervalLength]/5, .0005);
        [self makeGraph:0 :[self findMax:self.yValues]+adjustment:[(NSNumber*)[self.xValues objectAtIndex:0] doubleValue] :[(NSNumber*)[self.xValues objectAtIndex:[self.xValues count]-1] doubleValue] :self.frame];
    }
    [self setNeedsLayout];
}

-(void) makeGraph :(double)yStart :(double)yMax :(double)xStart :(double)xMax :(CGRect)frame
{
    self.graph = [[CPTXYGraph alloc] initWithFrame:frame];
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    
    [plotSpace setYRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble( 0 ) length:CPTDecimalFromDouble( yMax )]];
    [plotSpace setXRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble( xStart ) length:CPTDecimalFromDouble( xMax-xStart )]];
    
    CPTScatterPlot* plot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    
    plot.dataSource = self;
    
    CPTMutableLineStyle *style = [plot.dataLineStyle mutableCopy];
    CPTColor *myColor = [CPTColor redColor];
    
    style.lineWidth = 1.0;
    style.lineColor = myColor;
    plot.dataLineStyle = style;
    
    [self.graph addPlot:plot toPlotSpace:self.graph.defaultPlotSpace];
    
    [self.graph.plotAreaFrame setPaddingLeft:40.0f];
    [self.graph.plotAreaFrame setPaddingBottom:20.0f];
    
    [self configureAxes];
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plotnumberOfRecords {
    return [self.xValues count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    if(fieldEnum == CPTScatterPlotFieldX)
    {
        // Return x value
        return [NSNumber numberWithDouble: [[self.xValues objectAtIndex:index] doubleValue]];
    } else {
        // Return y value
        return [NSNumber numberWithDouble: [[self.yValues objectAtIndex:index] doubleValue]];
    }
}

-(double)yAxisIntervalLength{
    double length = [self findMax:[self yValues]] - [self findMin:[self yValues]];
    return length/5;
}

-(double)xAxisIntervalLength :(double)numTicks{
    double length = [self findMax:[self xValues]] - [self findMin:[self xValues]];
    return length/numTicks;
}


-(void)configureAxes {
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.graph.axisSet;
    double xMin = [(NSNumber*)[self.xValues objectAtIndex:0] doubleValue];  //[self findMin:self.xValues];
    double xMax = [(NSNumber*)[self.xValues objectAtIndex:[self.xValues count]-1]doubleValue];
    double yMax = [self findMax:self.yValues];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    if (xMax - xMin < 300)
        [dateFormatter setDateFormat:@"hh:mm:ssa"];
    else
        [dateFormatter setDateFormat:@"hh:mma"];
    
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc]initWithDateFormatter:dateFormatter];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
    [numberFormatter setMaximumFractionDigits:4];
    [numberFormatter setMinimumFractionDigits:2];
    
    axisSet.yAxis.labelFormatter = numberFormatter;
    axisSet.yAxis.minorTicksPerInterval = 0;
    axisSet.yAxis.majorTickLength = 5.0f;
    axisSet.yAxis.labelOffset = 1.0f;
    axisSet.yAxis.orthogonalCoordinateDecimal = CPTDecimalFromDouble(xMin);
    axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    axisSet.yAxis.title = @"Movements";
    axisSet.yAxis.titleOffset = 20.0f;
    
    CGFloat yLabelCount = 5;
    NSMutableSet *yLabels = [NSMutableSet setWithCapacity:yLabelCount];
    NSMutableSet *yLocations = [NSMutableSet setWithCapacity:yLabelCount];
    double i = .02;
    for (i=0; i < yMax+.005; i+=yMax/5) {
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[numberFormatter stringFromNumber:[NSNumber numberWithDouble:i]] textStyle:axisSet.yAxis.labelTextStyle];
        label.tickLocation = CPTDecimalFromDouble(i);
        label.offset = 1.0f;
        if (label) {
            [yLabels addObject:label];
            [yLocations addObject:[NSNumber numberWithDouble:i]];
        }
    }
    axisSet.yAxis.axisLabels = yLabels;
    axisSet.yAxis.labelFormatter = numberFormatter;
    axisSet.yAxis.majorTickLocations = yLocations;
    
    axisSet.xAxis.labelFormatter = timeFormatter;
    
    CPTMutableTextStyle *xAxisTextStyle = [CPTMutableTextStyle textStyle];
    xAxisTextStyle.color = [[CPTColor blackColor] colorWithAlphaComponent:1];
    xAxisTextStyle.fontName = @"Helvetica-Bold";
    xAxisTextStyle.fontSize = 8.0f;
    
    axisSet.xAxis.labelTextStyle = xAxisTextStyle;
    axisSet.yAxis.labelTextStyle = xAxisTextStyle;
    
    axisSet.xAxis.minorTicksPerInterval = 0;
    axisSet.xAxis.minorTickLength = 5.0f;
    axisSet.xAxis.majorTickLength = 7.0f;
    axisSet.xAxis.labelOffset = 3.0f;
    axisSet.xAxis.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0);

    axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    
    double xTickCount = ([[self xValues] count]>=5)?5:[[self xValues] count];
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:xTickCount];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:xTickCount];
    NSLog(@"xMin is %@", [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:xMin]]);
    axisSet.xAxis.majorIntervalLength = CPTDecimalFromDouble([self xAxisIntervalLength:xTickCount]);
    
    for (double i = xMin; i < xMax; i+=(xMax-xMin)/xTickCount) {
        NSLog(@"i is %@", [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:i]]);
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:i]] textStyle:axisSet.xAxis.labelTextStyle];
        label.tickLocation = CPTDecimalFromDouble(i);
        label.offset = 3.0f;
        if (label) {
            [xLabels addObject:label];
            [xLocations addObject:[NSNumber numberWithFloat:i]];
        }
    }
    
    axisSet.xAxis.axisLabels = xLabels;
    axisSet.xAxis.labelFormatter = dateFormatter;
    axisSet.xAxis.majorTickLocations = xLocations;

    self.graph.axisSet = axisSet;
}

@end
