

# WBikes

[![Install](Screenshots/app_store_Badge.svg)](https://apps.apple.com/us/app/sharelink-pro/id1537276318)

Final project for "Udacity iOS Developer Nanodegree". The app allows you to view bike stations and their availability in more than 650 cities.

![MapController](https://raw.githubusercontent.com/diegulog/Wbikes/main/Screenshots/map-controller.png)
![SelectCityController](https://raw.githubusercontent.com/diegulog/Wbikes/main/Screenshots/select-city-controller.png)
![SearchController](https://raw.githubusercontent.com/diegulog/Wbikes/main/Screenshots/search-controller.png)
![FavoritesController](https://raw.githubusercontent.com/diegulog/Wbikes/main/Screenshots/favorite-controller.png)
![InfoController](https://raw.githubusercontent.com/diegulog/Wbikes/main/Screenshots/Info-controller.png)


## Implementation

The app has five view control scenes:

- **SelectCityController**: shows the user the available cities ordered by country, when selecting a city it is saved in UserDefaults

- **MapController**: shows on the map the annotations with the different stops downloaded from the API http://api.citybik.es/v2/, to show the information of each station a custom BottomSheetView has been implemented that is show with an animation when touching the annotation

- **SearchController**: Allows users to see the stations in list mode and search for the stop using UISearchBar, this controller implements NSFetchedResultsControllerDelegate to observe any data changes.

- **FavoritesController**: Allows users to view favorite stations in list mode and delete stations by tapping the edit button. NSFetchedResultsControllerDelegate is also implemented to handle any data changes.

- **InfoController**: Shows relevant information of the application and allows the user to change cities.


The application uses CoreData to store Cities and their stations. All API calls are executed in background and updated data is stored in each query using CoreData.


**Testing The App:**

* Download the project to your computer from this project page.
* Once the project is downloaded, open the .xcodeproj file from the folder.
* Run the project either using the iPhone simulator or your device.

## Requirements

 - Xcode Version 12.0.1
 - Swift 5 
 - iOS 13.0

## Credits

**Citybikes**

To date [Citybikes](https://citybik.es) supports more than 650 cities and the Citybikes API is the most widely used dataset for building bike sharing transportation projects.

## License

    Copyright 2020 Diego Guaña

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
