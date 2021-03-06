//------------------------------------------------------------------------------
// 血圧入力エリア
//------------------------------------------------------------------------------
#import "BPValueView.h"
#import "UATextAttribute.h"
@implementation BPValueView
//デフォルトイニシャライザ
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    _intValue = 0;
    return self;
}
//ビューの再表示
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    //血圧値の表示
    float x = (dirtyRect.size.width/2)-(attributedStringValue.size.width/2);
    float y = (dirtyRect.size.height/2)-(attributedStringValue.size.height/2);
    [attributedStringValue drawAtPoint:NSMakePoint(x, y)];
    if (self.window.firstResponder == self)
    {
        [self selectedColor];   //コントロールの色を変える（選択中）
    }else{
        [self defaultColor];    //コントロールの色を変える
    }
}
//ファーストレスポンダーを受け入れる
- (BOOL)acceptsFirstResponder{
    return YES;
}
//ファーストレスポンダーになった
- (BOOL)becomeFirstResponder{
    _initialInput = YES;    //初期入力フラグ
    [self selectedColor];   //コントロールの色を変える（選択中）
    return YES;
}
//ファーストレスポンダーを放棄する
- (BOOL)resignFirstResponder{
    _preIntValue = _intValue;
    [self defaultColor];    //コントロールの色を変える
    return YES;
}
// Accesser ********************************************************************
// 血圧値のget
-(NSInteger)getIntValue{
    return _intValue;
}
// 血圧値のset
-(void)setIntValue:(NSInteger)intValue{
    _intValue = intValue;
    NSString* string = [NSString stringWithFormat:@"%ld",_intValue];
    attributedStringValue = [self makeAttributedString:string];
}
// Override ********************************************************************
-(void)keyDown:(NSEvent *)theEvent{
    //NSLog(@"BPValueView keyDown:%d", theEvent.keyCode);
    if (theEvent.keyCode == 48){
        //tabキーで次のコントロールに移動する。
        if ([_delegate respondsToSelector:@selector(tabkeyJumpView:)]){
            [_delegate tabkeyJumpView:self];
        }
    }else{
        [super keyDown:theEvent];
    }
}
//Interenal Routine ************************************************************
// 文字列装飾
-(NSMutableAttributedString*)makeAttributedString:(NSString*)str{
    NSMutableAttributedString* attrStr = [UATextAttribute attributedString:str FontSize:19];
    // AlignmentCenter
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [attrStr addAttribute:NSParagraphStyleAttributeName
                    value:paragraphStyle
                    range:NSMakeRange(0, [attrStr length])];
    
    return attrStr;
}
//非選択中の色
-(void)defaultColor{
    self.layer.borderWidth = 1;
    self.layer.borderColor = [NSColor whiteColor].CGColor;
    self.layer.backgroundColor = [NSColor whiteColor].CGColor;
}
//選択中の色
-(void)selectedColor{
    self.layer.borderWidth = 1;
    self.layer.borderColor = [NSColor blackColor].CGColor;
    self.layer.backgroundColor = [NSColor yellowColor].CGColor;
}
@end
