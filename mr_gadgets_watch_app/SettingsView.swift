import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: VoiceAssistantViewModel

    @State private var wakeWord: String = ""

    var body: some View {
        VStack {
            TextField("Wake Word", text: $wakeWord)
                .padding()
            Button("Update Wake Word") {
                viewModel.updateWakeWord(wakeWord)
            }
            .padding()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
