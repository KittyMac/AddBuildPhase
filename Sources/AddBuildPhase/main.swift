import AddBuildPhaseFramework
import ArgumentParser

struct AddBuildPhase: ParsableCommand {
    
    @Argument(help: "Path to project.pbxproj file")
    var xcodeProject: String
    
    @Argument(help: "Name of the target to add the build script phase to")
    var targetName: String
    
    @Argument(help: "The script to run in the build phase being added")
    var script: String

    mutating func run() throws {
        if !AddBuildPhaseFramework().process(xcodeProject, targetName, script) {
            fatalError("Failed to add build script phase to project")
        }
    }

}

AddBuildPhase.main()
