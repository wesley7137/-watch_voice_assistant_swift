import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: VoiceAssistantViewModel

    var body: some View {
        List {
            Text(viewModel.message)
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView(viewModel: VoiceAssistantViewModel())
    }
}
