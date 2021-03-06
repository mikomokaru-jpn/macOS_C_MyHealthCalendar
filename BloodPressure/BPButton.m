#import "BPButton.h"
//------------------------------------------------------------------------------
// 数値ボタン
//------------------------------------------------------------------------------
@implementation BPButton
-(id)initWithRect:(NSRect)rect number:(NSInteger)num delegate:(id)obj{
    self = [super init];
    if (self == nil){
        return self;
    }    
    //ボタンの種類・形状の定義
    [self setButtonType:NSMomentaryPushInButton];
    [self setBezelStyle:NSBezelStyleTexturedSquare];
    self.bordered = NO;
    self.frame = rect;
    //カスタムプロパティ
    _number = num;
    _delegate = obj;
    return self;
}
//ビューの再表示
- (void)drawRect:(NSRect)dirtyRect {
    //タイトル（数字）のセット
    if (self.number == -1){
        [self setTitle:@"C"];
    }else{
        [self setTitle:[NSString stringWithFormat:@"%ld", self.number]];
    }
    self.font = [NSFont fontWithName:@"Arial" size:22];     //フォント（NSButton固有属性）
    self.layer.borderWidth = 1;                             //枠線の太さ（NSButton固有属性）
    self.layer.borderColor = [NSColor grayColor].CGColor;   //枠線の色（NSButton固有属性）
    [self pushOff]; //背景色オフ
    [super drawRect:dirtyRect];
}
//マウスでクリックした
- (void)mouseDown:(NSEvent *)event{
    [self pushOn]; //背景色オン
    //クリックされた数字を入力フィールドに追加する。自オブジェクトを引数とする
    [_delegate clickNumber:self];
}
//マウスを戻した
- (void)mouseUp:(NSEvent *)event{
    [self pushOff]; //背景色
}
//背景色オン：黄色
-(void)pushOn{
    self.layer.backgroundColor =  [NSColor yellowColor].CGColor;
}
//背景色オフ：グレー
-(void)pushOff{
    self.layer.backgroundColor =  [NSColor whiteColor].CGColor;
}
@end
