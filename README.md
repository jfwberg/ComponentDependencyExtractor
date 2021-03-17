  
## PACKAGE LINK
https://login.salesforce.com/packaging/installPackage.apexp?p0=04t0H000000cb4R

## COMPONENT DEPENDENCY EXTRACTOR (CDE) ##
The CDE is a tool to extract all metadata dependencies from the tooling API.
This API has it's limitations so this tool is build to have a dirty way of just collecting the dependencies one by one in a batch manner.
This is mainly a big issue with custom fields, the most used function.

## HOW DOES IT WORK ##
1) It has 2 custom obejcts, one to hold the metadata item and one one to hold the relationshipt between the two
2) It queries all metadata for a specified type (except custom fields)
3) Once queried, for each metadata item a batch runs to update the dependency
4) All is updateble by pressing the update button in case of new objects

## POST INSTALL
1) Add yourself to the component dependency extractor permission set
2) open the component dependency extractor from the app launcher
3) Select object and press update.

## NOTES
- For CustomFields you first need to extract the custom objects
- After custom object extraction the custom field depencies can be extracted, again by pressing the update button
- Does not yet extract custom fields from standard objects
