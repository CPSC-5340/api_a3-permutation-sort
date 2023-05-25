import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = HackerNewsViewModel()
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
                    ForEach(viewModel.hackerNewsPosts) { post in
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
            viewModel.fetchHackerNewsPosts()
        }
        .sheet(isPresented: $showWebView) {
            WebView(url: webViewURL)
        }
    }
}
