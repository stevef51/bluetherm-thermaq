package BlueThermThermaQ;

import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import uk.co.etiltd.thermalib.Device;
import uk.co.etiltd.thermalib.ThermaLib;

/**
 * This class echoes a string called from JavaScript.
 */
public class BlueThermThermaQ extends CordovaPlugin implements ThermaLib.ClientCallbacks {

    private ThermaLib _thermaLib;
    private Object _registerHandle;
    private CallbackContext _scanCC;

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
        jobj.put("name", device.getDeviceName());
        jobj.put("serialnumber", device.getSerialNumber());
        jobj.put("connectionstate", device.getConnectionState().toString());
        jobj.put("batterylevel", device.getBatteryLevel());
        jobj.put("modelnumber", device.getModelNumber());
        jobj.put("manufacturername", device.getManufacturerName());
        jobj.put("rssi", device.getRssi());
        jobj.put("softwarerevision", device.getSoftwareRevision());
        jobj.put("hardwarerevision", device.getHardwareRevision());
        jobj.put("firmwarerevision", device.getFirmwareRevision());
        return jobj;
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("startScan")) {
            int timeout = 10000;
            if (args.length() > 1) {
                timeout = args.getInt(0);
            }
            this.startScan(timeout, callbackContext);
            return true;
        }
        return false;
    }

    private void startScan(int timeout, CallbackContext callbackContext) throws JSONException {
        if (_thermaLib.startScanForDevices(timeout)) {
            _scanCC = callbackContext;

            JSONObject msg = new JSONObject();
            msg.put("state", "scanning");

            PluginResult result = new PluginResult(PluginResult.Status.OK, msg);
            result.setKeepCallback(true);

            callbackContext.sendPluginResult(result);
        } else {
            _scanCC = null;

            callbackContext.error("startScan failed");
        }
    }

    @Override
    public void onNewDevice(Device device, long l) {
        if (_scanCC != null) {
            JSONObject msg = new JSONObject();
            msg.put("state", "newdevice");
            msg.put("device", MakeJSONDevice(device));

            PluginResult result = new PluginResult(PluginResult.Status.OK, msg);
            result.setKeepCallback(true);
            _scanCC.sendPluginResult(result);
        }
    }

    @Override
    public void onDeviceDeleted(String s, int i) {

    }

    @Override
    public void onDeviceConnectionStateChanged(Device device, Device.ConnectionState connectionState, long l) {

    }

    @Override
    public void onBatteryLevelReceived(Device device, int i, long l) {

    }

    @Override
    public void onDeviceUpdated(Device device, long l) {

    }

    @Override
    public void onRefreshComplete(Device device, long l) {

    }

    @Override
    public void onRssiUpdated(Device device, int i) {

    }

    @Override
    public void onScanComplete(int i, int i1) {

    }

    @Override
    public void onMessage(Device device, String s, long l) {

    }

    @Override
    public void onDeviceReady(Device device, long l) {

    }

    @Override
    public void onDeviceNotificationReceived(Device device, int i, byte[] bytes, long l) {

    }

    @Override
    public void onUnexpectedDeviceDisconnection(Device device, long l) {

    }
}
