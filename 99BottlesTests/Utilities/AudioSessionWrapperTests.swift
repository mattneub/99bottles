@testable import Bottles
import Testing
import AVFoundation

struct AudioSessionWrapperTests {
    @Test("configure: calls setCategory")
    func configure() {
        let subject = AudioSessionWrapper()
        let session = MockAudioSession()
        subject.audioSessionProvider = { session }
        subject.configure()
        #expect(session.methodsCalled == ["setCategory(_:mode:options:)"])
        #expect(session.category == .playback)
        #expect(session.mode == .default)
        #expect(session.categoryOptions == [])
    }

    @Test("activate: calls setActive")
    func activate() {
        let subject = AudioSessionWrapper()
        let session = MockAudioSession()
        subject.audioSessionProvider = { session }
        subject.activate()
        #expect(session.methodsCalled == ["setActive(_:options:)"])
        #expect(session.active == true)
        #expect(session.activeOptions == [])
    }
}
