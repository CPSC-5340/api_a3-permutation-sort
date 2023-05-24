import SwiftUI
import WebKit

struct ContentView: View {
    @State private var hackerNewsPosts: [HackerNewsPost] = []
    @State private var showWebView = false
    @State private var webViewURL: URL?
    
    var body: some View {
        VStack {
            Text("Hacker News")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(hackerNewsPosts) { post in
                        Button(action: {
                            if let url = post.url {
                                webViewURL = URL(string: url)
                                showWebView = true
                            }
                        }) {
                            VStack(alignment: .leading) {
                                Text(post.title)
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .lineLimit(2)
                                if let url = post.url {
                                    Text(url)
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                        .lineLimit(1)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .padding(.top, 10)
        }
        .background(Color.orange.ignoresSafeArea())
        .onAppear {
            fetchHackerNewsPosts()
        }
        .sheet(isPresented: $showWebView) {
            WebView(url: webViewURL)
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

struct WebView: UIViewRepresentable {
    let url: URL?
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = url {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
}

struct HackerNewsPost: Identifiable, Decodable {
var id: Int
var title: String
var url: String?
}
