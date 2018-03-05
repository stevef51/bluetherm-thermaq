//
//  TLSimDevice.h
//  ThermaLib
//
//  Copyright © 2016 Electronic Temperature Instruments Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLDevice.h"

/// Represents a simulated device where all properties can be manually set. <b> NOTE THAT THIS CLASS IS NOT SUPPORTED IN SDK V2.0. </b>
@interface TLSimDevice : NSObject <TLDevice>

@property (strong, nonatomic, readwrite) NSString *manufacturerName;

@property (strong, nonatomic, readwrite) NSString *serialNumber;

@property (strong, nonatomic, readwrite) NSString *modelNumber;

@property (strong, nonatomic, readwrite) NSString *protocolVersion;

@property (strong, nonatomic, readwrite) NSString *hardwareVersion;

@property (strong, nonatomic, readwrite) NSString *softwareRevision;

@property (strong, nonatomic, readwrite) NSString *firmwareRevision;

@property (assign, nonatomic, readwrite) TLTransport transportType;

@property (strong, nonatomic, readwrite) NSString *deviceName;

@property (assign, nonatomic, readwrite) TLDeviceType deviceType;

@property (assign, nonatomic, readonly) int features;

@property (strong, nonatomic, readwrite) NSString *deviceIdentifier;

@property (strong, nonatomic, readonly) NSString *deviceTypeName;

@property (strong, nonatomic, readwrite) NSArray<id<TLSensor>> *sensors;

@property (assign, nonatomic) TLDeviceUnit unit ;

@property (assign, nonatomic) NSInteger measurementInterval;

@property (assign, nonatomic) NSInteger transmissionInterval;

@property (assign, nonatomic) NSInteger autoOffInterval;

@property (assign, nonatomic) float emissivity;

@property (strong, nonatomic, readwrite) NSNumber *rssi;

@property (assign, nonatomic, readwrite) NSInteger batteryLevel;

@property (assign, nonatomic, readonly) TLBatteryWarningLevel batteryWarningLevel;

@property (assign, nonatomic, readwrite) TLDeviceConnectionState connectionState;

@property (nonatomic, readwrite) NSDate * nextTransmissionTime;

@property (assign, nonatomic, readwrite, getter=isReady) BOOL ready;

@property (assign, nonatomic, readonly) BOOL userRequestedDisconnect;

@property (nonatomic, readwrite) id<TLRemoteSettings> remoteSettings;

- (BOOL)isConnected;

- (NSInteger)maxSensorCount;

- (id<TLSensor>)sensorAtIndex:(NSUInteger)index;

- (BOOL)isSensorEnabledAtIndex:(NSUInteger)index;

- (void)updateRssi;
- (void)sendCommand:(TLDeviceCommandType)command;

- (void)refresh;

- (void)reset __deprecated_msg("Reserved for internal use only");

-(TLDeviceUnit)displayUnitForGenericSensorType:(TLGenericSensorType)genericType;

-(void)setDisplayUnitForGenericSensorType:(TLGenericSensorType)genericType
                                     unit:(TLDeviceUnit)unit;

@property (readwrite, nonatomic, assign) NSUInteger pollInterval;


-(BOOL) hasFeature:(int) feature;
@end
