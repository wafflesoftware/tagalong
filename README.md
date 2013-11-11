# Tagalong
## An ad-hoc system to generate dependent files without a build system

Tagalong is an application which watches the system for changes to files with specified OS X (Mavericks) file system tags and invokes a specified script when they change. The script gets the path to the file as an argument and will print the desired output of the dependent file on STDOUT. This file will be created with the file name of the original file and an extra file extension.

For example, this readme is written in Markdown. On my computer, it is tagged with @markdown which has been associated with the extra extension .html and the original Markdown script. When the file is saved, the document README.md.html is created momentarily with the transformed file.

When the script is run, the original file is marked with a custom attribute, marking the file modification date of which the current dependent document was created. When the script next triggers, it will check this attribute to see if the file modification date has changed and avoid running the script and recreating the file is that is the case.

Tagalong is a proof of concept, licensed under the new BSD license:

    Copyright (c) 2013, waffle software
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
    
    1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    
    2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    

## Known bugs or issues

* The Spotlight query does not always trigger.

* The initial mode of operation works with Markdown, but not with many other obvious applications, like LESS or TypeScript, which would be able to do a decent job. The files are indeed created as part of the normal operation of these programs, but at the risk of creating useless shadow files.

* The app should be more robust. 
  * It currently applies every change instantly.
  * The Spotlight query only searches the user's home folder. (This might be a setting per row.)

* The app should perhaps be split into a daemon handling the continuous application of the scripts and an app for configuration.