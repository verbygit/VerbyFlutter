# Verby App - Functionality and Flow Documentation

## Overview

Verby is a mobile application designed for hotel and cleaning service workers to manage their daily operations, track work activities, and perform quality checks. The app supports face recognition for authentication, offline functionality, and automatic synchronization with a central server.

## App Purpose

The app enables workers to:

- Log in and authenticate using Employee ID and PIN (with optional face recognition)
- Record work actions (check-in, check-out, pause-in, pause-out) for different operations
- Select and manage room assignments (Depart and Restant rooms)
- Perform quality checks on rooms with detailed checklists
- Track volunteer assistance
- Synchronize data with the server when online
- Work offline with local data storage

---

## Main User Flows

### 1. Initial Setup and Authentication Flow

#### 1.1 First Launch

- App launches to the **Worker Screen** (main entry point)
- App checks if a user is already authenticated
- If no user exists, shows **Authentication Dialog**
- User enters email and password to log in
- Upon successful authentication, user and device information is saved locally
- App automatically syncs employee data from the server

#### 1.2 Worker Screen (Main Entry)

- Displays current time and device name
- Shows internet connection status (green indicator = connected, red = offline)
- Main input field: "Enter your ID"
- Submit button to proceed
- Settings icon (gear) - access to app settings
- Lock/unlock icon - for app pinning (Kiosk mode)

#### 1.3 Employee Login Process

1. **Enter Employee ID**

   - Worker enters their numeric Employee ID (up to 10 digits)
   - App validates the ID format

2. **PIN Verification**

   - If ID is valid, **PIN Dialog** appears
   - Worker enters their PIN code
   - System verifies PIN against stored employee data

3. **Face Recognition (Optional)**

   - **If Face ID is required for ALL employees:**

     - App checks if face is registered for the employee
     - If missing, shows error message
     - If registered, proceeds to **Face Verification Screen**

   - **If Face ID is required ONLY for those with registered faces:**

     - App checks if face exists for the employee
     - If face exists → **Face Verification Screen**
     - If no face → **Select Operation Screen**

   - **If Face ID is not required:**
     - Directly proceeds to **Select Operation Screen**

#### 1.4 Face Verification Screen

- Uses device camera for real-time face detection
- Compares live face against registered face template
- Provides visual feedback:
  - Face positioning guides (move left, right, up, down)
  - Head orientation instructions (turn left, turn right)
  - Blink detection for liveness verification
  - Progress indicators during verification
- On successful match → **Select Operation Screen**
- On failure → Returns to Worker Screen with error message

---

### 2. Operation Selection Flow

#### 2.1 Select Operation Screen

After successful authentication, worker sees operation options:

**Available Operations:**

- **STEWARDING** (Kitchen/Service operations)
- **UNTERHALT** (Maintenance)
- **GOUVERNANTE** (Room Control)
- **RAUMPFLEGERIN** (Room Cleaning)
- **BÜRO** (Office)

**Operation Availability:**

- Operations are enabled/disabled based on employee's permissions
- Disabled operations appear grayed out and cannot be selected
- Enabled operations appear in black and are clickable

**Additional Feature:**

- **Quality Check** button (floating action button) - allows direct access to room checklist

**Flow:**

- Worker selects an available operation
- App navigates to **Action Screen** for that specific operation

---

### 3. Action Recording Flow

#### 3.1 Action Screen

After selecting an operation, worker sees action options:

**Available Actions:**

- **CHECK-IN** (Start work)
- **CHECK-OUT** (End work)
- **PAUSE-IN** (Start break)
- **PAUSE-OUT** (End break)

**Action Flow:**

**For CHECK-IN:**

1. Worker selects CHECK-IN
2. App records the action with timestamp
3. Action is saved locally to database
4. Success message: "Thanks" with sound feedback
5. Returns to **Select Operation Screen**

**For CHECK-OUT:**

1. Worker selects CHECK-OUT
2. **For specific operations (Maintenance, Room Cleaning, Room Control):**
   - App navigates to **Rooms and Department Screen**
   - Worker selects rooms (Depart/Restant)
   - Confirms selection
3. **For other operations:**
   - Directly records CHECK-OUT action
4. Action is saved locally
5. Success message: "Thanks" with sound feedback
6. Returns to **Select Operation Screen**

**For PAUSE-IN:**

1. Worker selects PAUSE-IN
2. Action is recorded with timestamp
3. Saved locally
4. Returns to **Select Operation Screen**

**For PAUSE-OUT:**

1. Worker selects PAUSE-OUT
2. Action is recorded with timestamp
3. System automatically calculates break duration
4. If worker didn't take a break, shows message: "You did not take a break. The breaks are automatically deducted"
5. Saved locally
6. Returns to **Select Operation Screen**

**State Management:**

- App tracks current employee's action state
- Prevents duplicate check-ins if already checked in
- Tracks performance state for each operation type

---

### 4. Room Management Flow

#### 4.1 Rooms and Department Screen (for CHECK-OUT)

