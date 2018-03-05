//
//  TLSensor.h
//  ThermaLib
//
//  Copyright © 2016 Electronic Temperature Instruments Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLRange.h"
#import "TLDevice.h"

@class TLDateStamp;

/// Possible sensor types
typedef NS_ENUM(NSInteger, TLSensorType) {
    /// Unknown
    TLSensorTypeUnknown,
    /// Internal Thermistor
    TLSensorTypeInternalThermistor,
    /// External Thermistor
    TLSensorTypeExternalThermistor,
    /// External Thermistor Connector
    TLSensorTypeExternalThermistorConnector,
    /// Infrared Sensor Type 1
    TLSensorTypeInfraredType1,
    /// K Thermocouple
    TLSensorTypeKThermocouple,
    /// T Thermocouple
    TLSensorTypeTThermocouple,
    /// PT1000 (NOT YET SUPPORTED)
    TLSensorTypePT1000,
    /// pH Sensor (NOT YET SUPPORTED)
    TLSensorTypePHSensor,
    /// Humidity Temperature
    TLSensorTypeHumidityTemperature,
    /// Humidity
    TLSensorTypeHumidity,
    /// Moisture Sensor (NOT YET SUPPORTED)
    TLSensorTypeMoistureSensor,
    /// For example ThermaPen
    TLSensorTypeKThermocoupleFixed
};

/// The `TLSensor` protocol encapsulates a sensor in a way that is independent of the underlying connection type of the device
@protocol TLSensor <NSObject>

/// Device that the sensor is part of
@property (weak, nonatomic, readonly) id<TLDevice> device;

/**
 * @brief Current trim value set on the sensor.
 *
 * The trim value allows a limited degree of user-level recalibration of sensors, and is only
 * currently available for Bluetooth Low Energy instruments
 */
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
@property (assign, nonatomic, readonly) float reading;

/// The temperature at which the high alarm should trigger
@property (assign, nonatomic) float highAlarm;

/// Whether the high alarm is activated
@property (assign, nonatomic) BOOL highAlarmEnabled;

/// The temperature at which the low alarm should trigger
@property (assign, nonatomic) float lowAlarm;

/// Whether the low alarm is activated
@property (assign, nonatomic) BOOL lowAlarmEnabled;

/// The type of sensor
@property (assign, nonatomic, readonly) TLSensorType type;

/// The sensor's index (1-based)
@property (assign, nonatomic, readonly) NSUInteger index;

/// Whether the sensor is enabled or not (Note: not all sensors can be disabled on all device types)
@property (assign, nonatomic, getter=isEnabled) BOOL enabled;

/// Whether the sensor currently has a fault
@property (assign, nonatomic, readonly, getter=isFault) BOOL fault;

/// The sensor's name
@property (strong, nonatomic) NSString *name;

/// the effective range of the sensor
@property (strong, nonatomic, readonly) TLRange *range;

/// Whether the high alarm has been breached
@property (nonatomic, readonly) BOOL highAlarmBreached;

/// Whether the low alarm has been breached
@property (nonatomic, readonly) BOOL lowAlarmBreached;

/// The unit in which #reading represents its value.
@property (assign, readonly) TLDeviceUnit readingUnit;

/// Indicates whether the physical device would be signalling a high alarm for the currently-held latest reading
@property (assign, nonatomic) BOOL highAlarmSignalled;

/// Indicates whether the physical device would be signalling a low alarm for the currently-held latest reading
@property (assign, nonatomic) BOOL lowAlarmSignalled;

/// The time associated with the current reading. This is the best  estimate available of the time at which the reading was taken.
@property (nonatomic, readonly) NSDate *readingTimestamp;

/**
 * @brief The display unit for the sensor.
 *
 * If the device the sensor is attached to has a physical display, this will reflect the units in which readings for
 * this sensor will be shown. Note that in some cases, for example the ThermaPen Blue,
 * the device stores a unit setting even though it has no physical display.
 *
 * This attribute may be used, at the client app's discretion, to match the the app's display of readings with
 * that of the actual device.
 */
 
@property (readonly, assign) TLDeviceUnit displayUnit;
/**
 * @brief The generic type of the sensor.
 *
 * @see {@link TLGenericSensorType}.
 */
@property (assign, readonly)TLGenericSensorType genericType;

/**
 * @brief How the device would display the current reading.
 *
 * This is provided so that if necessary client apps can ensure that they present reading values exactly
 * as they appear on the instrument's display, if it has one.
 */
@property (readonly, nonatomic) NSString *readingAsDisplayed;


@end
