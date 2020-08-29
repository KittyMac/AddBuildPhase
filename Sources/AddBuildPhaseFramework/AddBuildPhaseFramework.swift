import Foundation
import Ipecac

public struct AddBuildPhaseFramework {
    
    public init() {
        
    }
    
    @discardableResult
    public func process(_ path: String, _ target: String, _ script: String) -> Bool {
        let projectUrl = URL(fileURLWithPath: path)
        guard let projectData = try? Data(contentsOf: projectUrl) else { return false }
        guard let project = try? PropertyListSerialization.propertyList(from:projectData, options: .mutableContainersAndLeaves, format: nil) as? NSObject else { return false }
                
        //print(project)
        // Extract all of the objects we need from the project.  This includes:
        // "objects" - root level thing which contains lookup values of all objects
        // "target" - the target object for the named target we were given
        // "buildPhases" - the build phases object for the "target" object
        guard let objects = project.value(forKey: "objects") as? NSObject else { return false }
        guard let target = objects.value(forKey: target) as? NSObject else { return false }
        guard let buildPhases = target.value(forKey: "buildPhases") as? NSMutableArray else { return false }
        
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
