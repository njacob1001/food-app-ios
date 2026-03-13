import OpenAPIURLSession
import Foundation
import SwiftUI

class APIClient {
    static let shared = APIClient()

    let client: Client

    private init() {
        client = Client(
            serverURL: URL(string: "https://tuapi.com")!,
            transport: URLSessionTransport()
        )
    }
}


struct APIClientKey: EnvironmentKey {
    static let defaultValue: any APIProtocol = Client(
        serverURL: URL(string: "https://tuapi.com")!,
        transport: URLSessionTransport()
    )
}

extension EnvironmentValues {
    var apiClient: any APIProtocol {
        get { self[APIClientKey.self] }
        set { self[APIClientKey.self] = newValue }
    }
}
