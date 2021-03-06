//------------------------------------------------------------------------------
// 血圧レコード定義
//------------------------------------------------------------------------------
#import <Foundation/Foundation.h>
#import "UADate.h"
@interface RERecord : NSObject
@property NSInteger ID;                         //個人識別コード
@property NSInteger upper;                      //最高血圧
@property NSInteger lower;                      //最低血圧
@property NSInteger confirm;                    //確定フラグ
//日付情報（uadateより作成）
@property NSInteger integerYearMonthDay;        //年月日(yyyymmdd）
@property NSInteger day;                        //日
@property NSString* yobi;                       //曜日
@property DayType dayType;                      //曜日タイプ
@property BOOL isHoliday;                       //休日フラグ
@end
