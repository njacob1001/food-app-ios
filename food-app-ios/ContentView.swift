import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        MenuView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Dish.self, inMemory: true)
}
