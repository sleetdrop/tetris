import SwiftUI

@main
struct TetrisApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 600, minHeight: 800)
        }
        .windowResizability(.contentSize)
    }
}