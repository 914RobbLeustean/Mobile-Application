//
//  NetworkMonitor.swift
//  HabitFlow
//
//  Monitors network connectivity status using NWPathMonitor
//

import Foundation
import Network
import Combine

/// Monitors network connectivity and publishes connection status changes
@MainActor
class NetworkMonitor: ObservableObject {
    /// Published property indicating whether device is connected to network
    @Published var isConnected: Bool = true

    /// Published property indicating connection type
    @Published var connectionType: ConnectionType = .unknown

    /// Network path monitor
    private let monitor = NWPathMonitor()

    /// Queue for network monitor callbacks
    private let queue = DispatchQueue(label: "NetworkMonitor")

    /// Connection types
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }

    init() {
        startMonitoring()
    }

    /// Start monitoring network connectivity
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                guard let self = self else { return }

                // Update connection status
                let wasConnected = self.isConnected
                self.isConnected = (path.status == .satisfied)

                // Update connection type
                if path.usesInterfaceType(.wifi) {
                    self.connectionType = .wifi
                } else if path.usesInterfaceType(.cellular) {
                    self.connectionType = .cellular
                } else if path.usesInterfaceType(.wiredEthernet) {
                    self.connectionType = .ethernet
                } else {
                    self.connectionType = .unknown
                }

                // Log connection status changes
                if wasConnected != self.isConnected {
                    if self.isConnected {
                        print("🌐 Network connected (\(self.connectionType))")
                    } else {
                        print("📴 Network disconnected")
                    }
                }
            }
        }

        monitor.start(queue: queue)
        print("📡 Network monitoring started")
    }

    /// Stop monitoring network connectivity
    nonisolated func stopMonitoring() {
        monitor.cancel()
        print("📡 Network monitoring stopped")
    }

    deinit {
        stopMonitoring()
    }

    /// Force check current connection status
    func checkConnection() -> Bool {
        return isConnected
    }
}
