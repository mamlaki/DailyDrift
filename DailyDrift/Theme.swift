import SwiftUI

protocol Theme {
    var backgroundColor: Color { get }
    var primaryColor: Color { get }
}

struct DefaultTheme: Theme {
    var colorScheme: ColorScheme
    
    var backgroundColor: Color {
        switch colorScheme {
        case .dark:
            return Color.black
        default:
            return Color.white
        }
    }
    
    var primaryColor: Color {
        switch colorScheme {
        case .dark:
            return Color.white
        default:
            return Color.black
        }
    }
}

struct LightTheme: Theme {
    var backgroundColor = Color.white
    var primaryColor = Color.black
}

struct DarkTheme: Theme {
    var backgroundColor = Color.black
    var primaryColor = Color.white
}

struct SepiaTheme: Theme {
    var backgroundColor = Color(red: 245/255, green: 223/255, blue: 191/255)
    var primaryColor = Color(red: 172/255, green: 146/255, blue: 120/255)
}

struct ThemeEnvironmentKey: EnvironmentKey {
    static let defaultValue: Theme = LightTheme()
}

extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}

struct ThemeModifier: ViewModifier {
    @Environment(\.theme) var theme

    func body(content: Content) -> some View {
        content.foregroundStyle(theme.primaryColor)
    }
}

struct ThemedListModifier: ViewModifier {
    var theme: Theme
    
    func body(content: Content) -> some View {
        content
            .background(theme.backgroundColor.ignoresSafeArea(.all))
            .scrollContentBackground(.hidden)
            .foregroundStyle(theme.primaryColor)
    }
}

extension List {
    func themed(theme: Theme) -> some View {
        self.modifier(ThemedListModifier(theme: theme))
    }
}

struct ThemedFormModifier: ViewModifier {
    var theme: Theme
    
    func body(content: Content) -> some View {
        content
            .background(theme.backgroundColor.ignoresSafeArea(.all))
            .scrollContentBackground(.hidden)
            .foregroundStyle(theme.primaryColor)
    }
}

extension Form {
    func themed(theme: Theme) -> some View {
        self.modifier(ThemedFormModifier(theme: theme))
    }
}
