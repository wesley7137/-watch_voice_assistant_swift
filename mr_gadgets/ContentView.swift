import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: VoiceAssistantViewModel
   
    var body: some View {
        VStack {
            Text(viewModel.transcription)
                .padding()

            Button(action: {
                viewModel.startListening()
            }) {
                Text("Start Listening")
            }
            .padding()

            Button(action: {
                viewModel.stopListening()
            }) {
                Text("Stop Listening")
            }
            .padding()

            if let error = viewModel.errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: VoiceAssistantViewModel())
    }
}


