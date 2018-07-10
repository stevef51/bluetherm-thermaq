/********* BlueThermThermaQ.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import "ThermaLib.h"
#import "TLDevice.h"
#import "TLSensor.h"

#define PLUGIN_VERSION @"1.1.3"

typedef void (^FnUpdate)(void);

/// Note, these toStrings are taken from Android library decompile to stay 100% compatible with Droid plugin
NSString* stringFromTLDeviceType(TLDeviceType deviceType) {
    switch(deviceType) {
        case TLDeviceTypeThermaDataWiFi:
        return @"ThermaDataWifi";
        case TLDeviceTypeThermaPenBlue:
        return @"ThermaPenBlue";
        case TLDeviceTypeBlueThermOne:
        return @"BlueThermOne";
        case TLDeviceTypeThermaQWiFi:
        return @"ThermaQWiFi";
        case TLDeviceTypeThermaQBlue:
        return @"ThermaQBlue";
        case TLDeviceTypeRayTempBlue:
        return @"RayTempBlue";
        default:
        return @"Unknown";
    }
}

NSString* stringFromTLTransport(TLTransport transport) {
    switch(transport) {
        case TLTransportBluetoothLE:
        return @"BluetoothLE";
        case TLTransportCloudService:
        return @"CloudService";
        case TLTransportSimulated:
        return @"Simulated";
        default:
        return @"Unknown";
    }
}

NSString* stringFromTLDeviceConnectionState(TLDeviceConnectionState connectionState) {
    switch(connectionState) {
        case TLDeviceConnectionStateUnknown:
        return @"Unknown";
        case TLDeviceConnectionStateAvailable:
        return @"Available";
        case TLDeviceConnectionStateConnecting:
        return @"Connecting";
        case TLDeviceConnectionStateConnected:
        return @"Connected";
        case TLDeviceConnectionStateDisconnecting:
        return @"Disconnecting";
        case TLDeviceConnectionStateDisconnected:
        return @"Disconnected";
        case TLDeviceConnectionStateUnavailable:
        return @"Unavailable";
        case TLDeviceConnectionStateUnsupported:
        return @"Unsupported";
        default:
        return @"Unknown";
    }
}

NSString* stringFromTLDeviceUnit(TLDeviceUnit deviceUnit) {
    switch(deviceUnit) {
        case TLDeviceUnitCelsius:
        return @"CELSIUS";

        case TLDeviceUnitFahrenheit:
        return @"FAHRENHEIT";

        default:
        return @"Unknown";
    }
}

NSString* stringFromTLDeviceCommandType(TLDeviceCommandType commandType) {
    switch(commandType) {
        case TLDeviceCommandTypeMeasure:
        return @"Measure";

        case TLDeviceCommandTypeIdentify:
        return @"Identify";

        case TLDeviceCommandTypeFactorySettings:
        return @"FactorySettings";

        case TLDeviceCommandTypeFactoryReset:
        return @"FactoryReset";

        default:
        return @"Unknown";
    }
};


NSString* stringFromTLDeviceNotificationType(TLDeviceNotificationType notificationType) {
    switch(notificationType) {
        case TLDeviceNotificationTypeNone:
        return @"NONE";

        case TLDeviceNotificationTypeButtonPressed:
        return @"BUTTON PRESSED";

        case TLDeviceNotificationTypeShutdown:
        return @"SHUTDOWN";

        case TLDeviceNotificationTypeInvalidSetting:
        return @"INVALID SETTING";

        case TLDeviceNotificationTypeInvalidCommand:
        return @"INVALID COMMAND";

        case TLDeviceNotificationTypeCommunicationError:
        return @"COMMUNICATION_ERROR";

        default:
        return @"UNKNOWN NOTIFICATION";
    }
};

NSString* stringFromTLSensorType(TLSensorType sensorType) {
    switch(sensorType) {
        case TLSensorTypeInternalThermistor:
        return @"Internal Thermistor";

        case TLSensorTypeExternalThermistor:
        return @"External Thermistor";

        case TLSensorTypeKThermocouple:
        return @"Type K Thermocouple";

        case TLSensorTypeTThermocouple:
        return @"Type T Thermocouple";

        case TLSensorTypePT1000:
        return @"PT1000";

        case TLSensorTypePHSensor:
        return @"PHSensor";

        case TLSensorTypeHumidityTemperature:
        return @"Humidity Temperature";

        case TLSensorTypeHumidity:
        return @"Humidity";

        case TLSensorTypeMoistureSensor:
        return @"Moisture Sensor";

        case TLSensorTypeExternalThermistorConnector:
        return @"External Thermistor Connector";

        case TLSensorTypeKThermocoupleFixed:
        return @"Type K Thermocouple Fixed";

        case TLSensorTypeInfraredType1:
        return @"Infrared Type 1";

        default:
        return @"Unknown";
    }
}

NSMutableDictionary* MakeJSONSensor(id<TLSensor> sensor)
{
    NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
    [info setObject: [NSNumber numberWithUnsignedInteger: sensor.index - 1] forKey: @"index"];      // Android index is 0-based

    NSString* name = [sensor name];
    if (name != nil && name.length)
    [info setObject: name forKey: @"name"];

    [info setObject: stringFromTLSensorType(sensor.type) forKey: @"type"];
    [info setObject: [NSNumber numberWithDouble: sensor.reading] forKey: @"reading"];
    if (sensor.highAlarmEnabled) {
        [info setObject: [NSNumber numberWithDouble: sensor.highAlarm] forKey: @"highAlarm"];
    } else {
        [info setObject: [NSNull null] forKey: @"highAlarm"];
    }
    if (sensor.lowAlarmEnabled) {
        [info setObject: [NSNumber numberWithDouble: sensor.lowAlarm] forKey: @"lowAlarm"];
    } else {
        [info setObject: [NSNull null] forKey: @"lowAlarm"];
    }
    [info setObject: [NSNumber numberWithBool: sensor.fault] forKey: @"fault"];
    [info setObject: [NSNumber numberWithDouble: sensor.trimValue] forKey: @"trimValue"];

    return info;
}

NSMutableDictionary* MakeJSONDevice(id<TLDevice> device)
{
    NSMutableDictionary* info = [[NSMutableDictionary alloc] init];

    [info setObject: device.deviceIdentifier forKey: @"id"];
    if (device.deviceName != nil && device.deviceName.length)
    [info setObject: device.deviceName forKey: @"name"];
    [info setObject: [NSNumber numberWithBool: device.ready] forKey: @"ready"];
    [info setObject: [NSNumber numberWithBool: device.isConnected] forKey: @"isConnected"];

    if (device.serialNumber != nil && device.serialNumber.length)
    [info setObject: device.serialNumber forKey: @"serialNumber"];

    [info setObject: stringFromTLDeviceConnectionState(device.connectionState) forKey: @"connectionState"];
    [info setObject: [NSNumber numberWithInteger: device.batteryLevel] forKey: @"batteryLevel"];

    if (device.modelNumber != nil && device.modelNumber.length)
    [info setObject: device.modelNumber forKey: @"modelNumber"];

    if (device.manufacturerName != nil && device.manufacturerName.length)
    [info setObject: device.manufacturerName forKey: @"manufacturerName"];

    if (device.rssi != nil)
    [info setObject: device.rssi forKey: @"rssi"];

    if (device.softwareRevision != nil && device.softwareRevision.length)
    [info setObject: device.softwareRevision forKey: @"softwareRevision"];

    if (device.hardwareVersion != nil && device.hardwareVersion.length)
    [info setObject: device.hardwareVersion forKey: @"hardwareRevision"];       // Droid uses "hardwareRevision"

    if (device.firmwareRevision != nil && device.firmwareRevision.length)
    [info setObject: device.firmwareRevision forKey: @"firmwareRevision"];

    [info setObject: [NSNumber numberWithInteger: device.measurementInterval * 1000] forKey: @"measurementMilliseconds"];
    [info setObject: [NSNumber numberWithInteger: device.autoOffInterval * 60] forKey: @"autoOffSeconds"];

    NSMutableArray* sensors = [[NSMutableArray alloc] init];
    for (int i = 1 ; i <= device.maxSensorCount ; i++) {
        if ([device isSensorEnabledAtIndex:i]) {
            id<TLSensor> sensor = [device sensorAtIndex:i];
            if (sensor != nil) {
                [sensors addObject: MakeJSONSensor(sensor)];
            }
        }
    }

    [info setObject: sensors forKey: @"sensors"];

    return info;
}

@interface BlueThermThermaQ : CDVPlugin {
    BOOL _scanning;
}

@property (nonatomic, retain) ThermaLib* thermaLib;
@property (nonatomic, retain) NSString* eventCallbackId;
@property (nonatomic, retain) NSArray* lastDeviceList;
//@property (nonatomic, retain) NSMutableArray* scanDeviceList;
@property (nonatomic, retain) NSMutableDictionary* deviceCallbacks;

- (void)pluginInitialize;
- (void)dispose;

- (void)getVersion:(CDVInvokedUrlCommand*) command;
- (void)registerCallback:(CDVInvokedUrlCommand*) command;
- (void)startScan:(CDVInvokedUrlCommand*) command;
- (void)stopScan:(CDVInvokedUrlCommand*) command;
- (void)getDeviceList:(CDVInvokedUrlCommand*) command;
- (void)device_connect:(CDVInvokedUrlCommand*) command;
- (void)device_disconnect:(CDVInvokedUrlCommand*) command;
- (void)device_identify:(CDVInvokedUrlCommand*) command;
- (void)device_measure:(CDVInvokedUrlCommand*) command;
- (void)device_delete:(CDVInvokedUrlCommand*) command;
- (void)device_refresh:(CDVInvokedUrlCommand*) command;
- (void)device_configure:(CDVInvokedUrlCommand*) command;
@end

@implementation BlueThermThermaQ

@synthesize
    thermaLib,
    eventCallbackId,
    lastDeviceList,
//    scanDeviceList,
    deviceCallbacks;

-(void)pluginInitialize
{
    NSLog(@"pluginInitialize");
    [super pluginInitialize];

    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(onPause) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [nc addObserver:self selector:@selector(onResume) name:UIApplicationWillEnterForegroundNotification object:nil];

    [nc addObserver:self selector:@selector(onNewDevice:) name:ThermaLibNewDeviceFoundNotificationName object:nil];
    [nc addObserver:self selector:@selector(onDeviceNotificationReceived:) name:ThermaLibNotificationReceivedNotificationName object:nil];
    [nc addObserver:self selector:@selector(onBatteryLevelReceived:) name:ThermaLibBatteryLevelNotificationName object:nil];
    [nc addObserver:self selector:@selector(onDeviceUpdated:) name:ThermaLibDeviceUpdatedNotificationName object:nil];
    [nc addObserver:self selector:@selector(onSensorUpdated:) name:ThermaLibSensorUpdatedNotificationName object:nil];
    [nc addObserver:self selector:@selector(onRssiUpdated:) name:ThermaLibRSSINotificationName object:nil];
    [nc addObserver:self selector:@selector(onDeviceDeleted:) name:ThermaLibDeviceDeletedNotificationName  object:nil];

    self.thermaLib = [ThermaLib sharedInstance];
    self.deviceCallbacks = [[NSMutableDictionary alloc] init];
    _scanning = false;
}

-(NSMutableArray*) queueForDeviceId:(NSString*) deviceId withMethod:(NSString*) method createIfNeeded:(BOOL) createIfNeeded
{
    NSMutableDictionary* methods = [deviceCallbacks objectForKey:deviceId];
    if (methods == nil) {
        if (!createIfNeeded) {
            return nil;
        }
        methods = [[NSMutableDictionary alloc] init];
        [deviceCallbacks setObject:methods forKey:deviceId];
    }

    NSMutableArray* fns = [methods objectForKey:method];
    if (fns == nil) {
        if (!createIfNeeded) {
            return nil;
        }
        fns = [[NSMutableArray alloc] init];
        [methods setObject:fns forKey:method];
    }
    if (!createIfNeeded) {
        // Client will consume the array
        [methods removeObjectForKey:method];
    }
    return fns;
}

-(void) queueUpdate:(FnUpdate) fn forDeviceId:(NSString*) deviceId withMethod:(NSString*) method
{
    NSMutableArray* fns = [self queueForDeviceId:deviceId withMethod:method createIfNeeded:TRUE];
    [fns addObject:fn];
}

-(void)dispose
{
    NSLog(@"dispose");

    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [nc removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];

    [nc removeObserver:self name:ThermaLibNewDeviceFoundNotificationName object:nil];
    [nc removeObserver:self name:ThermaLibNotificationReceivedNotificationName object:nil];
    [nc removeObserver:self name:ThermaLibBatteryLevelNotificationName object:nil];
    [nc removeObserver:self name:ThermaLibDeviceUpdatedNotificationName object:nil];
    [nc removeObserver:self name:ThermaLibSensorUpdatedNotificationName object:nil];
    [nc removeObserver:self name:ThermaLibRSSINotificationName object:nil];

    self.thermaLib = nil;
    self.eventCallbackId = nil;
    self.lastDeviceList = nil;
//    self.scanDeviceList = nil;
    self.deviceCallbacks = nil;

    [super dispose];
}

- (void)getVersion:(CDVInvokedUrlCommand*) command
{
    NSLog(@"getVersion:");
    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
    [result setObject: @"iOS" forKey:@"platform"];
    [result setObject: PLUGIN_VERSION forKey:@"version"];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsDictionary: result];

    [self.commandDelegate sendPluginResult: pluginResult callbackId: command.callbackId];
}

-(void) deviceResult:(id<TLDevice>) device
{
    NSMutableArray* replies = [[NSMutableArray alloc] init];
    NSMutableDictionary* msg = [[NSMutableDictionary alloc] init];
    [msg setObject: @"deviceUpdated" forKey: @"command"];
    [msg setObject: MakeJSONDevice(device) forKey: @"device"];

    [replies addObject:msg];

    CDVPluginResult* eventResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsArray: replies];
    [eventResult setKeepCallbackAsBool: TRUE];

    [self.commandDelegate sendPluginResult: eventResult callbackId: self.eventCallbackId];
}

- (void)registerCallback:(CDVInvokedUrlCommand*) command
{
    NSLog(@"registerCallback:");

    self.eventCallbackId = command.callbackId;

    NSMutableArray* replies = [[NSMutableArray alloc] init];
    NSMutableDictionary* msg = [[NSMutableDictionary alloc] init];
    [msg setObject: @"registerCallback" forKey: @"command"];
    [replies addObject:msg];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsArray:replies];
    [pluginResult setKeepCallbackAsBool:TRUE];

    [self.commandDelegate sendPluginResult: pluginResult callbackId: command.callbackId];
}

- (void)getDeviceList:(CDVInvokedUrlCommand*) command
{
    NSLog(@"getDeviceList:");

    NSMutableArray* devices = [[NSMutableArray alloc] init];
    for(id<TLDevice> device in thermaLib.deviceList) {
        [devices addObject: MakeJSONDevice(device)];
    }

    NSMutableDictionary* msg = [[NSMutableDictionary alloc] init];
    [msg setObject: devices forKey: @"devices"];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsDictionary: msg];

    [self.commandDelegate sendPluginResult: pluginResult callbackId: command.callbackId];
}

-(void)startScanTimeout
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startScanTimeout) object:nil];

    [thermaLib stopDeviceScan];
    _scanning = false;

    NSMutableArray* replies = [[NSMutableArray alloc] init];
    for(id<TLDevice> device in lastDeviceList) {
        if (![[thermaLib deviceList] containsObject:device]) {
            // Device no longer visible, delete it ..
            NSMutableDictionary* msg = [[NSMutableDictionary alloc] init];
            [msg setObject: @"deviceDeleted" forKey: @"command"];
            [msg setObject: device.deviceIdentifier forKey: @"deviceId"];

            [replies addObject:msg];

            // No longer visible, complete any "newDevice" connect requests (they will fail with "Device not found")
            NSArray* fns = [self queueForDeviceId:device.deviceIdentifier withMethod:@"newDevice" createIfNeeded:FALSE];
            if (fns != nil) {
                for(FnUpdate fn in fns) {
                    fn();
                }
            }
        }
    }
//    self.scanDeviceList = nil;

    NSMutableArray* devices = [[NSMutableArray alloc] init];
    for(id<TLDevice> device in thermaLib.deviceList) {
        [devices addObject: MakeJSONDevice(device)];
    }

    NSMutableDictionary* msg = [[NSMutableDictionary alloc] init];
    [msg setObject: @"scanComplete" forKey: @"command"];
    [msg setObject: devices forKey: @"devices"];
    [msg setObject: @"0" forKey: @"errorCode"];

    [replies addObject:msg];

    CDVPluginResult* eventResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsArray: replies];
    [eventResult setKeepCallbackAsBool: TRUE];

    [self.commandDelegate sendPluginResult: eventResult callbackId: self.eventCallbackId];
}

- (void)startScan:(CDVInvokedUrlCommand*) command
{
    NSLog(@"startScan:");
    CDVPluginResult* pluginResult = nil;
    NSNumber* timeoutMilliseconds = nil;

    if (command.arguments.count >= 1) {
        timeoutMilliseconds = [command.arguments objectAtIndex:0];
    }

    if (timeoutMilliseconds == nil) {
        pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString: @"timeout required"];
    }

    if (pluginResult == nil) {
        self.lastDeviceList = [[thermaLib deviceList] copy];

        _scanning = true;
        for(id<TLDevice> device in self.lastDeviceList) {
            switch([device connectionState]) {
                case TLDeviceConnectionStateConnecting:
                case TLDeviceConnectionStateConnected:
                    break;

                default:
                    [thermaLib removeDevice:device];
                    break;
            }
        }

        // startDeviceScanWithTransport will clear the internal cache of BLE devices before scanning
        [thermaLib startDeviceScanWithTransport: TLTransportBluetoothLE];

        [self performSelector:@selector(startScanTimeout) withObject:nil afterDelay:[timeoutMilliseconds doubleValue] / 1000.0];

        pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK];
    }

    [self.commandDelegate sendPluginResult: pluginResult callbackId: command.callbackId];
}

- (void)stopScan:(CDVInvokedUrlCommand*) command
{
    NSLog(@"stopScan:");

    // Invoke the startScanTimeout which will stop the scan and send results
    [self startScanTimeout];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult: pluginResult callbackId: command.callbackId];
}


- (void)device_connect:(CDVInvokedUrlCommand*) command
{
    NSLog(@"device_connect:");
    CDVPluginResult* pluginResult = nil;
    NSString* deviceId = nil;

    if (command.arguments.count >= 1) {
        deviceId = [command.arguments objectAtIndex: 0];
    }

    if (deviceId == nil) {
        pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString: @"deviceId required"];
    }

    if (pluginResult == nil) {
        id<TLDevice> device = [thermaLib deviceWithIdentifier: deviceId];
        if (device == nil) {
            // If we are scanning then its possible it has not been rediscovered yet
            if (_scanning) {
                __weak BlueThermThermaQ* weakSelf = self;
                [self queueUpdate:^{
                    CDVPluginResult* pluginResult = nil;
                    id<TLDevice> device = [thermaLib deviceWithIdentifier: deviceId];
                    if (device == nil) {
                        pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString: @"Device not found"];
                    } else {
                        [thermaLib connectToDevice: device];

                        [weakSelf deviceResult: device];

                        pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK];
                    }
                    [weakSelf.commandDelegate sendPluginResult: pluginResult callbackId: command.callbackId];
                } forDeviceId:deviceId withMethod:@"newDevice"];
            } else {
                // Not scanning, not found ..
                pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString: @"Device not found"];
            }
        } else {
            [thermaLib connectToDevice: device];

            [self deviceResult: device];

            pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK];
        }
    }

    [self.commandDelegate sendPluginResult: pluginResult callbackId: command.callbackId];
}

- (void)device_disconnect:(CDVInvokedUrlCommand*) command
{
    NSLog(@"device_disconnect:");
    CDVPluginResult* pluginResult = nil;
    NSString* deviceId = nil;

    if (command.arguments.count >= 1) {
        deviceId = [command.arguments objectAtIndex: 0];
    }

    if (deviceId == nil) {
        pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString: @"deviceId required"];
    }

    if (pluginResult == nil) {
        id<TLDevice> device = [thermaLib deviceWithIdentifier: deviceId];
        if (device == nil) {
            pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString: @"Device not found"];
        } else if (!device.isConnected) {
            pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString: @"Device not connected"];
        } else {
            [thermaLib disconectFromDevice: device];

            [self deviceResult: device];

            pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK];
        }
    }

    [self.commandDelegate sendPluginResult: pluginResult callbackId: command.callbackId];
}

- (void)device_identify:(CDVInvokedUrlCommand*) command
{
    NSLog(@"device_identify:");
    CDVPluginResult* pluginResult = nil;
    NSString* deviceId = nil;

    if (command.arguments.count >= 1) {
        deviceId = [command.arguments objectAtIndex: 0];
    }

    if (deviceId == nil) {
        pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString: @"deviceId required"];
    }

    if (pluginResult == nil) {
        id<TLDevice> device = [thermaLib deviceWithIdentifier: deviceId];
        if (device == nil) {
            pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString: @"Device not found"];
        } else if (!device.isConnected) {
            pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString: @"Device not connected"];
        } else {
            [device sendCommand: TLDeviceCommandTypeIdentify];

            pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK];
        }
    }

    [self.commandDelegate sendPluginResult: pluginResult callbackId: command.callbackId];
}

- (void)device_measure:(CDVInvokedUrlCommand*) command
{
    NSLog(@"device_measure:");
    CDVPluginResult* pluginResult = nil;
    NSString* deviceId = nil;

    if (command.arguments.count >= 1) {
        deviceId = [command.arguments objectAtIndex: 0];
    }

    if (deviceId == nil) {
        pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString: @"deviceId required"];
    }

    if (pluginResult == nil) {
        id<TLDevice> device = [thermaLib deviceWithIdentifier: deviceId];
        if (device == nil) {
            pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString: @"Device not found"];
        } else if (!device.isConnected) {
            pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString: @"Device not connected"];
        } else {
            [device sendCommand: TLDeviceCommandTypeMeasure];

            __weak BlueThermThermaQ* weakSelf = self;
            [self queueUpdate:^{
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsDictionary:MakeJSONDevice(device)];
                [weakSelf.commandDelegate sendPluginResult: pluginResult callbackId: command.callbackId];
            } forDeviceId:device.deviceIdentifier withMethod:@"sensorUpdated"];
        }
    }

    if (pluginResult != nil) {
        [self.commandDelegate sendPluginResult: pluginResult callbackId: command.callbackId];
    }
}

- (void)device_refresh:(CDVInvokedUrlCommand*) command
{
    NSLog(@"device_refresh:");
    CDVPluginResult* pluginResult = nil;
    NSString* deviceId = nil;

    if (command.arguments.count >= 1) {
        deviceId = [command.arguments objectAtIndex: 0];
    }

    if (deviceId == nil) {
        pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString: @"deviceId required"];
    }

    if (pluginResult == nil) {
        id<TLDevice> device = [thermaLib deviceWithIdentifier: deviceId];
        if (device == nil) {
            pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString: @"Device not found"];
        } else if (!device.isConnected) {
            pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString: @"Device not connected"];
        } else {
            [device refresh];

            __weak BlueThermThermaQ* weakSelf = self;
            [self queueUpdate:^{
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsDictionary:MakeJSONDevice(device)];
                [weakSelf.commandDelegate sendPluginResult: pluginResult callbackId: command.callbackId];
            } forDeviceId:device.deviceIdentifier withMethod:@"deviceUpdated"];
        }
    }

     if (pluginResult != nil) {
         [self.commandDelegate sendPluginResult: pluginResult callbackId: command.callbackId];
     }
}

- (void)device_delete:(CDVInvokedUrlCommand*) command
{
    NSLog(@"device_delete:");
    CDVPluginResult* pluginResult = nil;
    NSString* deviceId = nil;

    if (command.arguments.count >= 1) {
        deviceId = [command.arguments objectAtIndex: 0];
    }

    if (deviceId == nil) {
        pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString: @"deviceId required"];
    }

    if (pluginResult == nil) {
        id<TLDevice> device = [thermaLib deviceWithIdentifier: deviceId];
        if (device == nil) {
            pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString: @"Device not found"];
        } else {
            [thermaLib removeDevice: device];

            // Simulate the Droid "onDeviceDeleted" event since iOS ThermaLib does not generate this event
            [self.commandDelegate runInBackground: ^{
                NSMutableArray* replies = [[NSMutableArray alloc] init];
                NSMutableDictionary* msg = [[NSMutableDictionary alloc] init];
                [msg setObject: @"deviceDeleted" forKey: @"command"];
                [msg setObject: deviceId forKey: @"deviceId"];
                [replies addObject:msg];

                CDVPluginResult* eventResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsArray: replies];
                [eventResult setKeepCallbackAsBool: TRUE];

                [self.commandDelegate sendPluginResult: eventResult callbackId: self.eventCallbackId];
            }];
            pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK];
        }
    }

    [self.commandDelegate sendPluginResult: pluginResult callbackId: command.callbackId];
}

-(void)configureDeviceWithOptions:(NSDictionary*) args
{
    CDVPluginResult* pluginResult = nil;
    NSDictionary* options = [args objectForKey:@"options"];
    id<TLDevice> device = [args objectForKey:@"device"];
    NSString* callbackId = [args objectForKey:@"callbackId"];
    NSNumber* retryInterval = [args objectForKey:@"retryInterval"];
    NSNumber* tryCount = [args objectForKey:@"tryCount"];

    @try {

        NSNumber* measurementMilliseconds = [options objectForKey: @"measurementMilliseconds"];
        if (measurementMilliseconds != nil) {
            device.measurementInterval = ([measurementMilliseconds intValue] + 1000 - 1) / 1000;    // Round up
        }

        NSNumber* autoOffSeconds = [options objectForKey: @"autoOffSeconds"];
        if (autoOffSeconds != nil) {
            device.autoOffInterval = ([autoOffSeconds intValue] + 60 - 1) / 60;        // Round up
        }

        NSArray* sensorConfigs = [options objectForKey: @"sensors"];
        if (sensorConfigs != nil) {
            for(NSDictionary* sensorConfig in sensorConfigs) {
                NSNumber* index = [sensorConfig objectForKey: @"index"];
                if (index == nil) {
                    pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString: @"Sensor.index required"];
                    break;
                }

                id<TLSensor> sensor = [device sensorAtIndex: [index intValue] + 1];     // sensorAtIndex is 1-based
                if (sensor == nil) {
                    pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString: @"Sensor not found"];
                    break;
                }

                NSNumber* enabled = [sensorConfig objectForKey: @"enabled"];
                if (enabled != nil && ![enabled isKindOfClass:[NSNull class]]) {
                    sensor.enabled = [enabled boolValue];
                }

                NSNumber* lowAlarm = [sensorConfig objectForKey: @"lowAlarm"];
                if (lowAlarm != nil) {
                    if ([lowAlarm isKindOfClass:[NSNull class]]) {
                        sensor.lowAlarmEnabled = FALSE;
                    } else {
                        sensor.lowAlarmEnabled = TRUE;
                        sensor.lowAlarm = [lowAlarm doubleValue];
                    }
                }

                NSNumber* highAlarm = [sensorConfig objectForKey: @"highAlarm"];
                if (highAlarm != nil) {
                    if ([highAlarm isKindOfClass:[NSNull class]]) {
                        sensor.highAlarmEnabled = FALSE;
                    } else {
                        sensor.highAlarmEnabled = TRUE;
                        sensor.highAlarm = [highAlarm doubleValue];
                    }
                }

                NSNumber* trimValue = [sensorConfig objectForKey: @"trimValue"];
                if (trimValue != nil && ![trimValue isKindOfClass:[NSNull class]]) {
                    sensor.trimValue = [trimValue intValue];
                }
            }
        }

        if (pluginResult == nil) {
            __weak BlueThermThermaQ* weakSelf = self;
            [self queueUpdate:^{
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsDictionary:MakeJSONDevice(device)];
                [weakSelf.commandDelegate sendPluginResult: pluginResult callbackId: callbackId];
            } forDeviceId:device.deviceIdentifier withMethod:@"deviceUpdated"];
        } else {
            [self.commandDelegate sendPluginResult: pluginResult callbackId: callbackId];
        }
    } @catch(NSException* e) {
        NSLog(@"Exception: %@", e);

        if ([tryCount intValue] > 0) {
            [args setValue:[NSNumber numberWithInteger:[tryCount intValue] - 1] forKey:@"tryCount"];
            [self performSelector:@selector(configureDeviceWithOptions:) withObject:args afterDelay:[retryInterval doubleValue]];
        }
    }
}

- (void)device_configure:(CDVInvokedUrlCommand*) command
{
    NSLog(@"device_configure:");
    CDVPluginResult* pluginResult = nil;
    NSString* deviceId = nil;
    NSDictionary* options = nil;

    if (command.arguments.count >= 1) {
        deviceId = [command.arguments objectAtIndex: 0];
    }

    if (command.arguments.count >= 2) {
        options = [command.arguments objectAtIndex: 1];
    }

    if (deviceId == nil) {
        pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString: @"deviceId required"];

    } else if (options == nil) {
        pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString: @"options required"];
    }

    if (pluginResult == nil) {
        id<TLDevice> device = [thermaLib deviceWithIdentifier: deviceId];
        if (device == nil) {
            pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString: @"Device not found"];

        } else if (!device.isConnected) {
            pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString: @"Device not connected"];

        } else {
            NSMutableDictionary* args = [[NSMutableDictionary alloc] init];
            NSNumber* tryCount = [options objectForKey: @"tryCount"];
            if (tryCount == nil) {
                tryCount = [NSNumber numberWithInteger:10];
            }
            [args setObject:tryCount forKey:@"tryCount"];

            NSNumber* retryInterval = [options objectForKey: @"retryInterval"];
            if (retryInterval == nil) {
                retryInterval = [NSNumber numberWithDouble:0.5];
            }
            [args setObject:retryInterval forKey:@"retryInterval"];

            [args setObject:command.callbackId forKey:@"callbackId"];
            [args setObject:device forKey:@"device"];
            [args setObject:options forKey:@"options"];

            [self configureDeviceWithOptions:args];
        }
    }

    if (pluginResult != nil) {
        [self.commandDelegate sendPluginResult: pluginResult callbackId: command.callbackId];
    }
}

- (void)onPause
{
    NSLog(@"onPause");
}

- (void)onResume
{
    NSLog(@"onResume");
}

- (void)onNewDevice:(NSNotification *)sender
{
    NSMutableArray* replies = [[NSMutableArray alloc] init];
    id<TLDevice> device = [sender object];
    if (device == NULL) {
        NSLog(@"onNewDevice: NULL DEVICE !!");
        return;
    }
    NSLog(@"onNewDevice: %@", device.deviceName);
    NSMutableDictionary* msg = [[NSMutableDictionary alloc] init];
    [msg setObject: @"newDevice" forKey: @"command"];
    [msg setObject: MakeJSONDevice(device) forKey: @"device"];

    [replies addObject:msg];

//    [self.scanDeviceList addObject:device];

    NSArray* fns = [self queueForDeviceId:device.deviceIdentifier withMethod:@"newDevice" createIfNeeded:FALSE];
    if (fns != nil) {
        for(FnUpdate fn in fns) {
            fn();
        }
    }

    self.lastDeviceList = [[thermaLib deviceList] copy];

    CDVPluginResult* eventResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsArray:replies];
    [eventResult setKeepCallbackAsBool: TRUE];

    [self.commandDelegate sendPluginResult: eventResult callbackId: self.eventCallbackId];
}

- (void)onDeviceDeleted:(NSNotification *)sender
{
    NSMutableArray* replies = [[NSMutableArray alloc] init];
    id<TLDevice> device = [sender object];
    if (device == NULL) {
        NSLog(@"onDeviceDeleted: NULL DEVICE !!");
        return;
    }
    NSLog(@"onDeviceDeleted: %@", device.deviceName);
    NSMutableDictionary* msg = [[NSMutableDictionary alloc] init];
    [msg setObject: @"deviceDeleted" forKey: @"command"];
    [msg setObject: device.deviceIdentifier forKey: @"deviceId"];

    [replies addObject:msg];

/*
    NSArray* fns = [self queueForDeviceId:device.deviceIdentifier withMethod:@"newDevice" createIfNeeded:FALSE];
    if (fns != nil) {
        for(FnUpdate fn in fns) {
            fn();
        }
    }
*/
    self.lastDeviceList = [[thermaLib deviceList] copy];

    CDVPluginResult* eventResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsArray:replies];
    [eventResult setKeepCallbackAsBool: TRUE];

    [self.commandDelegate sendPluginResult: eventResult callbackId: self.eventCallbackId];
}

