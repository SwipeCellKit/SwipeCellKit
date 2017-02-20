# CHANGELOG

`SwipeCellKit` adheres to [Semantic Versioning](http://semver.org/).

---

## [1.2.1](https://github.com/jerkoch/SwipeCellKit/releases/tag/1.2.1)

#### Fixed

- Call `reset` at the end of a destructive swipe to ensure the tableView gestures are re-enabled (#3).
- Feedback was not being generated when swiping from non-centered state
- `SwipeTableViewCellDelegate` compiler error in README example.

---

## [1.2.0](https://github.com/jerkoch/SwipeCellKit/releases/tag/1.2.0)

#### Breaking

- Update `SwipeTableViewCellDelegate` allowing `editActionsForRowAt` to return `nil` and prevent swiping in the supplied orientation (#2).

#### Added

- Example app now lets you choose to disable swiping right. 
- Expose `hideSwipe(animated:)` to allow the cell to be programmatically hidden.

---

## [1.1.1](https://github.com/jerkoch/SwipeCellKit/releases/tag/1.1.1)

#### Fixed

- Memory leak in `SwipeActionsView` holding reference to actions causing a retain cycle.

---

## [1.1.0](https://github.com/jerkoch/SwipeCellKit/releases/tag/1.1.0)
This release is mainly for Swift Package Manager support and some minor documentation clean up.

#### Added

- Swift Package Manager support.
- A CHANGELOG to the project documenting each official release.
- Examples of available transitions and expansions to the README.

#### Fixed

- The `SwipeTableViewCellDelegate` default implementation not exposed as `public`.

---

## [1.0.0](https://github.com/jerkoch/SwipeCellKit/releases/tag/1.0.0)

Initial release!
