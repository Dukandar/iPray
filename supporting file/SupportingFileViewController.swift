//
//  AccountCreateViewController.swift
//  iPray
//
//  Created by vivek on 15/03/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

import Foundation
import UIKit
class supportingfuction: NSObject
{
    // MARK: date picker View
    class func datePikkerView(mode : UIDatePicker.Mode,frame: CGRect)->UIDatePicker
    {
        let currentdate = Date()
        let datepicker: UIDatePicker = UIDatePicker()
        datepicker.frame = frame
        datepicker.datePickerMode = mode
        datepicker.date = currentdate
        datepicker.minimumDate = Date()
        return datepicker
    }
    
    class func UIpikkerview(frame: CGRect) -> UIPickerView
    {
        let pickerView = UIPickerView()
        pickerView.frame = frame
        pickerView.showsSelectionIndicator = true
        pickerView.selectRow(1, inComponent: 0, animated: true)
        return pickerView
    }
    
    // MARK: Get TimeZone
    class  func getTimeZone() -> String {
        var localTimeZoneAbbreviation: String { return TimeZone.current.abbreviation() ?? "" }
        var newtimeZone = localTimeZoneAbbreviation
        if newtimeZone.count > 3
        {
            newtimeZone = String(newtimeZone.dropFirst(3))
        }
        return newtimeZone
    }
    
