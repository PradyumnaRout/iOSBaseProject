//
//  NetworkReachabilityManager.swift
//  FreshMorning
//
//  Created by hb on 28/10/26.
//

import Foundation
import Network
import Observation

/// Represents the type of Network interface currently in use.
enum NetworkConnectionType: Equatable {
    case wifi
    case cellular
    case wiredEthernet
    case other
    case none
}


/// Represents the current network path status.
enum NetworkStatus: Equatable {
    case unknown
    case connected
    case disconnected
    case requiresConnection
}



/// Monitor Network path changes and exposes observable states to SwiftUI.
///
/// Create one instance at the app level and inject it into the environment.
/// This class observes network availability; it does not verify that a
/// particular server or API endpoint is reachable.
@MainActor
@Observable
final class NetworkReachabilityManager {
    
    // MARK: - Observable State
    private(set) var status: NetworkStatus = .unknown
    
    private(set) var connectionType: NetworkConnectionType = .none
    
    private(set) var isExpensive = false
    
    private(set) var isConstrained = false
    
    /// Indicates that a network path is currently available
    var isConnected: Bool {
        print("Is network Connected:: \(status == .connected)")
        return status == .connected
    }
    
    // MARK: - Private Properties
    
    @ObservationIgnored
    private var monitor: NWPathMonitor?
    
    @ObservationIgnored
    private let monitorQueue = DispatchQueue(label: "com.app.network-reachability")
    
    @ObservationIgnored
    private var isMonitoring = false
    
    // MARK: - Lifecycle
    
    init() {}
    
    /// Starts monitoring network manager
    ///
    /// Calling this method multiple times does not create duplicate monitors
    func start() {
        guard !isMonitoring else { return }
        
        let newMonitor = NWPathMonitor()
        monitor = newMonitor
        isMonitoring = true
        
        newMonitor.pathUpdateHandler = { [weak self] path in
            // NWPathMonitor delivers updates on its monitoring queue.
            // Move observable state change to the main actor
            // print("NWPathMonitor status: \(path.status)")
            // print("Wi-Fi interface: \(path.usesInterfaceType(.wifi))")
            // print("Cellular interface: \(path.usesInterfaceType(.cellular))")
            Task { @MainActor [weak self] in
                self?.update(with: path)
            }
        }
        
        newMonitor.start(queue: monitorQueue)
    }
    
    
    /// Stops monitoring and releases the current Monitor
    ///
    /// A subsequent call to start() creates a fresh monitor
    func stop() {
        guard isMonitoring else { return }
        
        monitor?.cancel()
        monitor = nil
        isMonitoring = false
        
        // Do not claim that the device is disconnected just because monitoring was stopped
        status = .unknown
        connectionType = .none
        isExpensive = false
        isConstrained = false
    }
    
    
    // MARK: - Private state updates
    private func update(with path: NWPath) {
        switch path.status {
        case .satisfied:
            status = .connected
        case .unsatisfied:
            status = .disconnected
        case .requiresConnection:
            status = .requiresConnection
            
        @unknown default:
            status = .unknown
        }
        
        // An unavailable path may use more than one interface
        // Prefer Wi-Fi, then cellular, then wired Ethernet.
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .wiredEthernet
        } else if path.status == .satisfied {
            connectionType = .other
        } else {
            connectionType = .none
        }
        
        isExpensive = path.isExpensive
        isConstrained = path.isConstrained
        print("Updated observable status: \(status)")
    }
    
}
