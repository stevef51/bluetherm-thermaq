//
//  TLSimSensor.h
//  ThermaLib
//
//  Copyright © 2016 Electronic Temperature Instruments Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLSensor.h"


/// Represents a simulated sensor where all properties can be manually set
@interface TLSimSensor : NSObject <TLSensor>

/// The device that the sensor is part of
@property (weak, nonatomic, readonly) id<TLDevice> device;

/// The current trim value set on the sensor
@property (assign, nonatomic) float trimValue;

/// The date that the trim value was set
@property (strong, nonatomic, readonly) TLDateStamp *trimSetDate;

/**
 * @brief Most recent available reading.
 *
 * The reading is represented in units given by #readingUnit, and will
 * depend on the generic type (temperature, humidity etc.) of the sensor,
 * given by #genericType.
 */
@property (assign, nonatomic, readwrite) float reading;

/// The temperature at which the high alarm should trigger
@property (assign, nonatomic) float highAlarm;

/// Whether the high alarm is on/off
@property (assign, nonatomic) BOOL highAlarmEnabled;

/// The temperature at which the low alarm should trigger
@property (assign, nonatomic) float lowAlarm;

/// Whether the low alarm is on/off
@property (assign, nonatomic) BOOL lowAlarmEnabled;

/// The type of sensor
@property (assign, nonatomic, readwrite) TLSensorType type;

/// The sensor's index (1-based)
@property (assign, nonatomic, readwrite) NSUInteger index;

/// Whether the sensor is enabled or not (Note: not all sensors can be disabled on all device types)
@property (assign, nonatomic, getter=isEnabled) BOOL enabled;

/// Whether the sensor currently has a fault
@property (assign, nonatomic, readwrite, getter=isFault) BOOL fault;

/// The sensor's name
@property (strong, nonatomic) NSString *name;

/// the effective range of the sensor
@property (strong, nonatomic, readonly) TLRange *range;

/// Whether the high alarm has been breached
@property (nonatomic, readwrite) BOOL highAlarmBreached;

/// Whether the low alarm has been breached
@property (nonatomic, readwrite) BOOL lowAlarmBreached;

/// The unit in which #reading represents its value.
@property (assign, readonly) TLDeviceUnit readingUnit;

/// Indicates whether the physical device would be signalling a high alarm for the currently-held latest reading
@property (assign, nonatomic) BOOL highAlarmSignalled;

/// Indicates whether the physical device would be signalling a low alarm for the currently-held latest reading
@property (assign, nonatomic) BOOL lowAlarmSignalled;

/// The time associated with the current reading. This is the best  estimate available of the time at which the reading was taken.
@property (nonatomic, readwrite) NSDate *readingTimestamp;

/**
 * @brief The display unit for the sensor.
 *
 * If the device the sensor is attached to has a physical display, this will reflect the units in which readings for
 * this sensor will be shown. Note that in some cases, for example the ThermaPen Blue, it is possible that
 * the device still stores a unit setting even though it has no physical display.
 *
 * The use of this method is at the discretion of the client application.
 */

@property (readwrite, assign) TLDeviceUnit displayUnit;
/**
 * @brief The generic type of the sensor.
 *
 * This governs the unit in which readings are presented. See the #reading and #readingUnit attributes.
 */
@property (assign, readwrite)TLGenericSensorType genericType;

/**
 * @brief How the device would display the current reading.
 *
 * This is provided so that if necessary client apps can ensure that they present reading values exactly
 * as they appear on the instrument's display, if it has one.
 */
@property (readwrite, nonatomic) NSString *readingAsDisplayed;
@end
