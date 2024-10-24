# 2023-TMDBExercise

## **Building the APP**


- Using the latest Xcode (15.0.1) on the date of 2023-10-30
- Get the App from Repo at [https://github.com/SimonZhang2012/2023-TMDBExercise](https://github.com/SimonZhang2012/2023-TMDBExercise)
	- If need access, send mail to [contact@simonyz.com](https://contact@simonyz.com) or call the authour
- Build the app and run it on iOS Simulator 
- Build the app and run it on real device

Should a testFlight required, please contact author as well

## **Checking against the requirements:**

1. ### The app should have two screens: a search screen and a details screen.


	Confirmed. Additionally, a separate view has been created for showcasing favourites.

2. ### The search screen should have a search bar that allows the user to search for movies by title. The search results should be displayed in a table view.


	Confirmed. However, in SwiftUI terminology, it's referred to as a list, not a table view as in UIKit. 🙂 

3. ### The table view should display the movie title, release date, and poster image.


	Confirmed.

4. ### The details screen should display additional information about the selected movie, including the movie title, release date, poster image, and overview.


	Confirmed. Additionally, a star icon has been incorporated for adding to/removing from the favourite list.

5. ### The app should cache search results for offline use.


	Confirmed.

	In addition, 

	1 images are also cached.

	2 Implemented an unrequested feature to display cache size and provide an option to clear cache. This feature can be accessed by entering “Debug” in the search bar.

6. ### The app should handle error cases gracefully and provide feedback to the user when necessary.


	Confirmed - all exceptions are captured and appropriately displayed to the user

**Bonus points:**

1. ### Implement pagination in the search results table view.


	Confirmed. A pagination control has been added at the bottom, displaying the current/total page count and navigation controls for previous and next pages.

2. ### Allow users to save movies to a favourite list.


	Confirmed. Users can tap the star icon in the detail view to add/remove movies to/from the favourite list.

3. ### Add unit tests and UI tests for your code.


	Confirmed, although they are basic due to time constraints.


	- In the Unit Test, demonstrated how to use dependency injection for testing required features in isolation.
	- In UI Test, demonstrated how to utilize accessibility labels for control identification and asynchronous testing.

	It would cause a huge amount of time (might more than develop the features it self) to write  complete tests

4. ### Offline mode: the app can persist the data previously fetched and see them when the app is opened in offline mode.


	Confirmed. Search results, images, and favorites are cached locally for offline access

**Deliverables:**

1. ### A working iOS app that meets the above requirements.


	**Need clarification. Is it expected to run the app on Xcode/Simulator or a real device, or is a TestFlight build needed?**

2. ### A README file with instructions for building and running the app.


	Confirmed - detailed in a separate document.

3. ### A brief write-up describing the decisions you made while building the app, any challenges you faced, and how you overcame them.


	Confirmed - detailed in a separate document.

4. ### Your source code, preferably hosted on a public repository such as GitHub.


	confirmed - [https://github.com/SimonZhang2012/2023-TMDBExercise](https://github.com/SimonZhang2012/2023-TMDBExercise)


## **Developer Notes**: Technical Challenges and Decisions


- [x] Opted for a timed challenge to prevent it from stretching over a long duration.
- [x] Drafted a test plan encompassing basic functionalities and bonus points for tracking progress.
- [x] Employed SwiftUI + MVVM + Interactor architectural pattern.
- [x] Models - Distinguished between server models and app-specific models.
	- [x] Leveraged TMDB ID for data handling; foresee transitioning to a different UUID in the future.
- [x] Established several Interactors for a clear separation of concerns.
	- [x] API Manager - Entrusted with communication with the TMDB Server.
	- [x] DataManager - Central role in data handling, initially fetching from the server, later managing cache and offline storage.
- [x] Challenge: Slow poster loading - Solution: Employed async image and placeholder image.
- [x] Implemented numerous minor UI enhancements not specified in the scope but aimed at enriching user experience.
- [x] Deliberated between infinite scrolling and pagination with navigation control.
	- [x] Chose pagination, enabling users to navigate to specific pages intentionally.
	- [x] Decision: Displayed "page 1 of 1" even when only one page exists for clarity.
- [x] Decision: Cached data saved as files instead of using user defaults to accommodate potential data size increase.
	- [x] Introduced a user interface for viewing cache size and facilitating cache clearing.
- [x] Challenge: Writing unit tests for Interactors with numerous external dependencies.
	- [x] Resolved: Employed dependency injection.

Intentionally Unresolved and Areas for Improvement

- The app should run on iPad, though not verified.
- Implementing search auto-completion based on saved searches could enhance usability.
- Differentiating between small and large poster sizes to load varying resolutions in list and detail views.
- DataManager has grown large and could benefit from further modularization.
- Checked warnings in the Xcode console, yet some appear to be SwiftUI bugs and are not easily resolvable.
- Testing on older iOS versions and different machine models has not been conducted.


## **Manual Test Plan**: 

- App Launch: Display Search Screen
- Verifying Search Functionality:
	- Execute a search for "007" and observe the results in a list format:
		- Ensure the current page index is displayed on screen.
		- Ability to navigate to next/previous pages.
		- Check performance while scrolling through results.
		- Verify the accuracy of the title, release date, and poster displayed in the list.
	- Execute a search for a non-existing movie, e.g., "Test123" - expect no results.
	- With the internet connection off, initiate a search and verify an alert is displayed to the user.
- Navigating to Detail View:
	- Tap on a movie in the list and verify the navigation to the detail view.
		- Ensure the title, release date, poster, and overview are accurately displayed.
- Testing Cache Functionality:
	- Verify image caching:
		- Search for "007", navigate through different pages, and upon revisiting a page, ensure images are not reloaded.
	- Test image caching across app sessions:
		- Terminate and relaunch the app, search for "007", and ensure images are not reloaded.
	- Verify search caching:
		- Execute a search for "a", followed by a search for "b", and then search for "a" again; the second search for "a" should be significantly quicker. Alternatively, test through offline mode.
	- Test search caching across app sessions:
		- Similar to the above, but terminate the app before executing the second search for "a".
- Testing Offline Functionality:
	- Ensure previous search results, including images, are cached and displayed correctly.
	- Attempt a new search and verify that an error alert is displayed.
- Testing Favorites Functionality:
	- Add/remove movies from favorites by tapping the star icon in the detail view.
	- View favorites through the segment control at the top.
- Testing Bonus Secret Feature:
	- Search for "Debug" from the search bar; the app should display a debug view for managing cache, including showing cache size and providing a clean cache option.
- Testing for Potential Bugs:
	- Execute a search for "007" displaying multiple pages, type "transformer" but without committing it, tap the next page button at the bottom; the app should display the 2nd page of "007" results, not "transformer".


Test1

