import Foundation

private func executeGit(args: [String], workingDirectory: String? = nil) async throws -> String {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
    process.arguments = args
    
    if let workDir = workingDirectory {
        process.currentDirectoryURL = URL(fileURLWithPath: workDir)
    }
    
    let outputPipe = Pipe()
    let errorPipe = Pipe()
    process.standardOutput = outputPipe
    process.standardError = errorPipe
    
    try process.run()
    process.waitUntilExit()
    
    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
    
    let output = String(data: outputData, encoding: .utf8) ?? ""
    let error = String(data: errorData, encoding: .utf8) ?? ""
    
    guard process.terminationStatus == 0 else {
        throw ToolError.executionFailed(error.isEmpty ? output : error)
    }
    
    return output.trimmingCharacters(in: .whitespacesAndNewlines)
}

public struct GitInitTool: ToolCallable {
    public let toolID = ToolID.gitInit
    public let displayName = "Git Init"
    public let description = "Initialize a new Git repository"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let path = parameters["path"] as? String else {
            throw ToolError.invalidParameters("Missing 'path'")
        }
        let output = try await executeGit(args: ["init"], workingDirectory: path)
        return .success(output)
    }
}

public struct GitCloneTool: ToolCallable {
    public let toolID = ToolID.gitClone
    public let displayName = "Git Clone"
    public let description = "Clone a remote repository"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let url = parameters["url"] as? String else {
            throw ToolError.invalidParameters("Missing 'url'")
        }
        let destination = parameters["destination"] as? String
        var args = ["clone", url]
        if let dest = destination {
            args.append(dest)
        }
        let output = try await executeGit(args: args)
        return .success(output)
    }
}

public struct GitStatusTool: ToolCallable {
    public let toolID = ToolID.gitStatus
    public let displayName = "Git Status"
    public let description = "Show working tree status"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let path = parameters["path"] as? String else {
            throw ToolError.invalidParameters("Missing 'path'")
        }
        let output = try await executeGit(args: ["status", "--porcelain"], workingDirectory: path)
        return .success(output)
    }
}

public struct GitAddTool: ToolCallable {
    public let toolID = ToolID.gitAdd
    public let displayName = "Git Add"
    public let description = "Add files to staging area"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let path = parameters["path"] as? String else {
            throw ToolError.invalidParameters("Missing 'path'")
        }
        let files = parameters["files"] as? [String] ?? ["."]
        let output = try await executeGit(args: ["add"] + files, workingDirectory: path)
        return .success(output.isEmpty ? "Files added to staging" : output)
    }
}

public struct GitCommitTool: ToolCallable {
    public let toolID = ToolID.gitCommit
    public let displayName = "Git Commit"
    public let description = "Record changes to the repository"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let path = parameters["path"] as? String,
              let message = parameters["message"] as? String else {
            throw ToolError.invalidParameters("Missing 'path' or 'message'")
        }
        let output = try await executeGit(args: ["commit", "-m", message], workingDirectory: path)
        return .success(output)
    }
}

public struct GitPushTool: ToolCallable {
    public let toolID = ToolID.gitPush
    public let displayName = "Git Push"
    public let description = "Push changes to remote repository"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let path = parameters["path"] as? String else {
            throw ToolError.invalidParameters("Missing 'path'")
        }
        let remote = parameters["remote"] as? String ?? "origin"
        let branch = parameters["branch"] as? String
        var args = ["push", remote]
        if let b = branch {
            args.append(b)
        }
        let output = try await executeGit(args: args, workingDirectory: path)
        return .success(output)
    }
}

public struct GitPullTool: ToolCallable {
    public let toolID = ToolID.gitPull
    public let displayName = "Git Pull"
    public let description = "Fetch and merge from remote repository"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let path = parameters["path"] as? String else {
            throw ToolError.invalidParameters("Missing 'path'")
        }
        let output = try await executeGit(args: ["pull"], workingDirectory: path)
        return .success(output)
    }
}

public struct GitBranchTool: ToolCallable {
    public let toolID = ToolID.gitBranch
    public let displayName = "Git Branch"
    public let description = "List, create, or delete branches"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let path = parameters["path"] as? String else {
            throw ToolError.invalidParameters("Missing 'path'")
        }
        let name = parameters["name"] as? String
        let delete = parameters["delete"] as? Bool ?? false
        
        var args = ["branch"]
        if delete, let n = name {
            args += ["-d", n]
        } else if let n = name {
            args.append(n)
        }
        
        let output = try await executeGit(args: args, workingDirectory: path)
        return .success(output)
    }
}

public struct GitCheckoutTool: ToolCallable {
    public let toolID = ToolID.gitCheckout
    public let displayName = "Git Checkout"
    public let description = "Switch branches or restore files"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let path = parameters["path"] as? String,
              let target = parameters["target"] as? String else {
            throw ToolError.invalidParameters("Missing 'path' or 'target'")
        }
        let createNew = parameters["create"] as? Bool ?? false
        var args = ["checkout"]
        if createNew {
            args.append("-b")
        }
        args.append(target)
        let output = try await executeGit(args: args, workingDirectory: path)
        return .success(output)
    }
}

