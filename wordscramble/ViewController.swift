//
//  ViewController.swift
//  wordscramble
//
//  Created by Alysha Kester-Terry on 1/17/21.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [String]()
    // loading our array. This is done in three parts: finding the path to our start.txt file, loading the contents of that file, then splitting it into an array.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addButton = UIBarButtonItem(image: UIImage(named: "addWord"), style: .plain, target: self, action: #selector(promptForAnswer))
            addButton.tintColor = .systemPurple
        let restartButton = UIBarButtonItem(image: UIImage(named: "restart"), style: .plain, target: self, action: #selector(startGame))
        restartButton.tintColor = .systemGreen
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.rightBarButtonItems = [restartButton, addButton]
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        startGame()
    }

    @objc func startGame() {
        title = allWords.randomElement()
        
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
   
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Try a word...", message: nil, preferredStyle: .alert)
        ac.addTextField()

        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else { return }
            if answer.isEmpty {
                self?.showErrorMessage(whichtype: "tryagain")
            }else{
            self?.submit(answer: answer)
            }
        }

        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
            for letter in word {
                if word.count  < 3{
                    return false
                }
                if let position = tempWord.firstIndex(of: letter) {
                    tempWord.remove(at: position)
                } else {
                    return false
                }
            }

            return true
    }

    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word) && title?.lowercased() != word
    }

    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        if misspelledRange.location == NSNotFound {
            return true
        } else {
            return false
        }
    }
    
    func submit(answer: String) {
        let lowerAnswer = answer.lowercased()
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    usedWords.insert(answer, at: 0)
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                } else {
                    showErrorMessage(whichtype: "possible")
                 }
            } else {
                showErrorMessage(whichtype: "used")
            }
        } else {
            showErrorMessage(whichtype: "tryagain")
        }
        promptForAnswer()
        return
    }
    
    func showErrorMessage(whichtype: String){
        let errorTitle: String
        let errorMessage: String
        
        if whichtype == "possible"{
            errorTitle = "That's not a word!"
            errorMessage = "You can't just make them up, you know!"
        }else if whichtype == "used"{
            errorTitle = "Word used already..."
            errorMessage = "Be more original!"
        }
        else{
            errorTitle = "Try again."
            errorMessage = "Use words with at least 3 letters and make sure you spell the word correctly!"
        }
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}


