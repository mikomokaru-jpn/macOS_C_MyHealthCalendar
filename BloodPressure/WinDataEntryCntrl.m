#import "WinDataEntryCntrl.h"
#import "CAShapeLayer+MyShapeLayer.h"
#import "NSTextField+MyTextField.h"
#import "UAServerRequest.h"
#import "BPValueView.h"
//------------------------------------------------------------------------------
// 血圧データ入力ウィンドウ制御
//------------------------------------------------------------------------------
@interface WinDataEntryCntrl ()
//コントロール
@property NSMutableArray *btns;         //数値ボタン　0〜9
@property BPButton *btnC;               //クリアボタン　C
@property NSTextField* dateLabel;       //日付
@property BPValueView *value1;          //最高血圧
@property BPValueView *value2;          //最低血圧
@property UAAcceptButton *confirmFlg;   //確定フラグ
@property NSTextField *warning;         //警告メッセージ
//プロパティ
@property UADate *date;                 //日付オブジェクト
@property NSRegularExpression* regex;   //正規表現
@property UAServerRequest *serveReq;    //HTTPインタフェースメソッド（クライアント・リクエスト）
@property NSInteger upper;              //最高血圧（保存用）
@property NSInteger lower;              //最低血圧（保存用）
@property BOOL confirm;                 //確定フラグ（保存用）
@end

