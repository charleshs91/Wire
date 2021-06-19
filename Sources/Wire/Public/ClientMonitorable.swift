import Foundation

/// An object that gets notified of the activity of `DataTaskClient`.
public protocol ClientMonitorable: AnyObject {
    func client(_ client: DataTaskClient, didExecute request: RequestBuildable)
    func client(_ client: DataTaskClient, didSucceedWith data: Data, requestBuilder: RequestBuildable)
}

public extension ClientMonitorable {
    func client(_ client: DataTaskClient, didExecute request: RequestBuildable) {}
    func client(_ client: DataTaskClient, didSucceedWith data: Data, requestBuilder: RequestBuildable) {}
}
