# My Daily Habits – Mobile App Proposal

## 1. Short Description

**My Daily Habits** is a simple mobile app that helps users build and track their daily habits.  
The user can create habits (like “Drink Water”, “Read for 20 Minutes”), check them off each day, view progress over time, and stay motivated.  
The app is designed to be easy to use for anyone — no technical knowledge required.

---

## 2. Domain Details

### **Entity: Habit**

This is the main entity of the app. Each habit created by the user will be saved and managed in the app.

| Field Name | Type | Description |
|-------------|------|-------------|
| **id** | Integer | A unique identifier for each habit. |
| **name** | Text | The title of the habit (e.g., “Morning Jog”). |
| **description** | Text | A short description or goal related to the habit. |
| **frequency** | Text | Defines how often the user wants to do the habit (e.g., Daily, Weekly). |
| **status** | Boolean | Indicates whether the habit is completed for the current day (true/false). |
| **created_at** | Date | The date when the habit was added. |

---

## 3. CRUD Operations

Below are the CRUD (Create, Read, Update, Delete) operations for the **Habit** entity:

### **Create**
- **Action:** The user adds a new habit by entering its name, description, and frequency.  
- **Example:** “Drink 2L of water daily.”  
- **Result:** A new record is stored both locally and on the server.

### **Read**
- **Action:** The app displays the list of all habits or details of one specific habit.  
- **Example:** Viewing all current habits and their completion status.  
- **Result:** Data is fetched from the local database and synchronized with the server.

### **Update**
- **Action:** The user edits a habit’s details (e.g., changing the frequency or marking it as done).  
- **Example:** Marking “Read for 20 minutes” as completed for today.  
- **Result:** The change is saved locally and synced to the server when online.

### **Delete**
- **Action:** The user deletes a habit they no longer want to track.  
- **Example:** Removing “Morning Jog.”  
- **Result:** The habit is removed from both local and server databases.

---

## 4. Persistence Details

| CRUD Operation | Local Database | Server Database |
|----------------|----------------|----------------|
| **Create** | ✅ Yes | ✅ Yes |
| **Read** | ✅ Yes | ✅ Yes |
| **Update** | ✅ Yes | ✅ Yes |
| **Delete** | ✅ Yes | ✅ Yes |

**Explanation:**  
The app stores habits in a **local SQLite database** to allow offline access.  
When internet is available, changes are synchronized with the server (cloud database).

---

## 5. Offline Scenarios

| Operation | Offline Behavior |
|------------|------------------|
| **Create** | The new habit is saved in the local database and marked as “Pending Sync.” Once the device is online, it’s uploaded to the server. |
| **Read** | The user can view all habits stored locally, even without internet. Data is loaded from the local cache. |
| **Update** | When the user marks a habit as completed, it’s saved locally. The change syncs with the server later. |
| **Delete** | The habit is removed locally and flagged for deletion on the server once the device reconnects. |

---

## 6. App Mockup

*(The mockup screenshots will be added by the user — e.g., designed in Figma or Sketch.)*

Suggested Screens:
1. **Home Screen:** List of habits with daily progress.
2. **Add Habit Screen:** Form to create a new habit.
3. **Habit Details Screen:** Shows frequency and history.
4. **Settings Screen:** Basic app preferences.

---

✅ **End of README.md**
