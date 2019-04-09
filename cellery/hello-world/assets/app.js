/*
 * Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

var express = require('express');
var path = require('path');
var fs=require('fs');
var exec = require('child_process').exec;

const temp = `/tmp/`;
const port = 9990;
var app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: false }));

app.use('/hello', function (req, res) {
    exec("cellery view wso2cellery/cells-hello-world-webapp:0.1.0", function(err, stdout, stderr) {
        console.log(stdout);
    });
    var docViewFiles = getCelleryDocsFolders();
    var docViewFolder = getLastCreatedFolder(docViewFiles);
    app.use(express.static(docViewFolder));
    res.sendFile(path.join(docViewFolder, 'index.html'));
});

function getCelleryDocsFolders(){
    var files=fs.readdirSync(temp);
    var docViewFiles = [];
    for(var i=0;i<files.length;i++){
        var filepath=path.join(temp,files[i]);
        var filename = files[i];
        var stat = fs.lstatSync(filepath);
        if (stat.isDirectory()){
            if (filename.startsWith('cellery-docs-view')) {
                docViewFiles.push(filepath)
            }
        }
    }
    return docViewFiles;
}

function getLastCreatedFolder (folderList) {
    var latestFolderPath = folderList[0];
    var latestFolderTime = folderList[0];
    for(var i=0;i<folderList.length;i++){
        var stat = fs.lstatSync(folderList[i]);
        var currentFolderCreationTime = stat.ctime;
        if (currentFolderCreationTime > latestFolderTime) {
            latestFolderPath = folderList[i];
            latestFolderTime = currentFolderCreationTime;
        }
    }
    return latestFolderPath;
}

app.listen(port, () => console.log(`Hello World Web App is running on port ${port}!`));

module.exports = app;
