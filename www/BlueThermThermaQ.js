var exec = require('cordova/exec');

var _module = "BlueThermThermaQ";

function Device(deviceResult, client) {
	Object.assign(this, deviceResult);
	// Parent reference via function prevents JSON.stringify circular reference loops
	this.client = function() { return client; }
	this.connected = false;
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
	exec(success, error, _module, "device_connect", [self.id]);
}

Device.prototype.disconnect = function(success, error) {
	var self = this;
	exec(success, error, _module, "device_disconnect", [self.id]);
}

Device.prototype.delete = function(success, error) {
	var self = this;
	exec(success, error, _module, "device_delete", [self.id]);
}

Device.prototype.setMeasurementInterval = function(intervalSeconds, success, error) {
	var self = this;
	exec(success, error, _module, "device_setMeasurementInterval", [self.id, intervalSeconds]);
}

function Client() {
	this.devices = Object.create(null);
}

function updateDevice(deviceResult, client) {
  var device = client.devices[deviceResult.id];
  if (device === undefined) {
    device = new Device(deviceResult, client);
    client.devices[deviceResult.id] = device;
  }
  Object.assign(device, deviceResult);
  return device;
}

Client.prototype.registerCallback = function(success, error) {
  var self = this;
  exec(function(result) {
    if (result.device !== undefined) {
      result.device = updateDevice(result.device, self);
    }

    switch (result.command) {
      case "deviceDeleted":
        var device = self.devices[result.deviceid];
        if (device !== undefined) {
          delete self.devices[result.deviceId];
          result.device = device;
        }
        break;
    }

    if (success) {
      success(result);
    }
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

exports.Client = Client;
