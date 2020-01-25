//
//  ConfigurationTool.swift
//  
//
//  Created by Phil Wilson on 25/1/20.
//

import Foundation
import FileService

public final class ConfigurationTool
{
    public let configurationModel = ConfigurationModel()
    
    public init() {
        let fileService = FileService()
        fileService.generateDefaultConfigurationFile()
    }
}
