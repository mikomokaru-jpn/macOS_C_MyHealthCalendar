//------------------------------------------------------------------------------
// アイテムビュークラス
//------------------------------------------------------------------------------
#import "NSColor+MyColor.h"
#import "UATextAttribute.h"
#import "REItemView.h"
@interface REItemView()
@property NSSize mySize;
@end

@implementation REItemView
- (BOOL) isFlipped{
    return YES;
}
//イニシャライザ
-(id)initWithFrame:(NSRect)frameRect{
    self = [super initWithFrame:frameRect];
    if (self == nil){
        return self;
    }
    //プロパティのデフォルト値
    _backgroundColor = [NSColor whiteColor];
    _borderWidth = 1.0;
    _opacity = 1.0;
    //文字列装飾
    _atr = [UATextAttribute makeAttributesFontSize:14];
    return self;
}
//描画
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    //ビューの大きさ
    _mySize = dirtyRect.size;
    //テキスト
    if (_string){
        NSSize textSize = [_string sizeWithAttributes:_atr];
        NSPoint newPoint;
        float wPad = 5; //横padding
        float hPad = 2; //縦padding
        //テキスト揃え
        if (_allign == ALLIGN_RHGHT){       //右
            newPoint = NSMakePoint(_mySize.width-textSize.width-wPad,
                                   _mySize.height-textSize.height-hPad);
        }else if (_allign == ALLIGN_CENTER){ //中央
            newPoint = NSMakePoint((_mySize.width/2)-(textSize.width/2),
                                   _mySize.height-textSize.height-hPad);
        }else{                              //左
            newPoint = NSMakePoint(wPad, _mySize.height-textSize.height-hPad);
        }
        [_string drawAtPoint:newPoint withAttributes:_atr];
    }
    //透明度
    self.layer.opacity = _opacity;
    //枠線
    self.layer.borderWidth = _borderWidth;
    self.layer.borderColor = [NSColor myColorR:80 G:80 B:80].CGColor;
    //背景色
    self.layer.backgroundColor = _backgroundColor.CGColor;
}
@end
