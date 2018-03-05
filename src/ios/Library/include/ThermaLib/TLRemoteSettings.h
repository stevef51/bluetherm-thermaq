//
//  TLRemoteSettings.h
//  ThermaLib
//
//  Copyright © 2017 Electronic Temperature Instruments Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLDevice.h"

@protocol TLDevice;

/**
 * @brief Latest copy of a device's actual settings.
 *
 * This class presents the most up-to-date available version of the settings currently active on the device. It is
 * only relevant for certain devices, for example ThermaQ WiFi and ThermaData WiFi, where ThermaLib's representation
 * of the current settings do not in general take effect on the actual device until the next time it communicates.
 *
 * (Currently only used where Device.hasFeature returns YES for TLDeviceFeaturePolledDevice
 *
 */
@protocol TLRemoteSettings <NSObject>

/**
* @brief The current unit on the device's display
*/
@property (assign, nonatomic) TLDeviceUnit temperatureDisplayUnit;

/**
* @brief If this is true the device will send an audit notification when the start button is pressed.
*/
@property (assign, nonatomic) bool auditEnabled;

/**
* @brief The date of the first reading stored on the device.
*/
@property (strong, nonatomic) NSDate *startDate;

/**
* @brief The amount of readings stored on the device.
*/
@property (assign, nonatomic) int samplesInMemory;

/**
* @brief The devices signal strength in dbm (i.e Cloud device will be WiFi strength).
*/
@property (assign, nonatomic) int signalStrength;

/**
* @brief The current measurement interval that is on the device.
*/
@property (assign, nonatomic) int measurementInterval;

/**
* @brief The current transmission interval that is on the device.
*/
@property (assign, nonatomic) int transmissionInterval;

/**
* @brief return true if the sensor's high alarm is enabled.
* @param sensorIndex The sensor index to test.
* @return bool The result of the test.
*/
-(bool)highAlarmEnabledForSensor:(int) sensorIndex;

/**
* @brief return true if the sensor's low alarm is enabled.
* @param sensorIndex The sensor index to test.
* @return bool The result of the test.
*/
-(bool)lowAlarmEnabledForSensor: (int) sensorIndex;

/**
* @brief returns the sensors high alarm that is on the device.
* @param sensorIndex The sensor index to test.
* @return float The result of the test.
*/
-(float)highLimitForSensor: (int) sensorIndex;

/**
* @brief returns the sensors low alarm that is on the device.
* @param sensorIndex The sensor index to test.
* @return float The result of the test.
*/
-(float)lowLimitForSensor: (int) sensorIndex;

/**
* @brief returns the sensors name that is on the device.
* @param sensorIndex The sensor index to test.
* @return float The result of the test.
*/
-(NSString *)nameOfSensor: (int) sensorIndex;

/**
* @brief returns the total alarm delay in seconds allowed for the log in this instance of the alarm.
* @param sensorIndex The sensor index to test.
* @return float The result of the test.
*/
-(int) alarmDelayForSensor: (int) sensorIndex;

/**
* @brief returns the sensors trim value that is on the device.
* @param sensorIndex The sensor index to test.
* @return float The result of the test.
*/
-(float) trimValueForSensor: (int) sensorIndex;

/**
* @brief returns the sensors trim date that is on the device.
* @param sensorIndex The sensor index to test.
* @return float The result of the test.
*/
-(NSDate *) trimDateForSensor: (int) sensorIndex;

/**
* @brief returns true if the sensor is enabled.
* @param sensorIndex The sensor index to test.
* @return float The result of the test.
*/
-(bool) isSensorEnabled: (int) sensorIndex;

@end
