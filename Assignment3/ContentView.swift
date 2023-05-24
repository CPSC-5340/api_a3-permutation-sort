import SwiftUI
import WebKit

struct ContentView: View {
    @State private var hackerNewsPosts: [HackerNewsPost] = []

    var body: some View {
        NavigationView {
            List(hackerNewsPosts) { post in
                NavigationLink(destination: WebView(url: URL(string: post.url)!)) {
                    VStack(alignment: .leading) {
                        Text(post.title)
                            .font(.headline)
                        Text(post.url)
                            .font(.subheadline)
                    }
                }
            }
            .onAppear {
                fetchHackerNewsPosts()
            }
            .padding()
            .navigationTitle("Hacker News")
            .background(Color.orange) // Set the background color of NavigationView
        }
    }

    private func fetchHackerNewsPosts() {
        hackerNewsPosts = [
            HackerNewsPost(title: "Sample Post 1", url: "https://example.com/1"),
            HackerNewsPost(title: "Sample Post 2", url: "https://example.com/2"),
            //...
        ]
    }
}

struct HackerNewsPost: Identifiable {
    var id = UUID()
    var title: String
    var url: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView  {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Nothing to do here
    }
}
