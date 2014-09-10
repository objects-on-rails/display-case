# Change Log
All notable changes to this project will be documented in this file.


## 0.1.1 - 2014-09-10
### Added
- Change log (this file) (see: http://keepachangelog.com/)

### Fixed
- [#51](https://github.com/objects-on-rails/display-case/pull/51): Will now re-exhibit an exhibited model when rendering from an exhibit. This ensures that the exhibit chain includes all possible exhibit objects instead of just `self`. (by @pdobb)


## 0.1.0 - 2013-07-22
### Added
- [#47](https://github.com/objects-on-rails/display-case/pull/47): Ability to send an options hash to the `render` method. (by @pdobb)
- [#45](https://github.com/objects-on-rails/display-case/pull/45): Add `pop` as a query_method on DisplayCase::EnumerableExhibit. This ensures that `pop`ping the result of an exhibited list of objects returns an exhibited object. (by @pdobb)
