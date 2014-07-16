# EdmodoConnectIOS

[![Version](https://img.shields.io/cocoapods/v/EdmodoConnectIOS.svg?style=flat)](http://cocoadocs.org/docsets/EdmodoConnectIOS)
[![License](https://img.shields.io/cocoapods/l/EdmodoConnectIOS.svg?style=flat)](http://cocoadocs.org/docsets/EdmodoConnectIOS)
[![Platform](https://img.shields.io/cocoapods/p/EdmodoConnectIOS.svg?style=flat)](http://cocoadocs.org/docsets/EdmodoConnectIOS)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

EdmodoConnectIOS is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "EdmodoConnectIOS"

## Author

Doug Banks, doug@edmodo.com

## License

EdmodoConnectIOS is available under the MIT license. See the LICENSE file for more info.

## Usage
### Get an access token.
Use EMConnectLoginView to bring up a webview where users can authenticate.  If that succeeds the success block is called with your access token.
### Use the API
Once you have your access token, use EMConnectDataStore to do asynchronous communication with the EdmodoConnect API.
### Use EMObjects as a cache
Pass your configured data store to EMObjects and call resetFromDataStore.  When that asynchronous command is resolved, the authenticated user's edmodo network (groups, teachers, etc) has been pulled into EMObjects.  Users and groups are bundled into convenient classes and are available through function calls on EMObjects.
### Shortcut: EMLoginService
EMLoginService is a wrapper around everything up to and including passing a data store into EMObjects.  On a success callback, simply call resetFromDataStore on EMObjects.
EMLoginService also supports a mock data store so you can quickly log in as different parties. The mock store has no real connection to Edmodo, but it populates the EMObjects with a useful set of entities so you can focus debugging efforts on the logic on top of that level.
