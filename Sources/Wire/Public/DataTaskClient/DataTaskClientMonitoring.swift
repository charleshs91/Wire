import Foundation

public protocol DataTaskClientMonitoring: AnyObject {
    func client(_ client: DataTaskClient, didExecute request: RequestBuildable)
    func client(_ client: DataTaskClient, didReceive data: Data, requestBuilder: RequestBuildable)
}

public extension DataTaskClientMonitoring {
    func client(_ client: DataTaskClient, didExecute request: RequestBuildable) {}
    func client(_ client: DataTaskClient, didReceive data: Data, requestBuilder: RequestBuildable) {}
}
