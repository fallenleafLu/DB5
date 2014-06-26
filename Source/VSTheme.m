//
//  VSTheme.m
//  Q Branch LLC
//
//  Created by Brent Simmons on 6/26/13.
//  Copyright (c) 2012 Q Branch LLC. All rights reserved.
//

#import "VSTheme.h"


static BOOL stringIsEmpty(NSString *s);
static UIColor *colorWithHexString(NSString *hexString);
static NSArray *separatedValues(NSString *originString);

@interface VSTheme ()

@property (nonatomic, strong) NSDictionary *themeDictionary;
@property (nonatomic, strong) NSCache *colorCache;
@property (nonatomic, strong) NSCache *fontCache;

@end


@implementation VSTheme


#pragma mark Init

- (id)initWithDictionary:(NSDictionary *)themeDictionary {
	
	self = [super init];
	if (!self) {
		return nil;
    }
	
	_themeDictionary = themeDictionary;

	_colorCache = [NSCache new];
	_fontCache = [NSCache new];

	return self;
}

- (id)objectForKey:(NSString *)key {
	id object = self.themeDictionary[key];
	if (!object && self.parentTheme) {
		object = [self.parentTheme objectForKey:key];
    }
	return object;
}

- (BOOL)boolForKey:(NSString *)key {
	id object = [self objectForKey:key];
	if (!object) {
		return NO;
    }
	return [object boolValue];
}

- (NSString *)stringForKey:(NSString *)key {
	id object = [self objectForKey:key];
	if (!object) {
		return nil;
    }
    
	if ([object isKindOfClass:[NSString class]]) {
		return object;
    }
    
	if ([object isKindOfClass:[NSNumber class]]) {
		return [object stringValue];
    }
	
    return nil;
}

- (NSInteger)integerForKey:(NSString *)key {
	id object = [self objectForKey:key];
	if (!object) {
		return 0;
    }
	return [object integerValue];
}

- (CGFloat)floatForKey:(NSString *)key {
	id object = [self objectForKey:key];
	if (!object) {
		return  0.0f;
    }
	return [object floatValue];
}

- (NSTimeInterval)timeIntervalForKey:(NSString *)key {
	id object = [self objectForKey:key];
	if (!object) {
		return 0.0;
    }
	return [object doubleValue];
}

- (UIImage *)imageForKey:(NSString *)key {
	NSString *imageName = [self stringForKey:key];
	if (stringIsEmpty(imageName)) {
		return nil;
	}
	return [UIImage imageNamed:imageName];
}


- (UIColor *)colorForKey:(NSString *)key {
	UIColor *cachedColor = [self.colorCache objectForKey:key];
	if (cachedColor) {
		return cachedColor;
    }
    
	NSString *colorString = [self stringForKey:key];
	UIColor *color = colorWithHexString(colorString);
	if (!color) {
		color = [UIColor clearColor];
    }
    
	[self.colorCache setObject:color
                        forKey:key];

	return color;
}


- (UIEdgeInsets)edgeInsetsForKey:(NSString *)key {
    NSString *edgeString = [self stringForKey:key];
    
    if (edgeString) {
        NSArray *edgeValues = separatedValues(edgeString);
        switch ([edgeValues count]) {
            case 1:
                return UIEdgeInsetsMake([edgeValues[0] floatValue],
                                        [edgeValues[0] floatValue],
                                        [edgeValues[0] floatValue],
                                        [edgeValues[0] floatValue]);
            case 2:
                return UIEdgeInsetsMake([edgeValues[0] floatValue],
                                        [edgeValues[1] floatValue],
                                        [edgeValues[0] floatValue],
                                        [edgeValues[1] floatValue]);
                break;
            case 4:
                return UIEdgeInsetsMake([edgeValues[0] floatValue],
                                        [edgeValues[1] floatValue],
                                        [edgeValues[2] floatValue],
                                        [edgeValues[3] floatValue]);
                break;
        }
    }
    
	CGFloat left = [self floatForKey:[key stringByAppendingString:@"Left"]];
	CGFloat top = [self floatForKey:[key stringByAppendingString:@"Top"]];
	CGFloat right = [self floatForKey:[key stringByAppendingString:@"Right"]];
	CGFloat bottom = [self floatForKey:[key stringByAppendingString:@"Bottom"]];

	UIEdgeInsets edgeInsets = UIEdgeInsetsMake(top, left, bottom, right);
	return edgeInsets;
}


- (UIFont *)fontForKey:(NSString *)key {
	UIFont *cachedFont = [self.fontCache objectForKey:key];
	if (cachedFont) {
		return cachedFont;
    }
    
	NSString *fontName = [self stringForKey:key];
	CGFloat fontSize = [self floatForKey:[key stringByAppendingString:@"Size"]];

	if (fontSize < 1.0f) {
		fontSize = 15.0f;
    }

	UIFont *font = nil;
    
	if (stringIsEmpty(fontName)) {
		font = [UIFont systemFontOfSize:fontSize];
    } else if ([font isEqual:@"BoldSystem"]) {
        font = [UIFont boldSystemFontOfSize:fontSize];
    } else if ([font isEqual:@"System"]) {
        font = [UIFont systemFontOfSize:fontSize];
	} else {
		font = [UIFont fontWithName:fontName size:fontSize];
    }
    
	if (!font) {
		font = [UIFont systemFontOfSize:fontSize];
    }
    
	[self.fontCache setObject:font
                       forKey:key];

	return font;
}