**Purpose:** Select rooms assigned to worker for checkout operations

**Screen Layout:**

- Two sections: **DEPART** (Departure rooms) and **RESTANT** (Remaining rooms)
- Each section shows list of rooms
- Search functionality to filter rooms
- Room selection mechanism

**Room Selection:**

1. Worker views available rooms in each category
2. Can select multiple rooms
3. Selected rooms are highlighted
4. Worker can change room status (if applicable)
5. Confirmation button to proceed

**Room Status Options:**

- **RED CARD** - Room had issues
- **HAD VOLUNTEER** - Received support from volunteer
- **DID NOT CLEAN** - Room was not cleaned

**After Selection:**

- Returns to Action Screen with selected rooms
- CHECK-OUT action is recorded with room information
- Data saved locally

---

### 5. Quality Check Flow

#### 5.1 Accessing Quality Check

**Two ways to access:**

1. From **Select Operation Screen** - Tap "Quality Check" floating button
2. Direct navigation to **Room List Screen**

#### 5.2 Room List Screen

- Displays all available rooms in a grid layout
- Search bar to filter rooms by name
- Each room shown as a card
- Tap on a room to open its checklist

#### 5.3 Room Checklist Screen

**Purpose:** Perform detailed quality inspection of a room

**Checklist Items:**

- **General cleanliness** - Overall room cleanliness
- **Sheets folded correctly** - Bed linens check
- **Towels** - Towel placement and condition
- **Missing item** - Any items that should be present but aren't

**Interaction:**

- Each item shows a checkmark (✓) or minus (-) icon
- Tap the icon to toggle between checked and unchecked
- Tap the item name to add details (comment and photo)

#### 5.4 Add Comment and Picture Dialog

**When:** Worker taps on a checklist item name

**Features:**

- **Comment field** - Text input for additional notes
- **Add Image button** - Camera access to take photos
- **Image display** - Shows captured images
- **Save button** - Saves comment and images to checklist item

**Use Cases:**

- Document issues found during inspection
- Add visual evidence of problems
- Provide detailed feedback for room status

**After Completion:**

- Checklist data is saved locally
- Can be synchronized to server when online
- Returns to Room List Screen

---

### 6. Data Synchronization Flow

#### 6.1 Automatic Synchronization

**Triggers:**

- When app detects internet connection is restored
- When employee data is first loaded
- After certain actions are completed
- When returning from settings screen

**Synchronization Process:**

1. **Upload Local Records**

   - All locally saved records (actions, checklists) are uploaded to server
   - Process runs in background
   - Shows "Data syncing..." message if user tries to perform action during sync

2. **Download Server Data**

   - Employee information
   - Employee permissions and states
   - Room assignments (Depart/Restant)
   - Plans and schedules
   - Action states and performance states

3. **Conflict Resolution**
   - Server data takes precedence
   - Local unsynced data is uploaded first
   - Then server data overwrites local data

#### 6.2 Manual Synchronization

- Can be triggered from settings (if available)
- Automatic retry on connection restoration

#### 6.3 Offline Mode

- App functions fully offline
- All actions saved locally
- Data queue for upload when connection restored
- Visual indicator shows connection status

---

### 7. Settings and Configuration Flow

#### 7.1 Settings Screen Access

- Tap settings icon (gear) from Worker Screen
- Requires authentication (password or PIN)

#### 7.2 Settings Options

**Face ID Settings:**

- **Require Face ID For ALL** - Toggle to require face verification for all employees
- **Require for ONLY those with Face ID** - Only verify employees who have registered faces
- **Number of retries** - Configure verification retry attempts

**Face Management:**

- **Register Face ID**

  1. Select employee from identification dialog
  2. Verify PIN
  3. Navigate to **Face Registration Screen**
  4. Capture face using camera
  5. Save face template to database

- **Edit Face ID**

  1. Select employee with existing face
  2. Verify PIN
  3. Re-capture face
  4. Update existing face template

- **Delete Face ID**
  1. Select employee from delete dialog
  2. Verify PIN
  3. Remove face from database

**Authentication Settings:**

- Change password
- Device configuration
- Language settings (English/German)

**Data Management:**

- Upload archived records
- Backup and restore functionality
- Clear local data (with authentication)

---

### 8. Face Registration Flow

#### 8.1 Face Registration Screen

**Purpose:** Register employee's face for future verification

**Process:**

1. Camera activates with live preview
2. Face detection overlay guides positioning
3. Worker centers face in frame
4. System captures face image
5. Processes face using TensorFlow Lite model
6. Extracts face embeddings
7. Saves to local database
8. Success confirmation

**Requirements:**

- Good lighting
- Face centered in frame
- Single person in view
- No obstructions (masks, glasses if needed)

**After Registration:**

- Returns to Settings Screen
- Face is now available for verification

---

### 9. Volunteer Selection Flow

#### 9.1 Volunteer Selection Screen

**Purpose:** Select volunteer/helper who assisted with work

**When Used:**

- During room status selection
- When marking "Had Volunteer" status

