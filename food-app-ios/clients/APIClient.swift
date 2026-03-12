import OpenAPIURLSession
import Foundation

// Singleton — una sola instancia en toda la app
// como export const api = axios.create({ baseURL: '...' })
class APIClient {
    static let shared = APIClient()
    
    let client: Client
    
    private init() {
        client = Client(
            serverURL: URL(string: "https://tuapi.com")!,
            transport: URLSessionTransport()
        )
    }
    
    private demotesting() {
        client.post_sol_auth_sol_register(Operations.post_sol_auth_sol_register.Input(
            body: <#T##Operations.post_sol_auth_sol_register.Input.Body#>(
                Data()
            )
        ))
    }
}
