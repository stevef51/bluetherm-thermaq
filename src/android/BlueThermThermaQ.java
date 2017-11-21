package BlueThermThermaQ;

import android.telecom.Call;

import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.List;

import uk.co.etiltd.thermalib.Device;
import uk.co.etiltd.thermalib.Sensor;
import uk.co.etiltd.thermalib.ThermaLib;
import uk.co.etiltd.thermalib.ThermaLibException;

/**
 * This class echoes a string called from JavaScript.
 */
public class BlueThermThermaQ extends CordovaPlugin implements ThermaLib.ClientCallbacks {

    private ThermaLib _thermaLib;
    private Object _registerHandle;
    private CallbackContext _callbackContext;

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);

        _thermaLib = ThermaLib.instance(cordova.getActivity());
        _registerHandle = _thermaLib.registerCallbacks(this, "BlueThermThermaQ");
    }

    private static JSONObject MakeJSONDevice(Device device) throws JSONException
    {
        JSONObject jobj = new JSONObject();
        jobj.put("id", device.getDeviceAddress());
        if (!device.getDeviceName().isEmpty())
            jobj.put("name", device.getDeviceName());
        if (!device.getSerialNumber().isEmpty())
            jobj.put("serialNumber", device.getSerialNumber());
        jobj.put("connectionState", device.getConnectionState());
        jobj.put("batteryLevel", device.getBatteryLevel());
        if (!device.getModelNumber().isEmpty())
            jobj.put("modelNumber", device.getModelNumber());
        if (!device.getManufacturerName().isEmpty())
            jobj.put("manufacturerName", device.getManufacturerName());
        jobj.put("rssi", device.getRssi());
        if (!device.getSoftwareRevision().isEmpty())
            jobj.put("softwareRevision", device.getSoftwareRevision());
        if (!device.getHardwareRevision().isEmpty())
            jobj.put("hardwareRevision", device.getHardwareRevision());
        if (!device.getFirmwareRevision().isEmpty())
            jobj.put("firmwareRevision", device.getFirmwareRevision());

        JSONArray jSensors = new JSONArray();
        for (Sensor sensor: device.getSensors()) {
            jSensors.put(MakeJSONSensor(sensor));
        }
        jobj.put("sensors", jSensors);

        return jobj;
    }

    private static JSONObject MakeJSONSensor(Sensor sensor) throws JSONException
    {
        JSONObject jobj = new JSONObject();
        jobj.put("index", sensor.getIndex());
        jobj.put("name", sensor.getName());
        jobj.put("type", sensor.getType());
        jobj.put("reading", sensor.getReading());
        jobj.put("highAlarm", sensor.getHighAlarm());
        jobj.put("lowAlarm", sensor.getLowAlarm());
        jobj.put("readingUnit", sensor.getReadingUnit());
        jobj.put("rangeHigh", sensor.getRange().high);
        jobj.put("rangeLow", sensor.getRange().low);
        jobj.put("state", sensor.getState());
        return jobj;
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("registerCallback")) {
            this.registerCallback(callbackContext);
            return true;
        } else if (action.equals("startScan")) {
            int timeout = 10;
            if (args.length() >= 1) {
                timeout = args.getInt(0);
            }
            this.startScan(timeout, callbackContext);
            return true;
        } else if (action.equals("stopScan")) {
            this.stopScan(callbackContext);
            return true;
        } else if (action.equals("getDeviceList")) {
            this.getDeviceList(callbackContext);
            return true;
        } else if (action.equals("device_refresh")) {
            String deviceId;
            if (args.length() >= 1) {
                deviceId = args.getString(0);
                this.device_refresh(deviceId, callbackContext);
            } else {
                callbackContext.error("deviceId required");
            }
            return true;
        } else if (action.equals("device_connect")) {
            String deviceId;
            if (args.length() >= 1) {
                deviceId = args.getString(0);
                this.device_connect(deviceId, callbackContext);
            } else {
                callbackContext.error("deviceId required");
            }
            return true;
        } else if (action.equals("device_disconnect")) {
            String deviceId;
            if (args.length() >= 1) {
                deviceId = args.getString(0);
                this.device_disconnect(deviceId, callbackContext);
            } else {
                callbackContext.error("deviceId required");
            }
            return true;
        } else if (action.equals("device_measure")) {
            String deviceId;
            if (args.length() >= 1) {
                deviceId = args.getString(0);
                this.device_measure(deviceId, callbackContext);
            } else {
                callbackContext.error("deviceId required");
            }
            return true;
        } else if (action.equals("device_identify")) {
            String deviceId;
            if (args.length() >= 1) {
                deviceId = args.getString(0);
                this.device_identify(deviceId, callbackContext);
            } else {
                callbackContext.error("deviceId required");
            }
            return true;
        } else if (action.equals("device_delete")) {
            String deviceId;
            if (args.length() >= 1) {
                deviceId = args.getString(0);
                this.device_delete(deviceId, callbackContext);
            } else {
                callbackContext.error("deviceId required");
            }
            return true;
        } else if (action.equals("device_setMeasurementInterval")) {
            String deviceId;
            int interval = 0;
            if (args.length() >= 1) {
                deviceId = args.getString(0);
                if (args.length() >= 2) {
                  interval = args.getInt(1);
                }
                this.device_setMeasurementInterval(deviceId, interval, callbackContext);
            } else {
                callbackContext.error("deviceId required");
            }
            return true;
        }

        return false;
    }

    private void device_setMeasurementInterval(String deviceId, int intervalSeconds, CallbackContext callbackContext) throws JSONException {
        Device device = _thermaLib.getDeviceWithAddress(deviceId);
        if (device == null) {
            callbackContext.error("Device not found");
        } else {
            device.setMeasurementInterval(intervalSeconds);
            callbackContext.success();
        }
    }
    private void device_measure(String deviceId, CallbackContext callbackContext) throws JSONException {
        Device device = _thermaLib.getDeviceWithAddress(deviceId);
        if (device == null) {
            callbackContext.error("Device not found");
        } else {
            device.sendCommand(Device.CommandType.MEASURE, null);
            callbackContext.success();
        }
    }

    private void device_identify(String deviceId, CallbackContext callbackContext) throws JSONException {
        Device device = _thermaLib.getDeviceWithAddress(deviceId);
        if (device == null) {
            callbackContext.error("Device not found");
        } else {
            device.sendCommand(Device.CommandType.IDENTIFY, null);
            callbackContext.success();
        }
    }

    private void device_refresh(String deviceId, CallbackContext callbackContext) throws JSONException {
        Device device = _thermaLib.getDeviceWithAddress(deviceId);
        if (device == null) {
            callbackContext.error("Device not found");
        } else {
            device.refresh();
            callbackContext.success();
        }
    }

    private void device_connect(String deviceId, CallbackContext callbackContext) throws JSONException {
        Device device = _thermaLib.getDeviceWithAddress(deviceId);
        if (device == null) {
            callbackContext.error("Device not found");
        } else {

            try {
                device.requestConnection();
                callbackContext.success();
            } catch (IllegalStateException lse) {
                JSONObject msg = new JSONObject();
                msg.put("error", lse.getMessage());
                msg.put("display", lse.getLocalizedMessage());
                callbackContext.error(msg);
            } catch (ThermaLibException tle) {
                JSONObject msg = new JSONObject();
                msg.put("error", tle.getMessage());
                msg.put("display", tle.getLocalizedMessage());
                callbackContext.error(msg);
            }
        }
    }

    private void device_disconnect(String deviceId, CallbackContext callbackContext) throws JSONException {
        Device device = _thermaLib.getDeviceWithAddress(deviceId);
        if (device == null) {
            callbackContext.error("Device not found");
        } else {
            try {
                device.requestDisconnection();
                callbackContext.success();
            } catch (IllegalStateException lse) {
                JSONObject msg = new JSONObject();
                msg.put("error", lse.getMessage());
                msg.put("display", lse.getLocalizedMessage());
                callbackContext.error(msg);
            }
        }
    }

    private void device_delete(String deviceId, CallbackContext callbackContext) throws JSONException {
        Device device = _thermaLib.getDeviceWithAddress(deviceId);
        if (device == null) {
            callbackContext.error("Device not found");
        } else {
            _thermaLib.deleteDevice(device);
            callbackContext.success();
        }
    }

    private void registerCallback(CallbackContext callbackContext) throws JSONException {
        _callbackContext = callbackContext;

        JSONObject msg = new JSONObject();
        msg.put("command", "registerCallback");

        PluginResult result = new PluginResult(PluginResult.Status.OK, msg);
        result.setKeepCallback(true);

        callbackContext.sendPluginResult(result);
    }

    private void startScan(int timeout, CallbackContext callbackContext) {
        if (_thermaLib.startScanForDevices(timeout)) {
            callbackContext.success();
        } else {
            callbackContext.error("startScan failed");
        }
    }

    private void stopScan(CallbackContext callbackContext) {
        if (_thermaLib.stopScanForDevices()) {
            callbackContext.success();
        } else {
            callbackContext.error("stopScan failed");
        }
    }

    private void getDeviceList(CallbackContext callbackContext) throws JSONException {
        List<Device> devices = _thermaLib.getDeviceList();

        JSONArray jDevices = new JSONArray();
        for (Device device : devices) {
            jDevices.put(MakeJSONDevice(device));
        }
        JSONObject msg = new JSONObject();
        msg.put("devices", jDevices);

        PluginResult result = new PluginResult(PluginResult.Status.OK, msg);
        result.setKeepCallback(true);

        callbackContext.sendPluginResult(result);
    }

    @Override
    public void onNewDevice(Device device, long timestamp) {
        if (_callbackContext != null) {
            JSONObject msg = new JSONObject();
            try {
                msg.put("command", "newDevice");
                msg.put("device", MakeJSONDevice(device));
                msg.put("timestamp", timestamp);
            } catch (JSONException je) {

            }

            PluginResult result = new PluginResult(PluginResult.Status.OK, msg);
            result.setKeepCallback(true);
            _callbackContext.sendPluginResult(result);
        }
    }

    @Override
    public void onDeviceDeleted(String deviceAddress, int transportType) {
        if (_callbackContext != null) {
            JSONObject msg = new JSONObject();
            try {
                msg.put("command", "deviceDeleted");
                msg.put("deviceId", deviceAddress);
            } catch (JSONException je) {

            }

            PluginResult result = new PluginResult(PluginResult.Status.OK, msg);
            result.setKeepCallback(true);
            _callbackContext.sendPluginResult(result);
        }
    }

    @Override
    public void onDeviceConnectionStateChanged(Device device, Device.ConnectionState connectionState, long timestamp) {
        if (_callbackContext != null) {
            JSONObject msg = new JSONObject();
            try {
                msg.put("command", "deviceConnectionChanged");
                msg.put("device", MakeJSONDevice(device));
                msg.put("connectionState", connectionState.toString());
                msg.put("timestamp", timestamp);
            } catch (JSONException je) {

            }

            PluginResult result = new PluginResult(PluginResult.Status.OK, msg);
            result.setKeepCallback(true);
            _callbackContext.sendPluginResult(result);
        }
    }

    @Override
    public void onBatteryLevelReceived(Device device, int batteryPercentage, long timestamp) {
        if (_callbackContext != null) {
            JSONObject msg = new JSONObject();
            try {
                msg.put("command", "deviceBatteryLevel");
                msg.put("device", MakeJSONDevice(device));
                msg.put("batteryPercentage", batteryPercentage);
                msg.put("timestamp", timestamp);
            } catch (JSONException je) {

            }

            PluginResult result = new PluginResult(PluginResult.Status.OK, msg);
            result.setKeepCallback(true);
            _callbackContext.sendPluginResult(result);
        }
    }

    @Override
    public void onDeviceUpdated(Device device, long timestamp) {
        if (_callbackContext != null) {
            JSONObject msg = new JSONObject();
            try {
                msg.put("command", "deviceUpdated");
                msg.put("device", MakeJSONDevice(device));
                msg.put("timestamp", timestamp);
            } catch (JSONException je) {

            }

            PluginResult result = new PluginResult(PluginResult.Status.OK, msg);
            result.setKeepCallback(true);
            _callbackContext.sendPluginResult(result);
        }
    }

    @Override
    public void onRefreshComplete(Device device, long timestamp) {
        if (_callbackContext != null) {
            JSONObject msg = new JSONObject();
            try {
                msg.put("command", "refresh_complete");
                msg.put("device", MakeJSONDevice(device));
                msg.put("timestamp", timestamp);
            } catch (JSONException je) {

            }

            PluginResult result = new PluginResult(PluginResult.Status.OK, msg);
            result.setKeepCallback(true);
            _callbackContext.sendPluginResult(result);
        }

    }

    @Override
    public void onRssiUpdated(Device device, int rssi) {
        if (_callbackContext != null) {
            JSONObject msg = new JSONObject();
            try {
                msg.put("command", "rssi");
                msg.put("device", MakeJSONDevice(device));
                msg.put("rssi", rssi);
            } catch (JSONException je) {

            }

            PluginResult result = new PluginResult(PluginResult.Status.OK, msg);
            result.setKeepCallback(true);
            _callbackContext.sendPluginResult(result);
        }

    }

    @Override
    public void onScanComplete(int errorCode, int deviceCount) {
        if (_callbackContext != null) {
            JSONObject msg = new JSONObject();
            try {
                msg.put("command", "scanComplete");
                msg.put("errorCode", errorCode);
                msg.put("deviceCount", deviceCount);
            } catch (JSONException je) {

            }

            PluginResult result = new PluginResult(PluginResult.Status.OK, msg);
            result.setKeepCallback(true);
            _callbackContext.sendPluginResult(result);
        }

    }

    @Override
    public void onMessage(Device device, String message, long timestamp) {
        if (_callbackContext != null) {
            JSONObject msg = new JSONObject();
            try {
                msg.put("command", "message");
                msg.put("device", MakeJSONDevice(device));
                msg.put("message", message);
                msg.put("timestamp", timestamp);
            } catch (JSONException je) {

            }

            PluginResult result = new PluginResult(PluginResult.Status.OK, msg);
            result.setKeepCallback(true);
            _callbackContext.sendPluginResult(result);
        }
    }

    @Override
    public void onDeviceReady(Device device, long timestamp) {
        if (_callbackContext != null) {
            JSONObject msg = new JSONObject();
            try {
                msg.put("command", "deviceReady");
                msg.put("device", MakeJSONDevice(device));
                msg.put("timestamp", timestamp);
            } catch (JSONException je) {

            }

            PluginResult result = new PluginResult(PluginResult.Status.OK, msg);
            result.setKeepCallback(true);
            _callbackContext.sendPluginResult(result);
        }
    }

    @Override
    public void onDeviceNotificationReceived(Device device, int notificationType, byte[] payload, long timestamp) {
        if (_callbackContext != null) {
            JSONObject msg = new JSONObject();
            try {
                msg.put("command", "deviceNotification");
                msg.put("device", MakeJSONDevice(device));
                msg.put("notificationType", Device.NotificationType.toString(notificationType));
                msg.put("payload", payload);
                msg.put("timestamp", timestamp);
            } catch (JSONException je) {

            }

            PluginResult result = new PluginResult(PluginResult.Status.OK, msg);
            result.setKeepCallback(true);
            _callbackContext.sendPluginResult(result);
        }
    }

    @Override
    public void onUnexpectedDeviceDisconnection(Device device, long timestamp) {
        if (_callbackContext != null) {
            JSONObject msg = new JSONObject();
            try {
                msg.put("command", "deviceDisconnect");
                msg.put("id", device.getDeviceAddress());
                msg.put("timestamp", timestamp);
            } catch (JSONException je) {

            }

            PluginResult result = new PluginResult(PluginResult.Status.OK, msg);
            result.setKeepCallback(true);
            _callbackContext.sendPluginResult(result);
        }
    }
}