**Features:**

- Search bar to find volunteers by name
- List of all available employees
- Selection returns to previous screen with volunteer information

---

### 10. App Pinning (Kiosk Mode) Flow

#### 10.1 Android (Lock Task Mode)

- Tap lock icon from Worker Screen
- Toggles lock task mode on/off
- Prevents users from exiting the app
- Useful for dedicated devices

#### 10.2 iOS (Guided Access)

- Tap lock icon from Worker Screen
- Shows instructions dialog
- Guides user to enable Guided Access in iOS Settings
- User must enable in iOS Settings > Accessibility > Guided Access
- Then triple-click side button to activate

---

## Key Features and Behaviors

### Multi-language Support

- English and German language support
- All UI text is localized
- Language can be changed in settings

### Offline Capability

- Full functionality without internet
- Local SQLite database storage
- Automatic sync when connection restored
- Visual connection status indicator

### Error Handling

- Clear error messages for user actions
- Network error handling
- Validation for all inputs
- Graceful degradation when features unavailable

### User Feedback

- Haptic feedback on button presses
- Sound notifications for successful actions
- Visual indicators (spinners, progress bars)
- Toast messages for status updates
- Color-coded UI elements (green = success, red = error)

### Security Features

- PIN verification for all sensitive actions
- Face recognition for authentication
- Encrypted local storage
- Secure communication with server
- Password protection for settings

### Performance Optimizations

- Background data synchronization
- Efficient local database queries
- Optimized face recognition processing
- Image compression for storage
- Lazy loading of data

---

## Data Flow Summary

### Input Data

- Employee ID and PIN
- Face images
- Action selections
- Room selections
- Checklist responses
- Comments and photos

### Stored Data (Local)

- User authentication credentials
- Employee information
- Face recognition templates
- Action records with timestamps
- Room assignments
- Checklist data
- Comments and images

### Synchronized Data (Server)

- All action records
- Room status updates
- Checklist results
- Employee states
- Plans and schedules
- Performance metrics

---

## Screen Navigation Hierarchy

```
Worker Screen (Main Entry)
├── Authentication Dialog (if no user)
├── PIN Dialog (for employee login)
├── Face Verification Screen (if face required)
├── Select Operation Screen
│   ├── Action Screen
│   │   ├── Rooms and Department Screen (for checkout)
│   │   │   └── Volunteer Selection Screen (optional)
│   │   └── Loader Screen (processing)
│   └── Room List Screen (Quality Check)
│       └── Room Checklist Screen
│           └── Add Comment and Picture Dialog
└── Settings Screen
    ├── Face Registration Screen
    ├── Identification Dialog
    ├── Delete Face Dialog
    ├── Password Dialog
    └── Various configuration dialogs
```

---

## User Roles and Permissions

### Employee Permissions

- Each employee has specific operation permissions
- Operations are enabled/disabled based on employee role
- Employees can only access permitted operations
- Face registration may be restricted to certain users

### Operation Types

1. **Stewarding** - Kitchen and food service operations
2. **Maintenance (Unterhalt)** - Maintenance and repair work
3. **Room Control (Gouvernante)** - Room inspection and control
4. **Room Cleaning (Raumpflegerin)** - Room cleaning operations
5. **Office (Büro)** - Administrative tasks

---

## Technical Highlights

### Face Recognition

- Uses Google ML Kit for face detection
- TensorFlow Lite for face recognition
- On-device processing (privacy-focused)
- Liveness detection (blink detection)
- Head orientation tracking

### Data Persistence

- SQLite for local database
- SharedPreferences for app settings
- Secure storage for sensitive data
- Image files stored locally

### Network Communication

- RESTful API communication
- Automatic retry on failure
- Request queuing for offline actions
- Error handling and reporting

---

## End-to-End User Journey Example

**Scenario: Room Cleaning Worker Starting Shift**

1. **Worker opens app** → Worker Screen appears
2. **Enters Employee ID** → PIN dialog appears
3. **Enters PIN** → Face verification (if enabled)
4. **Face verified** → Select Operation Screen
5. **Selects "Room Cleaning"** → Action Screen
6. **Selects "CHECK-IN"** → Action recorded, returns to Select Operation
7. **Taps "Quality Check"** → Room List Screen
8. **Selects a room** → Room Checklist Screen
9. **Completes checklist** → Items checked, comments added
10. **Finishes work** → Returns to Select Operation
11. **Selects "Room Cleaning"** → Action Screen
12. **Selects "CHECK-OUT"** → Rooms and Department Screen
13. **Selects completed rooms** → Confirms selection
14. **CHECK-OUT recorded** → Success message
15. **Data syncs to server** → When online

---

## Conclusion

Verby is a comprehensive workforce management application designed specifically for hotel and cleaning service operations. It combines authentication, work tracking, quality control, and data synchronization in a user-friendly mobile interface. The app supports both online and offline operations, ensuring workers can continue their tasks regardless of connectivity while maintaining data integrity through automatic synchronization.
