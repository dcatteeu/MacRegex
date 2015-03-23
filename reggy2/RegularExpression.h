//
//  RegularExpression.h
//  MacRegex
//
//  Created by David Catteeuw on 16/03/15.
//  Copyright (c) 2015 David R. Catteeuw. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CocoaOniguruma/OnigRegexp.h"

//typedef NSUInteger RESyntax;
typedef enum {
    RE_SYNTAX_ASIS,
    RE_SYNTAX_POSIX_BASIC,
    RE_SYNTAX_POSIX_EXTENDED,
    RE_SYNTAX_EMACS,
    RE_SYNTAX_GREP,
    RE_SYNTAX_GNU_REGEX,
    RE_SYNTAX_JAVA,
    RE_SYNTAX_PERL,
    RE_SYNTAX_PERL_NG,
    RE_SYNTAX_RUBY,
    RE_SYNTAX_OBJECTIVE_C
} RESyntax;

/* The result of a search in a given string. range holds the start index in target and the length of the result. 
 */
@interface REMatch : NSObject
@property (readonly) NSRange range;
@property (readonly) NSString *target;
@end

/* Return the matches (NSArray of Match) for regexAsString in target, or nil if a error occured. In that case *error is non-nil. 
 */
NSArray *REGetMatches(NSString *regexAsString, NSString *target, RESyntax syntax, NSError **error);

NSUInteger RENumberOfSyntaxes();
NSString *REGetSyntaxName(RESyntax syntax);
OnigSyntaxType* REGetSyntaxType(RESyntax index);
