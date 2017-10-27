//
//  LJXCEditorHelper.m
//  XCEditorTool
//
//  Created by lic on 2017/10/24.
//  Copyright © 2017年 LJ. All rights reserved.
//

#import "LJXCEditorHelper.h"

static NSString *const pragmaMark = @"#pragma mark -- Life Cycle --\n\n#pragma mark -- UI Layout --\n\n#pragma mark -- Getters & Setters --\n\n#pragma mark -- Public Methods --\n\n#pragma mark -- Private Methods --\n\n#pragma mark -- Override Methods --\n\n#pragma mark -- Delegate --\n\n";
static NSString *const commentStr = @"/**\n* @brief\n* @param\n* @return N/A\n*/\n";

@implementation LJXCEditorHelper

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler {
    
    if ([invocation.commandIdentifier containsString:@"CommentCode"]) {
        NSLog(@"CommentCode");
        XCSourceTextRange *range = invocation.buffer.selections.firstObject;
        NSInteger endLineNum = range.end.line;
        __block NSString *funStr = commentStr;
        [invocation.buffer.lines insertObject:funStr atIndex:endLineNum+1];

    } else if ([invocation.commandIdentifier containsString:@"PragmaMark"]) {
        XCSourceTextRange *range = invocation.buffer.selections.firstObject;
        NSInteger endLineNum = range.end.line;
        __block NSString *funStr = pragmaMark;
        [invocation.buffer.lines insertObject:funStr atIndex:endLineNum+1];
        
    } else if ([invocation.commandIdentifier containsString:@"LJXCEditorHelper"]) {
        NSMutableDictionary *headerDict = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *deleteDict = [[NSMutableDictionary alloc] init];
        
        NSInteger count = invocation.buffer.lines.count;
        
        for (int i = 0; i < count; i++) {
            NSString *line = invocation.buffer.lines[i];
            
            if (deleteDict.count > 0) {
                [deleteDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    if ([line containsString:(NSString *)obj]) {
                        if (![line containsString:@"#import"]) {
                            if ([headerDict[obj] isEqualToNumber:@1]) {
                                [deleteDict removeObjectForKey:key];
                                headerDict[obj] = @0;
                            }
                        }
                    }
                }];
            }
            if ([line containsString:@"#import"] && ![line containsString:@"+"]) {
                NSRange range1 = [line rangeOfString:@"\""];
                NSRange range2 = [line rangeOfString:@"\"" options:NSBackwardsSearch];
                NSRange oriRange = NSMakeRange(0, 0);
                if (!(NSEqualRanges(range1, oriRange) || NSEqualRanges(range2, oriRange))) {
                    NSRange classRange = NSMakeRange(range1.location + 1, range2.location - range1.location - 3);
                    NSString *classStr = [line substringWithRange:classRange];
                    headerDict[classStr] = @1;
                    deleteDict[@(i)] = classStr;
                }
            }
        }
        
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        [deleteDict.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [indexSet addIndex:[obj integerValue]];
        }];
        [invocation.buffer.lines removeObjectsAtIndexes:indexSet];
    }
   
    
    completionHandler(nil);
}

@end
