//
//  ContentView.swift
//  WordScramble
//
//  Created by Anthy Chen on 5/3/23.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var score = 0
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                }
//                Section("Your score") {
//                    Text("\(score)")
//                        .font(.headline)
//                }
                Section(usedWords.isEmpty ? "" : "Used words") {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit {
                addNewWord()
            }
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .toolbar {
                Button("New Word") {
                    startGame()
                }

            }
            .safeAreaInset(edge: .bottom) {
                Text("\(score)")
                    .font(.title)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 30.0)
                    .background(.blue)
                    .foregroundColor(.white)
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // word validation
        guard answer.count >= 3 else {
            wordError(title: "Word too short", message: "Word must be at least 3 or more letters!")
            return
        }
        guard answer != rootWord else {
            wordError(title: "Nice try...", message: "You can't use the root word as an answer!")
            return
        }
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Try something else!")
            return
        }
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from \(rootWord)!")
            return
        }
        guard isReal(word: answer) else {
            wordError(title: "Word not recognised", message: "You can't just make them up, you know!")
            return
        }
        
        calculateScoreFor(word: answer)
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    
    func calculateScoreFor(word: String) {
        score += (10 - (rootWord.count - word.count))
    }
    
    func startGame() {
        newWord = ""
        usedWords = []
        score = 0
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "skilkworm"
                return
            }
        }
        fatalError("Could not load start.text from bundle")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var temp = rootWord
        
        for letter in word {
            if let index = temp.firstIndex(of: letter) {
                temp.remove(at: index)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
