import Foundation
import Dispatch 

// Define the Canvas API manager class
class CanvasAPIManager {
    // Properties to hold the API URL and access token
    private let baseApiUrl: String
    private let accessToken: String
    private let enrollmentState: String
    
    // Initialize the class with required parameters
    init(baseApiUrl: String, accessToken: String, enrollmentState: String) {
        self.baseApiUrl = baseApiUrl
        self.accessToken = accessToken
        self.enrollmentState = enrollmentState
    }
    
    // Function to fetch course data from the API and return it as JSON
    func fetchCourseData(completion: @escaping (Result<Any, Error>) -> Void) {
        // Construct the full API URL with the enrollment_state parameter
        let apiUrl = "\(baseApiUrl)?access_token=\(accessToken)&enrollment_state=\(enrollmentState)"
        
        // Ensure the API URL is a valid URL
        guard let url = URL(string: apiUrl) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        // Create a data task to make the API request
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Handle any errors
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Ensure data is received and cast the response to HTTPURLResponse
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response or data"])))
                return
            }
            
            // Check the response status code
            if httpResponse.statusCode == 200 {
                do {
                    // Parse the JSON data
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    // Return the JSON data as an array or dictionary
                    completion(.success(json))
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP status code \(httpResponse.statusCode)"])))
            }
        }
        
        // Start the data task
        task.resume()
    }
    
    // Function to parse JSON data and process each item
    func parseJson(jsonData: Any, completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        guard let jsonArray = jsonData as? [[String: Any]] else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "JSON data is neither an array nor a dictionary"])))
            return
        }
        
        var results: [[String: Any]] = []
        let dispatchGroup = DispatchGroup() // Create a dispatch group to track asynchronous operations
        
        for item in jsonArray {
            dispatchGroup.enter() // Enter the group before starting the asynchronous operation
            
            // Process each item and fetch ICS data
            let calendarLink = getCalendarData(classData: item)
            
            fetchICS(from: calendarLink) { jsonString in
                guard let jsonString = jsonString else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch ICS data"])))
                    dispatchGroup.leave() // Leave the group on failure
                    return
                }
                
                // Process the fetched data as needed
                var processedItem = item
                processedItem["icsData"] = jsonString
                results.append(processedItem)
                
                dispatchGroup.leave() // Leave the group after processing the item
            }
        }
        
        // Wait for all asynchronous operations to complete
        dispatchGroup.notify(queue: .main) {
            // Now you know all asynchronous operations have completed
            completion(.success(results))
        }
    }

    
    // Function to fetch the .ics file from the given URL and return the JSON string using a completion handler
    func fetchICS(from url: String, completion: @escaping (String?) -> Void) {
        // Replace webcal:// with https:// and handle the URL string
        let httpsUrlString = url.replacingOccurrences(of: "webcal://", with: "https://")
        
        guard let icsUrl = URL(string: httpsUrlString) else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        // Create a data task to fetch the ICS content
        let task = URLSession.shared.dataTask(with: icsUrl) { data, response, error in
            // Handle errors
            if let error = error {
                print("Error accessing URL:", error.localizedDescription)
                completion(nil)
                return
            }
            
            // Check the HTTP status code
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("HTTP status code:", (response as? HTTPURLResponse)?.statusCode ?? -1)
                completion(nil)
                return
            }
            
            // Handle the data
            guard let data = data, let icsContent = String(data: data, encoding: .utf8) else {
                print("No data received")
                completion(nil)
                return
            }
            
            // Parse the ICS content and return the JSON string
            let jsonString = self.parseICS(icsContent)
            
            completion(jsonString)
        }
        
        // Start the data task
        task.resume()
    }
    
    // Function to parse .ics content and convert it to JSON format
    // Function to parse .ics content and convert it to JSON format
    func parseICS(_ icsContent: String) -> String? {
        // Dictionary to hold the organized data
        var organizedData = [String: [String: String]]()
        
        // Variables to hold current event data
        var currentEvent = [String: String]()
        var courseCode: String? = nil
        
        // Split the content into lines
        let lines = icsContent.components(separatedBy: "\n")
        
        // Parse the lines
        for line in lines {
            let lineTrimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Check for event start
            if lineTrimmed == "BEGIN:VEVENT" {
                currentEvent = [:]
            } else if lineTrimmed == "END:VEVENT" {
                // Process current event
                if let summary = currentEvent["SUMMARY"],
                   let dtstart = currentEvent["DTSTART"] ?? currentEvent["DTSTART;VALUE=DATE;VALUE=DATE"],
                   let range = summary.range(of: "[", options: .backwards) {
                    
                    // Extract the course code from the summary
                    courseCode = String(summary[range.lowerBound...])
                    
                    // Remove the brackets and any trailing whitespace from the course code
                    courseCode = courseCode?.replacingOccurrences(of: "[", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Extract the assignment title
                    let assignmentTitle = summary.components(separatedBy: " [")[0]
                    
                    // Ensure course code exists in the dictionary
                    if organizedData[courseCode!] == nil {
                        organizedData[courseCode!] = [:]
                    }
                    
                    // Add the assignment title and due date to the dictionary
                    organizedData[courseCode!]?[assignmentTitle] = dtstart
                }
            } else {
                // Split the line into key and value
                let components = lineTrimmed.split(separator: ":")
                if components.count == 2 {
                    let key = String(components[0]).trimmingCharacters(in: .whitespaces)
                    let value = String(components[1]).trimmingCharacters(in: .whitespaces)
                    
                    // Add key-value pair to the current event
                    currentEvent[key] = value
                }
            }
        }
        
        // Convert the organized data dictionary to JSON format
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: organizedData, options: [.prettyPrinted])
            // Convert the JSON data to a string
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            // Handle JSON serialization error
            print("Error serializing JSON data: \(error)")
            return nil
        }
        
        // Return nil if conversion to JSON failed
        return nil
    }

    
    // Function to get the class name from class data
    func getClassName(classData: Any) -> String {
        var className = ""
        
        if let jsonDict = classData as? [String: Any], let name = jsonDict["name"] as? String {
            className = name
        }
        
        return className
    }
    
    // Function to get calendar data from class data
    func getCalendarData(classData: Any) -> String {
        if let jsonDict = classData as? [String: Any], let calendarData = jsonDict["calendar"] as? [String: String], let icsLink = calendarData["ics"] {
            return convertURL(icsLink) ?? ""
        }
        
        return ""
    }
    
    func convertURL(_ urlString: String) -> String? {
        // Define the base domain to replace the domain in the URL
        let targetBaseDomain = "https://webcourses.ucf.edu"
        
        // Define the possible base domains in the input URL
        let baseDomains = ["https://canvas.instructure.com", "https://webcourses.ucf.edu"]
        
        // Iterate through each possible base domain
        for baseDomain in baseDomains {
            // Check if the input URL starts with the current base domain
            if urlString.hasPrefix(baseDomain) {
                // Get the relative path from the URL by removing the base domain
                let relativePath = urlString.dropFirst(baseDomain.count)
                // Combine the target base domain with the relative path
                return targetBaseDomain + relativePath
            }
        }
        
        // Return nil if the input URL does not start with any of the known base domains
        return nil
    }

}
