$ = @$ or window?.$ or (try require?('jquery'))
extendr = require('extendr')

class Pointer
	config: null
	bound: false
	bindTimeout: null

	constructor: (item) ->
		@config ?= {}

		type = if item.length? then 'collection' else 'model'

		@setConfig(
			type: type
			item: item
		)

		@bindTimeout = setTimeout(@bind, 0)

		@

	bind: =>
		(clearTimeout(@bindTimeout); @bindTimeout = null)  if @bindTimeout
		return @  if @bound is true
		@bound = true

		@config.element.data('pointer')?.destroy()
		@config.element.data('pointer', @)

		@unbind()

		if @config.type is 'model'
			if @config.attributes
				@config.handler ?= @defaultModelHandler
				@config.item.on('change:'+attribute, @changeAttributeHandler)  for attribute in @config.attributes
				@changeAttributeHandler(@config.model, null, {})
				if @config.update is true
					@config.element.on('change', @updateHandler)

			if @config.View
				@createViewViaModel(@config.item)

		else
			if @config.View
				@config.handler ?= @defaultCollectionHandler
				@config.element.off('change', @updateHandler)
				@config.item
					.on('add',    @addHandler)
					.on('remove', @removeHandler)
					.on('reset',  @resetHandler)
				@resetHandler(@config.item.models, @config.item, {})
		@

	unbind: =>
		(clearTimeout(@bindTimeout); @bindTimeout = null)  if @bindTimeout
		return @  if @bound is false
		@bound = false

		@config.item.off('change:'+attribute, @changeAttributeHandler)  for attribute in @config.attributes  if @config.attributes
		@config.item
			.off('add',    @addHandler)
			.off('remove', @removeHandler)
			.off('reset',  @resetHandler)
		@

	destroy: (opts) =>
		@unbind()

		@config.element.children().each ->
			$el = $(@)
			$el.data('view')?.destroy()

		@

	setConfig: (config={}) ->
		for own key,value of config
			@config[key] = value
		@


	updateHandler: (e) =>
		attrs = {}
		attrs[@config.attributes[0]] = @config.element.val()
		@config.item.set(attrs)
		@

	addHandler: (model, collection, opts) =>
		@callUserHandler extendr.extend(opts, {event:'add', model, collection})
	removeHandler: (model, collection, opts) =>
		@callUserHandler extendr.extend(opts, {event:'remove', model, collection})
	resetHandler: (collection, opts) =>
		@callUserHandler extendr.extend(opts, {event:'reset', collection})
	changeAttributeHandler: (model, value, opts) =>
		value ?= @fallbackValue()
		@callUserHandler extendr.extend(opts, {event:'change', model, value})

	callUserHandler: (opts) =>
		opts.$el = @config.element
		opts[@config.type] = @config.item
		opts.item = @config.item
		@config.handler(opts)
		return true

	defaultModelHandler: ({$el, value}) =>
		value ?= @fallbackValue()
		if $el.is(':input')
			$el.val(value)
		else
			$el.text(value)
		return true

	createViewViaModel: (model) =>
		model ?= @config.item

		view = new @config.View(item: model)

		view.$el
			.data('view', view)
			.data('model', model)
			.addClass("model-#{model.cid}")

		view
			.render()
			.$el.appendTo(@config.element)

		return view

	destroyViewViaElement: (element) =>
		$el = element
		$el.data('view')?.destroy()
		@

	defaultCollectionHandler: (opts) =>
		{model, event, collection} = opts
		switch event
			when 'add'
				@createViewViaModel(model)

			when 'remove'
				$el = @getModelElement(model)
				@destroyViewViaElement($el)

			when 'reset'
				@config.element.children().each =>
					@destroyViewViaElement $(@)

				for model in collection.models
					@createViewViaModel(model)

		return true

	fallbackValue: ->
		value = null
		for attribute in @config.attributes
			if (value = @config.item.get(attribute))
				break
		return value

	getModelElement: (model) =>
		return @config.element.find(".model-#{model.cid}:first") ? null
	getModelView: (model) =>
		return @getModelElement(model)?.data('view') ? null

	getElement: =>
		return @getModelElement(@config.item)
	getView: =>
		return @getElement().data('view')

	update: ->
		update = true
		@setConfig({update})
		@

	attributes: (attributes...) ->
		@setConfig({attributes})
		@

	view: (View) ->
		@setConfig({View})
		@

	using: (handler) ->
		@setConfig({handler})
		@

	to: (element) ->
		@setConfig({element})
		@

# Exports
module.exports = {Pointer}