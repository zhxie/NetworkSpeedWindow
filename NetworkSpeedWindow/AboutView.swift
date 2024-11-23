import SwiftUI

struct AboutView: View {
    var body: some View {
        NavigationView {
            Form {
                Section(LocalizedStringKey("about")) {
                    HStack {
                        Text(LocalizedStringKey("version"))
                        
                        Spacer()
                        
                        Text(version)
                    }
                    SafariButton(title: LocalizedStringKey("source_code_repository"), url: URL(string: "https://github.com/zhxie/NetworkSpeedWindow")!)
                    SafariButton(title: LocalizedStringKey("privacy_policy"), url: URL(string: "https://github.com/zhxie/NetworkSpeedWindow/wiki/Privacy-Policy")!)
                }
                
                Section(LocalizedStringKey("acknowledgements")) {
                    SafariButton(title: "Pipify for SwiftUI", url: URL(string: "https://github.com/getsidetrack/swiftui-pipify")!)
                }
            }
            .navigationTitle(LocalizedStringKey("network_speed_window"))
        }
    }
    
    var version: String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        
        return String(format: "%@ (%@)", version, build)
    }
}

#Preview {
    AboutView()
}
