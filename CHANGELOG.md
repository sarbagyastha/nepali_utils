# 2.1.0+3
* Fixes in *NepaliNumberFormat*.
* Fixed lint warning.

# 2.1.0+1
* Added `totalDays` getter for *NepaliDateTime* class.

# 2.1.0
* **[Improvement]** Code refactor.
* Added dart docs.
* Methods in *NepaliNumberFormat* are now generic and supports types `String` and `num`.

# 2.0.0+4
* **FIXED** Issue with comma formatting in `NepaliNumberFormat`.

# 2.0.0+2
* **ADDED** `mergeTime` method to NepaliDateTime.

## 2.0.0+1
**BREAKING CHANGES** 
* DateConvertor is now integrated to NepaliDateTime class.
* NepaliNumber is renamed into NepaliNumberFormat.
* NepaliDateFormatter is renamed into NepaliDateFormat.
* **FEATURE** The package now supports from 2000 B.S. upto 2099 B.S. 
* Preconfigured constructors are added for quick formatting in NepaliDateFormat class.
  
See ReadMe section to know about using newer APIs.

## 1.1.0+2
* **ADDED** `NepaliMoment` class.

## 1.1.0
* **ADDED** `NepaliUnicode` class.
* Updated Dart Constraint to `>=2.2.2 <3.0.0`.

## 1.0.1
* **Fixed** Wrong current datetime retrieval.

## 1.0.0+3
* `formatWithComma` boolean argument added to `from` & `fromString` methods of **NepaliNumber**.

## 1.0.0+1
* Added Example

## 1.0.0
**Initial Version with**
* NepaliDateTime
* DateConverter
* NepaliDateFormatter
* NepaliNumber
