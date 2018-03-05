//
//  TLDateStamp.h
//  ThermaLib
//
//  Copyright © 2016 Electronic Temperature Instruments Limited. All rights reserved.
//

#import <Foundation/Foundation.h>


/// Represents a date as 3 separate integers
@interface TLDateStamp : NSObject
/// 2 digit year. Post-2000
@property (assign, nonatomic) NSUInteger year;
/// Month
@property (assign, nonatomic) NSUInteger month;
/// Day
@property (assign, nonatomic) NSUInteger day;

/**
 * @brief Custom initialiser
 *
 * @param year Year
 * @param month Month
 * @param day Day
 */
- (instancetype)initWithYear:(NSUInteger)year month:(NSUInteger)month day:(NSUInteger)day;

/// Creates an object initialised to today's date
+ (instancetype)today;

/// Resets the properties
- (void)clear;
@end
