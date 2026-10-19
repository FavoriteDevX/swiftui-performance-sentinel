import Foundation
import OSLog

public final class PerformanceSentinel {
    public static let shared = PerformanceSentinel()
    private let logger = Logger(subsystem: "com.apple.developer.sentinel", category: "MemoryTelemetry")
    private var timer: Timer?
    
    private init() {}
    
    /// Activates low-level heap memory polling sequences to detect allocation leaks inside simulated simulator grids.
    public func startMonitoring(interval: TimeInterval = 2.0) {
        #if DEBUG
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.reportMemoryUsage()
        }
        #endif
    }
    
    public func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func reportMemoryUsage() {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size / MemoryLayout<integer_t>.size)
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            let memoryInMB = Double(taskInfo.resident_size) / 1024.0 / 1024.0
            logger.info("📊 Persistent memory resident heap allocation size: \(String(format: "%.2f", memoryInMB)) MB")
        } else {
            logger.error("❌ Failed retrieving POSIX task kernel footprint diagnostics registry keys.")
        }
    }
}
