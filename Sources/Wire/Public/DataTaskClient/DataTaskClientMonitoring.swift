import Foundation

/// An object that gets notified of the activity of `DataTaskClient`.
public protocol DataTaskClientMonitoring: AnyObject {
    func client(_ client: DataTaskClient, didExecute request: RequestBuildable)
    func client(_ client: DataTaskClient, didSucceedWith data: Data, requestBuilder: RequestBuildable)
}

public extension DataTaskClientMonitoring {
    func client(_ client: DataTaskClient, didExecute request: RequestBuildable) {}
    func client(_ client: DataTaskClient, didSucceedWith data: Data, requestBuilder: RequestBuildable) {}
}
