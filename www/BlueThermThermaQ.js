var cordova_exec = require('cordova/exec');
var exec = cordova_exec;

var _module = "BlueThermThermaQ";

function log(msg) {
	var dt = new Date();
	msg = dt.toTimeString() + ' - ' + msg;
	console.log(msg);
}

var debugExec = false;
if (debugExec) {
	exec = function(success, error, module, method, args) {
		log('Calling ' + method + ': ' + JSON.stringify(args));
		cordova_exec(function(result) {
			log('Success ' + method + ': ' + JSON.stringify(result));
			if (success) {
				success(result);
			}
		}, function(result) {
			log('Error ' + method + ': ' + JSON.stringify(result));
			if (error) {
				error(result);
			}
		}, module, method, args);
	}
}

function Device(deviceResult, client) {
	Object.assign(this, deviceResult);
	// Parent reference via function prevents JSON.stringify circular reference loops
	this.client = function() { return client; }
}

Device.prototype.refresh = function(success, error) {
	var self = this;
	exec(success, error, _module, "device_refresh", [self.id]);
}

Device.prototype.identify = function(success, error) {
	var self = this;
	exec(success, error, _module, "device_identify", [self.id]);
}

Device.prototype.measure = function(success, error) {
	var self = this;
	exec(success, error, _module, "device_measure", [self.id]);
}

Device.prototype.connect = function(success, error) {
	var self = this;
	// We defer success until the device is actually Connected
	if (success) {
		this.$connect_success = success;
	}
	exec(null, error, _module, "device_connect", [self.id]);
}

Device.prototype.disconnect = function(success, error) {
	var self = this;
	exec(success, error, _module, "device_disconnect", [self.id]);
}

Device.prototype.delete = function(success, error) {
	var self = this;
	exec(success, error, _module, "device_delete", [self.id]);
}

Device.prototype.configure = function(options, success, error) {
	var self = this;

	var makeOptions = function(device) {
		var options = {
			measurementMilliseconds: device.measurementMilliseconds,
			autoOffSeconds: device.autoOffSeconds,
			sensors: []
		};

		device.sensors.forEach(function(sensor) {
			options.sensors.push({
				index: sensor.index,
				enabled: sensor.enabled,
				lowAlarm: sensor.lowAlarm,
				highAlarm: sensor.highAlarm,
				trimValue: sensor.trimValue
			});
		});

		return options;
	}

	if (options !== undefined) {
		exec(function(device) {
			Object.assign(self, device);
			if (success) {
				success(makeOptions(device));
			}
		}, error, _module, "device_configure", [self.id, options]);
	} else {
		if (success) {
			success(makeOptions(this));
		}
	}
}

function Client() {
	this.devices = Object.create(null);
    this._cachedDevices = Object.create(null);      // Cache all devices seen so we never have 2 copies referencing same Id
}

function updateDevice(deviceResult, client) {
	var device = client.devices[deviceResult.id];
	if (device === undefined) {
        device = client._cachedDevices[deviceResult.id];
        if (device === undefined) {
		    device = new Device(deviceResult, client);
            client._cachedDevices[deviceResult.id] = device;
        }
		client.devices[deviceResult.id] = device;
	}
	Object.assign(device, deviceResult);

	// See if Connect_Success can be called ..
	if (device.ready == true && typeof device.$connect_success === 'function') {
		var $connect_success = device.$connect_success;
		delete device.$connect_success;
		$connect_success();
	}

	return device;
}

Client.prototype.registerCallback = function(success, error) {
	var self = this;
	exec(function(replies) {
		// Replies can contain 1 or more Cordova result's
		replies.forEach(function(result) {
			if (result.device !== undefined) {
				result.device = updateDevice(result.device, self);
			}

			switch (result.command) {
				case "deviceDeleted":
				var device = self.devices[result.deviceId];
				if (device !== undefined) {
					delete self.devices[result.deviceId];
					result.device = device;
				}
				break;

				case "scanComplete":
				var deletedDevices = [];
				for(var deviceId in self.devices) {
					var device = self.devices[deviceId];
					device.$keep = false;
					result.devices.forEach(function(liveDevice) {
						if (liveDevice.id == device.id) {
							device.$keep = true;
						}
					})
					if (!device.$keep) {
						deletedDevices.push(device);
					}
					delete device.$keep;
				}

				deletedDevices.forEach(function(device) {
					delete self.devices[device.id];
				})

				for(var i = 0 ; i < result.devices.length ; i++) {
					result.devices[i] = updateDevice(result.devices[i], self);
				}
				break;
			}

			if (success) {
				success(result);
			}
		});
	}, error, _module, "registerCallback");
}

Client.prototype.startScan = function (timeout, success, error) {
	var self = this;
	exec(success, error, _module, "startScan", [timeout]);
}

Client.prototype.stopScan = function (success, error) {
	exec(success, error, _module, "stopScan", []);
}

Client.prototype.getDeviceList = function (success, error) {
	var self = this;
	exec(function(result) {
		for(var i = 0 ; i < result.devices.length ; i++) {
			result.devices[i] = updateDevice(result.devices[i], self);
		}

		if (success) {
			success(result);
		}
	}, error, _module, "getDeviceList", []);
}

Client.prototype.getVersion = function(success, error) {
	exec(success, error, _module, "getVersion");
}

exports.Client = Client;
