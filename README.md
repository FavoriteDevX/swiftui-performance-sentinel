# 🛡️ SwiftUI Performance Sentinel

> A high-performance, lightweight telemetry plugin for debugging SwiftUI views invalidation loops and memory footprints in real-time across iOS, iPadOS, watchOS, and visionOS.

## 🚀 Architectural Advantages
*   **Zero Repaint Overhead:** Uses lightweight, un-intrusive `DynamicProperty` wrappers to track drawing behaviors without triggering perpetual render feedback loops.
*   **On-Canvas Metrics HUD:** Injects a micro-telemetry HUD display on top of your application layout structure (exclusively inside `#DEBUG` compilation gates).
*   **Posix Thread Memory Polling:** Hooks straight into `mach_task_self_` to track the real runtime footprint size in Megabytes.

## Usage Matrix

```swift
import SwiftUI
import PerformanceSentinel

@main
struct MyApp: App {
    init() {
        // Ignite active heap memory auditing
        PerformanceSentinel.shared.startMonitoring(interval: 3.0)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .trackRenders(id: "RootContentView")
        }
    }
}
```
