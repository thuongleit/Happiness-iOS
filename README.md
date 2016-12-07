# Happiness-iOS
   An app that lets you save your precious moments and then reflect on them to make you smile or feel happy.

## Sprint 3

## User Stories

The following **required** functionality is completed:

- [x] Timeline and create/edit/delete entry
   - [x] Make updates to timeline immediately, not waiting for database call to succeed. If database call fails, undo updates.
   - [x] When making updates to timeline immediately, disable pull to refresh, edit, and delete as appropriate.
- [x] Timeline
   - [x] Change "Timeline" in nav bar to app icon. 
   - [x] Change image for "Compose" button.
   - [x] Use round corners on images.
- [x] Create/edit entry
   - [x] Make colors consistent with other views.
   - [x] Use images for "Cancel" and "Save" buttons instead of text.
   - [x] Remove "What are you most grateful for today?"
   - [x] Use round corners on text view. 
   - [x] Replace "Location" with location image used elsewhere in app.
   - [x] Use subtle cross-dissolve animation for happiness emoji changes.
   - [x] Use round corners on image.
   - [x] Aspect fit image into a 4:3 frame. Constraints fit iPhone 5.
   - [x] Use camera image placeholder rather than current (landscape) image.
   - [x] For photo picker, remove the unused square frame.
   - [x] Allow user to take a picture from within the app.
- [x] View entry
   - [x] Make colors consistent with other views.
   - [x] Use custom image for "Back" button.
   - [x] Use image for "Edit" button.
   - [x] Make scrollable using UITableView.
   - [x] Remove "What are you most grateful for today?"
   - [x] Use a UITextView so that HTTP links are clickable.
   - [x] Use round corners on images.
   - [x] Start with emoji fully overlapping profile pic, then shrinking down to overlap in the corner as it is currently.
- [x] Nudge prompt
   -[x] Use custom alert controller which includes profile image
   -[x] Originate alert controller from the profile image in the section header.
- [x] Bug fixes
   - [x] Fix problem where Timeline is not updated correctly after entry is edited
   - [x] Fix retain cycles and cleaned up reference usage
   - [x] Fix User.encode() "archive already finished, cannot encode anything more"

## Sprint 2

<img src="https://github.com/TeamHappiness/Happiness-iOS/blob/master/Sprint2.gif" alt="sprint2"/>

## User Stories

The following **required** functionality is completed:

- [x] Sign up / log in / sign out
   - [x] Profile image for sign up
- [x] Tab bar
   - [x] Hide tab bar, since timeline is the only main view
- [x] Timeline navigation bar
   - [x] Settings button on left for sign out
- [x] Timeline section and row management
   - [x] Use getEntries() to retrieve nest entries from service
   - [x] Use getEntries() beforeCreatedDate for infinite scroll
   - [x] Divide entries into sections by week
   - [X] Discard entries for a partial week
   - [x] Add section header for current milestone even if it has no entries
   - [x] Only display entries for milestone if user created entry for that milestone
   - [x] Only allow swipe to delete for current user's entries
   - [x] Make necessary adjustments to section headers and rows when a new entry is created or an existing entry is deleted
- [x] Timeline "milestone" section header
   - [x] Displays profile pictures of all users in nest
   - [x] When a user has not completed entry for milestone, profile picture is grayed out
   - [x] When a user has completed entry for milestone, profile picture is color
   - [x] Display label which describes if user has completed entry
- [x] Timeline entries
  - [x] New layout based on nest design
- [x] View entry
  - [x] Display profile picture
- [x] Edit entry
  - [x] Only allow edit entry for current user's entries
- [x] Push notifications
   - [x] Tapping on another user's grayed profile picture on section header will show an alert asking if you want to nudge that person.
      - [x] If yes, then a push notification is sent to that user.
      - [x] Display success/failure banner which indicates if nudge was successful
      - [ ] For user receiving the push notification, sliding the notification takes user to new entry screen
      - [x] Push notifications set up on one machine. Having problem with exporting Provisioning Profile/Certificates.
- [x] Model
      - [x] Nest class
      - [x] Add nests member to User class
      - [x] Singleton for current user
      - [x] Current User object stored in UserDefaults
- [x] Service
   - [x] getEntries() retrieves nest entries of current user's nest
   - [x] getAllNestUsers() retrieves users in current user's nest
   - [x] getEntries() skip count
   - [x] Store entry image aspect ratio in database
   - [x] Downsize images for faster performance
   - [x] update create entry to store user's nest into entry table nest column as pointer
- [x] Location
   - [x] For reverse geocoding, use city/state or area of interest
   - [x] If create entry location name is blank, set based on lat/lon (i.e., don't call locationString() when scrolling)

The following **optional** features are nice to have:

- [x] Change app name to "Happynest"
- [x] Progress indicator uses spinning emoji
- [x] Confetti when everyone completes milestone (display only one time)
   - [x] Show confetti for last user who completes milestone
   - [x] Also show confetti for users who have already completed milestone when they next open the app
- [ ] Display milestone deadline date if you haven't written yet. E.g. "3 days left!"


## Sprint 1

<img src="https://github.com/TeamHappiness/Happiness-iOS/blob/master/Happinest.gif" alt="sprint1"/>

## User Stories

The following **required** functionality is completed:

- [x] Parse
   - [x] Sign up
   - [x] Log in
   - [x] Log out
   - [x] Current user persisted across restarts
- [x] Log in/Sign up
   - [x] User input validations
   - [x] Present error message banner on error
   - [x] Log out
- [x] Timeline for user journal entries
   - [x] Autolayout constraints for the view
   - [x] Table sections grouped by month
- [x] Create journal entry
   - [x] Contains text input
   - [x] Ability to categorize the entry as angry, bothered, sad, happy, excited or super excited
   - [x] Save to the database
- [x] View journal entry
- [x] Custom tab bar controller

The following **optional** features are nice to have:

- [x] For Parse:
   - [x] Edit and Delete entry database calls
- [x] For timeline for user journal entries:
   - [x] URLs, etc. in entries are clickable
   - [x] Pull to refresh
   - [x] Swipe to delete
   - [x] User sees loading state while waiting for Parse API
   - [x] Present error message banner on error
- [x] For create journal entry:
   - [x] Slider for happiness level, changes smiley image as user slides
   - [x] Upload image to entry from Photo library
   - [x] User's current location tagged to the entry
   - [x] User sees loading state while waiting for Parse API
   - [x] Present alert controller on error
- [x] Edit journal entry
   - [x] User can edit existing journal entry
- [x] Global error message banner
   - [x] Fancy reusable error banner that slides down from top
- [x] Colors/Skinning
   - [x] Choose pretty colors for app. Color nav bar, text, tab bar, icons.
   - [x] Pretty cold start splash screen.
   - [x] App icon.
- [x] Launch screen
- [ ] Calendar view for user journal entries



## Wireframe

<img src="https://github.com/TeamHappiness/Happiness-iOS/blob/master/smileFirstSprint.gif" alt="app wireframe"/>



####PDF
https://github.com/TeamHappiness/Happiness-iOS/blob/master/smileFirstSprint.pdf




## Credits & Attribution
Smiley icons by Freepik

http://www.freepik.com/free-vector/several-emoticons-in-flat-style_950559.htm?utm_campaign=flaticon&utm_medium=banner

<img src="https://image.freepik.com/free-vector/several-emoticons-in-flat-style_23-2147572596.jpg"/>
