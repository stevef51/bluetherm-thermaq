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

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import uk.co.etiltd.thermalib.Device;
import uk.co.etiltd.thermalib.Sensor;
import uk.co.etiltd.thermalib.ThermaLib;
import uk.co.etiltd.thermalib.ThermaLibException;

import static uk.co.etiltd.thermalib.Sensor.NO_VALUE;

/**
* This class echoes a string called from JavaScript.
*/
public class BlueThermThermaQ extends CordovaPlugin implements ThermaLib.ClientCallbacks {
	private final String PLUGIN_VERSION = "1.0.0";

	private ThermaLib _thermaLib;
	private Object _registerHandle;
	private CallbackContext _callbackContext;
	private HashMap<Device, ArrayList<Runnable>> _updateBlocks = new HashMap<Device, ArrayList<Runnable>>();

	// Queue a runnable on the next deviceUpdate from specific device
	private void queueUpdateBlock(Device device, Runnable runnable) {
		ArrayList<Runnable> fns = null;
		if (!_updateBlocks.containsKey(device)) {
			fns = new ArrayList<Runnable>();
			_updateBlocks.put(device, fns);
		} else {
			fns = _updateBlocks.get(device);
		}
		fns.add(runnable);
	}

	@Override
	public void initialize(CordovaInterface cordova, CordovaWebView webView) {
		super.initialize(cordova, webView);

		_thermaLib = ThermaLib.instance(cordova.getActivity());
		_registerHandle = _thermaLib.registerCallbacks(this, "BlueThermThermaQ");
	}

	private static JSONObject MakeJSONDevice(Device device)
	{
		JSONObject jobj = new JSONObject();
		try {
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
			jobj.put("measurementMilliseconds", device.getMeasurementInterval() * 1000);
			jobj.put("autoOffSeconds", device.getAutoOffInterval() * 60);
			jobj.put("ready", device.isReady());
			jobj.put("isConnected", device.isConnected());

			JSONArray jSensors = new JSONArray();
			for (Sensor sensor : device.getSensors()) {
				jSensors.put(MakeJSONSensor(sensor));
			}
			jobj.put("sensors", jSensors);
		} catch (JSONException je) {

		}

		return jobj;
	}

	private static JSONObject MakeJSONSensor(Sensor sensor) throws JSONException
	{
		JSONObject jobj = new JSONObject();
		jobj.put("index", sensor.getIndex());
		jobj.put("enabled", sensor.isEnabled());
		jobj.put("name", sensor.getName());
		jobj.put("type", sensor.getType());
		jobj.put("reading", sensor.getReading());
		if (sensor.getHighAlarm() != NO_VALUE) {
			jobj.put("highAlarm", sensor.getHighAlarm());
		} else {
			jobj.put("highAlarm", JSONObject.NULL);
		}
		if (sensor.getLowAlarm() != NO_VALUE) {
			jobj.put("lowAlarm", sensor.getLowAlarm());
		} else {
			jobj.put("lowAlarm", JSONObject.NULL);
		}
		jobj.put("fault", sensor.isFault());
		jobj.put("trimValue", sensor.getTrimValue());
		//jobj.put("trimValueDate", sensor.getTrimSetDate());
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
		} else if (action.equals("device_configure")) {
			if (args.length() >= 1) {
				String deviceId = args.getString(0);
				if (args.length() >= 2) {
					JSONObject options = args.getJSONObject(1);
					this.device_configure(deviceId, options, callbackContext);
				} else {
					callbackContext.error("options required");
				}
			} else {
				callbackContext.error("deviceId required");
			}
			return true;
		} else if (action.equals("getVersion")) {
			JSONObject msg = new JSONObject();
			msg.put("platform", "Android");
			msg.put("version", PLUGIN_VERSION);
			callbackContext.success(msg);
		}

