//
//  SourceEditorCommand.m
//  LJModelTool
//
//  Created by lic on 2017/10/21.
//  Copyright © 2017年 LJ. All rights reserved.
//

#import "SourceEditorCommand.h"

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
    NSDictionary *dic = [[NSDictionary alloc] init];
    XCSourceTextRange *range = invocation.buffer.selections.firstObject;
    NSInteger beginLineNum = range.start.line;
    NSInteger endLineNum = range.end.line;
    NSString *totalStr = @"";
    for (NSInteger i = beginLineNum; i <= endLineNum; i++) {
        totalStr = [totalStr stringByAppendingString:invocation.buffer.lines[i]];
        
    }
    NSData *data = [[NSData alloc] initWithData:[totalStr dataUsingEncoding:NSUTF8StringEncoding]];
    id jsonValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    if (jsonValue != nil) {
        dic = [self getDictionaryWithjsonObj:jsonValue];
    }
    if (dic == nil) {
        NSError *error = [NSError errorWithDomain:@"json 解析为nil" code:101 userInfo:nil];
        completionHandler(error);
        return;
    }
    __block NSInteger maxLocation = 0;
    __block NSString *propertyStr = @"";
    __block NSString *funStr = @"\n+ (NSDictionary *)JSONKeyPathsByPropertyKey {\n    return @{ ";
    NSMutableArray *propArray = [NSMutableArray arrayWithCapacity:dic.allKeys.count];
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *type = @"";
        NSString *att = @"strong";
        if ([obj isKindOfClass:[NSString class]]) {
            type = @"NSString";
            att = @"copy";
        } else if ([obj isKindOfClass:[NSArray class]]) {
            type = @"NSArray";
        } else if ([obj isKindOfClass:[NSDictionary class]]) {
            type = @"NSDictionary";
        } else if ([obj isKindOfClass:[NSNumber class]]) {
            type = @"NSNumber";
        } else {
            type = @"id";
        }
        propertyStr = [propertyStr stringByAppendingString:[NSString stringWithFormat:@"\n@property (nonatomic, %@) %@ *%@;", att, type, key]];
        NSString *dicStr = [NSString stringWithFormat:@"@\"%@\" : @\"%@\",\n              ", key, obj];
        [propArray addObject:dicStr];
        
        NSRange range = [dicStr rangeOfString:@":"];
        maxLocation = maxLocation < range.location ? range.location : maxLocation;
    }];
    
    [propArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableString *valStr = [obj mutableCopy];
        
        NSRange range = [valStr rangeOfString:@":"];
        for (NSInteger i = range.location; i < maxLocation; i++) {
            [valStr insertString:@" " atIndex:range.location];
        }
        
        funStr = [funStr stringByAppendingString:valStr];
    }];
    funStr = [funStr stringByAppendingString:@"};\n}"];
    [invocation.buffer.lines insertObject:funStr atIndex:endLineNum+1];
    [invocation.buffer.lines insertObject:propertyStr atIndex:endLineNum+1];

    completionHandler(nil);
}

- (NSDictionary *)getAreaSelectedDict:(XCSourceEditorCommandInvocation *)invocation {
    NSDictionary *dic = [[NSDictionary alloc] init];
    XCSourceTextRange *range = invocation.buffer.selections.firstObject;
    NSInteger beginLineNum = range.start.line;
    NSInteger endLineNum = range.end.line;
    NSString *totalStr = @"";
    for (NSInteger i = beginLineNum; i <= endLineNum; i++) {
        totalStr = [totalStr stringByAppendingString:invocation.buffer.lines[i]];
        
    }
    NSData *data = [[NSData alloc] initWithData:[totalStr dataUsingEncoding:NSUTF8StringEncoding]];
    id jsonValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    if (jsonValue != nil) {
        dic = [self getDictionaryWithjsonObj:jsonValue];
    }
    if (dic == nil) {
        NSError *error = [NSError errorWithDomain:@"json 解析为nil" code:101 userInfo:nil];
    }
    
    
    return dic;
}

- (NSDictionary *)getDictionaryWithjsonObj:(id)jsonObj {
    if ([jsonObj isKindOfClass:[NSDictionary class]]) {
        return jsonObj;
    }else if ([jsonObj isKindOfClass:[NSArray class]] && [(NSArray *)jsonObj count]){
        id firstObj = [(NSArray *)jsonObj firstObject];
        return [self getDictionaryWithjsonObj:firstObj];
    }else{
        return nil;
    }
}




@end