- (void)onBatteryLevelReceived:(NSNotification *)sender
{
    id<TLDevice> device = sender.object;
    if (device == nil)
        return;
    NSLog(@"onBatteryLevelReceived: %@", device.deviceName);

    [self deviceResult: device];
}

- (void)onDeviceNotificationReceived:(NSNotification *)sender
{
    id<TLDevice> device = sender.object;
    if (device == nil)
        return;
    NSLog(@"onDeviceNotificationReceived: %@", device.deviceName);

    TLDeviceNotificationType notificationType = [[sender.userInfo objectForKey:ThermaLibNotificationReceivedNotificationTypeKey] intValue];
    NSMutableArray* replies = [[NSMutableArray alloc] init];
    NSMutableDictionary* msg = [[NSMutableDictionary alloc] init];
    [msg setObject: @"deviceNotification" forKey: @"command"];
    [msg setObject: stringFromTLDeviceNotificationType(notificationType) forKey: @"notificationType"];
    [msg setObject: MakeJSONDevice(device) forKey: @"device"];

    [replies addObject:msg];

    CDVPluginResult* eventResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsArray: replies];
    [eventResult setKeepCallbackAsBool: TRUE];

    [self.commandDelegate sendPluginResult: eventResult callbackId: self.eventCallbackId];
}

