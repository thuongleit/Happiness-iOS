# Happiness-iOS
   An app that lets you save your precious moments and then reflect on them to make you smile or feel happy.

## Sprint 2

## User Stories

The following **required** functionality is completed:

- [x] Sign up / log in / sign out
   - [x] Profile image for sign up
- [x] Tab bar
   - [x] Hide tab bar, since timeline is the only main view
- [x] Timeline navigation bar
   - [x] Settings button on left for sign out
- [ ] Timeline section and row management
   - [x] Use getEntries() to retrieve nest entries from service
   - [ ] Use getEntries() skip count for infinite scroll
   - [x] Divide entries into sections by week
   - [ ] Discard entries for a partial week
   - [x] Add section header for current milestone even if it has no entries
   - [x] Only display entries for milestone if user created entry for that milestone
   - [x] Only allow swipe to delete for current user's entries
   - [ ] Make necessary adjustments to section headers and rows when a new entry is created or an existing entry is deleted
- [x] Timeline "milestone" section header
   - [x] Displays profile pictures of all users in nest
   - [x] When a user has not completed entry for milestone, profile picture is grayed out
   - [x] When a user has completed entry for milestone, profile picture is color
   - [x] Display label which describes if user has completed entry
- [x] Timeline entries
  - [x] New layout based on nest design
- [x] View entry
  - [x] Display profile picture
- [ ] Edit entry
  - [ ] Only allow edit entry for current user's entries
- [ ] Push notifications
   - [ ] Tapping on another user's grayed profile picture on section header will show an alert asking if you want to nudge that person.
      - [ ] If yes, then a push notification is sent to that user.
      - [ ] Display success/failure banner which indicates if nudge was successful
      - [ ] For user receiving the push notification, sliding the notification takes user to new entry screen
- [x] Model
      - [x] Nest class
      - [x] Add nests member to User class
- [ ] Service
   - [x] getEntries() retrieves nest entries of current user's nest
   - [x] getAllNestUsers() retrieves users in current user's nest
   - [ ] getEntries() skip count
   - [x] Store entry image aspect ratio in database
   - [x] Downsize images for faster performance
- [ ] Location
   - [ ] For reverse geocoding, use city/state or area of interest
   - [ ] If create entry location name is blank, set based on lat/lon (i.e., don't call locationString() when scrolling)

The following **optional** features are nice to have:

- [x] Change app name to "Happynest"
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


