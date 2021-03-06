//
//  DownLoadFiles.swift
//  spdbapp
//
//  Created by GBTouchG3 on 15/5/19.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit
import Alamofire

class DownLoadManager: NSObject {
    
    //static var router = Router.GetCurrentMeeting()
    
    
    //判断当前文件夹是否存在jsondata数据，如果不存在，则继续进入下面的步骤
    //如果存在该数据，则判断当前json与本地jsonlocal是否一致，如果一致，则打印 json数据信息已经存在，return
    class func isSameJSONData(jsondata: NSData) -> Bool {
        
        var localJSONPath = NSHomeDirectory().stringByAppendingPathComponent("Documents/jsondata.txt")
        var filemanager = NSFileManager.defaultManager()
        
        if filemanager.fileExistsAtPath(localJSONPath){
            let jsonLocal = filemanager.contentsAtPath(localJSONPath)
            
            if jsonLocal == jsondata {
                //println("json数据信息已经存在")
                return true
            }
            return false
        }
        return false
    }
    
    
    class func isSamePDFFile(fileName: String) -> Bool {
        
        
        var docPath = NSHomeDirectory().stringByAppendingPathComponent("Documents")
        var filePath = docPath.stringByAppendingPathComponent("\(fileName)")
        //println("path = \(filePath)")
        
        var filemanager = NSFileManager.defaultManager()
        
        if filemanager.fileExistsAtPath(filePath){
            return true
        }
        return false
    }
    
    class func isStart(bool: Bool){
        if bool == true{
            downLoadAllFile()
            downLoadJSON()
        }
    }

    
    class func finish() {
        
    }
    
    //下载所有文件
    class func downLoadAllFile(){
        
//        Alamofire.request(.GET, Router.baseURLFile+"/meeting/current").responseJSON(options: NSJSONReadingOptions.MutableContainers) { (_, _, data, err) -> Void in
       
        
        Alamofire.request(.GET, ServerConfig.getMeetingService()).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (_, _, data, err) -> Void in
        if(err != nil){
                NSLog("download allfile error ==== %@", err!)
                //return
            }
            
            let json = JSON(data!)
            
            if let filesInfo = json["files"].array
            {
                //获取所有的文件信息
                for var i = 0 ;i < filesInfo.count ; i++ {
                    var file = filesInfo[i]
                    
                    var fileid = file["_id"].stringValue
                    var filename = file["name"].stringValue
                    
//                    var filepath = Router.baseURLFile + "/file/" + fileid + ".pdf"
                    
                    
                    var filepath = ServerConfig.getFileService() + fileid + ".pdf"
                    var getPDFURL = NSURL(string: filepath)
                    
                    
                    let destination: (NSURL, NSHTTPURLResponse) -> (NSURL) = {
                        (temporaryURL, response) in
                        if let directoryURL = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.AllDomainsMask)[0] as? NSURL{
                            var filenameURL = directoryURL.URLByAppendingPathComponent("\(filename)")
                            
                            return filenameURL
                        }
                        return temporaryURL
                    }
                    
                    //判断../Documents是否存在当前filename为名的文件，如果存在，则返回；如不存在，则下载文件
                    var b = self.isSamePDFFile(filename)
                    
                    if b == false{
                        Alamofire.download(.GET, getPDFURL!, destination)
                        println("下载\(filename)成功")
                    }
                }
            }
        }
    }
    
    
    
    //下载json数据到本地并保存
    class func downLoadJSON(){
        
        Alamofire.request(.GET, ServerConfig.getMeetingService()).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (_, _, data, err) -> Void in
            var jsonFilePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/jsondata.txt")
            
            //println("\(jsonFilePath)")
            
            if(err != nil){
                println("下载当前json出错，error ===== \(err)")
                return
            }
            var jsondata = NSJSONSerialization.dataWithJSONObject(data!, options: NSJSONWritingOptions.allZeros, error: nil)
            
            //如果当前json和服务器上的json数据不一样，则保存。保存成功提示：当前json保存成功，否则提示：当前json保存失败。
            var bool = self.isSameJSONData(jsondata!)
            if !bool{
                var b = jsondata?.writeToFile(jsonFilePath, atomically: true)
                if (b! == true) {
                    NSLog("当前json保存成功")
                }
                else{
                    NSLog("当前json保存失败")
                }
                
            }
            
            var manager = NSFileManager.defaultManager()
            if !manager.fileExistsAtPath(jsonFilePath){
                var b = manager.createFileAtPath(jsonFilePath, contents: nil, attributes: nil)
                if b{
                    println("创建json成功")
                }
            }
        }
    }
    
}
