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

const express = require('express');
const path = require('path');
const fs = require('fs');
const admZip = require('adm-zip');
const fse = require("fs-extra");

const assetsDir = "./assets";
const docsStorageDir = `${assetsDir}/images`;
const celleryRepoDir = '/root/.cellery/repo';
const docsViewBaseFilesDir = '/usr/share/cellery/docs-view';

const port = 9990;
let app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: false }));

const renderDocsViewPage = (cell) => "<!DOCTYPE html>" +
    "<html lang='en'>" +
    "<head>" +
    "<meta charset='utf-8'>" +
    `<link rel="shortcut icon" href="/files/favicon.ico" type="image/x-icon"/>` +
    `<link rel="stylesheet" type="text/css" href="/files/style.css">` +
    "<title>Cellery Docs View</title>" +
    "</head>" +
    "<body>" +
    `<header>` +
    `<div class="line">` +
    `<img class="imgrules" src="/files/cellery-logo.svg" alt="cellery-logo">` +
    `<h6 class="cellery-header">Image View</h6>` +
    `</div>` +
    `</header>` +
    `<div class="center">`+
    `<h1>Cell Images List</h1>`+
    `<ol class="list-numbered">`+
    generateCellListingHtml(cell) +
    '</ol>' +
    `</div>`+
    "</body>" +
    "</html";

const renderErrorPage = () => "<!DOCTYPE html>" +
    "<html lang='en'>" +
    "<head>" +
    "<meta charset='utf-8'>" +
    `<link rel="shortcut icon" href="/files/favicon.ico" type="image/x-icon"/>` +
    `<link rel="stylesheet" type="text/css" href="/files/style.css">` +
    "<title>Cellery Docs View</title>" +
    "</head>" +
    "<body>" +
    `<header>` +
    `<div class="line">` +
    `<img class="imgrules" src="/files/cellery-logo.svg" alt="cellery-logo">` +
    `<h6 class="cellery-header">Image View</h6>` +
    `</div>` +
    `</header>` +
    `<div class="center">`+
    `<h1>No Cells Available</h1>`+
    `</div>`+
    "</body>" +
    "</html";

function generateCellListingHtml(cell) {
    let resultString = "";
    for (let i = 0; i < cell.length; i++) {
        resultString += `<li><a href=/files/images/${cell[i].filename} target="_blank">${cell[i].org}/${cell[i].name}:${cell[i].version}</a></li>`
    }
    return resultString;
}

app.use("/docs", function (req, res) {
    try {
        let cellDetailsList = getCellDetails();
        if (!fs.existsSync(docsStorageDir)) {
            fs.mkdirSync(docsStorageDir);
        }
        let cellDocsViewInfoList = createCellDocsDir(cellDetailsList);
        if (cellDocsViewInfoList.length === 1) {
            res.redirect("/files/images/" + cellDocsViewInfoList[0].filename);
        } else {
            res.send(renderDocsViewPage(cellDocsViewInfoList));
        }
    } catch (e) {
        console.log(e);
        res.send(renderErrorPage());
    }
});

app.use('/files', express.static(assetsDir));

function createCellDocsDir(cellDetailsList) {
    for (let i = 0; i < cellDetailsList.length; i++) {
        let cell = cellDetailsList[i];
        let cellDocsFolderPath = path.join(docsStorageDir, `${cell.org}-${cell.name}-${cell.version}`);
        cell.filename = `${cell.org}-${cell.name}-${cell.version}`;
        if (fs.existsSync(cellDocsFolderPath)) {
            deleteFolderRecursive(cellDocsFolderPath)
        }
        fs.mkdirSync(cellDocsFolderPath);
        fse.copySync(docsViewBaseFilesDir, cellDocsFolderPath);
        let zip = new admZip(cell.filepath);
        zip.extractEntryTo("artifacts/cellery/metadata.json", path.join(cellDocsFolderPath, "data"), false, true);
        let cellDataFile = path.join(cellDocsFolderPath, "data", "cell.js");
        fs.renameSync(path.join(cellDocsFolderPath, "data", "metadata.json"), cellDataFile);
        appendCellMetaData(cellDataFile)
    }
    return cellDetailsList;
}

function findCellZipFiles(directory) {
    let files = fs.readdirSync(directory);
    let cellZipFileList = [];
    for (let i = 0; i < files.length; i++) {
        let filepath = path.join(directory, files[i]);
        let filename = files[i];
        let stat = fs.lstatSync(filepath);
        if (stat.isDirectory()) {
            let file = findCellZipFiles(filepath);
            if (file.length !== 0) {
                cellZipFileList = cellZipFileList.concat(file)
            }
        } else if (filename.indexOf('.zip') >= 0) {
            cellZipFileList.push(filepath);
            return cellZipFileList;
        }
    }
    return cellZipFileList;
}

function getCellDetails() {
    let cellZipFileList = findCellZipFiles(celleryRepoDir);
    let cellDetailsList = [];
    for (let i = 0; i < cellZipFileList.length; i++) {
        let filepath = cellZipFileList[i];
        let directoryList = path.dirname(filepath).split(path.sep);
        let cell = {
            name: directoryList[directoryList.length - 2],
            version: directoryList[directoryList.length - 1],
            org: directoryList[directoryList.length - 3],
            filepath: filepath,
            filename: ""
        };
        cellDetailsList.push(cell);
    }
    return cellDetailsList;
}

function appendCellMetaData(cellDataFile) {
    let data = fs.readFileSync(cellDataFile);
    let fd = fs.openSync(cellDataFile, 'w+');
    let buffer = new Buffer('window.__CELL_METADATA__ = ');
    fs.writeSync(fd, buffer, 0, buffer.length, 0);
    fs.writeSync(fd, data, 0, data.length, buffer.length);
    fs.closeSync(fd);
}

let deleteFolderRecursive = function (path) {
    if (fs.existsSync(path)) {
        fs.readdirSync(path).forEach(function (file, index) {
            let curPath = path + "/" + file;
            if (fs.lstatSync(curPath).isDirectory()) { // recurse
                deleteFolderRecursive(curPath);
            } else { // delete file
                fs.unlinkSync(curPath);
            }
        });
        fs.rmdirSync(path);
    }
};

app.listen(port, () => console.log(`Docs view Service is running on port ${port}!`));

module.exports = app;