public struct GitMergeTool: ToolCallable {
    public let toolID = ToolID.gitMerge
    public let displayName = "Git Merge"
    public let description = "Merge branches"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let path = parameters["path"] as? String,
              let branch = parameters["branch"] as? String else {
            throw ToolError.invalidParameters("Missing 'path' or 'branch'")
        }
        let output = try await executeGit(args: ["merge", branch], workingDirectory: path)
        return .success(output)
    }
}

public struct GitRebaseTool: ToolCallable {
    public let toolID = ToolID.gitRebase
    public let displayName = "Git Rebase"
    public let description = "Reapply commits on top of another base"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let path = parameters["path"] as? String,
              let onto = parameters["onto"] as? String else {
            throw ToolError.invalidParameters("Missing 'path' or 'onto'")
        }
        let output = try await executeGit(args: ["rebase", onto], workingDirectory: path)
        return .success(output)
    }
}

public struct GitLogTool: ToolCallable {
    public let toolID = ToolID.gitLog
    public let displayName = "Git Log"
    public let description = "Show commit logs"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let path = parameters["path"] as? String else {
            throw ToolError.invalidParameters("Missing 'path'")
        }
        let limit = parameters["limit"] as? Int ?? 10
        let output = try await executeGit(args: ["log", "--oneline", "-n", "\(limit)"], workingDirectory: path)
        return .success(output)
    }
}

public struct GitDiffTool: ToolCallable {
    public let toolID = ToolID.gitDiff
    public let displayName = "Git Diff"
    public let description = "Show changes between commits, branches, or working tree"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let path = parameters["path"] as? String else {
            throw ToolError.invalidParameters("Missing 'path'")
        }
        let target = parameters["target"] as? String
        var args = ["diff"]
        if let t = target {
            args.append(t)
        }
        let output = try await executeGit(args: args, workingDirectory: path)
        return .success(output)
    }
}

public struct GitStashTool: ToolCallable {
    public let toolID = ToolID.gitStash
    public let displayName = "Git Stash"
    public let description = "Stash changes in working directory"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let path = parameters["path"] as? String else {
            throw ToolError.invalidParameters("Missing 'path'")
        }
        let action = parameters["action"] as? String ?? "push"
        let output = try await executeGit(args: ["stash", action], workingDirectory: path)
        return .success(output)
    }
}

public struct GitTagTool: ToolCallable {
    public let toolID = ToolID.gitTag
    public let displayName = "Git Tag"
    public let description = "Create, list, or delete tags"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let path = parameters["path"] as? String else {
            throw ToolError.invalidParameters("Missing 'path'")
        }
        let name = parameters["name"] as? String
        var args = ["tag"]
        if let n = name {
            args.append(n)
        }
        let output = try await executeGit(args: args, workingDirectory: path)
        return .success(output)
    }
}

public struct GitRemoteTool: ToolCallable {
    public let toolID = ToolID.gitRemote
    public let displayName = "Git Remote"
    public let description = "Manage remote repositories"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let path = parameters["path"] as? String else {
            throw ToolError.invalidParameters("Missing 'path'")
        }
        let action = parameters["action"] as? String ?? "show"
        let output = try await executeGit(args: ["remote", action], workingDirectory: path)
        return .success(output)
    }
}

public struct GitResetTool: ToolCallable {
    public let toolID = ToolID.gitReset
    public let displayName = "Git Reset"
    public let description = "Reset current HEAD to specified state"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let path = parameters["path"] as? String else {
            throw ToolError.invalidParameters("Missing 'path'")
        }
        let target = parameters["target"] as? String ?? "HEAD"
        let hard = parameters["hard"] as? Bool ?? false
        var args = ["reset"]
        if hard {
            args.append("--hard")
        }
        args.append(target)
        let output = try await executeGit(args: args, workingDirectory: path)
        return .success(output)
    }
}

public struct GitRevertTool: ToolCallable {
    public let toolID = ToolID.gitRevert
    public let displayName = "Git Revert"
    public let description = "Revert commits"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let path = parameters["path"] as? String,
              let commit = parameters["commit"] as? String else {
            throw ToolError.invalidParameters("Missing 'path' or 'commit'")
        }
        let output = try await executeGit(args: ["revert", "--no-edit", commit], workingDirectory: path)
        return .success(output)
    }
}

public struct GitCherryPickTool: ToolCallable {
    public let toolID = ToolID.gitCherryPick
    public let displayName = "Git Cherry Pick"
    public let description = "Apply changes from specific commits"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let path = parameters["path"] as? String,
              let commit = parameters["commit"] as? String else {
            throw ToolError.invalidParameters("Missing 'path' or 'commit'")
        }
        let output = try await executeGit(args: ["cherry-pick", commit], workingDirectory: path)
        return .success(output)
    }
}

public struct GitBlameTool: ToolCallable {
    public let toolID = ToolID.gitBlame
    public let displayName = "Git Blame"
    public let description = "Show what revision and author last modified each line"
    
    public func execute(parameters: [String: Any]) async throws -> ToolResult {
        guard let path = parameters["path"] as? String,
              let file = parameters["file"] as? String else {
            throw ToolError.invalidParameters("Missing 'path' or 'file'")
        }
        let output = try await executeGit(args: ["blame", file], workingDirectory: path)
        return .success(output)
    }
}
