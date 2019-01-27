# CHANGELOG

`SwipeCellKit` adheres to [Semantic Versioning](http://semver.org/).

## [2.5.1](https://github.com/jerkoch/SwipeCellKit/releases/tag/2.5.0)

#### Fixed

- Cells do not hide correctly when also using non-`SwipeCollectionViewCell` cells in `UICollectionView`. (#265)

---

## [2.5.0](https://github.com/jerkoch/SwipeCellKit/releases/tag/2.5.0)

#### Fixed

- Update to Swift 4.2 and Xcode 10 Support (#215)

---

## [2.4.3](https://github.com/jerkoch/SwipeCellKit/releases/tag/2.4.3)

#### Fixed

- Fix issue where swipe cell does not return to neutral position correctly when swipping cell very quickly (#215)

---

## [2.4.2](https://github.com/jerkoch/SwipeCellKit/releases/tag/2.4.2)

#### Fixed

- Fix swipe action position when rotating a UITableView/UICollectionView with safe area insets.
- Fix issue where gesture cancellation causes swipe cell to remain in dragging state in a non-left, right or centre x position.
- Fix issue where expansion may trigger when swiping in the expansion zone very quickly.

---

## [2.4.1](https://github.com/jerkoch/SwipeCellKit/releases/tag/2.4.1)

#### Fixed

- Fix issue with swipe action handler not being invoked correctly at all times (#204, #205)

---

## [2.4.0](https://github.com/jerkoch/SwipeCellKit/releases/tag/2.4.0)

#### Added

- `UICollectionView` support. You can now add swipe actions to a `UICollectionViewCell` by using the `SwipeCollectionViewCell` (#4)

---

## [2.3.2](https://github.com/jerkoch/SwipeCellKit/releases/tag/2.3.2)

#### Fixed

- Add default implementation for `visibleRect(for tableView: UITableView)` as its optional (#201)

---

## [2.3.1](https://github.com/jerkoch/SwipeCellKit/releases/tag/2.3.1)

#### Fixed

- Fix issue where swiping a cell does not work while another cell is open (#197)

---

## [2.3.0](https://github.com/jerkoch/SwipeCellKit/releases/tag/2.3.0)

#### Added

- Support for vertically centered swipe actions for tall cells. (#186)

#### Fixed

- Resolved issue where touching cell in swipe expantion zone resulted in immediate cell expansion (#194)
- Reselect swipped cell if it was previously selected (#58)

---

## [2.2.0](https://github.com/jerkoch/SwipeCellKit/releases/tag/2.2.0)

#### Added

- Swift 4.1 Support. (#181)
- Allow mix use of only image or text label actions. (#139)

#### Fixed

- Fix issue where multiple `SwipeTableViewCells` can be swipped simultaneously. (#57)

---

## [2.1.0](https://github.com/jerkoch/SwipeCellKit/releases/tag/2.1.0)

#### Added

- Add support for safeAreaInsets (i.e. iPhone X) (#159, #119)

#### Fixed

- Update README to fix an error with how to fulfill a delete row operation
- Fix crash related to `UIAccessablilityCustomAction` if no accessability text is set on action image, or action label. (#156)
- Fix issue where SwipeActionButton.maximumButtonWidth is not respected when its value is below the default/computed minimumButtonWidth (#150)

---

## [2.0.1](https://github.com/jerkoch/SwipeCellKit/releases/tag/2.0.1)

#### Fixed

- Fix issue where swipe actions intermittently on iOS 11.2 were not displayed correctly when cell is swiped. (#126)

---

## [2.0.0](https://github.com/jerkoch/SwipeCellKit/releases/tag/2.0.0)

#### Added

- Add Swift 4 support
- New `highlightedTextColor` property on `SwipeAction`. (#88)

#### Fixed

- Fix issue where swipe actions intermittently were not displayed when cell is swiped. (#85)

---

## [1.9.1](https://github.com/jerkoch/SwipeCellKit/releases/tag/1.9.1)

#### Fixed

- Fix issue related to pixel misalignment for action buttons. (#50)
- Fix crash on iOS 10.0.0 where UIFeedbackGenerator crashed on non-haptic supported devices. (#51)
- Fix issue related to iOS 11. SwipeCellKit was inadvertently enabling/disabling various gestures on UITableView, including system level ones in hopes of disabling 3D Touch on swiped UITableViewCells. Developers must now handle the disabling/enabling of 3D touch when cell is swiped with the aid of `SwipeTableViewCellDelegate`. (#48)

---

## [1.9.0](https://github.com/jerkoch/SwipeCellKit/releases/tag/1.9.0)

#### Added

- Added highlighted background color for action button. (#52)

#### Fixed

- Correctly setting the parents project to support iOS 9.0+. (#40)
- Fix issue where using non-`SwipeTableViewCell` within a `UITableView` interfered with `didSelectRowAtIndexPath`. This was caused by the assumption all cells in a UITableView extend `SwipeTableViewCell`. (#37) (#43)
- Add protection against `superview` in `point(inside:)` being `nil` and crashing. (#46)

---

## [1.8.0](https://github.com/jerkoch/SwipeCellKit/releases/tag/1.8.0)

#### Added

- New `targetOverscrollElasticity` property in `SwipeExpansionStyle` to support customization of elasticity when dragging past the expansion target. (#30)
- New `swipeOffset` property and `setSwipeOffset(_:animated:completion:)` in `SwipeTableViewCell` to support programmatically setting the swipe offset. (#19)
- Add support for relayout of action buttons if cell frame changes while swiped (ie. rotation/tableview resizing). Now that active/swiped `SwipeTableViewCells` no longer reset to center when the parent `UITableView` performs layout (#28), better support for `UITableView` frame/bounds changes are required.  The `UITableView` frame/bounds may change during rotation or whenever its parent view frame changes.  The `SwipeActionsView` was already using auto layout to resize appropriately, but its button (and wrapper) subviews were using constraints derived from the default autoresizingMask.  This change ensures the `SwipeActionButtonWrapperView` flexes with its parent `SwipeActionsView`, and button subviews pin to the appropriate left/right side of their wrapper view depending on orientation.

#### Fixed

- Fix issue where mask was not removed when using `.reset` style action fulfillment. (#27)
- Fix to adjust the cell's new frame origin `x` value when it's already active. This ensures a swiped cell is not reset to center whenever the `UITableView` performs layout on it's cell subviews.

---

## [1.7.0](https://github.com/jerkoch/SwipeCellKit/releases/tag/1.7.0)

#### Added

- Support for iOS 9. Thanks to @DMCApps!
- Showcase link in the README to track apps using the framework. Please submit a pull request to add your app!

#### Updated

- The *Advanced Customization* section in the README and moved it to a separate file.
- The *Requirements* section in the README to reflect iOS 9 support.

---

## [1.6.1](https://github.com/jerkoch/SwipeCellKit/releases/tag/1.6.1)

#### Fixed

- Issue where transitions are messed up when `expansionStyle` is set to `nil`.

---

## [1.6.0](https://github.com/jerkoch/SwipeCellKit/releases/tag/1.6.0)

#### Added

- Fully customizable expansion styles. See README documentation for more details. (#14)
- `SwipeTableViewDelegate` delegate methods for `willBeginEditingRowAt` and `didEndEditingRowAt`. (#18)

#### Fixed

- Removed action view cleanup when cell moved moved off UIWindow. Initially, this was added to prevent retain cycles caused by `SwipeAction` handlers capturing `self`.  Instead, it should be left up to the implementor to use `[weak self]` in handler implementations or ensure the action view is hidden before dismissing/popping a temporary parent view controller.  I've verified this behaves the same way as `UITableViewRowAction`. (#23)
- Issue where the table view pan gesture was being disabled along with all other table view gestures when a cell was swiped. (#21)

---

## [1.5.0](https://github.com/jerkoch/SwipeCellKit/releases/tag/1.5.0)

#### Fixed

- Issue where the destructive action animation relied on the table view to animate covering the deleted cell with the cells below it in order for its height to appear to shrink. If the cell being deleted was the last row, or the remaining cells below were not tall enough, the height of the deleted cell would not appear to shrink. Fixed by adding a mask to cell and animate its height to zero. (#15)
- Missing call to `super.didMoveToSuperview` causing accessory taps to be ignored. (#16)
- The previous action button `textColor` fix to re-add also setting the tint color to the text color. The tint color effects button images rendered as template images.

#### Added

- Ability to programmatically show swipe actions. (#13)
- Support for action background effect. (#10)

---

## [1.4.0](https://github.com/jerkoch/SwipeCellKit/releases/tag/1.4.0)

#### Fixed

- The expansion threshold for selection-style was always 50% of the screen width regardless of if the action view width was larger.
- Issue where the `textColor` property in `SwipeAction` was not being applied.

#### Added

- Accessibility support. (#5)
- New `expansionDelegate` property in `SwipeTableOptions` providing ability to customize expansion behavior. See the README and API documentation for more details.
- New `transitionDelegate` property in `SwipeAction` providing ability to customize transition behavior of individual actions as the swipe gesture is performed. See the README and API documentation for more details. (#9)
- Example app now lets you choose *circular* button style to demo the new `transitionDelegate` and `expansionDelegate`.

#### Updated

- Internal `SwipeActionButton` layout to separate the background color from the actual `UIButton`

---

## [1.3.0](https://github.com/jerkoch/SwipeCellKit/releases/tag/1.3.0)

#### Fixed

- Active animations were not always stopped when a new pan gesture began.
- Images are not aligned properly on buttons without a title. (#6)

#### Added

- New options in `SwipeTableOptions` to for more layout customization. (#7)
- Example app now lets you choose between buttons with *title + image*, *title only*, and *image only*

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