    // MARK: Local time to GMT
    class func ChangeLocalTimeIntoGmt(date : NSDate) -> NSDate
    {
        let seconds = TimeZone.current.secondsFromGMT()
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .second, value: -seconds, to: date as Date)
        return date! as NSDate
    }
    
    // MARK: GMT to Local time
    class func ChangeGmtTimeIntoLocal(date : NSDate) -> NSDate
    {
        let seconds = TimeZone.current.secondsFromGMT()
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .second, value: seconds, to: date as Date)
        return date! as NSDate
    }

    // MARK: compress profile image
    class func compressimage(image : UIImage , compress: Double ,maxwidth:Int,maxheight : Int) -> Data
    {
        // compress image
        let imaageIs = self.changeImageSize(image, scaledToWidth:300 , scaledToHeight: 300)
        return imaageIs.jpegData(compressionQuality: CGFloat(compress))!
    }
    
    // MARK: Scale image for Thumbnail
    class   func changeImageSize(_ sourceImage:UIImage, scaledToWidth:CGFloat , scaledToHeight:CGFloat) -> UIImage
    {
        UIGraphicsBeginImageContext(CGSize(width: scaledToWidth, height: scaledToHeight))
        sourceImage.draw(in: CGRect(x: 0, y: 0, width: scaledToWidth, height: scaledToHeight))
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    //MARK: Get The Color From RGB
    class func UIColorFromRGB(_ rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    // MARK: Convert Hex to UIColor
    class func colorWithHexString (_ hex:NSString) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substring(from: 1)
        }
        if (cString.count != 6) {
            return UIColor.gray
        }
        
        let rString = (cString as NSString).substring(to: 2)
        let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
        let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
    
    
    //MARK:-  Function to get country calling code
    class func getThePhoneNumberListArray() -> [Any]
    {
        let array: [Any] = ["Afghanistan (+93)", "Albania (+355)", "Algeria (+213)", "American Samoa (+1684)", "Andorra (+376)", "Angola (+244)", "Anguilla (+1264)", "Antarctica (+672)", "Antigua and Barbuda (+1268)", "Argentina (+54)", "Armenia (+374)", "Aruba (+297)", "Australia (+61)", "Austria (+43)", "Azerbaijan (+994)", "Bahamas (+1242)", "Bahrain (+973)", "Bangladesh (+880)", "Barbados (+1246)" +
            "Belarus (+375)", "Belgium (+32)", "Belize (+501)", "Benin (+229)", "Bermuda (+1441)", "Bhutan (+975)", "Bolivia (+591)", "Bosnia and Herzegovina (+387)", "Botswana (+267)" +
            "Brazil (+55)", "British Virgin Islands (+1284)", "Brunei (+673)", "Bulgaria (+359)", "Burkina Faso (+226)", "Burma  (Myanmar) (+95)", "Burundi (+257)", "Cambodia (+855)", "Cameroon (+237)", "Canada (+1)", "Cape Verde (+238)", "Cayman Islands (+1345)", "Central African Republic (+236)", "Chad (+235)", "Chile (+56)", "China (+86)", "Christmas Island (+61)", "Cocos  (Keeling) Islands (+61)", "Colombia (+57)", "Comoros (+269)", "Cook Islands (+682)", "Costa Rica (+506)", "Croatia (+385)", "Cuba (+53)", "Cyprus (+357)", "Czech Republic (+420)", "Democratic Republic of the Congo (+243)", "Denmark (+45)", "Djibouti (+253)", "Dominica (+1767)", "Dominican Republic (+1809)", "Ecuador (+593)", "Egypt (+20)", "El Salvador (+503)", "Equatorial Guinea (+240)", "Eritrea (+291)", "Estonia (+372)", "Ethiopia (+251)", "Falkland Islands (+500)", "Faroe Islands (+298)", "Fiji (+679)", "Finland (+358)", "France  (+33)", "French Polynesia (+689)", "Gabon (+241)", "Gambia (+220)", "Gaza Strip (+970)", "Georgia (+995)", "Germany (+49)", "Ghana (+233)", "Gibraltar (+350)", "Greece (+30)", "Greenland (+299)", "Grenada (+1473)", "Guam (+1671)", "Guatemala (+502)", "Guinea (+224)", "Guinea-Bissau (+245)", "Guyana (+592)", "Haiti (+509)", "Holy See  (Vatican City) (+39)", "Honduras (+504)", "Hong Kong (+852)", "Hungary (+36)", "Iceland (+354)", "India (+91)", "Indonesia (+62)", "Iran (+98)", "Iraq (+964)", "Ireland (+353)", "Isle of Man (+44)", "Israel (+972)", "Italy (+39)", "Ivory Coast (+225)", "Jamaica (+1876)", "Japan (+81)", "Jordan (+962)", "Kazakhstan (+7)", "Kenya (+254)", "Kiribati (+686)", "Kosovo (+381)", "Kuwait (+965)", "Kyrgyzstan (+996)", "Laos (+856)", "Latvia (+371)", "Lebanon (+961)", "Lesotho (+266)", "Liberia (+231)", "Libya (+218)", "Liechtenstein (+423)", "Lithuania (+370)", "Luxembourg (+352)", "Macau (+853)", "Macedonia (+389)", "Madagascar (+261)", "Malawi (+265)", "Malaysia (+60)", "Maldives (+960)", "Mali (+223)", "Malta (+356)", "MarshallIslands (+692)", "Mauritania (+222)", "Mauritius (+230)", "Mayotte (+262)", "Mexico (+52)", "Micronesia (+691)", "Moldova (+373)", "Monaco (+377)", "Mongolia (+976)", "Montenegro (+382)", "Montserrat (+1664)", "Morocco (+212)", "Mozambique (+258)", "Namibia (+264)", "Nauru (+674)", "Nepal (+977)", "Netherlands (+31)", "Netherlands Antilles (+599)", "New Caledonia (+687)", "New Zealand (+64)", "Nicaragua (+505)", "Niger (+227)", "Nigeria (+234)", "Niue (+683)", "Norfolk Island (+672)", "North Korea  (+850)", "Northern Mariana Islands (+1670)", "Norway (+47)", "Oman (+968)", "Pakistan (+92)", "Palau (+680)", "Panama (+507)", "Papua New Guinea (+675)", "Paraguay (+595)", "Peru (+51)", "Philippines (+63)", "Pitcairn Islands (+870)", "Poland (+48)", "Portugal (+351)", "Puerto Rico (+1)", "Qatar (+974)", "Republic of the Congo (+242)", "Romania (+40)", "Russia (+7)", "Rwanda (+250)", "Saint Barthelemy (+590)", "Saint Helena (+290)", "Saint Kitts and Nevis (+1869)", "Saint Lucia (+1758)", "Saint Martin (+1599)", "Saint Pierre and Miquelon (+508)", "Saint Vincent and the Grenadines (+1784)", "Samoa (+685)", "San Marino (+378)", "Sao Tome and Principe (+239)", "Saudi Arabia (+966)", "Senegal (+221)", "Serbia (+381)", "Seychelles (+248)", "Sierra Leone (+232)", "Singapore (+65)", "Slovakia (+421)", "Slovenia (+386)", "Solomon Islands (+677)", "Somalia (+252)", "South Africa (+27)", "South Korea (+82)", "Spain (+34)", "Sri Lanka (+94)", "Sudan (+249)", "Suriname (+597)", "Swaziland (+268)", "Sweden (+46)", "Switzerland (+41)", "Syria (+963)", "Taiwan (+886)", "Tajikistan (+992)", "Tanzania (+255)", "Thailand (+66)", "Timor-Leste (+670)", "Togo (+228)", "Tokelau (+690)", "Tonga (+676)", "Trinidad and Tobago (+1868)", "Tunisia (+216)", "Turkey (+90)", "Turkmenistan (+993)", "Turks and Caicos Islands (+1649)", "Tuvalu (+688)", "Uganda (+256)", "Ukraine (+380)", "United Arab Emirates (+971)","United Kingdom (+44)","United States of America (+1)", "Uruguay (+598)", "US Virgin Islands (+1340)", "Uzbekistan (+998)", "Vanuatu (+678)", "Venezuela (+58)", "Vietnam (+84)", "Wallis and Futuna (+681)", "West Bank (970)", "Yemen (+967)", "Zambia (+260)", "Zimbabwe (+263)"]
        
        return array
    }
    
    class func getCountryCallingCode(_ countryRegionCode:String)->String{
        let prefixCodes = ["BD": "880", "BE": "32", "BF": "226", "BG": "359", "BA": "387", "BB": "1-246", "WF": "681", "BL": "590", "BM": "1-441", "BN": "673", "BO": "591", "BH": "973", "BI": "257", "BJ": "229", "BT": "975", "JM": "1-876", "BV": "", "BW": "267", "WS": "685", "BQ": "599", "BR": "55", "BS": "1-242", "JE": "44-1534", "BY": "375", "BZ": "501", "RU": "7", "RW": "250", "RS": "381", "TL": "670", "RE": "262", "TM": "993", "TJ": "992", "RO": "40", "TK": "690", "GW": "245", "GU": "1-671", "GT": "502", "GS": "", "GR": "30", "GQ": "240", "GP": "590", "JP": "81", "GY": "592", "GG": "44-1481", "GF": "594", "GE": "995", "GD": "1-473", "GB": "44", "GA": "241", "SV": "503", "GN": "224", "GM": "220", "GL": "299", "GI": "350", "GH": "233", "OM": "968", "TN": "216", "JO": "962", "HR": "385", "HT": "509", "HU": "36", "HK": "852", "HN": "504", "HM": " ", "VE": "58", "PR": "1-787 and 1-939", "PS": "970", "PW": "680", "PT": "351", "SJ": "47", "PY": "595", "IQ": "964", "PA": "507", "PF": "689", "PG": "675", "PE": "51", "PK": "92", "PH": "63", "PN": "870", "PL": "48", "PM": "508", "ZM": "260", "EH": "212", "EE": "372", "EG": "20", "ZA": "27", "EC": "593", "IT": "39", "VN": "84", "SB": "677", "ET": "251", "SO": "252", "ZW": "263", "SA": "966", "ES": "34", "ER": "291", "ME": "382", "MD": "373", "MG": "261", "MF": "590", "MA": "212", "MC": "377", "UZ": "998", "MM": "95", "ML": "223", "MO": "853", "MN": "976", "MH": "692", "MK": "389", "MU": "230", "MT": "356", "MW": "265", "MV": "960", "MQ": "596", "MP": "1-670", "MS": "1-664", "MR": "222", "IM": "44-1624", "UG": "256", "TZ": "255", "MY": "60", "MX": "52", "IL": "972", "FR": "33", "IO": "246", "SH": "290", "FI": "358", "FJ": "679", "FK": "500", "FM": "691", "FO": "298", "NI": "505", "NL": "31", "NO": "47", "NA": "264", "VU": "678", "NC": "687", "NE": "227", "NF": "672", "NG": "234", "NZ": "64", "NP": "977", "NR": "674", "NU": "683", "CK": "682", "XK": "", "CI": "225", "CH": "41", "CO": "57", "CN": "86", "CM": "237", "CL": "56", "CC": "61", "CA": "1", "CG": "242", "CF": "236", "CD": "243", "CZ": "420", "CY": "357", "CX": "61", "CR": "506", "CW": "599", "CV": "238", "CU": "53", "SZ": "268", "SY": "963", "SX": "599", "KG": "996", "KE": "254", "SS": "211", "SR": "597", "KI": "686", "KH": "855", "KN": "1-869", "KM": "269", "ST": "239", "SK": "421", "KR": "82", "SI": "386", "KP": "850", "KW": "965", "SN": "221", "SM": "378", "SL": "232", "SC": "248", "KZ": "7", "KY": "1-345", "SG": "65", "SE": "46", "SD": "249", "DO": "1-809 and 1-829", "DM": "1-767", "DJ": "253", "DK": "45", "VG": "1-284", "DE": "49", "YE": "967", "DZ": "213", "US": "1", "UY": "598", "YT": "262", "UM": "1", "LB": "961", "LC": "1-758", "LA": "856", "TV": "688", "TW": "886", "TT": "1-868", "TR": "90", "LK": "94", "LI": "423", "LV": "371", "TO": "676", "LT": "370", "LU": "352", "LR": "231", "LS": "266", "TH": "66", "TF": "", "TG": "228", "TD": "235", "TC": "1-649", "LY": "218", "VA": "379", "VC": "1-784", "AE": "971", "AD": "376", "AG": "1-268", "AF": "93", "AI": "1-264", "VI": "1-340", "IS": "354", "IR": "98", "AM": "374", "AL": "355", "AO": "244", "AQ": "", "AS": "1-684", "AR": "54", "AU": "61", "AT": "43", "AW": "297", "IN": "91", "AX": "358-18", "AZ": "994", "IE": "353", "ID": "62", "UA": "380", "QA": "974", "MZ": "258"]
        
        var countryDialingCode = prefixCodes[countryRegionCode]
        countryDialingCode = countryDialingCode?.replacingOccurrences(of: "", with: "", options:NSString.CompareOptions.literal,range:nil)
        return countryDialingCode!
    }
}

class commonValidations: NSObject
{
    // MARK:- Email validation
    class func isValidEmailid(_ testStr:String) -> Bool
    {
        
        // let emailRegex = "(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
           let emailRegex = "(?:[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?\\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[A-Za-z0-9-]*[A-Za-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: testStr)
    }
    
    //MARK: Alphanumeric  Password
    class func isalphanumericpassword(_ testStr:String) -> Bool
    {
        if testStr.count >= 6 &&  testStr.count <= 15
        {
            return true
        }
        return false
    }
    
    // MARK: Function to validate Contact Number
    class func isValidContact(_ testStr: String) -> Bool {
        let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: testStr)
        return result
    }
   
}

// MARK: Corner radius
extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}




