//------------------------------------------------------------------------------
// カテゴリ実装:NSBezierPath
//------------------------------------------------------------------------------
#import "NSBezierPath+MyBezierPath.h"

@implementation NSBezierPath (MyBezierPath)

// NSBezierPathをCGPathに変換する
-(CGPathRef)cgPath{
    CGMutablePathRef cgpath = CGPathCreateMutable();
    NSInteger n = [self elementCount];    
    for (NSInteger i = 0; i < n; i++) {
        NSPoint ps[3];
        switch ([self elementAtIndex:i associatedPoints:ps]) {
            case NSMoveToBezierPathElement: {
                CGPathMoveToPoint(cgpath, NULL, ps[0].x, ps[0].y);
                break;
            }
            case NSLineToBezierPathElement: {
                CGPathAddLineToPoint(cgpath, NULL, ps[0].x, ps[0].y);
                break;
            }
            case NSCurveToBezierPathElement: {
                CGPathAddCurveToPoint(cgpath, NULL, ps[0].x, ps[0].y, ps[1].x, ps[1].y, ps[2].x, ps[2].y);
                break;
            }
            case NSClosePathBezierPathElement: {
                CGPathCloseSubpath(cgpath);
                break;
            }
            default: NSAssert(0, @"Invalid NSBezierPathElement");
        }
    }
    CFAutorelease(cgpath);
    return cgpath;
}

@end
