//------------------------------------------------------------------------------
// カレンダオブジェクトクラス
//------------------------------------------------------------------------------
#import "UACalendar.h"
// *** インタフェース宣言 ***
@interface UACalendar(){
    NSMutableArray<NSMutableArray*> *monthList; //日付リスト(1ヶ月)のリスト(3ヶ月分)
    NSMutableArray<UADate*> *aDateList ;        //日付リスト(1ヶ月)のリスト(3ヶ月分)
    NSCalendar*  cal;                           //カレンダーオブジェクト(Foundation)
    UADateMgr* dtMgr;                           //日付操作ユーティリティ
    NSMutableDictionary* holidays;              //休日辞書
}
@end
// *** クラスの実装 ***
@implementation UACalendar
//------------------------------------------------------------------------------
// イニシャライザ
//------------------------------------------------------------------------------
-(id)init{
    self = [super init];
    if (self == nil){
        return self;
    }
    //休日ファイル：レコードは年月日と休日名のペア。年度ごとに作成する。
    //アプリケーションバンドルからJSON形式の休日ファイルを読み込み、辞書を作成する。
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *pth01 = [bundle pathForResource:@"holiday"
                                       ofType:@"json"];
    NSURL *url01 = [NSURL fileURLWithPath:pth01];
    NSData* contents  = [NSData dataWithContentsOfURL:url01];
    NSArray* holidayList = [NSJSONSerialization JSONObjectWithData:contents
                            options:NSJSONReadingMutableContainers
                            error:nil];
    //休日辞書　キー：年月日　値：休日名
    holidays = [[NSMutableDictionary alloc] initWithCapacity:10];
    for (NSArray* arr in holidayList){
        NSNumber* key = [NSNumber numberWithInteger:[[arr objectAtIndex:0] integerValue]];
        holidays[key] = [arr objectAtIndex:1];
    }
    _numWeeks = 0;
    
    return self;
}
// -----------------------------------------------------------------------------
// 引数の日付の年月に相当するカレンダーを作成し返す。日数(35 or 42)
// (1)３ヶ月分の日付リストを作成する。
// (2)当月一ヶ月の日付および、前月末の日、翌月末の日を合わせてカレンダーを作成する。
//    カレンダの週数は大体は5週になるが、月により6週になる場合がある。
// -----------------------------------------------------------------------------
-(NSArray<UADate*>*)createDateList:(NSDate*)date{
    dtMgr = [UADateMgr DateManager] ;    //日付操作ユーティリティ
    monthList = [[NSMutableArray<NSMutableArray*> alloc] init];  //日付リスト(1ヶ月)のリスト(3ヶ月分)
    //前月の日付リストを作成
    NSMutableArray<UADate*>* preDateList = [[NSMutableArray alloc] init];
    NSDate* firstDate = [dtMgr createPreFirstNSDate:date];
    UADate* uadate = [[UADate alloc] initWithDate:firstDate];
    _fromDate = [uadate integerYearMonthDay];               //開始日：前月の１日
    [preDateList addObject:uadate];                         //１日のUADateオブジェクトを作成し追加
    NSInteger days = [dtMgr daysOfMonth:firstDate];         //前月の日数を求める
    //2日から月末日まで、UADateオブジェクトを作成しリストに追加
    for (NSInteger i=1; i<days; i++){
        NSDate *wkDate = [dtMgr createNSDate:firstDate incr:i];
        [preDateList addObject:[[UADate alloc] initWithDate:wkDate]];
    }
    [monthList addObject:preDateList];  //３ヶ月分の日付リストのリストに「前月分」として追加
    //当月の日付リストを作成
    NSMutableArray<UADate*>* thisDateList = [[NSMutableArray alloc] init];
    firstDate = [dtMgr createFirstNSDate:date];             //当月の１日を求める
    [thisDateList addObject:[[UADate alloc] initWithDate:firstDate]];//１日のUADateオブジェクトを作成し追加
    days = [dtMgr daysOfMonth:firstDate];                   //当月の日数を求める
    //2日から月末日まで、UADateオブジェクトを作成しリストに追加
    for (NSInteger i=1; i<days; i++){
        NSDate *wkDate = [dtMgr createNSDate:firstDate incr:i];
        [thisDateList addObject:[[UADate alloc] initWithDate:wkDate]];
    }
    [monthList addObject:thisDateList];  //３ヶ月分の日付リストのリストに「当月分」として追加
    //翌月の日付リストを作成
    NSMutableArray<UADate*>* nextDateList = [[NSMutableArray alloc] init];
    firstDate = [dtMgr createNextFirstNSDate:date];         //翌月の１日を求める
    [nextDateList addObject:[[UADate alloc] initWithDate:firstDate]];//１日のUADateオブジェクトを作成し追加
    days = [dtMgr daysOfMonth:firstDate];                   //翌月の日数を求める
    //2日から月末日まで、UADateオブジェクトを作成しリストに追加
    for (NSInteger i=1; i<days; i++){
        NSDate *wkDate = [dtMgr createNSDate:firstDate incr:i];
        [nextDateList addObject:[[UADate alloc] initWithDate:wkDate]];
    }
    uadate = nextDateList[nextDateList.count-1];
    _toDate = uadate.integerYearMonthDay;   //最終日
    [monthList addObject:nextDateList];     //３ヶ月分の日付リストのリストに「当月分」として追加
    //一ヶ月分のカレンダーを作成する
    //当月一ヶ月の日付および、前月末の日、翌月末の日を合わせてカレンダーを作成する。
    //週数は、4週または5週となる。月曜始まり、土曜終わり。
    aDateList = [[NSMutableArray alloc] init]; //返却用カレンダーリスト
    //当月１日の曜日を求める
    UADate* dt = monthList[1][0];
    NSInteger iwd = dt.dayOfWeek;
    //曜日テーブル：weelDayの値とカレンダーの曜日の位置の対応をとる
    NSArray* tableCnv = [[NSArray alloc] initWithObjects:@7,@1,@2,@3,@4,@5,@6, nil];
    //前月処理：当月1日が週の途中から始まる場合、それまでを前月の日付で埋める。
    NSNumber* n = tableCnv[iwd-1];                      //カレンダ上の前月末の日数
    NSInteger daysOfLastMonth = [monthList[0] count];   //前月の日数
    NSInteger idx = daysOfLastMonth - (n.intValue - 1); //前月日付リストのインデックス：前月日の最初の日
    NSInteger count = 0;                                //カレンダーリストに追加した日付の件数
    for(NSInteger i = idx; i < daysOfLastMonth; i++){
        //前月末の日付をカレンダーリストに追加する。
        dt = monthList[0][i];
        dt.monthType = PreMonth;
        aDateList[count] = dt;
        count++;
    }
    //当月処理
    for(NSInteger i = 0; i < [monthList[1] count]; i++){
        //当月の日付をカレンダーリストに追加する。
        dt = monthList[1][i];
        dt.monthType = ThisMonth;
        aDateList[count] = dt;
        count++;
    }
    //翌月処理：当月末日が週の途中で終わった場合、それ以後を翌月の日付で埋める。
    // 週数の判定（4週 or 5週）
    NSInteger inc;
    if (count > DAYS_OF_5WEEKS){
        //日付の件数が5週を超えている。6週のカレンダ-
        _numWeeks = 6;
        inc = DAYS_OF_6WEEKS - count;   //月末までを翌月の日付で埋める日数
    }else{
        //日付の件数が5週を超えていない。5週のカレンダ-
        _numWeeks = 5;     
        inc = DAYS_OF_5WEEKS - count;   //月末までを翌月の日付で埋める日数
    }
    for(NSInteger i = 0; i < inc; i++)
    {
        //翌月末の日付をカレンダーリストに追加する。
        dt = monthList[2][i];
        dt.monthType = NextMonth;
        aDateList[count] = dt;
        count++;
    }
    //休日フラグのセット：日付リストの繰り返し
    for (int j=0; j<aDateList.count; j++)
    {
        UADate* dt = aDateList[j];
        //休日辞書を日付で検索し、あれば休日フラグと休日名を設定する。
        NSNumber* key = [NSNumber numberWithInteger:[dt integerYearMonthDay]];
        NSString* holidayName = [holidays objectForKey:key];
        //休日フラグのセット
        if (holidayName != nil)
        {
            [dt setHolidayName:holidayName];
            dt.isHoliday = YES;
        }else{
            dt.isHoliday= NO;
        }
    }
    return aDateList;//日付リストを返す
}
//指定の日付のUADateオブジェクトを返す
-(UADate*)getDate:(NSDate*)dt{
    for(UADate* ud in aDateList){
        if (ud.integerYearMonthDay == [dtMgr integerYearMonthDay:dt]){
            return ud;
        }
    }
    return nil;
}
@end
