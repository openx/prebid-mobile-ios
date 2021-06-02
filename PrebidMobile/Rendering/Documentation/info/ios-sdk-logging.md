Logging
=======

If you have `PrebidRenderingConfig.debugLogFileEnabled` set to `true` and `PrebidRenderingConfig.logLevel` set to `Info`, `Warn`, or `Error`, you will be able to log messages from the SDK.

How to get logs
---------------

You can get logs from your test device if it is connected to Xcode and your device has the test app on it. Note that logs are in plain text and are not encrypted, so you know what you are sending to Prebid server. The log file is in the Documents directory of the container.

1.  In Xcode, go to **Window \> Devices and Simulators**.
2.  Navigate to your test device or simulator.
3.  Click to select your app and then click the gear icon. In the menu
    that appears, select **Download Container**. This allows you to
    download the whole container for the app as an .xcappdata package.
4.  Click **Save** to save the package to your local drive.
5.  On the .xcappdata file, Ctrl+click and select **Show package contents** to navigate to the following file:

    App Data \> Documents \> OXALog.txt
    
    This is the log file of the SDK. You can now view, save, or share the file as needed.

The SDK creates this file and logs events as long as
`debugLogFileEnabled = true`. See [Request parameters](ios-sdk-parameters.md) for details.