//
//  TLDevice.h
//  ThermaLib
//
//  Copyright © 2016 Electronic Temperature Instruments Limited. All rights reserved.
//


#import <Foundation/Foundation.h>

@protocol TLSensor;
@protocol TLRemoteSettings;
@class TLDateStamp;

/**
 * @brief The connection method for the device
 **/
typedef NS_ENUM(NSInteger, TLTransport) {
    /// Bluetooth Low Energy connection
    TLTransportBluetoothLE,
    /// Indirect connection to an instrument via ETI Web Service
    TLTransportCloudService,
    /// Simulated device - not in current use
    TLTransportSimulated
};

/// The kinds of quantity a sensor can measure
typedef NS_ENUM(NSInteger, TLGenericSensorType) {
    /// The generic sensor type is not (yet) known
    TLGenericSensorTypeUnknown = 0,
    /// temperature
    TLGenericSensorTypeTemperature = 1,
    /// humidity
    TLGenericSensorTypeHumidity = 2,
    /// acidity
    TLGenericSensorTypeAcidity = 3
};

/// The type of device
typedef NS_ENUM(NSInteger, TLDeviceType) {
    /// Type unknown
    TLDeviceTypeUnknown,
    /// BlueTherm One
    TLDeviceTypeBlueThermOne,
    /// ThermaQ Blue
    TLDeviceTypeThermaQBlue,
    /// ThermaPen Blue
    TLDeviceTypeThermaPenBlue,
    /// ThermaQ WiFi
    TLDeviceTypeThermaQWiFi,
    /// ThermaData WiFi
    TLDeviceTypeThermaDataWiFi,
    /// RayTemp Blue
    TLDeviceTypeRayTempBlue,
    /// Simulated
};

/// Possible connection states
typedef NS_ENUM(NSInteger, TLDeviceConnectionState) {
    /// Connection state not (yet) known
    TLDeviceConnectionStateUnknown,
    /// When last tested, the device was eligible for connection.
    TLDeviceConnectionStateAvailable,
    /// A connection request has been issued but has not yet completed.
    TLDeviceConnectionStateConnecting,
    /// The device is connected to.
    TLDeviceConnectionStateConnected,
    /// A disconnection request has been made but has not yet completed.
    TLDeviceConnectionStateDisconnecting,
    /// The device has been disconnected
    TLDeviceConnectionStateDisconnected,
    /// The device is known to ThermaLib but is not available for connection
    TLDeviceConnectionStateUnavailable,
    /// The device is known to ThermaLib but it is not currenctly supported. An update of the app, the device, or both may be required.
    TLDeviceConnectionStateUnsupported,
    /// The device is known to ThermaLib but the app has not yet been registered to receive information about the device. A {@link #requestDeviceAccess} call is required.
    TLDeviceConnectionStateUnregistered
};

/// Possible disconnection reasons
typedef NS_ENUM(NSInteger, TLDeviceDisconnectionReason) {
    /// Unknown
    TLDeviceDisconnectionReasonUnknown,
    /// User disconnect
    TLDeviceDisconnectionReasonUser,
    /// No Internet
    TLDeviceDisconnectionReasonNoInternet,
    /// No Bluetooth
    TLDeviceDisconnectionReasonNoBluetooth,
    /// Authentication error
    TLDeviceDisconnectionReasonAuthenticationFailure,
    /// Unexpected
    TLDeviceDisconnectionReasonUnexpected,
    /// Device was deliberately shut down
    TLDeviceDisconnectionReasonDeviceShutDown,
};

/// Temperature display unit
typedef NS_ENUM(NSInteger, TLDeviceUnit) {
    /// degrees Celsius
    TLDeviceUnitCelsius,
    /// degrees Fahrenheit
    TLDeviceUnitFahrenheit,
    /// relative humidity
    TLDeviceUnitRelativeHumidity,
    /// pH
    TLDeviceUnitPH,
    /// unit not (yet) known
    TLDeviceUnitUnknown
};


/**
 * @brief Device command types.
 *
 * NB These are currently only used for Bluetooth Low Energy devices, i.e. those for which
 * {@link TLDevice.transportType} is #TLTransportBluetoothLE.
 */
typedef NS_ENUM(NSInteger, TLDeviceCommandType) {
    /// requests the device takes a measurement immediately and transmits it
    TLDeviceCommandTypeMeasure,
    /// requests the device identifies itself, for example by flashing an LED
    TLDeviceCommandTypeIdentify,
    /// requests the device returns to factory settings, excluding trim values
    TLDeviceCommandTypeFactorySettings,
    /// requests the device returns to factory settings, including trim values
    TLDeviceCommandTypeFactoryReset
};


