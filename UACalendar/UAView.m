//------------------------------------------------------------------------------
// カレンダービュークラス
//------------------------------------------------------------------------------
#import "UAView.h"
#import "UATextAttribute.h"     //文字列修飾ユーティリティ

@interface UAView (){
    UADateMgr* dtMgr;       //日付操作ユーティリティ
    UACalendar *calInfo;    //カレンダ-情報オブジェクト
}
@property NSMutableArray<UAItemView*> *itemViews;   //日付要素オブジェクトの配列
@property NSArray<UADate *> *dateList;      //日付リスト
@property NSDate *thisFirstDate;            //当月初日
@property NSDate *nowDate;                  //現在日
@property NSDate *selectedDate;             //選択された日付
@property NSMutableAttributedString *title; //タイトル：年月
@property WinDataEntryCntrl *dtEntCntrl;    //血圧データ入力シート
@property NSButton* openButton;             //血圧データ入力シートを開くボタン
@property NSButton* displayButton;          //月間血圧一覧表ボタン

@end

@implementation UAView
- (BOOL) isFlipped{
    return YES;
}
//------------------------------------------------------------------------------
// イニシャライザー：カレンダーを親ウィンドウの中央に表示
//------------------------------------------------------------------------------
-(id)initWindowCenter{
    self = [super initWithFrame:NSMakeRect(0, 0, 0, 0)];
    if (self) {
        [self _init]; //オブジェクトの初期化
    }
    return self;
}
//デフォルトイニシャライザ
- (id)initWithFrame:(CGRect)frame{
    return [self initWindowCenter];
}
//------------------------------------------------------------------------------
//ビューがウィンドウに追加されたとき
//------------------------------------------------------------------------------
- (void)viewDidMoveToWindow{
    //カレンダービューの表示位置（NSpoint）を決め、ビューを表示する。
    NSRect cframe = self.window.contentView.frame;
    NSPoint point;
    point.x = NSMidX(cframe) - WIDTH/2;
    point.y = NSMidY(cframe) - HEIGHT/2;
    [self setFrame:NSMakeRect(point.x, point.y, WIDTH, HEIGHT)];
}
// -----------------------------------------------------------------------------
// カレンダービューの再描画
// -----------------------------------------------------------------------------
- (void)drawRect:(NSRect)dirtyRect{
    [super drawRect:dirtyRect];
    //ビューの背景色
    [[NSColor lightGrayColor] set];
    NSRectFill(dirtyRect);
    //年月見出しはここで表示する。
    float xPos = (WIDTH/2)-(_title.size.width/2);
    [_title drawAtPoint:NSMakePoint(xPos, 15)];
    //曜日見出しはここで表示する。
    NSArray* youbis = [[NSArray alloc] initWithObjects:@"月",@"火",@"水",@"木",@"金",@"土",@"日",nil];
    for (NSInteger i=0; i<7; i++)
    {//曜日ごとに文字修飾し、表示位置を決め、等間隔に表示する。
        NSString *youbi = [youbis objectAtIndex:i];
        NSMutableAttributedString *atrYoubi;
        atrYoubi = [UATextAttribute attributedString:youbi FontName:@"Futura-CondensedMedium"
                                            FontSize:FONT_SIZE_WEEK ForeColor:nil];
        NSSize s = atrYoubi.size;
        NSPoint pos = NSMakePoint(5+(i*CELL_WIDTH)+(CELL_WIDTH/2-(s.width/2)),
                                  HEADER - 22);
        [atrYoubi drawAtPoint:pos];
    }
    //選択されている日にカーソルをセットする。(FirstResponderとする)
    for(UAItemView* item in _itemViews){
        if (item.uadate.integerYearMonthDay == [dtMgr integerYearMonthDay:_selectedDate])
        {
            [self.window makeFirstResponder:item];
            break;
        }
    }
}
//------------------------------------------------------------------------------
// 前月ボタンをクリック
//------------------------------------------------------------------------------
-(void)clickPreButton:(id)sender{
    _thisFirstDate = [dtMgr createPreFirstNSDate:_thisFirstDate]; //当月初日の変更
    _dateList = [calInfo createDateList:_thisFirstDate]; //日付リストの取得
    [self setDate];
    [self poinToDate:LAST_DATE];
}
//------------------------------------------------------------------------------
// 翌月ボタンをクリック
//------------------------------------------------------------------------------
-(void)clickNextButton:(id)sender{
    _thisFirstDate = [dtMgr createNextFirstNSDate:_thisFirstDate];  //当月初日の変更
    _dateList = [calInfo createDateList:_thisFirstDate]; //日付リストの取得
    [self setDate];
    [self poinToDate:FIRST_DATE];
}
//------------------------------------------------------------------------------
// キーボードイベント：月の移動
//------------------------------------------------------------------------------
-(void)keyDown:(NSEvent *)event{
    switch (event.keyCode) {
        case 43:    // 不等号 <
            if ([event modifierFlags] & NSEventModifierFlagShift) {
                //前月へ
                _thisFirstDate = [dtMgr createPreFirstNSDate:_thisFirstDate];   //当月初日の変更
                _dateList = [calInfo createDateList:_thisFirstDate]; //日付リストの取得
                [self setDate];
                [self poinToDate:LAST_DATE];
            }
            break;
        case 47:    // 不等号 >
            if ([event modifierFlags] & NSEventModifierFlagShift) {
                //翌月へ
                _thisFirstDate = [dtMgr createNextFirstNSDate:_thisFirstDate];  //当月初日の変更
                _dateList = [calInfo createDateList:_thisFirstDate]; //日付リストの取得
                [self setDate];
                [self poinToDate:FIRST_DATE];
            }
            break;
        default:
            [super keyDown:event];
            break;
    }
    
}
// CAItemViewDelegateの実装　****************************************************
//------------------------------------------------------------------------------
// 矢印キーで日付を移動する
//------------------------------------------------------------------------------
-(void)moveDate:(UAItemView*)view code:(MoveTyp)code;{
    NSInteger index = [view index];
    // 日付ビューの移動
    switch (code) {
        case LEFT://left
            if (index > 0) {
                index--;
            }else{ //前月へ
                _thisFirstDate = [dtMgr createPreFirstNSDate:_thisFirstDate]; //当月初日の変更
                _dateList = [calInfo createDateList:_thisFirstDate]; //日付リストの取得
                [self setDate];
                [self poinToDate:PRE_DATE];
                return;
            }
            break;
        case RIGHT://right
            if (index < (calInfo.numWeeks*7-1)) {
                index++;}
            else{ //翌月へ
                _thisFirstDate = [dtMgr createNextFirstNSDate:_thisFirstDate]; //当月初日の変更
                _dateList = [calInfo createDateList:_thisFirstDate]; //日付リストの取得
                [self setDate];
                [self poinToDate:NEXT_DATE];
                return;
            }
            break;
        case DOWN://down
            if (calInfo.numWeeks == 6){
                if (index < 7*5) {index += 7;}
                break;
            }else{
                if (index < 7*4) {index += 7;}
                break;
            }
        case UP://up
            if (index >= 7) {index -= 7;}
            break;
        default:
            break;
    }
    //当該日付をファーストレスポンダーにする。
    UAItemView* item = _itemViews[index];
    [self.window makeFirstResponder:item];
    _selectedDate = item.uadate.nsdate;
}
//------------------------------------------------------------------------------
// 血圧入力シートを開くボタンをクリック
//------------------------------------------------------------------------------
-(void)formOpen:(id)sender{
    //選択されている日付を求める
    NSInteger selymd = [dtMgr integerYearMonthDay:_selectedDate];
    for(UAItemView* item in _itemViews){
        if (item.uadate.integerYearMonthDay == selymd){
            [self clickItem:item.uadate];// 血圧入力フォームを開く（モーダルなシート）
            break;
        }
    }
}
//------------------------------------------------------------------------------
// 血圧入力シートを開く
//------------------------------------------------------------------------------
-(void)clickItem:(UADate*)uadate{
    // クリック（CAItemViewのmouseDownイベント）の結果、そのビューが自動的にFistResponderになる。
    _selectedDate = [uadate nsdate];
    //日付に対応したデータの取得（DB読み込み)
    [_dtEntCntrl getDataFor:uadate];
    //シートのデータ初期設定
    [_dtEntCntrl initialDataSet];
    //モーダルなシートを表示する。
    [self.window beginSheet:[_dtEntCntrl window]
      //シートを閉じたときのコールバック処理
      completionHandler:^(NSModalResponse returnCode) {
          if (returnCode == NSModalResponseOK){
              //
          }
      }];
}

