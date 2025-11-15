import Foundation

public struct WorkflowStep: Identifiable {
    public let id: String
    public let toolID: ToolID
    public let parameters: [String: Any]
    public var status: StepStatus
    public var result: ToolResult?
    public let dependencies: [String]
    
    public init(id: String = UUID().uuidString, toolID: ToolID, parameters: [String: Any], dependencies: [String] = []) {
        self.id = id
        self.toolID = toolID
        self.parameters = parameters
        self.status = .pending
        self.result = nil
        self.dependencies = dependencies
    }
}

public enum StepStatus {
    case pending
    case running
    case completed
    case failed
}

public class Orchestrator {
    private var workflow: [WorkflowStep] = []
    private let registry = ToolRegistry.shared
    
    public init() {}
    
    public func addStep(_ step: WorkflowStep) {
        workflow.append(step)
    }
    
    public func executeWorkflow(userConfirmation: @escaping (ToolID) -> Bool) async throws -> [ToolResult] {
        var results: [ToolResult] = []
        var completedSteps: Set<String> = []
        
        while completedSteps.count < workflow.count {
            for (index, step) in workflow.enumerated() {
                guard completedSteps.contains(step.id) == false else { continue }
                
                let dependenciesMet = step.dependencies.allSatisfy { completedSteps.contains($0) }
                guard dependenciesMet else { continue }
                
                workflow[index].status = .running
                
                if step.toolID.requiresUserConsent && !userConfirmation(step.toolID) {
                    throw OrchestratorError.userRejected(step.toolID)
                }
                
                do {
                    let result = try await registry.execute(toolID: step.toolID, parameters: step.parameters)
                    workflow[index].result = result
                    workflow[index].status = .completed
                    results.append(result)
                    completedSteps.insert(step.id)
                } catch {
                    workflow[index].status = .failed
                    throw OrchestratorError.stepFailed(step.toolID, error)
                }
            }
        }
        
        return results
    }
    
    public func getWorkflow() -> [WorkflowStep] {
        return workflow
    }
    
    public func clearWorkflow() {
        workflow.removeAll()
    }
}

public enum OrchestratorError: LocalizedError {
    case userRejected(ToolID)
    case stepFailed(ToolID, Error)
    case circularDependency
    
    public var errorDescription: String? {
        switch self {
        case .userRejected(let tool): return "User rejected \(tool.rawValue)"
        case .stepFailed(let tool, let error): return "\(tool.rawValue) failed: \(error.localizedDescription)"
        case .circularDependency: return "Circular dependency detected in workflow"
        }
    }
}
