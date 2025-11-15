import Foundation
import Combine

public final class ToolEventBus {
    public static let shared = ToolEventBus()
    
    private let subject = PassthroughSubject<ToolEvent, Never>()
    public var publisher: AnyPublisher<ToolEvent, Never> { subject.eraseToAnyPublisher() }
    
    private init() {}
    
    public func publish(_ event: ToolEvent) {
        subject.send(event)
    }
}
