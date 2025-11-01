@testable import Bottles
import Testing
import Foundation

struct SingerTests {
    let bundle = MockBundle()

    init() {
        services.playerType = MockPlayer.self
        services.bundle = bundle
    }

    @Test("sing: pops first phrase, sets pauseAfterwards, gets url, creates player, tells it to play")
    func sing() async throws {
        let subject = Singer(bottleNumber: 42, interactive: true, verse: [
            .init(sound: "howdy", pauseAfterwards: true),
            .init(sound: "there"),
        ])
        bundle.urlToReturn = URL(string: "file://yoho")
        #expect(subject.pauseAfterwards == false)
        try await subject.sing()
        #expect(subject.verse == [.init(sound: "there")])
        #expect(subject.pauseAfterwards == true)
        #expect(bundle.methodsCalled == ["url(forResource:withExtension:subdirectory:)"])
        #expect(bundle.resource == "howdy")
        #expect(bundle.ext == "aif")
        #expect(bundle.subdirectory == "Sounds")
        let player = try #require(subject.player as? MockPlayer)
        #expect(player.soundFile == URL(string: "file://yoho"))
        #expect(player.methodsCalled == ["playAsync()"])
    }

    @Test("stop: calls player stop")
    func stop() throws {
        let subject = Singer(bottleNumber: 42, interactive: true, verse: [
            .init(sound: "howdy", pauseAfterwards: true),
            .init(sound: "there"),
        ])
        let player = try MockPlayer(soundFile: URL(string: "file://yoho")!)
        subject.player = player
        subject.stop()
        #expect(player.methodsCalled == ["stop()"])
    }

    @Test("nextState: is another Singer")
    func nextState() throws {
        let subject = Singer(bottleNumber: 42, interactive: true, verse: [
            .init(sound: "howdy"),
            .init(sound: "there"),
        ])
        let result = subject.nextState()
        let singer = try #require(result as? Singer)
        #expect(singer.verse == [.init(sound: "howdy"), .init(sound: "there")]) // copies current verse
        #expect(singer.bottleNumber == 42)
        #expect(singer.interactive == true)
    }

    @Test("nextState: is WaitingForTap if `pauseAfterwards` is true")
    func nextStatePause() throws {
        let subject = Singer(bottleNumber: 42, interactive: true, verse: [
            .init(sound: "howdy"),
            .init(sound: "there"),
        ])
        subject.pauseAfterwards = true // *
        let result = subject.nextState()
        let waiting = try #require(result as? WaitingForTap)
        #expect(waiting.verse == [.init(sound: "howdy"), .init(sound: "there")]) // copies current verse
        #expect(waiting.bottleNumber == 42)
        #expect(waiting.interactive == true)
    }
}
