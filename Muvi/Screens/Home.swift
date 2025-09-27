//
//  ContentView.swift
//  Muvi
//
//  Created by Farid Mirzayev on 1.07.2021.
//

import SwiftUI

struct Home: View {
    @State var showCard = true
    @State var viewState = CGSize.zero
    @State var show = true
    @State private var searchTerm = ""
    @State private var tabs = ["Now Playing", "Upcoming", "Trending"]
    @ObservedObject var movieService = MovieService()
    @State private var selectionIndex = 0
    
    var body: some View {
        VStack {
            TopBar(tabs: $tabs, movieService: movieService, selectionIndex: $selectionIndex)
            Cards(searchTerm: $searchTerm, movieService: movieService)
            ActorCard(movieService: movieService)
            Spacer()
        }
        .padding(.top, 20)
        .background(Color(.secondarySystemBackground))
        .edgesIgnoringSafeArea(.all)
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Home()
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - TopBar

private struct TopBar: View {
    
    @Binding var tabs: [String]
    @ObservedObject var movieService: MovieService
    @Binding var selectionIndex: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "film")
                    .foregroundColor(.gray)
                Text("MOVIES")
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
            }

            HStack {
                Text("What would you like to see today?")
                    .font(.system(size: 24))
                    .fontWeight(.semibold)
                    .frame(maxWidth: UIScreen.main.bounds.width - 100, alignment: .leading)
                    .lineLimit(3)
                Spacer()
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 24))
            }

            VStack {
                Picker("_", selection: $selectionIndex) {
                    ForEach(0..<tabs.count) { index in
                        Text(tabs[index])
                            .font(.title)
                            .bold()
                            .tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: selectionIndex) { _ in
                    switch selectionIndex {
                    case 0: movieService.getNowPlaying()
                    case 1: movieService.getUpcoming()
                    case 2: movieService.getPopular()
                    default: break
                    }
                }
            }
            .padding(.top, 5)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(radius: 10)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal)
    }
}

// MARK: - Cards

private struct Cards: View {
    @Binding var searchTerm: String
    @ObservedObject var movieService: MovieService
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(movieService.movies.filter {
                    searchTerm.isEmpty ? true :
                        $0.title?.lowercased().localizedStandardContains(searchTerm.lowercased()) ?? true
                }) { movie in
                    GeometryReader { geometry in
                        NavigationLink(destination: FilmDetail(movie: movie)) {
                            FilmCard(movie: movie)
                                .rotation3DEffect(
                                    Angle(degrees: Double(geometry.frame(in: .global).minX) - 50) / -getAngleMultiplier(),
                                    axis: (x: 0, y: 10, z: 0)
                                )
                        }
                    }
                    .frame(width: 200, height: 280)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(radius: 10)
            )
            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
            .padding(.horizontal)
            .onAppear {
                movieService.getNowPlaying()
                movieService.getActors()
            }
        }
        .onAppear {
            UIScrollView.appearance().bounces = false
        }
    }
}

// MARK: - Utility

private func getAngleMultiplier() -> Double {
    return 20
}
