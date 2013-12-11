
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

Syncs a model/collection with an element. Supports two-way syncs. Respects garbage collection and bottom-up rendering. Reactive.

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

Element Sync comes in handy when you want to keep an element up to date with a model or collection, or a model up to date with the value of an element, or both.

There are three ways you can keep sync a model or collection to an element:

1. You can keep an element's text or value up to date with the value of a model's attributes
	1. Uses the `element` `item`, and `itemAttributes` configuration options
2. You can keep an element up to date with a view bound to the model
	1. Uses the `element`, and `item` configuration options
3. You can keep an element up to date with views for each model in a collection
	1. Uses the `element`, `item`, and `viewClass` configuration options

And there is one way you can sync an element to a model or collection:

1. You can keep a model's attributes value up to date with an element's value or text
	1. Uses the `element`, `item`, `itemAttributes`, and `itemSetter` configuration options

The only differences between these methods, are what configuration options are sent to the pointer. The available configuration options are:

- `item` — the model or collection that we want to sync with the element, e.g. `new Backbone.Model()`
- `itemAttributes` — when syncing a model's attributes to an element, this is an array of the attributes that we want to sync to the element's value, e.g. `['title', 'name', 'path']`
- `viewClass` — when syncing a model or collection directly to an element, this is the view class that be instantiated for the model, or for each of the collection's models
- `element` — the element to our collection, model, or specified model's attributes to
- `elementSetter` — when syncing a model's attributes to an element, this is either `true` to use the default setter that will update the element's value or text, or can be a custom function that accepts an object of `$el` the element, `item` the item this pointer is for, `value` the model value that just changed
-  `itemSetter` — when syncing an element's value to a model's attribute, this is either `false` to disable this ability (the default), `true` to use the default setter (just a plain set of the first specified itemAttribute using the element's latest value), or a function that accepts an object of `$el` the element, `item` the item this pointer is for, `value` the element value that just changed

Knowing all this, you create a pointer like so:

``` javascript
var Pointer = require('pointers').Pointer;

new Pointer({
	item: null,
	itemAttributes: null,
	viewClass: null,
	element: null,
	elementSetter: null,
	itemSetter: null
}),bind()
```


## Compatibility

### Elements

Pointers are compatible out of the box with both jQuery and Zepto, and whatever else that implements the API:

- `$el = $(domElement)`
- `$el.data('property')`, `$el.data('property', value)`
- `$el.addClass('className')`
- `$el.appendTo($anotherEl)`
- `$el.find('sizzle selector')`
- `$el.children()`
- `$el.each(function(){})`
- `$el.is('sizzle selector')`
- `$el.val('value')`
- `$el.text('html that will be escaped to text')`
- `$el.on('change', function(event){})`

### Views

Pointers are compatible out of the box with MiniView, or whatever else that implements the API:

- `new viewClass({item: item, model:item})` — the constructor of the view class should either accept the model via the `item` or `model` configuration options
- `view.destroy()` — a method to remove the element from the DOM, and clean up the view from memory
- `view.$el` — exposes the element that the view is for

Which can be easily accomplish with Backbone.js Views and SpineMVC Controllers.

### Models

Pointers are compatible out of the box with Backbone Models, and whatever else that implements the API:

- `model.set({name: "Benjamin Lupton"})` — updates the attributes on the model
- `model.on('change:name', function(theSameModel, theNewValue, someOptions){})`

### Collections

Pointers are compatible out of the box with Backbone Collections, and whatever else that implements the API:

- `collection.on('add', function(addedModel, theSameCollection, someOptions){})`
- `collection.on('remove', function(removedModel, theSameCollection, someOptions){})`
- `collection.on('reset', function(theSameCollection, someOptions){})`



## Tying it all together

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
class ListItemView
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
		@point(item:@item, itemAttributes:['title', 'name'], element:@$title).bind()

		# Bind the model's date attribute, to the $date element, with a custom setter
		@point(item:@item, itemAttributes:['title', 'name'], element:@$title, itemSetter: ({$el, item, value}) ->
			$el.text value?.toLocaleDateString()
		).bind()

		# Chain
		@

# List View
class ListView
	el: """
		<div class="list-view">
			<ul class="items"></ul>
		</div>
		"""

	elements:
		'ul.items': '$items'

	render: ->
		# Bind the collection, using the ListItemView, to the $items element
		@point(item:@item, viewClass:ListItemView, element:@$items).bind()

		# Chain
		@

# Edit View
class EditView
	el: """
		<li class="edit-view">
			<input type="text" class="field-title"></input>
		</li>
		"""

	elements:
		'.field-title :input': '$title'

	render: ->
		# Bind the model's title (fallback to name) attribute to the $title element, with a two way-sync
		@point(item:@item, itemAttributes:['title', 'name'], element:@$title, itemSetter:true).bind()

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