@implementation WinDataEntryCntrl
-(id) initWithWindowNibName:(NSString*)xibName{
    self = [super initWithWindowNibName:xibName];
    if (self == nil){
        return self;
    }    
    //数値ボタンオブジェクトの生成
    _btns = [[NSMutableArray alloc] init];  //数値ボタンオブジェクトの配列
    float xPos = 83; float yPos = 50;       //基準座標
    for(NSInteger i=0; i<10; i++)
    {
        BPButton *btn = [[BPButton alloc] initWithRect:CGRectMake(0 ,0 ,40 ,40)
                                                number:i delegate:self];
        [_btns addObject:btn];                      //配列に追加
        [self.window.contentView  addSubview:btn];  //ビューに追加
    }
    //数値ボタンの配置場所
    float span = 39;
    [_btns[7] setFrameOrigin:NSMakePoint(xPos, yPos)];
    [_btns[8] setFrameOrigin:NSMakePoint(xPos+span, yPos)];
    [_btns[9] setFrameOrigin:NSMakePoint(xPos+span*2, yPos)];
    [_btns[4] setFrameOrigin:NSMakePoint(xPos, yPos+span)];
    [_btns[5] setFrameOrigin:NSMakePoint(xPos+span, yPos+span)];
    [_btns[6] setFrameOrigin:NSMakePoint(xPos+span*2, yPos+span)];
    [_btns[1] setFrameOrigin:NSMakePoint(xPos, yPos+span*2)];
    [_btns[2] setFrameOrigin:NSMakePoint(xPos+span, yPos+span*2)];
    [_btns[3] setFrameOrigin:NSMakePoint(xPos+span*2, yPos+span*2)];
    [_btns[0] setFrameOrigin:NSMakePoint(xPos, yPos+span*3)];
    //クリアボタンの生成
    NSRect rect = NSMakeRect(xPos+span, yPos+span*3 ,79 ,40);
    _btnC = [[BPButton alloc] initWithRect:rect number:-1 delegate:self];
    [self.window.contentView  addSubview:_btnC];
    //閉じるボタンの生成
    NSButton* btnClose = [[NSButton alloc] init];
    btnClose = [NSButton buttonWithTitle:@"登録"
                                  target:self
                                  action:@selector(formClose:)];
    btnClose.frame = CGRectMake(110, 210 ,90 ,40);
    [btnClose setButtonType:NSMomentaryPushInButton];
    [btnClose setBezelStyle:NSBezelStyleRounded];
    [btnClose setKeyEquivalent:@"\r"];
    [self.window.contentView  addSubview:btnClose];
    //キャンセルボタンの生成
    NSButton *btnCancel = [[NSButton alloc] init];
    btnCancel = [NSButton buttonWithTitle:@"キャンセル"
                                   target:self
                                   action:@selector(formCancel:)];
    btnCancel.frame = CGRectMake(15, 210 ,90 ,40);
    [btnCancel setButtonType:NSMomentaryPushInButton];
    [btnCancel setBezelStyle:NSBezelStyleRounded];
    [self.window.contentView  addSubview:btnCancel];
    //日付ラベル
    _dateLabel = [self labelFontSize:20 point:NSMakePoint(15, 15)];
    [self.window.contentView addSubview:_dateLabel];
    //最高血圧入力エリア
    NSTextField* uLabel = [self labelFontSize:12 point:NSMakePoint(15, 50)];
    [uLabel setText:@"最高血圧"];
    [self.window.contentView addSubview:uLabel];
    _value1 = [[BPValueView alloc] init];
    _value1.frame = CGRectMake(17, 70 ,50 ,30);
    [self.window.contentView  addSubview:_value1];
    [_value1 setDelegate:self];         //BPValueViewDelegateを引き受ける
    //最低血圧入力エリア
    NSTextField* lLabel = [self labelFontSize:12 point:NSMakePoint(15, 110)];
    [lLabel setText:@"最低血圧"];
    [self.window.contentView addSubview:lLabel];
    _value2 = [[BPValueView alloc] init];
    _value2.frame = CGRectMake(17, 130 ,50 ,30);
    [self.window.contentView  addSubview:_value2];
    [_value2 setDelegate:self];         //BPValueViewDelegateを引き受ける
    //確定フラグ
    _confirmFlg = [[UAAcceptButton alloc] initWithFrame:NSMakeRect(15,180,60,18)];
    [_confirmFlg setButtonType:NSSwitchButton];
    [_confirmFlg setBezelStyle:0];
    [_confirmFlg setDelegate:self];
    [_confirmFlg setTitle:@"確定"];
    [self.window.contentView addSubview:_confirmFlg];
    //正規表現パターンの定義：数値以外の判定
    _regex = [NSRegularExpression regularExpressionWithPattern:@"[^0-9]"
                                                       options:0
                                                         error:nil];
    //警告メッセージ
    _warning = [self labelFontSize:12 point:NSMakePoint(15, 250)];
    _warning.textColor = [NSColor redColor];
    [self.window.contentView addSubview:_warning];
    return self;
}
// Windowコントーラの開始
- (void)windowDidLoad {
    [super windowDidLoad];
    /*for developer ............................................................
    CAShapeLayer* line1 = [CAShapeLayer layerGridInRect:self.window.contentView.frame
                                             atInterval:10    //線の間隔
                                                  width:0.2]; //細の太さ
    CAShapeLayer* line2 = [CAShapeLayer layerGridInRect:self.window.contentView.frame
                                             atInterval:50    //線の間隔
                                                  width:1.0]; //細の太さ
    [self.window.contentView.layer addSublayer:line1];
    [self.window.contentView.layer addSublayer:line2];
    // .........................................................................*/
    //コンテントビューの背景色
    self.window.contentView.layer.backgroundColor = [NSColor lightGrayColor].CGColor;
}
// event handler ***************************************************************
// キーボードのキーを押した
-(void)keyDown:(NSEvent *)theEvent{
    //数値キーのみ入力可能
    //ただし、deleteキー、"C"キーで入力エリアのクリア
    if (theEvent.keyCode == 51)
    {
        [self updateNumber:-1];
        return;
    }
    NSString* ch = theEvent.characters;
    NSInteger num = 10;
    if([ch isEqualToString:@"0"]){num = 0;}
    if([ch isEqualToString:@"1"]){num = 1;}
    if([ch isEqualToString:@"2"]){num = 2;}
    if([ch isEqualToString:@"3"]){num = 3;}
    if([ch isEqualToString:@"4"]){num = 4;}
    if([ch isEqualToString:@"5"]){num = 5;}
    if([ch isEqualToString:@"6"]){num = 6;}
    if([ch isEqualToString:@"7"]){num = 7;}
    if([ch isEqualToString:@"8"]){num = 8;}
    if([ch isEqualToString:@"9"]){num = 9;}
    if([ch caseInsensitiveCompare:@"c"]==NSOrderedSame){num = -1;}
    if(num < 10){
        [self updateNumber:num];
    }
}
//キャンセル処理 escキー押下時に呼ばれるNSResponderのcancel:アクションを実装する。
- (void)cancel:(id)sender{
    [self formCancel:nil];    //シートを閉じる
}
// BtnCalc Delegate ************************************************************
// 数字ボタンをクリックした
-(void)clickNumber:(BPButton*)btn{
    [self updateNumber:btn.number];
}
// BPValueViewDelegate *********************************************************
// タブキーによるコントロールの移動
-(void)tabkeyJumpView:(id)bpview{
    if (bpview == _value1){
        [self.window makeFirstResponder:_value2];
    }
    else if (bpview == _value2){
        [self.window makeFirstResponder:_confirmFlg];
    }
}

// UAAcceptButtonDelegate ******************************************************
//確定チェックボックスの反転
-(void)KeyDownFromUAButton:(id)sender event:(NSEvent *)theEvent{
    if (theEvent.keyCode == 48){
        //タブキーによるコントロールの移動
        [self.window makeFirstResponder:_value1];
    }else if (theEvent.keyCode == 36){
        //チェックを逆転する
        _confirmFlg.state = !_confirmFlg.state;
    }
}

