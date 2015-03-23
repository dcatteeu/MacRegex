//
//  AppDelegate.m
//  MacRegex
//
//  Created by David Catteeuw on 02/03/15.
//  Copyright (c) 2015 David R. Catteeuw. All rights reserved.
//

#import "AppDelegate.h"
#import "RegularExpression.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSTextField *regexField;
@property (weak) IBOutlet NSTextField *statusLabel;
@property (weak) IBOutlet NSWindow *window;
@property (unsafe_unretained) IBOutlet NSTextView *textView;
@property (weak) IBOutlet NSPopUpButton *syntaxPopupButton;

@property NSPasteboard *pasteboard;
@property NSInteger lastChangeCount;
@property NSArray *matches;
@property RESyntax syntax;

- (IBAction)clearRegexField:(id)sender;
- (IBAction)regexEntered:(id)sender;
- (IBAction)syntaxChanged:(id)sender;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.pasteboard = [NSPasteboard generalPasteboard];
    self.matches = [NSArray array];
    
    /* Load names of syntaxes in popupbutton. */
    int n = (int)RENumberOfSyntaxes();
    for (int i = 0; i < n; i++) {
        [self.syntaxPopupButton addItemWithTitle:REGetSyntaxName(i)];
    }
    
    /* Set default syntax. */
    self.syntax = RE_SYNTAX_OBJECTIVE_C;
    [self.syntaxPopupButton selectItemAtIndex:self.syntax];
}

- (void)applicationWillBecomeActive:(NSNotification *)note {
    [self refreshTextView];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
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
        [self.statusLabel setStringValue:@"Clipboard contents changed."];
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

- (IBAction)syntaxChanged:(id)sender {
    [self updateMatches];
}

- (void)removeHighlights:(NSArray *)matches textView:(NSTextView *)textView {
    for (REMatch *match in matches) {
        [textView.layoutManager removeTemporaryAttribute:NSBackgroundColorAttributeName
                                       forCharacterRange:match.range];
    }
}

- (void)addHighlights:(NSArray *)matches textView:(NSTextView *)textView {
    for (REMatch *match in matches) {
        [textView.layoutManager addTemporaryAttribute:NSBackgroundColorAttributeName
                                                value:[NSColor yellowColor]
                                    forCharacterRange:match.range];
    }
}

/* Call this whenever something changed. */
- (void)updateMatches {
    [self removeHighlights:self.matches textView:self.textView];
    
    NSString *regexAsString = [self.regexField stringValue];
    if ([regexAsString length] == 0)
        return;
    
    NSString *string = [self.textView string];
    RESyntax syntax = (RESyntax)[self.syntaxPopupButton indexOfSelectedItem];
    NSError *error = NULL;
    
    self.matches = REGetMatches(regexAsString, string, syntax, &error);
    
    if (error) {
        NSLog(@"error");
        [self.statusLabel setStringValue:[NSString stringWithFormat:@"The regex '%@' is invalid.", regexAsString]];
        return;
    }
    
    //NSLog(@"numberOfMatches: %lu", (unsigned long)self.matches.count);
    [self addHighlights:self.matches textView:self.textView];
    
    if (self.matches.count == 1) {
        [self.statusLabel setStringValue:@"1 match found."];
    } else if (self.matches.count > 1) {
        [self.statusLabel setStringValue:[NSString stringWithFormat:@"%lu matches found.", (unsigned long)self.matches.count]];
    } else {
        [self.statusLabel setStringValue:@"No matches found."];
    }
}

@end
