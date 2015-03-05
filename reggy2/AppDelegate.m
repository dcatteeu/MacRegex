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
@property NSArray *matches;

- (IBAction)clearRegexField:(id)sender;
- (IBAction)regexEntered:(id)sender;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.pasteboard = [NSPasteboard generalPasteboard];
    self.matches = [NSArray array];
}

- (void)applicationWillBecomeActive:(NSNotification *)note {
    [self refreshTextView];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)refreshTextView {
    if ([self.pasteboard changeCount] != self.lastChangeCount) {
        self.lastChangeCount = [self.pasteboard changeCount];
        [self.statusLabel setStringValue:@"Clipboard contents changed"];
        NSArray *classes = [[NSArray alloc] initWithObjects:[NSString class], nil];
        NSArray *copiedItems = [self.pasteboard readObjectsForClasses:classes                                                               options:[NSDictionary dictionary]];
        if (copiedItems != nil) {
            [self.textView setString:[copiedItems objectAtIndex:0]];
        }
        [self updateMatches];
    }
}

- (void)removeHighlights:(NSArray *)matches textView:(NSTextView *)textView {
    for (NSTextCheckingResult *match in matches) {
        [textView.layoutManager removeTemporaryAttribute:NSBackgroundColorAttributeName
                                       forCharacterRange:match.range];
    }
}

- (void)addHighlights:(NSArray *)matches  textView:(NSTextView *)textView {
    for (NSTextCheckingResult *match in matches) {
        [textView.layoutManager addTemporaryAttribute:NSBackgroundColorAttributeName
                                                value:[NSColor yellowColor]
                                    forCharacterRange:match.range];
    }
}

- (void)updateMatches {
    [self removeHighlights:self.matches textView:self.textView];
    
    NSString *regexAsString = [self.regexField stringValue];
    // TODO: check if string is not empty.
    
    NSString *string = [self.textView string];
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexAsString options:0 error:&error];
    // TODO: Check error here... (maybe the regex pattern was malformed)
    
    self.matches = [regex matchesInString:string
                                  options:0
                                    range:NSMakeRange(0, [string length])];
    NSLog(@"numberOfMatches: %lu", (unsigned long)self.matches.count);
    [self addHighlights:self.matches textView:self.textView];
    if (self.matches.count > 0) {
        [self.statusLabel setStringValue:[NSString stringWithFormat:@"%lu matches found.", (unsigned long)self.matches.count]];
    } else {
        [self.statusLabel setStringValue:@"No matches found."];
    }
}

- (IBAction)clearRegexField:(id)sender {
    [self.regexField setStringValue:@""];
    [self.statusLabel setStringValue:@"Input cleared."];
    [self updateMatches];
}

- (IBAction)regexEntered:(id)sender {
    [self updateMatches];
}

@end
