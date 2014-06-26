//
//  VSThemeLoader.m
//  Q Branch LLC
//
//  Created by Brent Simmons on 6/26/13.
//  Copyright (c) 2012 Q Branch LLC. All rights reserved.
//

#import "VSThemeLoader.h"

@interface VSThemeLoader ()

@property (nonatomic, strong, readwrite) VSTheme *defaultTheme;
@property (nonatomic, strong, readwrite) NSDictionary *themes;

@end

@implementation VSThemeLoader

+ (VSThemeLoader *)sharedThemeLoader {
    static dispatch_once_t onceToken;
    static VSThemeLoader *themeLoader;
    dispatch_once(&onceToken, ^{
        themeLoader = [[VSThemeLoader alloc] init];
    });
    
    return themeLoader;
}

- (instancetype)init {
	return [self initWithPropertyListName:@"DB5"];
}

- (instancetype)initWithPropertyListName:(NSString *)name {
	self = [super init];
	if (!self) {
		return nil;
    }
	
	NSString *themesFilePath = [[NSBundle mainBundle] pathForResource:name
                                                               ofType:@"plist"];
	NSDictionary *themesDictionary = [NSDictionary dictionaryWithContentsOfFile:themesFilePath];
	
	NSMutableDictionary *themes = [NSMutableDictionary dictionary];
	for (NSString *themeName in themesDictionary.allKeys) {
		VSTheme *theme = [[VSTheme alloc] initWithDictionary:themesDictionary[themeName]];
		if ([[themeName lowercaseString] isEqualToString:@"default"]) {
			_defaultTheme = theme;
        }
		theme.name = themeName;
		[themes setObject:theme
                   forKey:themeName];
	}
    
    for (VSTheme *theme in themes.allValues) { /*All themes inherit from the default theme.*/
		if (theme != _defaultTheme) {
			theme.parentTheme = _defaultTheme;
        }
    }
    
	_themes = themes;
	
	return self;
}

@end
