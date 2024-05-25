import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel = VoiceAssistantViewModel()

    var body: some View {
        TabView {
            ContentView(viewModel: viewModel)
                .tabItem {
                    Text("Main")
                }

            SettingsView(viewModel: viewModel)
                .tabItem {
                    Text("Settings")
                }

            HistoryView(viewModel: viewModel)
                .tabItem {
                    Text("History")
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
