#import <QuartzCore/QuartzCore.h>
#import "NSBezierPath+MyBezierPath.h"
#import "NSColor+MyColor.h"
#import "UATextAttribute.h"
#import "WinResultCntrl.h"
#import "RERecord.h"
#import "REHeaderView.h"
#import "REMainView.h"
#import "REItemView.h"
//------------------------------------------------------------------------------
// 月間血圧一覧表を作成する
//------------------------------------------------------------------------------
@interface WinResultCntrl ()
@property REHeaderView *headerView;                 //ヘッダビュー
@property NSScrollView *scrollView;                 //スクロールビュー
@property REMainView *mainView;                     //メインビュー
@property NSMutableArray<NSMutableArray<REItemView*>*>* matrix; //アイテムビューのリスト
@property NSMutableArray<RERecord*>* recordList;    //血圧レコードのリスト
//外形寸法
@property float window_height;                      //ウィンドウの高さ
@property float header_height;                      //ヘッダビューの高さ
@property float main_height;                        //明細行の高さの合計
@property float cell_height;                        //明細行の高さ
@property float scroll_width;                       //スクロールビューの幅
@property float main_width;                         //メインビューの幅
@property float graph_width;                        //グラフ領域の幅
@end

@implementation WinResultCntrl
//イニシャライザ
- (id)initWithWindowNibName:(NSNibName)windowNibName{
    self = [super initWithWindowNibName:windowNibName];
    if (self == nil){
        return self;
    }
    _recordList = [[NSMutableArray alloc] init];    //血圧データリスト
    _matrix = [[NSMutableArray alloc] init];        //アイテムビューリスト
    //外形寸法
    _window_height = 720;
    _header_height = 50;
    _cell_height = 20;
    _main_height = _cell_height * 31 + 1;   //1ヶ月MAX
    _scroll_width = 480;
    _main_width = 460;
    _graph_width = 299;
    return self;
}
//ウィンドウ・ロード時
- (void)windowDidLoad {
    [super windowDidLoad];
    NSRect rect = self.window.frame;
    rect.size.height = _window_height;
    [self.window setFrame:rect display:true];
    //コンテントビュー
    NSRect frame = self.window.contentView.frame;
    self.window.contentView.layer.backgroundColor = [NSColor whiteColor].CGColor;
    //ヘッダビュー
    _headerView = [[REHeaderView alloc]
                   initWithFrame:NSMakeRect(0, 0, frame.size.width, _header_height)];
    [self.window.contentView addSubview:_headerView];
    //スクロールビュー
    _scrollView = [[NSScrollView alloc] initWithFrame:
                   NSMakeRect(10, _header_height, _scroll_width, _main_height+20)];
    [self.window.contentView addSubview:_scrollView];
    [_scrollView setBorderType:NSNoBorder];
    [_scrollView setHasVerticalScroller:YES];
    //autoresizingMaskの設定
    _scrollView.autoresizingMask = NSViewMaxXMargin | NSViewHeightSizable;
    //[self evalAutoresizingMask:_scrollView.autoresizingMask]; for test
    //メインビュー
    _mainView = [[REMainView alloc] initWithFrame:
                 NSMakeRect(0, 0, _main_width, _main_height) graphWidth:299];
    [_scrollView setDocumentView:_mainView];        //スクロールビューに格納
    //アイテムビューオブジェクトの生成と親ビューへの格納
    for (NSInteger i=0; i<31; i++){
        NSMutableArray<REItemView*>* rows = [[NSMutableArray alloc] init];  //行の作成
        for (NSInteger j=0; j<7; j++){
            REItemView *view = [[REItemView alloc] initWithFrame:NSMakeRect(0, 0, 0, 0)];
            [_mainView addSubview:view];    //アイテムビューを親ビューに格納
            [rows addObject:view];          //アイテムビューをアイテムビューリストに追加
        }
        [_matrix addObject:rows];
    }
    [_mainView scrollPoint:NSMakePoint(0, 0)];      //スクロールの位置指定
}
//ユーザのキャンセル操作（escキー押下）
- (void)cancel:(id)sender{
    [self.window close];    //ウィンドウを閉じる
}
//**** NSWindowDelegateの実装 ****
//ウィンドウが閉じられた
- (void)windowWillClose:(NSNotification *)notificationb{
    //モーダルウィンドウの場合
    //イベントループを呼び出し元に戻す。
    //[NSApp stopModalWithCode:NSModalResponseCancel];
}
// ウィンドウのサイズが変更された。（高さは最小/最大の範囲、幅は固定）
- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize{
    NSSize theSize = frameSize;
    if (frameSize.width != 500){
        theSize.width = 500;
    }
    if (frameSize.height < 120){
        theSize.height = 120;
    }else if (frameSize.height > _window_height ){
        theSize.height = _window_height ;
    }
    return theSize;
}
// Instance method *************************************************************
//1ヶ月の血圧レコードを作成する。
//★カレンダービュー(UAViewオブジェクト)から、月間血圧一覧表ウィンドウを開いたときに呼ばれる。
-(void)monthlyChartItems:(NSArray<UAItemView*>*)itemViews
                   title:(NSString*)title{
    //レコードリストのクリア
    [_recordList removeAllObjects];
    for (UAItemView *item in itemViews){
        if(item.uadate.monthType == ThisMonth && !item.hidden){
            //当月かつ表示している日付（非表示の日付は6週目の日付の残骸である）
            [self addRecord:item];
        }
    }
    [self arrangeData:title];
}
// Internal Routine ************************************************************
//レコードリストに血圧レコードを追加する
-(void)addRecord:(UAItemView*)item{
    RERecord *record = [[RERecord alloc] init];
    record.ID = 500L;                                               //個人識別コード
    record.integerYearMonthDay = item.uadate.integerYearMonthDay;   //年月日yyyymmdd）
    record.day = item.uadate.day;                                   //日
    record.yobi = item.uadate.strYobi;                              //曜日
    record.dayType = item.uadate.dayType;                           //曜日タイプ
    record.isHoliday = item.uadate.isHoliday;                       //休日フラグ
    if (item.confirm){
        record.lower = item.lower;                                  //最低血圧
        record.upper = item.upper;                                  //最高血圧
    }else{
        record.lower = record.upper = 0;                            //未確定
    }
    record.confirm = item.confirm;                                  //確定フラグ
    [_recordList addObject:record];                                 //オブジェクトの追加
}
//アイテムビューにデータをセット及び属性を設定
-(void)arrangeData:(NSString*)title{
    NSNumber* ch1 = [NSNumber numberWithFloat:_cell_height];  //アイテムビューの高さ
    NSNumber* cw1 = @40;    //アイテムビューの幅（日）
    NSNumber* cw2 = @30;    //アイテムビューの幅（曜日）
    NSNumber* cw3 = @45;    //アイテムビューの幅（最低血圧）
    NSNumber* cw4 = @45;    //アイテムビューの幅（最高血圧）
    NSNumber* cw5 = @0;     //アイテムビューの幅（血圧棒グラフ下）
    NSNumber* cw6 = @0;     //アイテムビューの幅（血圧棒グラフ上）
    NSNumber* cw7 = @0;     //アイテムビューの幅（血圧棒グラフ余白）
    //アイテム幅テーブル
    NSMutableArray<NSNumber*>* cwArray
    = [[NSMutableArray alloc] initWithObjects:cw1, cw2, cw3, cw4, cw5, cw6, cw7, nil];
    float yPos = 0;
    RERecord *rec;
    //１ヶ月の日数の繰り返し
    for (NSInteger i=0; i<31; i++){
        if (_recordList.count > i)
            rec = _recordList[i];    //血圧レコードリストから１日のレコードを取得
        else
            rec = nil;
        //棒グラフの長さを求める（正規化）
        float len1 = [self gpaphLen:rec.lower MaxLen:_graph_width Limit:BP_LIMMIT];
        float len2 = [self gpaphLen:rec.upper MaxLen:_graph_width Limit:BP_LIMMIT] - len1;
        float len3 = _graph_width- len1 - len2;
        cwArray[4] = [NSNumber numberWithFloat:len1];
        cwArray[5] = [NSNumber numberWithFloat:len2];
        cwArray[6] = [NSNumber numberWithFloat:len3];
        //初期処理で生成したアイテムビューオブジェクトの取得
        NSMutableArray<REItemView*>* rows = _matrix[i];
        //アイテムビューの位置と大きさの設定（frame）
        float xPos = 0;
        for (NSInteger j=0; j<7; j++){
            rows[j].frame = NSMakeRect(xPos, yPos,
                                       cwArray[j].floatValue+1.0,ch1.floatValue+1.0);
            xPos += cwArray[j].floatValue;
        }
        //日付のセット
        rows[0].string = [NSString stringWithFormat:@"%ld",rec.day];
        if ([rows[0].string isEqualToString:@"0"])
             rows[0].string = @"";
        rows[0].allign = ALLIGN_RHGHT;
        rows[0].atr = [UATextAttribute makeAttributesFontSize:14];
        //曜日のセット
        rows[1].string = rec.yobi;
        if(rec.isHoliday || rec.dayType == Sunday){
            //休日または日曜
            rows[1].atr = [UATextAttribute makeAttributesFontSize:12 ForeColor:[NSColor redColor]];
        }else if (rec.dayType == Saturday){
            //土曜
            rows[1].atr = [UATextAttribute makeAttributesFontSize:12 ForeColor:[NSColor blueColor]];
        }else{
            //平日
            rows[1].atr = [UATextAttribute makeAttributesFontSize:12];
        }
        rows[1].allign = ALLIGN_CENTER;
        //最低血圧のセット
        if (rec.lower==0) {
            rows[2].string = @"";
        } else {
            rows[2].string = [NSString stringWithFormat:@"%ld",rec.lower];
            rows[2].allign = ALLIGN_RHGHT;
            //血圧チェック：文字色の変更
            if (rec.lower > BP_NORMAL_LOW){
                rows[2].atr = [UATextAttribute makeAttributesForeColor:[NSColor redColor]];
            }else{
                rows[2].atr = [UATextAttribute makeAttributesForeColor:[NSColor blackColor]];
            }
        }
        //最高血圧のセット
        if (rec.upper==0){
            rows[3].string = @"";
        }else{
            rows[3].string = [NSString stringWithFormat:@"%ld",rec.upper];
            rows[3].allign = ALLIGN_RHGHT;
            //血圧チェック：文字色の変更
            if (rec.upper > BP_NORMAL_HIGH){
                rows[3].atr = [UATextAttribute makeAttributesForeColor:[NSColor redColor]];
            }else{
                rows[3].atr = [UATextAttribute makeAttributesForeColor:[NSColor blackColor]];
            }
        }
        //棒グラフの属性設定
        //色
        NSColor* lowNormal = [NSColor myColorR:100 G:100 B:100 alph:0.2];   //下の正常
        NSColor* highNormal = [NSColor myColorR:100 G:100 B:100 alph:0.3];  //上の正常
        NSColor* lowWarning = [NSColor myColorR:255 G:100 B:100 alph:0.6];  //下の高血圧
        NSColor* highWarning = [NSColor myColorR:255 G:100 B:100 alph:0.9]; //上の高血圧
        if (rec.lower > BP_NORMAL_LOW ){
            rows[4].backgroundColor = lowWarning;
        }else{
            rows[4].backgroundColor = lowNormal;
        }
        //血圧チェック：高いときの色の変更
        if (rec.upper > BP_NORMAL_HIGH){
            rows[5].backgroundColor = highWarning;
        }else{
            rows[5].backgroundColor = highNormal;
        }
        rows[6].backgroundColor = [NSColor whiteColor]; //棒グラフの余白
        yPos = ch1.floatValue*(i+1); //高さの更新
        //設定したデータを表示させるため、１行の全列のアイテムビューを再描画する。
        for (NSInteger j=0;j<7;j++){
            [rows[j] setNeedsDisplay:YES];
        }
    }
    [_mainView setNeedsDisplay:YES]; //標準血圧上限値の垂直線を再描画するために必要
    //ヘッダ行の年月タイトルの設定
    _headerView.textOfDate = title;
    [_headerView setNeedsDisplay:YES];
    //NSLog(@"View Count:%ld",_mainView.subviews.count);
}
// Internal routine ************************************************************
-(float)gpaphLen:(NSInteger)value MaxLen:(float)maxlen Limit:(NSInteger)limit{
    //引数 :値 :棒グラフの長さ :棒グラフの上限値
    return (value / (float)limit) * maxlen;
}
//autoresizingMaskの評価
-(void)evalAutoresizingMask:(NSInteger)mask{
    NSLog(@"mask=%ld", mask);
    if (mask & NSViewMinXMargin) NSLog(@"NSViewMinXMargin");
    if (mask & NSViewWidthSizable) NSLog(@"NSViewWidthSizable");
    if (mask & NSViewMaxXMargin) NSLog(@"NSViewMaxXMargin");
    if (mask & NSViewMinYMargin) NSLog(@"NSViewMinYMargin");
    if (mask & NSViewHeightSizable) NSLog(@"NSViewHeightSizable");
    if (mask & NSViewMaxYMargin) NSLog(@"NSViewMaxYMargin");
}
@end
