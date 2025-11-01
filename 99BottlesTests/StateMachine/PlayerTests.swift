@testable import Bottles
import UniformTypeIdentifiers
import Testing
import Foundation
import WaitWhile
import AVFoundation

struct PlayerTests {
    init() {
        services.audioPlayerType = MockAudioPlayer.self
    }

    @Test("initialize: initializes audio player correctly, tells it to prepare, sets its delegate")
    func initialize() throws {
        let subject = try Player(soundFile: URL(string: "file://yoho")!)
        let audioPlayer = try #require(subject.audioPlayer as? MockAudioPlayer)
        #expect(audioPlayer.url == URL(string: "file://yoho")!)
        #expect(audioPlayer.hint == UTType.aiff.identifier)
        #expect(audioPlayer.methodsCalled == ["prepareToPlay()"])
        #expect(audioPlayer.delegate === subject)
    }

    @Test("playAsync: calls audio player play; didFinish: resumes continuation")
    func play() async throws {
        let subject = try Player(soundFile: URL(string: "file://yoho")!)
        let audioPlayer = try #require(subject.audioPlayer as? MockAudioPlayer)
        Task {
            await subject.playAsync()
        }
        await #while(subject.continuation == nil)
        #expect(audioPlayer.methodsCalled.last == "play()")
        #expect(subject.continuation != nil)
        subject.audioPlayerDidFinishPlaying(AVAudioPlayer(), successfully: true)
        #expect(subject.continuation == nil)
    }

    @Test("stop: calls audio player stop; resumes continuation")
    func stop() async throws {
        let subject = try Player(soundFile: URL(string: "file://yoho")!)
        let audioPlayer = try #require(subject.audioPlayer as? MockAudioPlayer)
        Task {
            await subject.playAsync()
        }
        await #while(subject.continuation == nil)
        #expect(subject.continuation != nil)
        subject.stop()
        #expect(audioPlayer.methodsCalled.last == "stop()")
        #expect(subject.continuation == nil)
    }
}
