import UIKit
import AVFoundation

final class Services {
    var audioPlayerType: AudioPlayerType.Type = AVAudioPlayer.self
    var bundle: BundleType = Bundle.main
    var persistence: PersistenceType = Persistence()
    var playerType: PlayerType.Type = Player.self
    var stateMachineFactory: StateMachineFactoryType = StateMachineFactory()
    var userDefaults: UserDefaultsType = UserDefaults.standard
    var viewType: UIView.Type = UIView.self
}
