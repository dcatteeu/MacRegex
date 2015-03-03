//
//  AppDelegate.m
//  reggy2
//
//  Created by David Catteeuw on 02/03/15.
//  Copyright (c) 2015 David R. Catteeuw. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSTextField *regexField;
@property (weak) IBOutlet NSTextField *statusLabel;
@property (weak) IBOutlet NSWindow *window;
@property (unsafe_unretained) IBOutlet NSTextView *textView;

@property NSPasteboard *pasteboard;
@property NSInteger lastChangeCount;

- (IBAction)clearRegexField:(id)sender;
- (IBAction)regexEntered:(id)sender;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.pasteboard = [NSPasteboard generalPasteboard];
}

- (void)applicationWillBecomeActive:(NSNotification *)note {
    [self refreshTextView];
    // TODO: update the regex
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)refreshTextView {
    if ([self.pasteboard changeCount] != self.lastChangeCount) {
        self.lastChangeCount = [self.pasteboard changeCount];
        [self.statusLabel setStringValue:@"Clipboard contents changed"];
    }
    NSArray *classes = [[NSArray alloc] initWithObjects:[NSString class], nil];
    NSArray *copiedItems = [self.pasteboard readObjectsForClasses:classes                                                               options:[NSDictionary dictionary]];
    if (copiedItems != nil) {
        [self.textView setString:[copiedItems objectAtIndex:0]];
    }
}

- (void)clearMatches {
    ;
}

- (void)updateMatches {
    NSString *regexAsString = [self.regexField stringValue];
    // TODO: check if string is not empty.
    
    NSString *string = [self.textView string];
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexAsString options:0 error:&error];
    // TODO: Check error here... (maybe the regex pattern was malformed)
    
    NSArray *matches = [regex matchesInString:string
                                      options:0
                                        range:NSMakeRange(0, [string length])];
    NSLog(@"numberOfMatches: %lu", (unsigned long)matches.count);
    NSLayoutManager *layoutManager = self.textView.layoutManager;
    if (matches.count > 0) {
        [self.statusLabel setStringValue:[NSString stringWithFormat:@"%lu matches found.", (unsigned long)matches.count]];
        for (NSTextCheckingResult * match in matches) {
            NSLog(@"%lu, %lu", (unsigned long)match.range.location, (unsigned long)match.range.length);
            [layoutManager addTemporaryAttribute:NSBackgroundColorAttributeName value:[NSColor yellowColor] forCharacterRange:match.range];
        }
    } else {
        [self.statusLabel setStringValue:@"No matches found."];
    }
}

- (IBAction)clearRegexField:(id)sender {
    [self.regexField setStringValue:@""];
    [self.statusLabel setStringValue:@"Input cleared."];
    [self clearMatches];
}

- (IBAction)regexEntered:(id)sender {
    [self updateMatches];
}

@end
