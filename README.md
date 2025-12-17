# Uchronic Spin

An iOS app that uses your Discogs collection to find a record to spin, based on your mood.

Currently implementing it using Swift 6, Swift Concurrency, SwiftUI, SwiftData.

Architecture: Clean architecture / modified VIP

## Done so far

- Authenticate to your Discogs user via OAuth 1
- Store credentials in keychain
- Sign out logic
- Basic logging and error management
- Fetch Discogs username and total number of items, and save into SwiftData store
- Delete user metadata from store
- Fetch user's Discogs collection, fetching pages concurrently.
- Save collection in SwiftData storage.
- Load collection user and collection data from SwiftData storage based on caching policy.

## Next up

- Build basic collection UI

## More to do

- Build some initial filtering options. This can be filtering by Format, Genre, and Style. 
    - Likely build indeces and store them in SwiftData?
- Fetch covers for every release 
- Ensure collection loading progress is saved to storage if the app is terminated abruptly
- More basic filtering: filter by original release year. This likely requires GETting the master release for every release in collection.
- Research how to use the Foundation Models framework to use on-device LLMs for search