// Action **********************************************************************
//キャンセルボタン
-(void)formCancel:(id)sender{
    //モーダルなシートを閉じる
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseCancel];
}
//登録ボタン
-(void)formClose:(id)sender{
    if (_lower == _value2.intValue & _upper == _value1.intValue
        & _confirm ==  _confirmFlg.state){
        //値の変更なし。（DB読み込み時と値が同じ）
    }
    else{
        if ([_warning.stringValue isEqualTo:@""]){
            [_warning setText:@""];
            //入力チェック
            if (_value1.intValue == 0 | _value2.intValue == 0){
                [_warning setText:@"血圧が入力されていません。"];
                return;
            }
            //入力チェック
            if (_value2.intValue >= _value1.intValue){
                [_warning  setText:@"値が不正です。最低≧最高"];
                return;
            }
            //DB更新
            NSString* param = [NSString stringWithFormat:@"id=%ld&date=%ld&lower=%ld&upper=%ld&confirm=%ld"
                           ,500L
                           ,_date.integerYearMonthDay
                           ,_value2.intValue
                           ,_value1.intValue
                           ,_confirmFlg.state];
            [UAServerRequest post:DB_URL_WRITE1 prmString:param];
            //カレンダービュー再表示
            [_delegate updateColendaer];
        }
    }
    //モーダルなシートを閉じる
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseCancel];
}

// Instance Method *************************************************************
// 指定された日付の血圧データを取得する（HTTP通信）
// UAViewからは、更新直後のデータは取得できない。
-(void)getDataFor:(UADate*)dt{
    //DB読み込み1（PHP実行）
    _date = dt;
    NSString* param = [NSString stringWithFormat:@"id=%ld&date=%ld",500L ,_date.integerYearMonthDay];
    NSArray* records = [UAServerRequest post:DB_URL_READ2 prmString:param];
    if (records.count < 1){
        //レコードなし
        _lower = 0;
        _upper = 0;
        _confirm = YES;
    }else{
        //レコードあり：
        NSDictionary *record = records[0];
        _lower = ((NSNumber*)record[@"lower"]).integerValue;
        _upper = ((NSNumber*)record[@"upper"]).integerValue;
        _confirm = ((NSNumber*)record[@"confirm"]).integerValue;
    }
}
//シートのデータ初期設定
-(void)initialDataSet{
    //日付ラベル
    NSString* date = [NSString stringWithFormat:@"%ld年%ld月%ld日(%@)",
                      _date.year, _date.month, _date.day, _date.strYobi];
    [_dateLabel setText:date];
    _dateLabel.needsDisplay = YES;
    //入力フィールドに値を設定
    _value1.intValue = _upper;
    _value2.intValue = _lower;
    _confirmFlg.state = _confirm;
    [_warning setText:@""];
    //日付
    _value1.needsDisplay = YES;
    _value2.needsDisplay = YES;
    [self.window makeFirstResponder:_value1];   //最高血圧にカーソルをおく
}
// Internal Routine ************************************************************
// 数値の入力
-(void)updateNumber:(NSInteger)num{
    id responder = self.window.firstResponder;
    //カーソルが血圧の入力フィールドにあるときのみ処理する
    if ([responder isMemberOfClass:[BPValueView class]]){
        BPValueView* bpview = responder;
        //カーソルが移った直後に値を入力したときは、最初からの入力とする。
        if (bpview.initialInput == YES ){
            bpview.intValue = 0;
            bpview.initialInput = NO;
        }
        //入力値の判定
        if (num == -1 ){
            //Clearボタン
            bpview.intValue = 0;
        }else{
            //クリックされた数字を入力フィールドに追加する。
            bpview.intValue = bpview.intValue * 10 + num;
            //最大桁数は3桁。3桁以上入力されたら
            if ( bpview.intValue > 99){
                //次のコントロールに移る。
                [self tabkeyJumpView:bpview];
            }
        }
        [(BPValueView*)responder setNeedsDisplay:YES]; //!!!!!
    }
}
//ラベルの作成：大きさゼロのframeを作成する。
-(NSTextField*)labelFontSize:(float)size point:(NSPoint)point{
    NSTextField* label = [[NSTextField alloc] init];
    label.editable = NO;
    label.font = [NSFont fontWithName:@"Arial" size:size];
    label.backgroundColor = [NSColor clearColor];
    label.bordered = NO;
    [label setFrame:NSMakeRect(point.x, point.y, 0, 0)];
    return label;
}
@end
