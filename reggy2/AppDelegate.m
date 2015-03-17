//
//  AppDelegate.m
//  MacRegex
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
    if ([self.pasteboard changeCount] == self.lastChangeCount)
        return;
    
    self.lastChangeCount = [self.pasteboard changeCount];
    NSArray *classes = [[NSArray alloc] initWithObjects:[NSString class], nil];
    NSArray *copiedItems = [self.pasteboard readObjectsForClasses:classes                                                               options:[NSDictionary dictionary]];
    
    if (copiedItems == nil) {
        NSLog(@"ERR: NSPasteboard readObjectsForClasses:options: did not allocate an array.");
        [self removeHighlights:self.matches textView:self.textView];
        return;
    }
    
    /* Handle cases where the clipboard contains only an image, or something else non-text. */
    if (copiedItems.count == 0) {
        [self.statusLabel setStringValue:@"Clipboard contains no text"];
        [self removeHighlights:self.matches textView:self.textView];
        return;
    }
    
    [self.textView setString:[copiedItems objectAtIndex:0]];
    [self updateMatches];
    
    /* It is possible that more than one text item is on the clipboard. TODO: Show all text items. */
    if (copiedItems.count > 1) {
        [self.statusLabel setStringValue:@"Clipboard contains more than one item. Only first element shown."];
    } else {
        [self.statusLabel setStringValue:@"Clipboard contents changed"];
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

- (NSArray *)getMatches:(NSString *)regexAsString inString:(NSString *)string error:(NSError **)error {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexAsString options:0 error:error];
    if (*error) {
        return NULL;
    }
    return [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
}

- (void)updateMatches {
    [self removeHighlights:self.matches textView:self.textView];
    
    NSString *regexAsString = [self.regexField stringValue];
    if ([regexAsString length] == 0)
        return;
    
    NSString *string = [self.textView string];
    NSError *error = NULL;
    
    self.matches = [self getMatches:regexAsString inString:string error:&error];
    
    if (error) {
        NSLog(@"error");
        [self.statusLabel setStringValue:[NSString stringWithFormat:@"The regex '%@' is invalid.", regexAsString]];
        return;
    }
    
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
