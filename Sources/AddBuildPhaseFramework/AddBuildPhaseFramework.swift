import Foundation
import Ipecac

public struct AddBuildPhaseFramework {
    
    public init() {
        
    }
    
    @discardableResult
    public func process(_ path: String, _ targetString: String, _ script: String) -> Bool {
        let projectUrl = URL(fileURLWithPath: path)
        guard let projectData = try? Data(contentsOf: projectUrl) else { return false }
        guard let project = try? PropertyListSerialization.propertyList(from:projectData, options: .mutableContainersAndLeaves, format: nil) as? NSObject else { return false }
                
        //print(project)
        // Extract all of the objects we need from the project.  This includes:
        // "objects" - root level thing which contains lookup values of all objects
        // "target" - the target object for the named target we were given
        // "buildPhases" - the build phases object for the "target" object
        guard let objects = project.value(forKey: "objects") as? NSDictionary else { return false }
        
        // Need to perform a case-insensitive search as different xcode versions perform
        // different transformations on name casing (ie target MyProject::Pamphlet vs myproject::Pamphlet)
        var actualTargetString = ""
        for key in objects.allKeys {
            if let keyString = key as? String,
               keyString.lowercased() == targetString.lowercased() {
                actualTargetString = keyString
                break
            }
        }
        guard actualTargetString.count > 0 else { return false }
        guard let target = objects.value(forKey: actualTargetString) as? NSObject else { return false }
        guard let buildPhases = target.value(forKey: "buildPhases") as? NSMutableArray else { return false }
        
        // set CURRRENT_PROJECT_VERSION of all build configurations to 1
        for key in objects.allKeys {
            guard let object = objects[key] as? NSObject else { continue }
            guard let isa = object.value(forKey: "isa") as? NSString else { continue }
            guard isa == "XCBuildConfiguration" else { continue }
            guard let buildSettings = object.value(forKey: "buildSettings") as? NSObject else { continue }
            guard buildSettings.value(forKey: "INFOPLIST_FILE") != nil else { continue }
            
            buildSettings.setValue("1", forKey: "CURRENT_PROJECT_VERSION")
        }
        
        
        // insert new run script build phase in objects
        let emptyArray = NSMutableArray()
        
        let runScriptUUID = UUID().uuidString
        let runScriptObject = NSMutableDictionary()
        
        runScriptObject.setValue("PBXShellScriptBuildPhase", forKey: "isa")
        runScriptObject.setValue(NSNumber(integerLiteral: 2147483647), forKey: "buildActionMask")
        runScriptObject.setValue(emptyArray, forKey: "files")
        runScriptObject.setValue(emptyArray, forKey: "inputFileListPaths")
        runScriptObject.setValue(emptyArray, forKey: "inputPaths")
        runScriptObject.setValue(emptyArray, forKey: "outputFileListPaths")
        runScriptObject.setValue(emptyArray, forKey: "outputPaths")
        runScriptObject.setValue(NSNumber(integerLiteral: 0), forKey: "runOnlyForDeploymentPostprocessing")
        runScriptObject.setValue("/bin/sh", forKey: "shellPath")
        runScriptObject.setValue(script, forKey: "shellScript")
                
        buildPhases.insert(runScriptUUID, at: 0)
        
        objects.setValue(runScriptObject, forKey: runScriptUUID)
                
        guard let outputData = try? PropertyListSerialization.data(fromPropertyList: project, format: PropertyListSerialization.PropertyListFormat.binary, options: 0) else { return false }
        do {
            try outputData.write(to: projectUrl, options: .atomic)
        } catch {
            return false
        }
        
        return true
    }
}
