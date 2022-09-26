# MRZ Scanner
 MRZ detection and parse with OCR Scanner (İOS - Android(included Huawei devices))
 
#Usage



```dart
async{
  var resulText = await MrzScan.openOCR(context);
                  setState(() {
                    showedText = result.toString(); }); }
```
 
 
When find correct format of mrz it return a Map 


```dart
  print(showedText);
  
  // output is
  {DocumentNo: "Your document no", DateofBirth: "Your date of birth", DateofValid: "Your indedity card's date of valid"}
  
```

İf you can make make development I would be grateful.