//------------------------------------------------------------------------------
// 血圧一覧表ウィンドウを開く
//------------------------------------------------------------------------------
-(void)displayOpen:(id)sender{
    //モードレスなウィンドウを表示する。
    NSRect rect = [self.window frame];
    NSPoint point = NSMakePoint(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    [_resultCntrl showWindow:self];                     //ウィンドウの表示
    [[_resultCntrl window] setFrameTopLeftPoint:point]; //表示位置の変更
    
    //モーダルなウィンドウを表示する。
    //NSModalResponse returnCode = [NSApp runModalForWindow:[_resultCntrl window]];
    //NSLog(@"ModalWindow finished of:%ld",returnCode);
    //月間表の作成・表示
    [_resultCntrl monthlyChartItems:_itemViews title:_title.string];
}
// Internan Routine ************************************************************
// -----------------------------------------------------------------------------
// 初期化：コントロールの生成
// -----------------------------------------------------------------------------
-(void)_init{
    //日付ビューテーブル（添え字処理用）
    _itemViews = [[NSMutableArray alloc] init];
    //見出し文字列オブジェクトの作成
    _title = [[NSMutableAttributedString alloc] init];
    //前月ボタンの作成とカレンダービューへの追加(target&action)
    float x = 5;//左余白>
    float y = 10;
    NSButton* clickPreButton = [NSButton buttonWithTitle:@"<"
                                                  target:self
                                                  action:@selector(clickPreButton:)];
    clickPreButton.frame = NSMakeRect(x,y,24,35);
    [clickPreButton setButtonType:NSMomentaryPushInButton];
    [clickPreButton setBezelStyle:NSBezelStyleTexturedSquare];
    [self addSubview:clickPreButton];
    //翌月ボタンの作成とカレンダービューへの追加(target&action)
    x = WIDTH-(5+24); //右余白+ボタンの幅
    NSButton *clickNextButton = [NSButton buttonWithTitle:@">"
                                          target:self
                                          action:@selector(clickNextButton:)];
    clickNextButton.frame = NSMakeRect(x,y,24,35);
    [clickNextButton setButtonType:NSMomentaryPushInButton];
    [clickNextButton setBezelStyle:NSBezelStyleTexturedSquare];
    [self addSubview:clickNextButton];
    //日付ビューのグリッド(6行×7列)を作成してカレンダービューへ追加する
    NSInteger index = 0;
    for (NSInteger i=1; i<=6; i++){
        for (NSInteger j=1; j<=7; j++){
            //日付ビュー(CAItemVieクラス)の作成
            float x = ((j-1) % 7) * CELL_WIDTH + 5;
            float y =  HEADER + ((i-1) * CELL_HEIGHT) + 4;
            NSRect rect = NSMakeRect(x,
                                     y,
                                     CELL_WIDTH,
                                     CELL_HEIGHT);
            UAItemView *item = [[UAItemView alloc] initWithFrame:rect index:index];
            [_itemViews addObject:item];    //日付ビューを日付ビューテーブルに追加
            [self addSubview:item];
            index++;
        }
    }
    //血圧入力フォームを開くボタンの作成とカレンダービューへの追加(target&action)
    _openButton = [NSButton buttonWithTitle:@"入力（⌘o）"
                                     target:self
                                     action:@selector(formOpen:)];
    _openButton.frame = CGRectMake(WIDTH/4-62 ,0 ,130 ,35);
    [_openButton setButtonType:NSMomentaryPushInButton];
    [_openButton setBezelStyle:NSBezelStyleTexturedSquare];
    _openButton.keyEquivalentModifierMask = NSEventModifierFlagCommand;
    _openButton.keyEquivalent = @"o";
    [self addSubview:_openButton];
    //血圧一覧表示ボタンの作成とカレンダービューへの追加(target&action)
    _displayButton = [NSButton buttonWithTitle:@"一覧表示（⌘d）"
                                        target:self
                                        action:@selector(displayOpen:)];
    _displayButton.frame = CGRectMake(WIDTH/4*3-68 ,0 ,130 ,35);
    [_displayButton setButtonType:NSMomentaryPushInButton];
    [_displayButton setBezelStyle:NSBezelStyleTexturedSquare];
    _displayButton.keyEquivalentModifierMask = NSEventModifierFlagCommand;
    _displayButton.keyEquivalent = @"d";
    [self addSubview:_displayButton];
    //カレンダーオブジェクトの取得
    dtMgr = [UADateMgr DateManager];                        //日付操作ユーティリティ
    calInfo = [[UACalendar alloc] init];                    //カレンダー情報のオブジェクト
    _nowDate = [NSDate date];                               //現在日を求める
    _thisFirstDate = [dtMgr createFirstNSDate:_nowDate];    //当月の1日の日付オブジェクト
    _dateList = [calInfo createDateList:_thisFirstDate];    //日付リストの取得
    //カレンダー情報をカレンダービューにセットする
    [self setDate];
    //現在日にカーソルをおく
    [self poinToDate:CURRENT_DATE];
    //血圧入力フォームオブジェクトの作成
    _dtEntCntrl = [[WinDataEntryCntrl alloc] initWithWindowNibName:@"WinDataEntry"];
    _dtEntCntrl.delegate = self;
    //血圧一覧表オブジェクトの作成
    _resultCntrl = [[WinResultCntrl alloc] initWithWindowNibName:@"WinResult"];
}
//------------------------------------------------------------------------------
// 日付情報をカレンダービューにセットする
//------------------------------------------------------------------------------
-(void)setDate{
    //年月見出しの編集
    DateRecord fdt = [dtMgr structYearMonthDay:_thisFirstDate];
    NSString* wareki = [dtMgr toWareki:_thisFirstDate]; //和暦を求める
    NSArray* values = [wareki componentsSeparatedByString:@" "];
    NSString* ymStr = [NSString stringWithFormat:
                       @"%ld年%ld月(%@%@)",fdt.year, fdt.month, values[0], values[1]];
    _title = [UATextAttribute attributedString:ymStr FontName:@"YuGothic"
                                      FontSize:FONT_SIZE_HEADER ForeColor:nil];
    //一ヶ月分の血圧データを読み込む。
    NSString* param = [NSString stringWithFormat:@"id=%ld&from_date=%ld&to_date=%ld",
                       500L ,calInfo.fromDate, calInfo.toDate];
    //結果は辞書の配列：辞書のKeys[id][date][upper][lower]
    NSArray<NSDictionary *>* bloodPressureList =
        [UAServerRequest post:DB_URL_READ1 prmString:param];
    // [参考] POSTパラメータをJSON形式のデータで送る場合
    //一ヶ月分の血圧データを読み込む。結果は辞書の配列：辞書のKeys[id][date][upper][lower]
    /*
    NSDictionary* param = @{
    @"id":@500L,
    @"fromDate":[NSNumber numberWithInteger:calInfo.fromDate],
    @"toDate":[NSNumber numberWithInteger:calInfo.toDate]};
    NSArray <NSDictionary*>*bloodPressureList = [UAServerRequest
                                                 postGetJson:DB_URL_READ1_JSON
                                                 pJson:param];
    */
    //カレンダの日数分繰り返し、日付情報を日付ビューのプロパティにセットする。
    for (NSInteger i=0; i< _itemViews.count; i++){
        UAItemView* item = _itemViews[i]; //日付ビュー
        if (i >= _dateList.count){
            //カレンダーが5週の場合、6週目の日付ビューは非表示とする。
            item.hidden = true;
            continue;
        }
        else{
            //日付ビューを表示とする。
            item.hidden = false;
        }
        UADate *dt = _dateList[i];          //日付リストの日付情報
        //各日付ビュー(CAItemViewオブジェクト)に日付の属性をセットする。
        NSString* str = [NSString stringWithFormat:@"%ld",[dt day]];
        [item setDateString:str];           //日付 (文字列)
        [item setUadate:dt];                //UADateオブジェクトの格納
        //現在日の判定
        NSInteger ndt = [dtMgr integerYearMonthDay:_nowDate];
        if (ndt == dt.integerYearMonthDay){
            dt.isToday = YES;
        }else{
            dt.isToday = NO;
        }
        [item setDelegate:self];    //CAItemViewクラスのDelegateを引き受ける
        //★血圧データの取得
        item.confirm = NO;
        item.lower = item.upper = 0;
        for (NSDictionary* response in bloodPressureList){
            NSInteger ymd = ((NSNumber*)response[@"date"]).integerValue;
            if (item.uadate.integerYearMonthDay == ymd){
                item.upper = ((NSNumber*)response[@"upper"]).integerValue;   //最高血圧(整数)
                item.lower = ((NSNumber*)response[@"lower"]).integerValue;   //最低血圧(整数)
                item.confirm = ((NSNumber*)response[@"confirm"]).integerValue; //確定フラグ
                break;
            }
        }
        item.needsDisplay = YES;
    }
    //NSLog(@"after  subviews.count of ItemView %ld",self.subviews.count);
    self.needsDisplay = YES;
    //ボタンの縦位置の決定（面倒だが以下の方法）
    float btnYpos = HEADER + CELL_HEIGHT*calInfo.numWeeks + 10; //Y座標
    //ボタンの形状情報の取得
    NSRect opnBtnRect = _openButton.frame;
    NSRect dspBtnRect = _displayButton.frame;
    //Y座標の変更
    opnBtnRect.origin.y = btnYpos;
    dspBtnRect.origin.y = btnYpos;
    //ボタンの形状情報を戻す
    _openButton.frame = opnBtnRect;
    _displayButton.frame = dspBtnRect;
    //ビューの高さの調整
    float viewHeight = HEADER + CELL_HEIGHT*calInfo.numWeeks + FOTTER;
    NSRect viewRect = self.frame;
    viewRect.size.height = viewHeight;
    self.frame = viewRect;
}
//------------------------------------------------------------------------------
// 選択状態にする日付
//------------------------------------------------------------------------------
-(void)poinToDate:(StartPosTyp)flg{
    //現在日を選択状態にする
    if (flg == CURRENT_DATE){
        _selectedDate = _nowDate;
    }
    //初日を選択状態にする
    if (flg == FIRST_DATE){
        _selectedDate = _thisFirstDate;
    }
    //末日を選択状態にする
    if (flg == LAST_DATE){
        _selectedDate = [dtMgr createLastNSDate:_thisFirstDate];
    }
    //翌日
    if (flg == NEXT_DATE){
        _selectedDate = [dtMgr createNSDate:_selectedDate incr:1];
    }
    //前日
    if (flg == PRE_DATE){
        _selectedDate = [dtMgr createNSDate:_selectedDate incr:-1];
    }
}
//WinDataEntryCntrlDelegate ----------------------------------------------------
-(void)updateColendaer{
    [self setDate];
}
@end
