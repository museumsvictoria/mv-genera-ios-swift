Genera for Swift 
(or should that be Swift For Genera?)

Read Me: Version 0.1
Create Date: August 8th, 2016
Author: Simon Sherrin - Senior Developer, Museum Victoria


Welcome.

This is the latest version of Museum Victoria's Genera platform for iOS. The current version is written in Swift, and targets iOS 8 and above.

This project supersedes the genera-ios project on Github. 

//What's Changed:

- Data format is now JSON 
The format of the datafile has been changed from Apple's plist format to JSON, and the expected filename is now "data.json". We did this for format consistency across operating systems.

- New data sections
There are two new sections in the datafile:
1. supergroupList
2. galleryImages

SupergroupList is an array of supergroup objects (see below). GalleryImages is an array of image objects (see changes to image object below).

Supergroups have been extracted to a separate section to remove the duplication in the group entries. 

Image galleries are a part of the latest MV field Guide for Gippsland lakes. Although not part of the base Genera spec, the code has been left in for this build. If there are no images in the galleryImages list, the gallery function is hidden in the app.


- Supergroup object
Supergroups have three fields 
"superGroupID": Identifier for the supergroup
"label" : Name of the supergroup (e.g. Vertebrates, or Humanities)
"order": Position of the supergroup in the supergroup list (inferred if blank)


- Group object - new field
"superGroupID" - the ID of the supergroup that the group belongs to.


- Image object - extra fields
Images now have two extra fields:
1. "alternateText" - an accessible description of the image
2. "licenseType" - license information for the image.
Licence type is not currently expressed in the interface.

- Audio object - extra fields
Audio entries now have two extra fields:
1. "alternateText" - an accessible description of the audio (e.g. Transcript)
2. "licenseType" - license information for the audio file.
The Alternate Text and LicenseType are currently not expressed in the interface.

- "objectData" array of Speci now "data" array of Speci objects

- Speci object
"audioFiles" array of audio objects now called "audio" 


//Setup Changes
- File Locations
Content - images, audio files, html templates no longer need to be "added" to the project within XCode. When you add files to the following directories, they are automatically included in the project.

Images -> genera-swift/Images
Audio Files -> genera-swift/Audio
HTML Templates -> genera-swift/Templates

Subdirectories created under the Templates directory - e.g. for CSS, javascript and CSS Assets - will also be automatically included in the project.


