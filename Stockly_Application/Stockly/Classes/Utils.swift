//
//  Utils.swift
//  Hargovind
//
//  Created by MACPro on 14/05/19.
//
//

import Foundation
import UIKit


// Utils calss

class Utils {
    
    //---**---- Get CFBundleDisplayName ----***--
    static var localizedAppName: String! {
        return (Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String)!
    }
    
    static var appVersion: String {
        return (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)!
    }
    
    //---**---- Get StatusBar Height ----***--
    static var screenStatusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
    
    //---**---- Platform ----***--

    struct Platform {
        static let isSimulator: Bool = {
            #if arch(i386) || arch(x86_64)
                return true
            #endif
            return false
        }()
    }

    //---**----UIUserInterfaceIdiom----***--

    enum UIUserInterfaceIdiom : Int
    {
        case Unspecified
        case Phone
        case Pad
    }
    
    //---**----Get Current Device Size----***--
    
    struct ScreenSize{
        
        static let WIDTH = UIScreen.main.bounds.size.width;
        
        static let HEIGHT = UIScreen.main.bounds.size.height;
        
        static let MAX_LENGTH  = max(ScreenSize.WIDTH, ScreenSize.HEIGHT);
        
        static let MIN_LENGTH = min(ScreenSize.WIDTH, ScreenSize.HEIGHT);
    }
    
    //---**---- Get Current Device Type ----***--
    
    struct DeviceType{
        
        static let IS_IPHONE_4_OR_LESS = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.MAX_LENGTH < 568.0
        
        static let IS_IPHONE_5 = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.MAX_LENGTH == 568.0
        
        static let IS_IPHONE_6 = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.MAX_LENGTH == 667.0

        static let IS_IPHONE_6_OR_6S = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.MAX_LENGTH == 667.0

        static let IS_IPHONE_6P = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.MAX_LENGTH == 736.0
        
        static let IS_IPHONE_X  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.MAX_LENGTH == 812.0

        static let IS_IPAD = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.MAX_LENGTH == 1024.0
        
    }
    
    
    
    //---**----Get APP_FONTS----***--
    struct FONT_SIZE{
        static let BigSize:CGFloat       = 22.0

        
    }
    struct APP_FONTS{
        
        static let Bold         = "Mallory-Book"
    
        static let Light        = "Mallory-Light"
        
        static let Regular      = "Mallory-Book"
        
        static let Semibold     = "Mallory-Book"
        
        static let Medium       = "Montserrat-Medium"

      /*  static let Black        = "Montserrat-Black"

        static let Bold         = "Montserrat-Bold"
        
        static let ExtraBold    = "Montserrat-ExtraBold"

        static let Hairline     = "Montserrat-Hairline"

        static let Light        = "Montserrat-Light"
        
        static let Regular      = "Montserrat-Regular"
        
        static let Semibold     = "Montserrat-Semibold"
        
        static let UltraLight   = "Montserrat-UltraLight"

        static let Medium       = "Montserrat-Medium" */
        
    }
    
    struct APP_IMAGES{
      
        static let imgUnchekedBox = #imageLiteral(resourceName: "unchekedstatus").withRenderingMode(.alwaysTemplate)
        static let imgChekedBox = #imageLiteral(resourceName: "chekedstatus").withRenderingMode(.alwaysTemplate)
        static let radio_select    = "fill_radio.png"
        static let imagePalne      = "40-x-40-plane-icon"
        static let radio_unselect  = "blank_radio.png"
        static let bgColorImage    = "1242px-×-2208px.png"

    }
    
    
    struct APP_COLORS {
        
        static let Theme = UIColor.fromHexString(hex:"#4FAD4F") // "#01B7F2"
        static let FBBlue = UIColor.fromHexString(hex:"#3b5997") // "#3b5997"
        static let LightGrey_FontColor = UIColor.fromHexString(hex:"#6d6d6d") //"#6d6d6d"
        static let DarkGrey = UIColor.fromHexString(hex:"#2e2d2d") // "#2e2d2d"
        static let LightGrey_PlaceholderColor = UIColor.fromHexString(hex:"#aaaaaa") // "#aaaaaa"
        static let TextBoxBottomBorder = UIColor.fromHexString(hex:"#000000") // "#000000"
        static let OrderSummery = UIColor.fromHexString(hex:"#EEF2F3") // "#EEF2F3"
        
        static let BG = UIColor.fromHexString(hex:"#ECEFF1")
        static let TextFieldBG = UIColor.fromHexString(hex:"#E4E4E4")
        static let TextFieldPlacholder = UIColor.fromHexString(hex:"#D4D2D5")

        static let Red = UIColor.fromHexString(hex:"#e23a3a") // "#00b437"

      static let DarkBlue = UIColor.fromHexString(hex:"#061e4b")
        
        static let Grey = UIColor.fromHexString(hex:"#696969")

        
        
    }
    
    struct COLOR_CODE {
        
        static let NAVCOLOR                        = "#01B7F2"
        static let COLOR_BG                        = "#ECEFF1"
        static let COLOR_TXTBORDER                 = "#DCDCDC"
        static let COLOR_LINE                      = "#BBBBBB"
        static let COLOR_TEXTFIELD_BG              = "#E4E4E4"
        static let COLOR_REGISTER_BUTTON           = "#FF3B55"
        static let COLOR_TEXTFILED_PLACEHOLDER     = "#D4D2D5"
        static let COLOR_IMAGEVIEW_BORDER          = "#4C4B56"
        static let COLOR_EVEN_CELL                 = "#FFFFFF"
        static let COLOR_ODD_CELL                  = "#F5F5F5"
        static let COLOR_TEXTFIELD_SEARCH          = "#FF3B55"
        static let COLOR_INDICATOR                 = "#FA5667"
        static let COLOR_LOGIN_BG                  = "#9D4399"
        static let COLOR_LOGIN_BUTTON              = "#00C1D0"
        static let COLOR_HOME_HEADER               = "#2D3E58"
        static let COLOR_FULNAME_PLACEHOLDER       = "#2DC1D0"
        static let COLOR_FULNAME_TEXTFIELD_BORDER  = "#EAEAEA"
        static let COLOR_LOGIN_BUTTON_BG           = "#E23A3A"
        
        // CLANEDAR
        static let COLOR_HRS                       = "#F4797C"
        
    }

    
    
}

//MARK:- @end
//MARK: -
