//
//  RegularExpression.m
//  MacRegex
//
//  Created by David Catteeuw on 16/03/15.
//  Copyright (c) 2015 David R. Catteeuw. All rights reserved.
//

#import "RegularExpression.h"

static OnigSyntaxType *syntaxTypes[] = {
    ONIG_SYNTAX_ASIS,
    ONIG_SYNTAX_POSIX_BASIC,
    ONIG_SYNTAX_POSIX_EXTENDED,
    ONIG_SYNTAX_EMACS,
    ONIG_SYNTAX_GREP,
    ONIG_SYNTAX_GNU_REGEX,
    ONIG_SYNTAX_JAVA,
    ONIG_SYNTAX_PERL,
    ONIG_SYNTAX_PERL_NG,
    ONIG_SYNTAX_RUBY,
    NULL // Objective-C is handled by Cocoa
};
static char* syntaxNames[] = {
    "Plain text",
    "POSIX Basic",
    "POSIX Extended",
    "Emacs",
    "Grep",
    "GNU",
    "Java",
    "Perl",
    "Perl with named groups",
    "Ruby",
    "Objective-C"
};

NSUInteger RENumberOfSyntaxes() {
    return sizeof(syntaxNames) / sizeof(NSString *);
}

NSString *REGetSyntaxName(RESyntax syntax) {
    return [NSString stringWithCString:syntaxNames[syntax] encoding:NSASCIIStringEncoding];
}

OnigSyntaxType* REGetSyntaxType(RESyntax syntax) {
    return syntaxTypes[syntax];
}

@implementation REMatch

- (id) initWithRange:(NSRange) range target:(NSString *)target {
    self = [super init];
    if (self) {
        _range = range;
        _target = target;
    }
    return self;
}

@end

NSArray *REGetMatches(NSString *regexAsString, NSString *target, RESyntax syntax, NSError **error) {
    NSMutableArray *matches = nil;
    OnigSyntaxType *syntaxType = REGetSyntaxType(syntax);
    if (syntaxType) { // Oniguruma
        OnigRegexp *regex = [OnigRegexp compile:regexAsString options:ONIG_OPTION_DEFAULT syntax:syntaxType error:error ];
        if (*error) return nil;
        matches = [NSMutableArray array];
        NSUInteger position = 0;
        OnigResult *result = nil;
        while (position < [target length]) {
            result = [regex search:target start:(int)position];
            if (!result) break;
            [matches addObject:[[REMatch alloc] initWithRange:[result bodyRange] target:target]];
            position = [result bodyRange].location + [result bodyRange].length;
        };
    } else { // Cocoa
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexAsString options:0 error:error];
        if (*error) return nil;
        NSArray *textCheckingResults = [regex matchesInString:target options:0 range:NSMakeRange(0, [target length])];
        matches = [NSMutableArray arrayWithCapacity:[textCheckingResults count]];
        for (NSTextCheckingResult *tcr in textCheckingResults) {
            [matches addObject:[[REMatch alloc] initWithRange:tcr.range target:target]];
        }
    }
    return matches;
}
