<!-- TITLE/ -->

# Pointers

<!-- /TITLE -->


<!-- BADGES/ -->

[![Build Status](http://img.shields.io/travis-ci/bevry/pointers.png?branch=master)](http://travis-ci.org/bevry/pointers "Check this project's build status on TravisCI")
[![NPM version](http://badge.fury.io/js/pointers.png)](https://npmjs.org/package/pointers "View this project on NPM")
[![Gittip donate button](http://img.shields.io/gittip/bevry.png)](https://www.gittip.com/bevry/ "Donate weekly to this project using Gittip")
[![Flattr donate button](http://img.shields.io/flattr/donate.png?color=yellow)](http://flattr.com/thing/344188/balupton-on-Flattr "Donate monthly to this project using Flattr")
[![PayPayl donate button](http://img.shields.io/paypal/donate.png?color=yellow)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=QB8GQPZAH84N6 "Donate once-off to this project using Paypal")

<!-- /BADGES -->


<!-- DESCRIPTION/ -->

Point a model or collection to a view. Respects garbage collection and bottom-up rendering. Reactive.

<!-- /DESCRIPTION -->


<!-- INSTALL/ -->

## Install

### [Node](http://nodejs.org/), [Browserify](http://browserify.org/)
- Use: `require('pointers')`
- Install: `npm install --save pointers`

### [Ender](http://ender.jit.su/)
- Use: `require('pointers')`
- Install: `ender add pointers`

<!-- /INSTALL -->


## Usage

``` coffeescript
# Import
{Pointer} = require('pointers')
MiniView = require('miniview').View

# Extend MiniView
class View extends MiniView
	point: (args...) ->
		pointer = new Pointer(args...)
		(@pointers ?= []).push(pointer)
		return pointer

	destroy: ->
		pointer.destroy()  for pointer in @pointers  if @pointers
		@pointers = null
		return super

	navigate: (args...) ->
		return Route.navigate.apply(Route, args)

# List Item View
class ListItemView extends View
	el: """
		<li class="list-item-view">
			<span class="field-title"></span>
			<span class="field-date"></span>
		</li>
		"""

	elements:
		'.field-title': '$title'
		'.field-date': '$date'

	render: ->
		# Bind the model's title (fallback to name) attribute, to the $title element
		@point(@item).attributes('title', 'name').to(@$title).bind()

		# Bind the model's date attribute, to the $date element, with a custom setter
		@point(@item).attributes('title', 'name').to(@$title)
			.using ($el, model, value) ->
				$el.text value?.toLocaleDateString()
			.bind()

		# Chain
		@

# List View
class ListView extends View
	el: """
		<div class="list-view">
			<ul class="items"></ul>
		</div>
		"""

	elements:
		'ul.items': '$items'

	render: ->
		# Bind the collection, using the ListItemView, to the $items element
		@point(@item).view(ListItemView).to(@$items).bind()

		# Chain
		@

# Edit View
class EditView extends View
	el: """
		<div class="edit-view">
			<form>
				<input type="text" class="field-title"></input>
			</form>
		</div>
		"""

	elements:
		'.field-title :input': '$title'

	render: ->
		# Bind the model's title (fallback to name) attribute to the $title element, with a two way-sync
		@point(@item).attributes('title', 'name').to(@$title).update().bind()

		# Chain
		@
```


<!-- HISTORY/ -->

## History
[Discover the change history by heading on over to the `History.md` file.](https://github.com/bevry/pointers/blob/master/History.md#files)

<!-- /HISTORY -->


<!-- CONTRIBUTE/ -->

## Contribute

[Discover how you can contribute by heading on over to the `Contributing.md` file.](https://github.com/bevry/pointers/blob/master/Contributing.md#files)

<!-- /CONTRIBUTE -->


<!-- BACKERS/ -->

## Backers

### Maintainers

These amazing people are maintaining this project:

- Benjamin Lupton <b@lupton.cc> (https://github.com/balupton)

### Sponsors

No sponsors yet! Will you be the first?

[![Gittip donate button](http://img.shields.io/gittip/bevry.png)](https://www.gittip.com/bevry/ "Donate weekly to this project using Gittip")
[![Flattr donate button](http://img.shields.io/flattr/donate.png?color=yellow)](http://flattr.com/thing/344188/balupton-on-Flattr "Donate monthly to this project using Flattr")
[![PayPayl donate button](http://img.shields.io/paypal/donate.png?color=yellow)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=QB8GQPZAH84N6 "Donate once-off to this project using Paypal")

### Contributors

These amazing people have contributed code to this project:

- Benjamin Lupton <b@lupton.cc> (https://github.com/balupton) - [view contributions](https://github.com/bevry/pointers/commits?author=balupton)

[Become a contributor!](https://github.com/bevry/pointers/blob/master/Contributing.md#files)

<!-- /BACKERS -->


<!-- LICENSE/ -->

## License

Licensed under the incredibly [permissive](http://en.wikipedia.org/wiki/Permissive_free_software_licence) [MIT license](http://creativecommons.org/licenses/MIT/)

Copyright &copy; 2013+ Bevry Pty Ltd <us@bevry.me> (http://bevry.me)

<!-- /LICENSE -->


