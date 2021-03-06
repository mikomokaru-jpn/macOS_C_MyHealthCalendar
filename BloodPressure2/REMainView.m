#import <QuartzCore/QuartzCore.h>
#import "NSBezierPath+MyBezierPath.h"
#import "REMainView.h"
//------------------------------------------------------------------------------
// メインビュークラス
//------------------------------------------------------------------------------
@interface REMainView()
@property CAShapeLayer *square1;
@property CAShapeLayer *square2;
@property NSColor *redColor;
@property NSColor *blueColor;
@end

@implementation REMainView
- (BOOL) isFlipped{
    return YES;
}
//イニシャライザ
- (instancetype)initWithFrame:(NSRect)frameRect graphWidth:(float)width{
    self = [super initWithFrame:frameRect];
    if (self == nil){
        return self;
    }
    self.layer.backgroundColor = [NSColor blackColor].CGColor;
    //血圧正常値の直線上の位置の算出
    float base = frameRect.size.width - width;
    float height = frameRect.size.height;
    float left = (BP_NORMAL_LOW / BP_LIMMIT ) * width + base;
    float right = (BP_NORMAL_HIGH / BP_LIMMIT ) * width + base;
    //最低血圧上限値
    _square1 = [CAShapeLayer layer];
    NSBezierPath *path1 = [NSBezierPath bezierPath];;
    [path1 appendBezierPathWithRect:NSMakeRect(left, 0, 1, height)];    //
    _square1.path = path1.cgPath;
    _square1.position = NSMakePoint(0, 0);
    _square1.fillColor =  [NSColor blueColor].CGColor;
    _square1.opacity = 1.0;
    //最高血圧上限値
    _square2 = [CAShapeLayer layer];
    NSBezierPath *path2 = [NSBezierPath bezierPath];;
    [path2 appendBezierPathWithRect:NSMakeRect(right, 0, 1, height)];   //
    _square2.path = path2.cgPath;
    _square2.position = NSMakePoint(0, 0);
    _square2.fillColor =  [NSColor redColor].CGColor;
    _square2.opacity = 1.0;
    return self;
}
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [self.layer addSublayer:_square1];
    [self.layer addSublayer:_square2];
}
@end
