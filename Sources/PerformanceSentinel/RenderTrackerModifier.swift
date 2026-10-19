import SwiftUI
import Combine

@propertyWrapper
public struct RenderCounter: DynamicProperty {
    @State private var count = 0
    
    public init() {}
    
    public var wrappedValue: Int {
        // Mutate state during body evaluation to capture render loop boundaries safely
        DispatchQueue.main.async {
            count += 1
        }
        return count
    }
}

public struct RenderTrackerModifier: ViewModifier {
    let viewName: String
    @State private var totalRenders = 0
    @State private var lastRenderTime = Date()
    
    public init(viewName: String) {
        self.viewName = viewName
    }
    
    public func body(content: Content) -> some View {
        let _ = sendTelemetry()
        content
            .overlay(
                PerformanceOverlayView(viewName: viewName, renderCount: totalRenders)
            )
    }
    
    private func sendTelemetry() {
        DispatchQueue.main.async {
            self.totalRenders += 1
            let interval = Date().timeIntervalSince(self.lastRenderTime)
            self.lastRenderTime = Date()
            
            if interval < 0.016 { // Frame rate drop boundary (< 60 FPS update window)
                print("⚠️ [PerformanceSentinel] Rapid view re-render detected on target '\(viewName)': Interval was \(String(format: "%.4f", interval))s. Optimize your @State/@ObservedObject bindings.")
            }
        }
    }
}

struct PerformanceOverlayView: View {
    let viewName: String
    let renderCount: Int
    
    var body: some View {
        #if DEBUG
        GeometryReader { geometry in
            VStack {
                HStack {
                    Spacer()
                    Text("\(viewName): \(renderCount)x")
                        .font(.system(size: 9, weight: .bold, design: .monospace))
                        .padding(4)
                        .background(renderCount > 10 ? Color.red.opacity(0.8) : Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(4)
                        .position(x: geometry.size.width - 45, y: 15)
                }
            }
        }
        .allowsHitTesting(false) // Pass touches directly through to underlying views
        #else
        EmptyView()
        #endif
    }
}

public extension View {
    /// Tracks rendering invalidations and highlights execution spikes visually on the canvas interface.
    func trackRenders(id viewName: String) -> some View {
        self.modifier(RenderTrackerModifier(viewName: viewName))
    }
}
