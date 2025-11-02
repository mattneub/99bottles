/// Messages sent from presenter to processor.
enum PreferencesAction: Equatable {
    case cancel // user wants to dismiss without saving
    case done(Int, Bool) // use wants to dismiss with saving
    case initialData // ready for initial data
}
