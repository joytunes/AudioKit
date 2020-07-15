// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if os(macOS)
public typealias DeviceID = AudioDeviceID
#else
public typealias DeviceID = String
#endif

/// Wrapper for audio device selection
public struct AKDevice: Equatable {
    /// The human-readable name for the device.
    var name: String
    var nInputChannels: Int?
    var nOutputChannels: Int?

    /// The device identifier.
    fileprivate(set) var deviceID: DeviceID

    /// Initialize the device
    ///
    /// - Parameters:
    ///   - name: The human-readable name for the device.
    ///   - deviceID: The device identifier.
    ///
    public init(name: String, deviceID: DeviceID, dataSource: String = "") {
        self.name = name
        self.deviceID = deviceID
        #if !os(macOS)
        if dataSource != "" {
            self.deviceID = "\(deviceID) \(dataSource)"
        }
        #endif
    }

    #if os(macOS)
    public init(ezAudioDevice: EZAudioDevice) {
        self.init(name: ezAudioDevice.name, deviceID: ezAudioDevice.deviceID)
        nInputChannels = ezAudioDevice.inputChannelCount
        nOutputChannels = ezAudioDevice.outputChannelCount
    }

    public init(deviceID: DeviceID) {
        self.init(name: AudioDeviceName(deviceID), deviceID: deviceID)
        nInputChannels = AudioDeviceInputChannels(deviceID)
        nOutputChannels = AudioDeviceOutputChannels(deviceID)
    }
    #endif

    #if !os(macOS)
    /// Initialize the device
    ///
    /// - Parameters:
    ///   - portDescription: A port description object that describes a single
    /// input or output port associated with an audio route.
    ///
    public init(portDescription: AVAudioSessionPortDescription) {
        let portData = [portDescription.uid, portDescription.selectedDataSource?.dataSourceName]
        let deviceID = portData.compactMap { $0 }.joined(separator: " ")
        self.init(name: portDescription.portName, deviceID: deviceID)
    }

    /// Return a port description matching the devices name.
    var portDescription: AVAudioSessionPortDescription? {
        return AVAudioSession.sharedInstance().availableInputs?.filter { $0.portName == name }.first
    }

    /// Return a data source matching the devices deviceID.
    var dataSource: AVAudioSessionDataSourceDescription? {
        let dataSources = portDescription?.dataSources ?? []
        return dataSources.filter { deviceID.contains($0.dataSourceName) }.first
    }
    #endif

}

extension AKDevice: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "<Device: \(name) (\(deviceID))>"
    }
}
