#import <QuartzCore/QuartzCore.h>
#import "NSBezierPath+MyBezierPath.h"
#import "CAShapeLayer+MyShapeLayer.h"
#import "UATextAttribute.h"
#import "REHeaderView.h"
//------------------------------------------------------------------------------
// ヘッダービュークラス
//------------------------------------------------------------------------------
@interface REHeaderView()
//文字列装飾
@property NSDictionary* font18;
@property NSDictionary* font12;
@property NSDictionary* font12r;
@property NSDictionary* font12b;
@property CAShapeLayer* line1;
@property CAShapeLayer* line2;
@end

@implementation REHeaderView

- (BOOL) isFlipped{
    return YES;
}

//イニシャライザ
- (instancetype)initWithFrame:(NSRect)frameRect{
    self = [super initWithFrame:frameRect];
    if (self == nil){
        return self;
    }    
    //格子を定義
    //_line1 = [CAShapeLayer layerGridInRect:self.frame AtInterval:10 width:0.2]; //細線
    //_line2 = [CAShapeLayer layerGridInRect:self.frame AtInterval:50 width:1.0]; //太線
    _font18 =  [UATextAttribute makeAttributesFontSize:18];
    _font12 = [UATextAttribute makeAttributesFontSize:12];
    _font12b = [UATextAttribute makeAttributesFontSize:12
                                             ForeColor:[NSColor blueColor]];  //文字列装飾
    _font12r = [UATextAttribute makeAttributesFontSize:12
                                             ForeColor:[NSColor redColor]];  //文字列装飾
    return self;
}
//描画
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    self.layer.backgroundColor = [NSColor whiteColor].CGColor;
    //格子を描く
    //[self.layer addSublayer:_line1];
    //[self.layer addSublayer:_line2];
    //見出しの編集
    [_textOfDate drawAtPoint:NSMakePoint(18, 7) withAttributes:_font18];
    [@"日付" drawAtPoint:NSMakePoint(20, 30) withAttributes:_font12];
    [@"曜日" drawAtPoint:NSMakePoint(55, 30) withAttributes:_font12];
    [@"最低" drawAtPoint:NSMakePoint(90, 30) withAttributes:_font12];
    [@"最高" drawAtPoint:NSMakePoint(135, 30) withAttributes:_font12];
    [@"85" drawAtPoint:NSMakePoint(290, 30) withAttributes:_font12b];
    [@"135" drawAtPoint:NSMakePoint(363, 30) withAttributes:_font12r];
    [@"200" drawAtPoint:NSMakePoint(458, 30) withAttributes:_font12];
}
@end
