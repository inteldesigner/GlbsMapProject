# GlbsMapProject

IOS Developer Test - Eric S.

Search places from Google Map API at a given location 
Story:​ As a user, I would like to ​search for places within a specified area. Requirements
1. Input
a. Two input parameters are required from user: Geographic coordinates (latitude,
longitude) and radius from the given point to define search area.
b. Input can be in any form. Eg. TextField, Map with ability to drop pin and define
circular radius, or whatever you find that suits the requirements.
c. “Search” button.
2. Displaying search results
a. Display search result information in a ​custom​ Table View.
b. Display search result information in a Map View with custom pin.
c. Ability to switch between Table View and MapView.
d. Table View should be sorted by alphabetical (place name).
e. Each place entry contains: ​Place name​, ​Distance​ from the input geographic
coordinate in KM (with two decimal points) and ​place’s photo ​(if available).
f. Search results retrieved from Google API should be stored in ​app’s local
database​.
g. Display matched search results from local database first (if any) before
performing search through Google Map API (see more detail in API Doc section)
3. Storing data in local database
a. Search results retrieved from Google API should be stored in app’s local database.
Implementation Guide
■ Check from a local database if there’s any matched results, then display the result from app’s database in the Table View result right away. Then retrieve places information from Google Map API. While retrieving places from Google Map API, display loading indicator.
■ Update Table View with search results from Google Map API. If search result matched the existing places in local database, update the record, else add a new record to Table View.
■ Google API doesn’t provide distance information. You should calculate it locally.
■ Place’s image URL can be found in photos -> photo_reference in JSON object for each
place entry.
■ Custom Table View Cell to display photo, place name and distance.
Acceptance Criterias
■ App should be written in Swift
■ Architecturing your code wisely: for example, using VIPER architecturing, MVP pattern
■ Photo loading should be asynchronous and store locally in app sandbox for the future
use.
■ Entry should not be duplicated in both local database and listview.
■ Map View and Table View should be able to switched flawlessly.
■ You are required to ​submit your​ well documented source code to GITHub repository
and provide the repository URL for us to access.
Google Map API (Place API)
URL:​ https://maps.googleapis.com/maps/api/place/nearbysearch/​output​?​parameters Output​ must be ​json indicates output​ in JavaScript Object Notation (JSON)
Required ​parameters
■ key​ — you can use this key: ​AIzaSyCZ1BCe4Q7YL1nCa_ovtet4Bjn52tT20T8
■ location​ — The latitude/longitude around which to retrieve place information. This must
be specified as latitude,longitude.
■ radius​ — Defines the distance (in meters) within which to return place results. The
maximum allowed radius is 50 000 meters.
An example request is below, showing a search for places within a 500m radius of a point in
Chiang Mai, Thailand
https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=18.7717874,9 8.9742796&radius=500&key=AIzaSyCZ1BCe4Q7YL1nCa_ovtet4Bjn52tT20T8
