# peek-coding-challenge
iOS coding challenge for Peek
iOS app written in Swift 2.0 that query Twitter API v1.1 for mentions of account @peek.

## Features
* On open retrieve the latest 7 tweets mentioning the account @peek.
* Pull-to-refresh to get latest tweets mentioning @peek.
* Infinite scrolling: when shown the latest item on the table (the 7th) loads another batch of older tweets.
* Slide to left on each cell to delete or retweet (using the account on the phone settings).

## Instalation
* Download or clone repository and run project from XCode.
* In order for the app to work the phone must have one twitter account.

## Screenshots
![simulator screen shot may 20 2016 08 18 57](https://cloud.githubusercontent.com/assets/14813651/15432692/30096326-1e64-11e6-9613-73362a73ce8c.png)
![simulator screen shot may 20 2016 08 17 24](https://cloud.githubusercontent.com/assets/14813651/15432694/300f9372-1e64-11e6-95d1-4a56d1e05b47.png)
![simulator screen shot may 20 2016 08 17 40](https://cloud.githubusercontent.com/assets/14813651/15432695/30101298-1e64-11e6-9fd4-8f6b2e5f2b00.png)
![simulator screen shot may 20 2016 08 18 09](https://cloud.githubusercontent.com/assets/14813651/15432696/3010519a-1e64-11e6-83c8-2217bd4545be.png)
![simulator screen shot may 20 2016 08 18 34](https://cloud.githubusercontent.com/assets/14813651/15432697/30118498-1e64-11e6-92fb-44adcce39ce7.png)
![simulator screen shot may 20 2016 08 18 38](https://cloud.githubusercontent.com/assets/14813651/15432693/300b22ec-1e64-11e6-8247-00cd65a24dc4.png)

## Future work
* More unit testing.
* Query to API differs from web.
* More alerts to users.
* Improve speed of first batch of fetch tweets.
* Better position loading animation.
