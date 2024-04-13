import requests
import json


# Define the base API URL and access token
base_api_url = "https://canvas.instructure.com/api/v1/courses"
access_token = "1158~9vn1qUR4MIWvnnTrYtqDAcHfG0xIS9c2ao3c4iCWfBjO8rD8HyNBjV90QcUxXC45"

# Specify the enrollment_state parameter you want to use (e.g., "active", "completed")
enrollment_state = "active"  # Change this value as needed

# Construct the full API URL with the enrollment_state parameter
api_url = f"{base_api_url}?access_token={access_token}&enrollment_state={enrollment_state}"

# Make the API request
response = requests.get(api_url)

# Check response status
if response.status_code == 200:
    # Convert the JSON response to a Python dictionary
    course_data = response.json()
    
    # Format the JSON data with an indent of 4 spaces for readability
    formatted_data = json.dumps(course_data, indent=4)
    
    # Print the formatted data
    print(formatted_data)
else:
    print("Error:", response.status_code)
