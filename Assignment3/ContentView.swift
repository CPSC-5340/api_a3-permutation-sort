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
            .background(Color.orange)
        }
    }

    private func fetchHackerNewsPosts() {
        guard let url = URL(string: "https://hacker-news.firebaseio.com/v0/topstories.json") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching Hacker News posts: \(error)")
                return
            }
            
            if let data = data {
                do {
                    let postIDs = try JSONDecoder().decode([Int].self, from: data)
                    
                    let postIDsSlice = postIDs.prefix(10)
                    let group = DispatchGroup()
                    
                    for postID in postIDsSlice {
                        group.enter()
                        
                        let postURL = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(postID).json")!
                        
                        URLSession.shared.dataTask(with: postURL) { postData, _, _ in
                            defer { group.leave() }
                            
                            if let postData = postData {
                                do {
                                    let post = try JSONDecoder().decode(HackerNewsPost.self, from: postData)
                                    DispatchQueue.main.async {
                                        hackerNewsPosts.append(post)
                                    }
                                } catch {
                                    print("Error decoding post data: \(error)")
                                }
                            }
                        }.resume()
                    }
                    
                    group.notify(queue: DispatchQueue.main) {
                        // All posts fetched
                    }
                } catch {
                    print("Error decoding post IDs: \(error)")
                }
            }
        }.resume()
    }

}

struct HackerNewsPost: Identifiable, Decodable {
    var id: Int
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
