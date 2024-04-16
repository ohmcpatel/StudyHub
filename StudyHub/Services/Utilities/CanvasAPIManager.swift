import Foundation

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
        if let jsonArray = jsonData as? [[String: Any]] {
            var results: [[String: Any]] = []
            
            // Iterate through each item in the array
            for item in jsonArray {
                // Process each item and add to the results array
                let className = getClassName(classData: item)
                let calendarLink = getCalendarData(classData: item)
                
                // Fetch the ICS data and handle it
                fetchICS(from: calendarLink) { jsonString in
                    guard let jsonString = jsonString else {
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch ICS data"])))
                        return
                    }
                    
                    // Process the fetched data as needed (e.g., printing or storing)
                    var processedItem = item
                    processedItem["icsData"] = jsonString
                    results.append(processedItem)
                }
            }
            
            // Complete with the results array
            completion(.success(results))
        } else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "JSON data is neither an array nor a dictionary"])))
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
    func parseICS(_ icsContent: String) -> String? {
        // Dictionary to hold JSON data
        var jsonDictionary = [String: Any]()
        
        // Variables to hold current event data
        var currentEvent = [String: Any]()
        var events = [[String: Any]]()
        
        // Split the content into lines
        let lines = icsContent.components(separatedBy: "\n")
        
        // Parse the lines
        for line in lines {
            let lineTrimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Check for event start
            if lineTrimmed == "BEGIN:VEVENT" {
                currentEvent = [:]
            } else if lineTrimmed == "END:VEVENT" {
                events.append(currentEvent)
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
        
        // Add the events to the JSON dictionary
        jsonDictionary["events"] = events
        
        // Convert the dictionary to JSON data
        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonDictionary, options: [.prettyPrinted]) {
            // Convert the JSON data to a string and return it
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
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
            return icsLink
        }
        
        return ""
    }
}