- (CGPoint)pointForKey:(NSString *)key {
    NSString *pointString = [self stringForKey:key];
    if (pointString) {
        NSArray *pointValues = separatedValues(pointString);
        
        switch ([pointValues count]) {
            case 2:
                return CGPointMake([pointValues[0] floatValue],
                                   [pointValues[1] floatValue]);
        }
    }
    
	CGFloat pointX = [self floatForKey:[key stringByAppendingString:@"X"]];
	CGFloat pointY = [self floatForKey:[key stringByAppendingString:@"Y"]];

	CGPoint point = CGPointMake(pointX, pointY);
	return point;
}


- (CGSize)sizeForKey:(NSString *)key {
    NSString *sizeString = [self stringForKey:key];
    if (sizeString) {
        NSArray *sizeValues = separatedValues(sizeString);
        
        switch ([sizeValues count]) {
            case 2:
                return CGSizeMake([sizeValues[0] floatValue],
                                  [sizeValues[1] floatValue]);
        }
    }
    
	CGFloat width = [self floatForKey:[key stringByAppendingString:@"Width"]];
	CGFloat height = [self floatForKey:[key stringByAppendingString:@"Height"]];

	CGSize size = CGSizeMake(width, height);
	return size;
}


- (UIViewAnimationOptions)curveForKey:(NSString *)key {
	NSString *curveString = [self stringForKey:key];
	if (stringIsEmpty(curveString)) {
		return UIViewAnimationOptionCurveEaseInOut;
    }

	curveString = [curveString lowercaseString];
	if ([curveString isEqualToString:@"easeinout"]) {
		return UIViewAnimationOptionCurveEaseInOut;
	} else if ([curveString isEqualToString:@"easeout"]) {
		return UIViewAnimationOptionCurveEaseOut;
	} else if ([curveString isEqualToString:@"easein"]) {
		return UIViewAnimationOptionCurveEaseIn;
	} else if ([curveString isEqualToString:@"linear"]) {
		return UIViewAnimationOptionCurveLinear;
    }
    
	return UIViewAnimationOptionCurveEaseInOut;
}


- (VSAnimationSpecifier *)animationSpecifierForKey:(NSString *)key {
	VSAnimationSpecifier *animationSpecifier = [VSAnimationSpecifier new];

	animationSpecifier.duration = [self timeIntervalForKey:[key stringByAppendingString:@"Duration"]];
	animationSpecifier.delay = [self timeIntervalForKey:[key stringByAppendingString:@"Delay"]];
	animationSpecifier.curve = [self curveForKey:[key stringByAppendingString:@"Curve"]];

	return animationSpecifier;
}


- (VSTextCaseTransform)textCaseTransformForKey:(NSString *)key {
	NSString *s = [self stringForKey:key];
	if (!s) {
		return VSTextCaseTransformNone;
    }
    
	if ([s caseInsensitiveCompare:@"lowercase"] == NSOrderedSame) {
		return VSTextCaseTransformLower;
	} else if ([s caseInsensitiveCompare:@"uppercase"] == NSOrderedSame) {
		return VSTextCaseTransformUpper;
    }

	return VSTextCaseTransformNone;
}


@end


@implementation VSTheme (Animations)


- (void)animateWithAnimationSpecifierKey:(NSString *)animationSpecifierKey animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion {

    VSAnimationSpecifier *animationSpecifier = [self animationSpecifierForKey:animationSpecifierKey];

    [UIView animateWithDuration:animationSpecifier.duration
                          delay:animationSpecifier.delay
                        options:animationSpecifier.curve
                     animations:animations
                     completion:completion];
}

@end


#pragma mark -

@implementation VSAnimationSpecifier

@end


static BOOL stringIsEmpty(NSString *s) {
	return !s || [s length] == 0;
}

static NSArray *separatedValues(NSString *originString) {
    originString = [originString stringByReplacingOccurrencesOfString:@"("
                                                           withString:@""];
    originString = [originString stringByReplacingOccurrencesOfString:@")"
                                                           withString:@""];
    originString = [originString stringByReplacingOccurrencesOfString:@" "
                                                           withString:@""];
    
    return [originString componentsSeparatedByString:@","];
}


static UIColor *colorWithHexString(NSString *hexString) {
	/*Picky. Crashes by design.*/
	
	if (stringIsEmpty(hexString)) {
		return [UIColor clearColor];
    }

	NSMutableString *s = [hexString mutableCopy];
	[s replaceOccurrencesOfString:@"#" withString:@"" options:0 range:NSMakeRange(0, [hexString length])];
	CFStringTrimWhitespace((__bridge CFMutableStringRef)s);

	NSString *redString = [s substringToIndex:2];
	NSString *greenString = [s substringWithRange:NSMakeRange(2, 2)];
	NSString *blueString = [s substringWithRange:NSMakeRange(4, 2)];

	unsigned int red = 0, green = 0, blue = 0;
	[[NSScanner scannerWithString:redString] scanHexInt:&red];
	[[NSScanner scannerWithString:greenString] scanHexInt:&green];
	[[NSScanner scannerWithString:blueString] scanHexInt:&blue];

	return [UIColor colorWithRed:(CGFloat)red / 255.0f
                           green:(CGFloat)green / 255.0f
                            blue:(CGFloat)blue / 255.0f
                           alpha:1.0f];
}
