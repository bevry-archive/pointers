$ = @$ or window?.$ or (try require?('jquery'))
extendr = require('extendr')
{extendOnClass} = require('extendonclass')

class Pointer
	@extend: extendOnClass

	config: null
	bound: false

	constructor: (config) ->
		@elementChangeValueHandler = @elementChangeValueHandler.bind(@)
		@collectionAddHandler = @collectionAddHandler.bind(@)
		@collectionRemoveHandler = @collectionRemoveHandler.bind(@)
		@collectionResetHandler = @collectionResetHandler.bind(@)
		@modelChangeAttributeHandler = @modelChangeAttributeHandler.bind(@)

		@config = extendr.extend({}, {
			item: null
			itemAttributes: null

			viewClass: null

			element: null
			elementSetter: true

			itemSetter: false
		}, config)

		@

	get: (attr) -> @config[attr]

	getConfig: -> @config

	setConfig: (config) ->
		(@config[key] = value)  for own key,value of config  if config
		@

	getItemType: -> if @get('item').length? then 'collection' else 'model'

	bind: ->
		return @  if @bound is true
		@bound = true

		item = @get('item')
		$el = @get('element')

		$el.data('pointer')?.destroy()
		$el.data('pointer', @)

		@unbind()

		if @getItemType() is 'model'

			if itemAttributes = @get('itemAttributes')
				item.on('change:'+attribute, @modelChangeAttributeHandler)  for attribute in itemAttributes
				@modelChangeAttributeHandler(item, null, {})
				$el.on('change', @elementChangeValueHandler)  if @get('itemSetter') is true

			else if @get('viewClass')
				@createViewViaModel(item)

		else
			item
				.on('add',    @collectionAddHandler)
				.on('remove', @collectionRemoveHandler)
				.on('reset',  @collectionResetHandler)

			@collectionResetHandler(item.models, item, {})

		# Chain
		@

	unbind: ->
		return @  if @bound is false
		@bound = false

		item = @get('item')
		itemAttributes = @get('itemAttributes')

		item.off('change:'+attribute, @modelChangeAttributeHandler)  for attribute in itemAttributes  if itemAttributes
		item
			.off('add',    @collectionAddHandler)
			.off('remove', @collectionRemoveHandler)
			.off('reset',  @collectionResetHandler)

		@

	destroy: (opts) ->
		@unbind()

		$el = @get('element')
		$el.children().each ->
			$child = $(@)
			$child.data('view')?.destroy()

		@

	# Fired by the jQuery Event Listener on the "change" event of the element
	# opts = jQuery Event Object
	elementChangeValueHandler: (opts) ->
		setter = @getSetter('itemSetter', @defaultModelSetterFromElement)
		if setter
			@prepareEventOptions(opts)
			return setter(opts)
		else
			return true

	collectionAddHandler: (model, collection, opts) ->
		setter = @getSetter('elementSetter', @defaultElementSetterFromCollection)
		if setter
			@prepareEventOptions extendr.extend(opts, {event:'add', model, collection})
			return setter(opts)
		else
			return true

	collectionRemoveHandler: (model, collection, opts) ->
		setter = @getSetter('elementSetter', @defaultElementSetterFromCollection)
		if setter
			@prepareEventOptions extendr.extend(opts, {event:'remove', model, collection})
			return setter(opts)
		else
			return true

	collectionResetHandler: (collection, opts) ->
		setter = @getSetter('elementSetter', @defaultElementSetterFromCollection)
		if setter
			@prepareEventOptions extendr.extend(opts, {event:'reset', collection})
			return setter(opts)
		else
			return true

	modelChangeAttributeHandler: (model, value, opts) ->
		setter = @getSetter('elementSetter', @defaultElementSetterFromModel)
		if setter
			value ?= @getFirstExistingAttributeValue()
			@prepareEventOptions extendr.extend(opts, {event:'change', model, value})
			return setter(opts)
		else
			return true

	getSetter: (name, defaultSetter) ->
		setter = @get(name)
		setter = defaultSetter.bind(@)  if setter is true
		return setter or null

	prepareEventOptions: (opts) ->
		opts.$el = opts.element = @get('element')
		opts[@getItemType()] = opts.item = @get('item')
		return opts

	defaultModelSetterFromElement: (opts) ->
		model = opts.item
		element = opts.element
		primaryItemAttribute = @get('itemAttributes')[0]
		value = element.val()

		attrs = {}
		attrs[primaryItemAttribute] = value
		model.set(attrs)

		return true

	defaultElementSetterFromModel: (opts) ->
		opts.value ?= @getFirstExistingAttributeValue()

		if opts.$el.is(':input')
			opts.$el.val(opts.value)
		else
			opts.$el.text(opts.value)

		return true

	defaultElementSetterFromCollection: (opts) ->
		pointer = @

		switch event
			when 'add'
				@createViewViaModel(opts.model)

			when 'remove'
				$el = @getElementViaModel(opts.model)
				@destroyViewViaElement($el)

			when 'reset'
				@get('element').children().each ->
					pointer.destroyViewViaElement $(@)

				for model in opts.collection.models
					@createViewViaModel(model)

		return true

	createViewViaModel: (model) ->
		model ?= @get('item')
		viewClass = @get('viewClass')
		$el = @get('element')

		view = new viewClass(item:model, model:model)

		view.$el
			.data('view', view)
			.data('model', model)
			.addClass("model-#{model.cid}")

		view
			.render()
			.$el.appendTo($el)

		return view

	destroyViewViaElement: ($el) ->
		$el.data('view')?.destroy()

		# Chain
		@

	getFirstExistingAttributeValue: ->
		item = @get('item')
		itemAttributes = @get('itemAttributes')
		value = null

		for attribute in itemAttributes
			if (value = item.get(attribute))
				break

		return value

	getElementViaModel: (model) ->
		model ?= @get('item')
		$el = @get('element')
		return $el.find(".model-#{model.cid}:first") ? null

	getViewViaModel: (model) ->
		$el = @getElementViaModel(model)
		return $el?.data('view') ? null

	# Public
	getElement: -> @getElementViaModel()
	getView: -> @getElement().data('view')


# Exports
module.exports = {Pointer}