- (void)onDeviceUpdated:(NSNotification *)sender
{
    id<TLDevice> device = sender.object;
    if (device == nil)
        return;
    NSLog(@"onDeviceUpdated: %@", device.deviceName);

    [self deviceResult: device];

    NSArray* fns = [self queueForDeviceId:device.deviceIdentifier withMethod:@"deviceUpdated" createIfNeeded:FALSE];
    if (fns != nil) {
        for(FnUpdate fn in fns) {
            fn();
        }
    }
}

- (void)onSensorUpdated:(NSNotification *)sender
{
    id<TLSensor> sensor = sender.object;
    if (sensor == nil)  // Really?
        return;
    id<TLDevice> device = sensor.device;
    if (device == nil)  // Really?
        return;
    NSLog(@"onSensorUpdated: %@", device.deviceName);

    [self deviceResult: device];

    NSArray* fns = [self queueForDeviceId:device.deviceIdentifier withMethod:@"sensorUpdated" createIfNeeded:FALSE];
    if (fns != nil) {
        for(FnUpdate fn in fns) {
            fn();
        }
    }
}

- (void)onRssiUpdated:(NSNotification *)sender
{
    id<TLDevice> device = sender.object;
    if (device == nil)
        return;
    NSLog(@"onRssiUpdated: %@", device.deviceName);

    [self deviceResult: device];
}

@end
