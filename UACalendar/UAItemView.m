//------------------------------------------------------------------------------
// 日付ビュークラス
//------------------------------------------------------------------------------
#import "UAItemView.h"
#import "UAView.h"
#import "UATextAttribute.h"
//インタフェース宣言
@interface UAItemView()
@property NSColor* blue1;             //選択された日付(FirstResponder)の枠線の色
@property NSColor* blue2;             //当日の背景色
@property NSAttributedString *aStr;   //日付文字列
@end
//クラスの実装
@implementation UAItemView
//------------------------------------------------------------------------------
//イニシャライザー　引数：①日付ビュー(矩形)の位置と大きさ、②順序番号
//------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame index:(NSInteger)index{
    _index = index;
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];   //初期処理
    }
    return self;
}
// -----------------------------------------------------------------------------
// 日付ビューの再描画
// -----------------------------------------------------------------------------
- (void)drawRect:(NSRect)dirtyRect{
    [super drawRect:dirtyRect];
    if ([_dateString isEqualToString:@""]){
        return; ////初期化のときはスキップ（無駄なことはしない）
    }
    //クリア
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path appendBezierPathWithRect:NSMakeRect(0, 0, width, height)];
    //デフォルト背景色
    [[NSColor whiteColor] set];
    [path fill];
    //背景色と枠線の設定
    if (self.window.firstResponder == self){
        //FirstResponderである
        if (_uadate.isToday){
            //当日のとき背景色を変更
            [_blue2 setFill];
            [path fill];
        }
        //FirstResponderのときの枠線の色
        [_blue1 set];
        [path setLineWidth:5];
        [path stroke];
    }
    else{
        //FirstResponderでない
        if (_uadate.isToday){
            //当日のとき背景色を変更
            [_blue2 setFill];
            [path fill];
        }
        //FirstResponder以外のときの枠線の色
        [[NSColor lightGrayColor] set];
        [path stroke];
    }
    //日付文字列の設定：位置指定
    _aStr = [self attributedDate:_dateString];
    NSSize size = [_aStr size];
    float x = (width/2)-(size.width/2);
    float y = (height/2)-(size.height/2);        // center
//    float y = (height)-(size.height)-height*0.1; // a little above
    //★血圧レコードの表示
    if(_confirm){
        //血圧入力確定済みの丸印
        NSBezierPath* path2 = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect
                               ((self.frame.size.width/2-17),
                                (self.frame.size.height/2-17),
                                34, 34)];
        [[NSColor.blackColor colorWithAlphaComponent:0.5] set];
        [path2 stroke];
    }
    //日付の描画
    [_aStr drawAtPoint:NSMakePoint(x, y)];
}
- (BOOL)acceptsFirstResponder{
    return YES; // default NO
}
- (BOOL)resignFirstResponder{
    //ビューをクリックしただけではdrawRect:が起動しないため、強制的に起動する。
    [self setNeedsDisplay:YES];
    return YES; // default YES
}
- (BOOL)becomeFirstResponder{
    //ビューをクリックしただけではdrawRect:が起動しないため、強制的に起動する。
    [self setNeedsDisplay:YES];
    return YES; // default YES
}
//------------------------------------------------------------------------------
// キーを押す。
//------------------------------------------------------------------------------
-(void)keyDown:(NSEvent *)event{
    switch (event.keyCode) {
        case 123:   //left  前日へ
            [_delegate moveDate:self code:LEFT];
            break;
        case 124:   //right 翌日へ
        case 48:    //tab 翌日へ
            [_delegate moveDate:self code:RIGHT];
            break;
        case 125:   //down  翌週へ
            [_delegate moveDate:self code:DOWN];
            break;
        case 126:   //up    前週へ
            [_delegate moveDate:self code:UP];
            break;
        case 36:   //★return 血圧入力フォーム
            [_delegate clickItem:_uadate];
            break;
        default:
            [super keyDown:event];
            break;
    }
}
//------------------------------------------------------------------------------
// 日付をクリックする。
//------------------------------------------------------------------------------
- (void)mouseUp:(NSEvent *)event{
    if([event clickCount] == 2){
        //★血圧データ入力フォーム
        [_delegate clickItem:_uadate];
    }else{
        [_delegate moveDate:self code:THIS];
    }
}
// Internan Routine ************************************************************
// -----------------------------------------------------------------------------
// 初期処理
// -----------------------------------------------------------------------------
-(void)_init{
    _dateString = @"";  //日付文字列の初期化　[これを行わないとdrawRectでオブジェクトのヌル参照例外が発生する]
    width = CELL_WIDTH;
    height = CELL_HEIGHT;
    _blue1 = [NSColor colorWithRed:45.0/255 green:100.0/255 blue:220.0/255 alpha:1.0];
    _blue2 = [NSColor colorWithRed:180.0/255 green:200.0/255 blue:220.0/255 alpha:0.75];
}
//------------------------------------------------------------------------------
// 日付の文字列装飾
//------------------------------------------------------------------------------
-(NSMutableAttributedString*)attributedDate:(NSString*)str{
    NSMutableAttributedString* attrStr;
    // フォント
    if (_uadate.monthType == ThisMonth){
        //当月
        if (_uadate.dayType == Saturday)
        {   //土曜
            attrStr = [UATextAttribute attributedString:str FontSize:FONT_SIZE
                                              ForeColor:[NSColor blueColor]];
        }else if (_uadate.dayType == Sunday | _uadate.isHoliday == YES)
        {   //日曜・休日
            attrStr = [UATextAttribute attributedString:str FontSize:FONT_SIZE
                                              ForeColor:[NSColor redColor]];
        }else
        {   //平日
            attrStr = [UATextAttribute attributedString:str FontSize:FONT_SIZE];
        }
    }else{
        //前月、翌月
        if (_uadate.dayType == Saturday)
        {   //土曜
            attrStr = [UATextAttribute attributedString:str FontSize:FONT_SIZE_SMALL
                                              ForeColor:[NSColor blueColor]];
        }else if (_uadate.dayType == Sunday | _uadate.isHoliday == YES)
        {   //日曜・休日
            attrStr = [UATextAttribute attributedString:str FontSize:FONT_SIZE_SMALL
                                              ForeColor:[NSColor redColor]];
        }else
        {   //平日
            attrStr = [UATextAttribute attributedString:str FontSize:FONT_SIZE_SMALL];
        }
    }
    return attrStr;
}
@end
