Ingest NSFs With Keys
=====================

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0)

View the GitHub project [here](LINK_TO_PROJECT) or download the latest release [here](LINK_TO_PROJECT_RELEASES).

# Overview

This script allows bulk ingestion of multiple NSF files which all require ID files.

![image](https://user-images.githubusercontent.com/11775738/84305388-db93a680-ab0e-11ea-8c4f-5ec65893f14f.png)



# Getting Started

## Setup

Begin by downloading the latest release of this code.  Extract the contents of the archive into your Nuix scripts directory.  In Windows the script directory is likely going to be either of the following:

- `%appdata%\Nuix\Scripts` - User level script directory
- `%programdata%\Nuix\Scripts` - System level script directory

# Usage

## Input CSV

![image](https://user-images.githubusercontent.com/11775738/84305429-ecdcb300-ab0e-11ea-8bd4-baa78606511f.png)

- `EvidenceContainerName` - The name of the evidence container which will be created to contain the given NSF.
- `NsfFilePath` - The absolute file path to a given NSF file.
- `IdFilePath` - The absolute file path to the corresponding ID file for this NSF.
- `IdFilePassword` - The password for the corresponding ID file.

## Processing Settings

To modify the processing settings not related to workers, edit the file `Settings.json` included with the script. Details about the settings can be found in the API documentation for [Processor.setProcessingSettings](https://download.nuix.com/releases/desktop/stable/docs/en/scripting/api/nuix/Processor.html#setProcessingSettings-java.util.Map-).

**You should review the processing settings before using this script to make sure the defaults provided are as desired!**

## Script Steps

1. Prompt for input with iniital dialog
2. Load records from CSV file specified
3. Create processor instance
4. Configure processing settings based on `Settings.json`
5. Configure parallel processing settings based on dialog input
6. For each record in CSV
    1. Add evidence container based on record value for `EvidenceContainerName`
    2. Add file to evidence container based on record value for `NSFFilePath`
    3. Save evidence container
    4. Add keystore information to processor based on `IdFilePath`, `IdFilePassword`, `NsfFilePath` filename without extension
7. Once all entries are added, processing begins
8. A basic processing dialog will show progress until processing is completed

**Note that you may need to close and re-open any open workbench tabs, after processing completes, for the newly added evidence to be present in the list.**

![image](https://user-images.githubusercontent.com/11775738/84309409-eea97500-ab14-11ea-8c54-ef10ab9af788.png)

# Cloning this Repository

This script relies on code from [Nx](https://github.com/Nuix/Nx) to present a settings dialog and progress dialog.  This JAR file is not included in the repository (although it is included in release downloads).  If you clone this repository, you will also want to obtain a copy of Nx.jar by either:
1. Building it from [the source](https://github.com/Nuix/Nx)
2. Downloading an already built JAR file from the [Nx releases](https://github.com/Nuix/Nx/releases)

Once you have a copy of Nx.jar, make sure to include it in the same directory as the script.

# License

```
Copyright 2020 Nuix

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