		return false;
	}

	private void device_configure(String deviceId, JSONObject options, final CallbackContext callbackContext) throws JSONException {
		final Device device = _thermaLib.getDeviceWithAddress(deviceId);
		if (device == null) {
			callbackContext.error("Device not found");
		} else if (!device.isConnected()) {
			callbackContext.error("Device not connected");
		} else {
			if (options.has("measurementMilliseconds")) {
				device.setMeasurementInterval((options.getInt("measurementMilliseconds") + 1000 - 1) / 1000);	 // Round up
			}

			if (options.has("autoOffSeconds")) {
				device.setAutoOffInterval((options.getInt("autoOffSeconds") + 60 - 1) / 60);	// Round up
			}

			if (options.has("sensors")) {
				JSONArray sensorsConfig = options.getJSONArray("sensors");
				for(int i = 0 ; i < sensorsConfig.length() ; i++) {
					JSONObject sensorConfig = sensorsConfig.getJSONObject(i);
					if (!sensorConfig.has("index")) {
						callbackContext.error("Sensor.index required");
						return;
					}

					Sensor sensor = device.getSensor(sensorConfig.getInt("index"));		// 0 based
					if (sensor == null) {
						callbackContext.error("Sensor not found");
						return;
					}

					if (sensorConfig.has("enabled")) {
						sensor.setEnabled(sensorConfig.getBoolean("enabled"));
					}

					if (sensorConfig.has("lowAlarm")) {
						if (!sensorConfig.isNull("lowAlarm")) {
							sensor.setLowAlarm((float) sensorConfig.getDouble("lowAlarm"));
						} else {
							sensor.setLowAlarm(NO_VALUE);
						}
					}

					if (sensorConfig.has("highAlarm")) {
						if (!sensorConfig.isNull("highAlarm")) {
							sensor.setHighAlarm((float) sensorConfig.getDouble("highAlarm"));
						} else {
							sensor.setHighAlarm(NO_VALUE);
						}
					}

					if (sensorConfig.has("trimValue")) {
						sensor.setTrimValue((float)sensorConfig.getDouble("trimValue"));
					}
				}
			}

			queueUpdateBlock(device, new Runnable() {
				@Override
				public void run() {
					callbackContext.success(MakeJSONDevice(device));
				}
			});
		}
	}

	private void device_measure(String deviceId, CallbackContext callbackContext) throws JSONException {
		Device device = _thermaLib.getDeviceWithAddress(deviceId);
		if (device == null) {
			callbackContext.error("Device not found");
		} else if (!device.isConnected()) {
			callbackContext.error("Device not connected");
		} else {
			device.sendCommand(Device.CommandType.MEASURE, null);
			callbackContext.success();
		}
	}

	private void device_identify(String deviceId, CallbackContext callbackContext) throws JSONException {
		Device device = _thermaLib.getDeviceWithAddress(deviceId);
		if (device == null) {
			callbackContext.error("Device not found");
		} else if (!device.isConnected()) {
			callbackContext.error("Device not connected");
		} else {
			device.sendCommand(Device.CommandType.IDENTIFY, null);
			callbackContext.success();
		}
	}

	private void device_refresh(String deviceId, final CallbackContext callbackContext) throws JSONException {
		final Device device = _thermaLib.getDeviceWithAddress(deviceId);
		if (device == null) {
			callbackContext.error("Device not found");
		} else if (!device.isConnected()) {
			callbackContext.error("Device not connected");
		} else {
			device.refresh();

			queueUpdateBlock(device, new Runnable() {
				@Override
				public void run() {
					callbackContext.success(MakeJSONDevice(device));
				}
			});
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
		} else if (!device.isConnected()) {
			callbackContext.error("Device not connected");
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

		JSONArray replies = new JSONArray();
		JSONObject msg = new JSONObject();
		msg.put("command", "registerCallback");
		replies.put(msg);

		PluginResult result = new PluginResult(PluginResult.Status.OK, replies);
		result.setKeepCallback(true);

		callbackContext.sendPluginResult(result);
	}

	private void startScan(int timeoutMilliseconds, CallbackContext callbackContext) {
		if (_thermaLib.startScanForDevices((timeoutMilliseconds + 1000 - 1) / 1000) {
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

	private void deviceResult(Device device, String command) {
		if (_callbackContext != null) {
			JSONArray replies = new JSONArray();
			JSONObject msg = new JSONObject();
			try {
				msg.put("command", command);
				msg.put("device", MakeJSONDevice(device));
				replies.put(msg);
			} catch (JSONException je) {

			}

			PluginResult result = new PluginResult(PluginResult.Status.OK, replies);
			result.setKeepCallback(true);
			_callbackContext.sendPluginResult(result);
		}
	}

	@Override
	public void onNewDevice(Device device, long timestamp) {
		if (_callbackContext != null) {
			JSONArray replies = new JSONArray();
			JSONObject msg = new JSONObject();
			try {
				msg.put("command", "newDevice");
				msg.put("device", MakeJSONDevice(device));
				replies.put(msg);
			} catch (JSONException je) {

			}

			PluginResult result = new PluginResult(PluginResult.Status.OK, replies);
			result.setKeepCallback(true);
			_callbackContext.sendPluginResult(result);
		}
	}

	@Override
	public void onDeviceDeleted(String deviceAddress, int transportType) {
		if (_callbackContext != null) {
			JSONArray replies = new JSONArray();
			JSONObject msg = new JSONObject();
			try {
				msg.put("command", "deviceDeleted");
				msg.put("deviceId", deviceAddress);
				replies.put(msg);
			} catch (JSONException je) {

			}

			PluginResult result = new PluginResult(PluginResult.Status.OK, replies);
			result.setKeepCallback(true);
			_callbackContext.sendPluginResult(result);
		}
	}

	@Override
	public void onDeviceConnectionStateChanged(Device device, Device.ConnectionState connectionState, long timestamp) {
		deviceResult(device, "deviceUpdated");
	}

	@Override
	public void onBatteryLevelReceived(Device device, int batteryPercentage, long timestamp) {
		deviceResult(device, "deviceUpdated");
	}

	@Override
	public void onDeviceUpdated(Device device, long timestamp) {
		deviceResult(device, "deviceUpdated");

		ArrayList<Runnable> fns = _updateBlocks.get(device);
		if (fns != null) {
			for(Runnable r : fns) {
				r.run();
			}
			_updateBlocks.remove(device);
		}
	}

	@Override
	public void onRefreshComplete(Device device, long timestamp) {
		deviceResult(device, "deviceUpdated");
	}

	@Override
	public void onRssiUpdated(Device device, int rssi) {
		deviceResult(device, "deviceUpdated");
	}

	@Override
	public void onScanComplete(int errorCode, int deviceCount) {
		if (_callbackContext != null) {
			JSONArray replies = new JSONArray();
			JSONObject msg = new JSONObject();
			try {
				msg.put("command", "scanComplete");
				msg.put("errorCode", errorCode);

				JSONArray jDevices = new JSONArray();
				for (Device device : _thermaLib.getDeviceList()) {
					jDevices.put(MakeJSONDevice(device));
				}
				msg.put("devices", jDevices);
				replies.put(msg);
			} catch (JSONException je) {

			}

			PluginResult result = new PluginResult(PluginResult.Status.OK, replies);
			result.setKeepCallback(true);
			_callbackContext.sendPluginResult(result);
		}

	}

	@Override
	public void onMessage(Device device, String message, long timestamp) {
		if (_callbackContext != null) {
			JSONArray replies = new JSONArray();
			JSONObject msg = new JSONObject();
			try {
				msg.put("command", "message");
				msg.put("device", MakeJSONDevice(device));
				msg.put("message", message);
				replies.put(msg);
			} catch (JSONException je) {

			}

			PluginResult result = new PluginResult(PluginResult.Status.OK, replies);
			result.setKeepCallback(true);
			_callbackContext.sendPluginResult(result);
		}
	}

	@Override
	public void onDeviceReady(Device device, long timestamp) {
		deviceResult(device, "deviceUpdated");
	}

	@Override
	public void onDeviceNotificationReceived(Device device, int notificationType, byte[] payload, long timestamp) {
		if (_callbackContext != null) {
			JSONArray replies = new JSONArray();
			JSONObject msg = new JSONObject();
			try {
				msg.put("command", "deviceNotification");
				msg.put("device", MakeJSONDevice(device));
				msg.put("notificationType", Device.NotificationType.toString(notificationType));
				replies.put(msg);
			} catch (JSONException je) {

			}

			PluginResult result = new PluginResult(PluginResult.Status.OK, replies);
			result.setKeepCallback(true);
			_callbackContext.sendPluginResult(result);
		}
	}

	@Override
	public void onUnexpectedDeviceDisconnection(Device device, long timestamp) {
		deviceResult(device, "unexpectedDisconnect");
	}
}
