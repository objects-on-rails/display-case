# Change Log
All notable changes to this project will be documented in this file.

## Unreleased
### Added
- Change log (this file) (see: http://keepachangelog.com/)
- `reexhibit` method to allow an exhibited object a chance to re-select the appropriate exhibit for ensuing method call(s). (by @pdobb)


## 0.1.0 - 2013-07-22
### Added
- Ability to send an options hash to the `render` method. (by @pdobb)
- Add `pop` as a query_method on DisplayCase::EnumerableExhibit. This ensures that `pop`ping the result of an exhibited list of objects returns an exhibited object. (by @pdobb)
