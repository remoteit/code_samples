# Scripts

Scripting is a feature that allows you to run a script unattended 
(written in any interpreted language you have installed on your Operating System) 
on any number of devices with a Linux or Windows based operating system.

## Environment Variables Available
JOB_DEVICE_ID - The job device ID of the device being managed
GRAPHQL_API_PATH - The GraphQL API path to the remote.it api server

### The following allow selecting a file, entering a string or selecting from a list,

1. <arguments>, <type>, <name>, <prompt>, <option1>, <option2>, ... 
1. FileSelect, imageFile, Select File, .png
1. StringEntry, url, Enter Fully-Qualified URL
1. StringEntry, bookmarkName, Enter Name For Bookmark
1. StringSelect, action, Choose Action, ADD, REMOVE



