# Fetch Project
<p align="center">
<img src="https://github.com/user-attachments/assets/02d66525-325f-4f45-8c7e-5a96dd6ffa3e" alt="FetchIntro" width="200" height="400"> 
  <img src="https://github.com/user-attachments/assets/ce1215c6-815e-4c35-b692-7c2ea09f7b6d" alt="FetchIntroTwo" width="200" height="400"> 
</p>

### Summary:
A recipes app that fetches food items from the server. The food items are displayed in a grid that can be sorted and searched. Clicking a food item reveals details such as recipes, image, videos, country of origin and an added wiki description. Links opens to webpages and video player.  

### Focus Areas:
  - Modern Swift Concurrency: used asyn/await to fetch JSON data from server. Async Image to fetch and display Images of food items.
  - NSCache: Caching Images fetched from server after initial request.
  - UIViewRepresentable: Needed to use UIViewRepresentable to work with Webkit and embed Youtube Videos in the app.
  - WebView: Used to Display sources of resipes.
  - UnitTest: Created Unit test for All Non-View files, Models, NSCaching, Mocking API Fetches, Mocking URL Session for 100% Code Coverage for all non view files.     

### Time Spent:
- Do not know exact time spent. 1-4 hours for 12-15 random days.
- Figuring out how to play Youtube videos in the app was half the time consumed.  

### Trade Offs:
- None

### Weak Parts:
- Could use some fancy animation
- The wikipedia Api does not have all Food Item for the added food Summaries (*Extra*)

### Additional Info:
- How to run the project:
  1. Three Buttons on the app fetches from the three endpoints provided in the instructions (Complete, Malformed & Empty).
  2. All three responses have been handled with a default value or actions to provide a video or source.
  3. Select one of the buttons and the app will fetch and display all recipes, an empty endpoint will show an alert.
  4. After the Initial fetch, the recipes will be cached to minimize network calls.
  5. The items are in a grid and can be sorted by name, country of origin & favourites.
  6. Items can also be searched for by name or country of origin
  7. Click the items to go into it's details. There will be a brief summary from wikipedia, a large image, an option to add to favourites, a source webview link and a link to an embeded youtube player.
- Dependencies:
    There are NO dependencies.


### Extras:
- Extra Added Features:
  1. Added Alerts to handle using empty endpoints and trying to sort or search an empty recipes.
  2. Added function to automatically search for recipes in google if the source-variable is missing by using the name of the item. (malformed endpoint items: 2,3,21,27,29)
  3. Added function to automatically search for videos in youtube if the videoURL-variable is missing by using the name of the item. (malformed endpoint items: 10,35,40,57)
  4. Added Sorting be name,country of origin, or favourites.
  5. Added Search by name or country of origin.
  6. Added Favourites Option.
  7. Added Embeded Youtube Video View & Source Webview
  8. Added Refreshable method by pulling scrollview down or tool bar "Show all"
  9. Added Wikipedia summary for the food items.

<!-- VIDS FIRST SET -->
<h3 align="center">Play Youtube Video and Display Source</h3>

<p align="center">
  <img src="https://github.com/user-attachments/assets/66a52207-dfd3-4eb4-bf1b-653f95030750" alt="FetchYoutubeVid" width="200" height="400" style="margin-right: 20px;" >
  <img src="https://github.com/user-attachments/assets/83641464-b43c-423d-b233-eae929b3ed79" alt="FetchSourceVid" width="200" height="400">
</p>

<!-- VIDS SECOND SET -->
<h3 align="center">Search By Name & Country of Origin</h3>

<p align="center">
  <img src="https://github.com/user-attachments/assets/cea7e77d-ac11-43e2-b91a-1a62077ff8ea" alt="FetchByName" width="200" height="400" style="margin-right: 20px;" >
  <img src="https://github.com/user-attachments/assets/abd2d1cb-db1b-4bb9-a5b2-105d17f43ba2" alt="FetchByOrigin" width="200" height="400">
</p>

<!-- VIDS THIRD SET -->
<h3 align="center">Applied Sorting and Refreshable Option</h3>

<p align="center">
  <img src="https://github.com/user-attachments/assets/84392dc0-480e-4448-8f35-98f1e1483f92" alt="FetchSort" width="200" height="400" style="margin-right: 20px;" >
  <img src="https://github.com/user-attachments/assets/446a6ddf-2c95-4690-be72-e467be958741" alt="FetchRefrehable" width="200" height="400">
</p>


<!-- VIDS FOURTH SET -->
<h3 align="center">Handle Missing Youtube URL & Missing Source URL (Malformed Endpoint) </h3>

<p align="center">
  <img src="https://github.com/user-attachments/assets/7d9a56a5-dcdc-45f7-b73e-ee068c673526" alt="FetchMissingSource" width="200" height="400" style="margin-right: 20px;" >
  <img src="https://github.com/user-attachments/assets/f806e1de-8fb0-49c8-9c41-9ffb9f5859de" alt="FetchMissingVid" width="200" height="400">
</p>
   
