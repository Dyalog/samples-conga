# samples-conga

This repository contains samples based on TCP communication using the CONGA library. Installations of Dyalog APL from version 16.0 (June 2017) will contain these folders and files in the folder Samples/Conga below the main Dyalog folder.

The Conga samples are organised into a number of folders:

## Folder CertTool
This currently only contains a single sample, which shows how the GnuTLS certTool can be used to generate self-signed certificates.

## Folder HttpServers
This folder contains a number of HTTP servers which can be used with the new Conga.Srv function. Most of the samples can be loaded and run using a recipe similar to the following:

    ]load Samples/Conga/HttpServers/DocHttpRequest
    iSrv←Conga.Srv 8088 DocHttpRequest
    iSrv.Start

    ]load Library/Conga/HttpCommand
    (rc headers data)←HttpCommand.Get 'http://localhost:8088/index.html'

## Folder RPCServices

This folder contains examples of simple servers that can be used to make remote procedure calls using Conga's Command mode, in which each transmission consists of an APL array.