/// Possible notifications
typedef NS_ENUM(NSInteger, TLDeviceNotificationType) {
    /// None
    TLDeviceNotificationTypeNone = 0,
    /// button pressed on the device
    TLDeviceNotificationTypeButtonPressed = 1,
    /// device is about to shut down
    TLDeviceNotificationTypeShutdown = 2,
    ///device received an invalid setting
    TLDeviceNotificationTypeInvalidSetting = 3,
    /// device received an invalid command
    TLDeviceNotificationTypeInvalidCommand = 4,
    /// device requests app to re-read all data
    TLDeviceNotificationTypeRefreshRequest = 5,
    /// communication error detected
    TLDeviceNotificationTypeCommunicationError = 6,
    /// Rremote device checkpoint event
    TLDeviceNotificationTypeCheckpoint = 7,
};

/**
 * @brief battery warning level
 *
 * Designed to correspond to the levels the battery LCD indicator would display. Apps can use this
 * to match their battery level displays to the physical device's display.
 *
 * See #batteryWarningLevel
 */
typedef NS_ENUM(NSInteger, TLBatteryWarningLevel) {
    /// The battery should be replaced immediately. Corresponds to an 'empty battery' indication on the device's physical display.
    TLBatteryWarningLevelCritical = 0,
    /// The battery should be replaced. Corresponds to a 'low battery' indication on the device's physical display.
    TLBatteryWarningLevelLow = 1,
    /// The battery charge is between that indicated by #TLBatteryWarningLevelLow and a notional, device-dependent 'half-full' level.
    TLBatteryWarningLevelHalf = 2,
    /// The battery charge is between that indicated by a notional, device-dependent 'half-full' level and fully-charged.
    TLBatteryWarningLevelFull = 3,
};


typedef NS_ENUM(NSInteger, TLDeviceFeature) {
    /**
     * @brief the device can be requested to switch itself off after a set period of time
     *
     * @see {@link TLDevice#autoOffInterval}
     */
    TLDeviceFeatureAutoOff = 0x01,
    /**
     * @brief the SDK polls for device updates. Currently true for Cloud devices
     *
     * @see {@link TLDevice#pollInterval}
     */
    TLDeviceFeaturePolledDevice = 0x02,
    /**
     * @brief the device has a settable emissivity. Relevant only for infrared devices,
     * e.g. the Raytemp Blue
     *
     * @see {@link TLDevice#emissivity}
     */
    TLDeviceFeatureEmissivity = 0x04,
    /**
     * @brief the device has its own display. Most devices do, but the ThermaPen Blue,
     * for example, doesn't.
     *
     * @see {@link TLDevice#readingAsDisplayed}..
     */
    TLDeviceFeatureDisplay = 0x08,
    /**
     * @brief the device settings will take effect on the actual instrument
     * some time after they are set locally.
     *
     * Currently only relevant for Cloud devices. The actual delay depends on the
     * transmission frequency (see TLDevice#transmissionInterval). Use TLDevice#remoteSettings
     * to find the latest settings reported by the actual device. This can be used to
     * identify which local settings have not yet taken effect on the actual instrument.
     *
     *
     * @see {@link TLDevice#readingAsDisplayed}..
     */
    TLDeviceFeatureAsynchronousSettings = 0x10,
    TLDeviceFeatureAlarm = 0x20
    
};

/// The `TLDevice` protocol encapsulates a device independently of the underlying connection type e.g. Bluetooth
@protocol TLDevice <NSObject>

/// The manufacturer name of the device
@property (strong, nonatomic, readonly) NSString *manufacturerName;

/// The serial number of the device
@property (strong, nonatomic, readonly) NSString *serialNumber;

/// The model number of the device
@property (strong, nonatomic, readonly) NSString *modelNumber;

/// The protocol version of the device
@property (strong, nonatomic, readonly) NSString *protocolVersion;

/// The hardware version of the device
@property (strong, nonatomic, readonly) NSString *hardwareVersion;

/// The software revision of the device
@property (strong, nonatomic, readonly) NSString *softwareRevision;

/// The firmware revision of the device
@property (strong, nonatomic, readonly) NSString *firmwareRevision;

/// The transport type of the device e.g. Bluetooth
@property (assign, nonatomic, readonly) TLTransport transportType;

/// The device name
@property (strong, nonatomic, readonly) NSString *deviceName;

/// The device type
@property (assign, nonatomic, readonly) TLDeviceType deviceType;

/**
 * @brief The features that this device has.
 *
 * This is a bitwise OR of the values defined in #TLDeviceFeature.
 */
@property (assign, nonatomic, readonly) int features;

/**
 * @brief The device identifier
 *
 * For Bluetooth devices, this is a UUID assigned by iOS at discovery time.
 * Only use this identifier for Bluetooth devices if you are sure it meets your requirements in terms of scope and stability.
 * (See https://developer.apple.com/reference/corebluetooth/cbperipheral/1518935-identifier). For a globally unique and stable identifier, use the serialNumber property.
 * 
 * For cloud devices this property is identical to the serialNumber property
 */
@property (strong, nonatomic, readonly) NSString *deviceIdentifier;

/// The string representation of deviceType
@property (strong, nonatomic, readonly) NSString *deviceTypeName;

/// The sensors included in the device
@property (strong, nonatomic, readonly) NSArray<id<TLSensor>> *sensors;

