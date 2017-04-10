/*
 * QRCodeReaderViewController
 *
 * Copyright 2014-present Yannick Loriot.
 * http://yannickloriot.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "QRCodeReaderView.h"

@interface QRCodeReaderView ()
@property (nonatomic, strong) CAShapeLayer *overlay;
@property (nonatomic, strong) CATextLayer *label;

@end

@implementation QRCodeReaderView

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self addOverlay];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(redrawOverlay:)
                                                 name:@"ScanSuccessNotification"
                                               object:nil];
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGRect innerRect = CGRectInset(rect, 50, 50);
    
    
    // Generate Square
    CGFloat minSize = MIN(innerRect.size.width, innerRect.size.height);
    if (innerRect.size.width != minSize) {
        innerRect.origin.x   += (innerRect.size.width - minSize) / 2;
        innerRect.size.width = minSize;
    }
    else if (innerRect.size.height != minSize) {
        innerRect.origin.y    += (innerRect.size.height - minSize) / 2;
        innerRect.size.height = minSize;
    }
    
    // Pull down
    CGRect offsetRect = CGRectOffset(innerRect, 0, 15);
    
    _overlay.path = [UIBezierPath bezierPathWithRoundedRect:offsetRect cornerRadius:7].CGPath;
}

#pragma mark - Private Methods

- (void)addOverlay
{
    _overlay = [[CAShapeLayer alloc] init];
    _overlay.backgroundColor = [UIColor clearColor].CGColor;
    _overlay.fillColor       = [UIColor clearColor].CGColor;
    _overlay.strokeColor     = [UIColor whiteColor].CGColor;//[UIColor colorWithRed:230.0/255.0 green:43.0/255.0 blue:30.0/255.0 alpha:1].CGColor;
    _overlay.lineWidth       = 5;
    
    [self.layer addSublayer:_overlay];
    
    _label = [[CATextLayer alloc] init];
    [_label setFont:@"Helvetica-Bold"];
    [_label setFontSize:18];
    [_label setString:@"NAME SURNAME"];
    [_label setAlignmentMode:kCAAlignmentCenter];
    [_label setForegroundColor:[[UIColor redColor] CGColor]];
    [_label setBackgroundColor:[[UIColor whiteColor] CGColor]];
//    [_label set]
    [_label setFrame: CGRectMake(52, 440, 271, 24)];
    [_label setContentsScale:[[UIScreen mainScreen] scale]];
    
    [self.layer addSublayer:_label];
}

- (void) redrawOverlay:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"ScanSuccessNotification"]) {
        
        CABasicAnimation *colorAnimation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
        colorAnimation.toValue = (id)[UIColor greenColor].CGColor;
        colorAnimation.duration = 0.3f;
        colorAnimation.autoreverses = YES;
        [_overlay addAnimation:colorAnimation forKey:@"strokeColor"];
        
        
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"lineWidth"];
        pathAnimation.duration = 0.3f;
        pathAnimation.fromValue = [NSNumber numberWithFloat:5.0f];
        pathAnimation.toValue = [NSNumber numberWithFloat:10.0f];
        pathAnimation.autoreverses = YES;
        [_overlay addAnimation:pathAnimation forKey:@"lineWidth"];
        
        NSDictionary *data = [[notification userInfo] valueForKey:@"JSONData"];
        
        [_label setString:[NSString stringWithFormat:@"%@ %@", [data objectForKey:@"name"], [data objectForKey:@"surname"]]];
    }
}

@end
