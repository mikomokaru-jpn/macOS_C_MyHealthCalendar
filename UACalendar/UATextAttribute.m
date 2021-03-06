#import "UATextAttribute.h"

@implementation UATextAttribute
//文字列装飾属性
+(NSDictionary*)makeAttributesFontName:(NSString*)fontName
                              FontSize:(float)size
                             ForeColor:(NSColor*)color{
    //フォント名
    NSString* fn;
    if ([fontName isEqualToString:@""]){
        fn = @"Arial";
    }else{
        fn = fontName;
    }
    //フォントサイズ
    float sz;
    if (size == 0){
        sz = 12;
    }else{
        sz = size;
    }
    NSFont* font = [NSFont fontWithName:fn size:sz];
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    attributes[NSFontAttributeName] = font;
    //文字色
    NSColor* cl;
    if (color){
        cl = color;
    }else{
        cl = [NSColor blackColor];
    }
    attributes[NSForegroundColorAttributeName] = cl;
    return attributes;
}
//文字列装飾属性（デフォルト）
+(NSDictionary*)makeAttributes{
    return [self makeAttributesFontName:@"" FontSize:12.0 ForeColor:nil];
}
//文字列装飾属性（フォントサイズ指定）
+(NSDictionary*)makeAttributesFontSize:(float)size{
    return [self makeAttributesFontName:@"" FontSize:size ForeColor:nil];
}
//文字列装飾属性（文字色指定）
+(NSDictionary*)makeAttributesForeColor:(NSColor*)color{
    return [self makeAttributesFontName:@"" FontSize:0 ForeColor:color];
}
//文字列装飾属性（フォントサイズ、文字色指定）
+(NSDictionary*)makeAttributesFontSize:(float)size ForeColor:(NSColor*)color{
    return [self makeAttributesFontName:@"" FontSize:size ForeColor:color];
}
//修飾文字列
+(NSMutableAttributedString*)attributedString:(NSString*)str
                                     FontName:(NSString*)name
                                     FontSize:(float)size
                                    ForeColor:(NSColor*)color;{
    NSMutableAttributedString* attrStr = [[NSMutableAttributedString alloc] initWithString:str];
    //フォント
    NSString* fn;
    if ([name isEqualToString:@""]){
        fn = @"Arial";
    }else{
        fn = name;
    }
    NSFont* font = [NSFont fontWithName:fn size:size];
    [attrStr addAttribute:NSFontAttributeName
                    value:font
                    range:NSMakeRange(0, [attrStr length])];
    //文字色
    NSColor* cl;
    if (color){
        cl = color;
    }else{
        cl = [NSColor blackColor];
    }
    [attrStr addAttribute:NSForegroundColorAttributeName
                    value:cl
                    range:NSMakeRange(0, [attrStr length])];
    return attrStr;
}
//修飾文字列
+(NSMutableAttributedString*)attributedString:(NSString*)str
                                     FontSize:(float)size
                                    ForeColor:(NSColor*)color{
    return [self attributedString:str FontName:@"" FontSize:size ForeColor:color];
}
//修飾文字列
+(NSMutableAttributedString*)attributedString:(NSString*)str FontSize:(float)size{
    return [self attributedString:str FontName:@"" FontSize:size ForeColor:nil];
}
@end