/**
 * @brief (Deprecated) The temperature unit the device is using.
 * @return TLDeviceUnit The unit for the device.
 * @deprecated Please use #displayUnitForGenericSensorType and #setDisplayUnitForGenericSensorType
 */
@property (assign, nonatomic) TLDeviceUnit unit __deprecated_msg("The latest device ranges support mixed sensor types. This attribute is retained for backward compatibility, but will report the unit in which the device will report temperatures only. Use TLSensor.getDisplayUnit, TLDevice.displayUnitForGenericSensorType, TLDevice.setDisplayUnitForGenericSensorType");

/**
 * @brief The interval between measurements recorded by the device (in seconds). For some devices (e.g. Bluetooth LowEnergy) this and
 * transmissionInterval are identical, i.e. changes to one will be reflected in the other.
 */
@property (assign, nonatomic) NSInteger measurementInterval;

/**
 * @brief The interval between transmissions from the device to the host (in seconds). For some devices (e.g. Bluetooth LowEnergy) this and
 * measurementInterval are identical, i.e. changes to one will be reflected in the other.
 */
@property (assign, nonatomic) NSInteger transmissionInterval;

/// The time internal for switching the device off (in minutes)
@property (assign, nonatomic) NSInteger autoOffInterval;

/// For infra-red devices, the emissivity in the range [0.1, 1]. Not used for other device types
@property (assign, nonatomic) float emissivity;

/// The last RSSI reported by the device
@property (strong, nonatomic, readonly) NSNumber *rssi;

/// The current battery level of the device
@property (assign, nonatomic, readonly) NSInteger batteryLevel;

/// The current battery warning level of the device
@property (assign, nonatomic, readonly) TLBatteryWarningLevel batteryWarningLevel;

/// The connection state of the device
@property (assign, nonatomic, readonly) TLDeviceConnectionState connectionState;

/// Returns the next transmission time. Only used currently for cloud devices
@property (nonatomic, readonly) NSDate * nextTransmissionTime;

/// Whether the device is ready. Implies that the device is connected and all settings have been read and processed
@property (assign, nonatomic, readonly, getter=isReady) BOOL ready;

/// Whether the user has requested that the device be disconnected, to contrast with unexpected disconnections
@property (assign, nonatomic, readonly) BOOL userRequestedDisconnect;

/// the last settings reported by the device. Only used currently for cloud devices
@property (nonatomic, readonly) id<TLRemoteSettings> remoteSettings;

/// whether the device is connected
@property (assign, readonly, getter=isConnected) BOOL connected;

/// number of sensors the device can physically accommodate
@property (assign, readonly) NSInteger maxSensorCount;

/**
 * @brief Defines how oftern ThermaLib requests updated information
 * for the device.
 *
 * Only appropriate for devices for which #hasFeature(TLDeviceFeaturePolledDevice)
 * returns YES.
 *
 * The poll interval is in seconds. An interval of 0 means ThermaLib will
 * not poll the device
 */
@property (readwrite, nonatomic, assign) NSUInteger pollInterval;

/**
 * @brief the sensor at the given index
 *
 * @param index index of the sensor (1-based)
 */
- (id<TLSensor>)sensorAtIndex:(NSUInteger)index;

/**
 * @brief whether the given sensor is enabled
 *
 * @param index index of the sensor (1-based)
 */
- (BOOL)isSensorEnabledAtIndex:(NSUInteger)index;

/// request that that the RSSI value be read from the device
- (void)updateRssi;

/**
 * @brief send a command to the device
 *
 * @param command command to send
 */
- (void)sendCommand:(TLDeviceCommandType)command;

/// Requests all values to be read from the device
- (void)refresh;

/**
 * @brief Resets a device by wiping any stored data in the sdk.
 * @deprecated Reserved for internal use only
 */
- (void)reset __deprecated_msg("Reserved for internal use only");


/**
 * @brief The current display unit for the given generic sensor type.
 *
 * The unit configured for display of readings of that generic type.
 * This does not affect the unit in which #reading is expressed, which
 * is fixed for a given generic sensor type, i.e. for temperature sensors,
 * #reading will always represent the temperature in degrees Celsius.
 *
 * @param genericType The generic sensor type
 * @return TLDeviceUnit The display unit for the specified generic sensor type.
 */
-(TLDeviceUnit)displayUnitForGenericSensorType:(TLGenericSensorType)genericType;

/**
 * @brief Sets the unit for the given generic sensor type. (Currently only relevant for temperature sensors.)
 *
 * This currently is used only for setting the Temperature unit.
 * @param genericType The generic sensor type
 * @param unit The unit for the specified generic sensor type.
 */
-(void)setDisplayUnitForGenericSensorType:(TLGenericSensorType)genericType
                                     unit:(TLDeviceUnit)unit;


/**
 * @brief Check to see whether the device has a specific feature.
 *
 * @param feature The feature to check
 * @return BOOL if the device has the specific feature
 */
-(BOOL) hasFeature:(int) feature;

@end
