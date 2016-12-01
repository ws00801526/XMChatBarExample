//
//  XMNChatTextEmotionParser.m
//  XMNChatFramework
//
//  Created by XMFraker on 16/6/15.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNChatTextParser.h"

#import "XMNChatConfiguration.h"

#pragma mark - Emoticon Parser

#define LOCK(...) dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(_lock);

@implementation XMNChatTextParser {
    
    NSDictionary *_mapper;
    dispatch_semaphore_t _lock;
    
    /** 匹配文本中的表情 */
    NSRegularExpression *_regex;

    /** 匹配文本中链接 */
    NSRegularExpression *_regexLink;
}

- (instancetype)init {
    self = [super init];
    
    _lock = dispatch_semaphore_create(1);
    _alignFont = [UIFont systemFontOfSize:14.f];
    _emotionSize = CGSizeMake(24, 24);
    _alignment = YYTextVerticalAlignmentCenter;
    
#define regexp(reg, option) [NSRegularExpression regularExpressionWithPattern : @reg options : option error : NULL]
    _regexLink = regexp("([hH][tT][tT][pP][sS]?:\\/\\/[^ ,'\">\\]\\)]*[^\\. ,'\">\\]\\)])", 0);
#undef regexp
    return self;
}

- (NSDictionary *)emoticonMapper {
    LOCK(NSDictionary *mapper = _mapper); return mapper;
}

- (void)setEmoticonMapper:(NSDictionary *)emoticonMapper {
    LOCK(
         _mapper = emoticonMapper.copy;
         if (_mapper.count == 0) {
             _regex = nil;
         } else {
             NSMutableString *pattern = @"(".mutableCopy;
             NSArray *allKeys = _mapper.allKeys;
             NSCharacterSet *charset = [NSCharacterSet characterSetWithCharactersInString:@"$^?+*.,#|{}[]()\\"];
             for (NSUInteger i = 0, max = allKeys.count; i < max; i++) {
                 NSMutableString *one = [allKeys[i] mutableCopy];
                 
                 // escape regex characters
                 for (NSUInteger ci = 0, cmax = one.length; ci < cmax; ci++) {
                     unichar c = [one characterAtIndex:ci];
                     if ([charset characterIsMember:c]) {
                         [one insertString:@"\\" atIndex:ci];
                         ci++;
                         cmax++;
                     }
                 }
                 
                 [pattern appendString:one];
                 if (i != max - 1) [pattern appendString:@"|"];
             }
             [pattern appendString:@")"];
             _regex = [[NSRegularExpression alloc] initWithPattern:pattern options:kNilOptions error:nil];
         }
         );
}

// correct the selected range during text replacement
- (NSRange)_replaceTextInRange:(NSRange)range withLength:(NSUInteger)length selectedRange:(NSRange)selectedRange {
    // no change
    if (range.length == length) return selectedRange;
    // right
    if (range.location >= selectedRange.location + selectedRange.length) return selectedRange;
    // left
    if (selectedRange.location >= range.location + range.length) {
        selectedRange.location = selectedRange.location + length - range.length;
        return selectedRange;
    }
    // same
    if (NSEqualRanges(range, selectedRange)) {
        selectedRange.length = length;
        return selectedRange;
    }
    // one edge same
    if ((range.location == selectedRange.location && range.length < selectedRange.length) ||
        (range.location + range.length == selectedRange.location + selectedRange.length && range.length < selectedRange.length)) {
        selectedRange.length = selectedRange.length + length - range.length;
        return selectedRange;
    }
    selectedRange.location = range.location + length;
    selectedRange.length = 0;
    return selectedRange;
}

- (BOOL)parseText:(NSMutableAttributedString *)text selectedRange:(NSRangePointer)range {
    
    if (text.length == 0) return NO;
    
    if (self.parseLinkEnabled) {
        text.yy_underlineStyle = NSUnderlineStyleNone;
        text.yy_color = RGB(51, 51, 51);
        [_regexLink enumerateMatchesInString:text.string options:0 range:NSMakeRange(0, text.string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            
            NSRange r = result.range;
            if (r.location != NSNotFound) {
                [text yy_setUnderlineStyle:NSUnderlineStyleSingle range:r];
                [text yy_setTextHighlightRange:r
                                         color:RGB(1,193,245)
                               backgroundColor:RGB(191, 191, 191)
                                     tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull highlightText, NSRange range, CGRect rect) {
                                         /** 修复发出的文字是attrS文字 */
                                         [[NSNotificationCenter defaultCenter] postNotificationName:kXMNChatMessageClickedNotification object:nil userInfo:@{kXMNChatMessageClickedNotificationTextKey:[highlightText yy_plainTextForRange:range]}];
                                     }];
            }
        }];
    }
    
    NSDictionary *mapper;
    NSRegularExpression *regex;
    
    LOCK(mapper = _mapper; regex = _regex;);
    if (mapper.count == 0 || regex == nil) return NO;
    
    NSArray *matches = [regex matchesInString:text.string options:kNilOptions range:NSMakeRange(0, text.length)];
    if (matches.count == 0) return NO;
    
    NSRange selectedRange = range ? *range : NSMakeRange(0, 0);
    NSUInteger cutLength = 0;
    for (NSUInteger i = 0, max = matches.count; i < max; i++) {
        NSTextCheckingResult *one = matches[i];
        NSRange oneRange = one.range;
        if (oneRange.length == 0) continue;
        oneRange.location -= cutLength;
        NSString *subStr = [text.string substringWithRange:oneRange];
        UIImage *emoticon = mapper[subStr];
        if (!emoticon) continue;
        /** 使用了自定义的添加表情的解析 */
        NSMutableAttributedString *atr = [NSMutableAttributedString yy_attachmentStringWithEmojiImage:emoticon attachmentSize:self.emotionSize alignToFont:self.alignFont alignment:self.alignment];
        [atr yy_setTextBackedString:[YYTextBackedString stringWithString:subStr] range:NSMakeRange(0, atr.length)];
        [text replaceCharactersInRange:oneRange withString:atr.string];
        [text yy_removeDiscontinuousAttributesInRange:NSMakeRange(oneRange.location, atr.length)];
        [text addAttributes:atr.yy_attributes range:NSMakeRange(oneRange.location, atr.length)];
        selectedRange = [self _replaceTextInRange:oneRange withLength:atr.length selectedRange:selectedRange];
        cutLength += oneRange.length - 1;
    }
    if (range) *range = selectedRange;
    
    
    return YES;
}
@end
