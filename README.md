# 🌸 Bloom Setup Instructions

## 1. Environment Variables
Create a `.env` file and add your Gemini API key:

```bash
GEMINI_API_KEY=your_api_key_here
```

## 2. Xcode (iOS App Setup)
- Ensure Xcode is installed on your Mac (download from the Mac App Store if needed).

- Open Xcode.

- Select Open an Existing Project.

- Open the project located in the bloom-ios directory.

## 3. Backend Server Setup
- Navigate to the server directory:
```bash
cd server
```
- Install required dependencies:
```bash
pip install -r requirements.txt
```
- Start the backend server:
```bash
python server.py
```
## 4. Update API URLs
- Open the iOS project in Xcode.

- Locate all server or API URL references.

- Replace localhost or placeholder URLs with your deployed server URL.
## 5. Run the App
- Select an iOS simulator or connected physical device in Xcode.

- Click Run ▶.

- Confirm the app builds successfully and connects to the backend server.

**Note**
login credentials are mom@bloom.com and dad@bloom.com, password is password