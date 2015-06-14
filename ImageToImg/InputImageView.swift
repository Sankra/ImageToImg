import Cocoa

class InputImageView: NSImageView, NSDraggingDestination {   
    var droppedFilePath: String?
    
    var supportedExtensions: [String]
    let draggedImage: NSImage
    let dndImage: NSImage
    
    required init?(coder: NSCoder) {
        dndImage = NSImage(named: "dnd")!
        draggedImage = NSImage(named: "dragged")!
        supportedExtensions = [String]()
        super.init(coder: coder)
        
        populateSupportedFileTypeList()
        registerForDraggedTypes([NSFilenamesPboardType, NSURLPboardType, NSPasteboardTypeTIFF])
        AppDelegate.imageView = self
    }
  
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        if isImage(sender) {
            image = draggedImage
            return .Copy
        } else {
            image = dndImage
            return .None
        }
    }
    
    override func draggingExited(sender: NSDraggingInfo?) {
        image = dndImage
    }
    
    override func draggingEnded(sender: NSDraggingInfo?) {
        if let imagePath = getFilePath(sender) {
            droppedFilePath = imagePath
        } else {
            droppedFilePath = nil
        }
    }
    
    func populateSupportedFileTypeList() {
        let documentTypes = NSBundle.mainBundle().infoDictionary?["CFBundleDocumentTypes"] as! NSArray
        for docInfo in documentTypes {
            let extensions = (docInfo as! NSDictionary)["CFBundleTypeExtensions"] as! NSArray
            for ext in extensions {
                supportedExtensions.append(ext as! String)
            }
        }
    }
   
    func isImage(drag: NSDraggingInfo) -> Bool {
        if let imagePath = getFilePath(drag) {
            if let url = NSURL(fileURLWithPath: imagePath) {
                return contains(supportedExtensions, url.pathExtension!)
            }
        }
        
        return false
    }
    
    func getFilePath(sender: NSDraggingInfo?) -> String? {
        if let draggingInfo = sender {
            if let board = draggingInfo.draggingPasteboard().propertyListForType("NSFilenamesPboardType") as? NSArray {
                return board[0] as? String
            }
        }
        
        return nil
    }
}
