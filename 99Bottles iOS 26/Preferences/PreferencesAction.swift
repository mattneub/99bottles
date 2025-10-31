/// Messages sent from presenter to processor.
enum PreferencesAction: Equatable {
    case cancel
    case done(Int, Bool)
    case initialData
}
