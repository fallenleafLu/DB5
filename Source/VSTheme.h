//
//  VSTheme.h
//  Q Branch LLC
//
//  Created by Brent Simmons on 6/26/13.
//  Copyright (c) 2012 Q Branch LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, VSTextCaseTransform) {
    VSTextCaseTransformNone,
    VSTextCaseTransformUpper,
    VSTextCaseTransformLower
};


@class VSAnimationSpecifier;

@interface VSTheme : NSObject

- (id)initWithDictionary:(NSDictionary *)themeDictionary;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, weak) VSTheme *parentTheme; /*can inherit*/

- (BOOL)boolForKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key;
- (CGFloat)floatForKey:(NSString *)key;
- (UIImage *)imageForKey:(NSString *)key; /*Via UIImage imageNamed:*/
/**
 *  Gets the color by the given key.
 *  To use it, you must set 6 digits RGB Hex format like 123ABC or #123ABC (# is optional).
 *  Set it empty if you want to use clear color.
 *
 *  @param key The key in the theme property list.
 *
 *  @return The specified edge insets.
 */
- (UIColor *)colorForKey:(NSString *)key;
/**
 *  Gets the edge insets by the given key.
 *  To use it, you can set the values by the following format
 *  1. key+"Top"   : top value
 *     key+"Left"  : left value
 *     key+"Bottom": bottom value
 *     key+"right" : right value
 *  2. key: The value for top, left, bottom, and right.
 *  3. key: (vertical value, horizontal value)
 *          The vertical value is for top and bottom.
 *          The horizontal value is for left and right.
 *  4. key: (top value, left value, bottom value, right value)
 *  @param key The key in the theme property list.
 *
 *  @return The specified edge insets.
 */
- (UIEdgeInsets)edgeInsetsForKey:(NSString *)key;
/**
 *  Gets the font by the given key.
 *  To use it, you must set it by the following format.
 *  key     : font name
 *  key+Size: font size
 *
 *  If you want to use system font, set "System" as its font name.
 *  If you want to use bold system font, set "BoldSystem" as its font name.
 *
 *  @param key The key in the theme property list
 *
 *  @return The specified font.
 */
- (UIFont *)fontForKey:(NSString *)key;
/**
 *  Gets the point by the given key.
 *  To use it, you can set the values by the following format.
 *  1. key+X: x value
 *     key+Y: y value
 *  2. key: (x value, y value)
 *  @param key The key in the theme property list.
 *
 *  @return The specified point.
 */
- (CGPoint)pointForKey:(NSString *)key;
/**
 *  Gets the size by the given key.
 *  To use it, you can set the values by the following format.
 *  1. key+Width : width value
 *     key+Height: height value
 *  2. key: (width value, height value.)
 *  @param key The key in the theme property list.
 *
 *  @return The specified size.
 */
- (CGSize)sizeForKey:(NSString *)key; /*xWidth and xHeight keys*/
- (NSTimeInterval)timeIntervalForKey:(NSString *)key;

- (UIViewAnimationOptions)curveForKey:(NSString *)key; /*Possible values: easeinout, easeout, easein, linear*/
- (VSAnimationSpecifier *)animationSpecifierForKey:(NSString *)key; /*xDuration, xDelay, xCurve*/

- (VSTextCaseTransform)textCaseTransformForKey:(NSString *)key; /*lowercase or uppercase -- returns VSTextCaseTransformNone*/

@end


@interface VSTheme (Animations)

- (void)animateWithAnimationSpecifierKey:(NSString *)animationSpecifierKey animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;

@end


@interface VSAnimationSpecifier : NSObject

@property (nonatomic, assign) NSTimeInterval delay;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) UIViewAnimationOptions curve;

@end

