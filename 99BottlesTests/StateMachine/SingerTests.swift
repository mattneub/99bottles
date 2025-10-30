@testable import Bottles
import Testing
import Foundation

struct SingerTests {
    let subject = Singer(bottleNumber: 42, interactive: true, verse: [.init(sound: "howdy"), .init(sound: "there")])
    let bundle = MockBundle()

    init() {
        services.playerType = MockPlayer.self
        services.bundle = bundle
    }

    @Test("sing: pops first phrase, gets url, creates player, tells it to play")
    func sing() async throws {
        bundle.urlToReturn = URL(string: "file://yoho")
        try await subject.sing()
        #expect(subject.verse == [.init(sound: "there")])
        #expect(bundle.methodsCalled == ["url(forResource:withExtension:subdirectory:)"])
        #expect(bundle.resource == "howdy")
        #expect(bundle.ext == "aif")
        #expect(bundle.subdirectory == "Sounds")
        let player = try #require(subject.player as? MockPlayer)
        #expect(player.soundFile == URL(string: "file://yoho"))
        #expect(player.methodsCalled == ["playAsync()"])
    }

    @Test("nextState: is another Singer")
    func nextState() throws {
        let result = subject.nextState()
        let singer = try #require(result as? Singer)
        #expect(singer.verse == [.init(sound: "howdy"), .init(sound: "there")]) // copies current verse
        #expect(singer.bottleNumber == 42)
        #expect(singer.interactive == true)
    }
}
