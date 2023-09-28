import SwiftUI

protocol Theme {
    var backgroundColor: Color { get }
    var primaryColor: Color { get }
    var secondaryColor: Color { get }
    var tertiaryColor: Color { get }
    var borderColor: Color { get }
    var highlightColor: Color { get }
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
    
    var secondaryColor: Color {
        switch colorScheme {
        case .dark:
            return Color.gray
        default:
            return Color.gray
        }
    }
    
    var tertiaryColor: Color {
        switch colorScheme {
        case .dark:
            return Color.blue
        default:
            return Color.blue
        }
    }
    
    var borderColor: Color {
        switch colorScheme {
        case .dark:
            return Color.gray.opacity(0.2)
        default:
            return Color.gray.opacity(0.2)
        }
    }
    
    var highlightColor: Color {
        switch colorScheme {
        case .dark:
            return Color.blue.opacity(0.2)
        default:
            return Color.blue.opacity(0.2)
        }
    }
    
}

struct LightTheme: Theme {
    var backgroundColor = Color.white
    var primaryColor = Color.black
    var secondaryColor = Color.gray
    var tertiaryColor = Color.blue
    var borderColor = Color.gray.opacity(0.2)
    var highlightColor = Color.blue.opacity(0.2)
}

struct DarkTheme: Theme {
    var backgroundColor = Color.black
    var primaryColor = Color.white
    var secondaryColor = Color.gray
    var tertiaryColor = Color.blue
    var borderColor = Color.gray.opacity(0.2)
    var highlightColor = Color.blue.opacity(0.2)
}

struct SepiaTheme: Theme {
    var backgroundColor = Color(red: 245/255, green: 223/255, blue: 191/255)
    var primaryColor = Color(red: 105/255, green: 79/255, blue: 53/255)
    var secondaryColor = Color(red: 153/255, green: 127/255, blue: 101/255)
    var tertiaryColor = Color(red: 172/255, green: 146/255, blue: 120/255)
    var borderColor = Color(red: 153/255, green: 127/255, blue: 101/255).opacity(0.4)
    var highlightColor = Color(red: 105/255, green: 79/255, blue: 53/255).opacity(0.3)
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
        content
            .background(theme.backgroundColor)
            .foregroundStyle(theme.primaryColor)
            .accentColor(theme.tertiaryColor)
    }
}

struct ThemedListModifier: ViewModifier {
    var theme: Theme
    var isLight: Bool
    
    func body(content: Content) -> some View {
        content
            .background(theme.backgroundColor.ignoresSafeArea(.all))
            .scrollContentBackground(isLight ? .visible : .hidden)
            .foregroundStyle(theme.primaryColor)
    }
}

extension List {
    func themed(theme: Theme, isLight: Bool) -> some View {
        self.modifier(ThemedListModifier(theme: theme, isLight: isLight))
    }
}

struct ThemedFormModifier: ViewModifier {
    var theme: Theme
    var isLight: Bool
    
    func body(content: Content) -> some View {
        content
            .background(theme.backgroundColor.ignoresSafeArea(.all))
            .scrollContentBackground(isLight ? .visible : .hidden)
            .foregroundStyle(theme.primaryColor)
    }
}

extension Form {
    func themed(theme: Theme, isLight: Bool) -> some View {
        self.modifier(ThemedFormModifier(theme: theme, isLight: isLight))
    }
}
