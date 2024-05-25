import ArgumentParser
import Foundation

struct VoiceAssistant: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A Swift command-line tool to handle voice assistant tasks."
    )

    func run() throws {
        print("Hello, Voice Assistant!")
    }
}

VoiceAssistant.main()
