class AdLayersAPI
	constructor: ->
		@adServer = null
		@nextSlotId = 1

	refresh: (adUnit) ->
		@adServer.refresh(adUnit) if @functionExists('refresh')

	refreshAll: ->
		@adServer.refreshAll() if @functionExists('refreshAll')

	functionExists: (name) ->
		@adServer? and name in @adServer

	generateSlotName: ->
		"ad_layers_slot_#{@nextSlotId++}"

	generateAd: ->
		slotName = @generateSlotName()
		$('body').append($('<div>').attr('id', slotName))
		slotName

class AdLayersDFPAPI extends AdLayersAPI
	refresh: (adUnit) ->
		googletag.pubads().refresh( [ dfpAdUnits[ adUnit ] ] ) if dfpAdUnits? and dfpAdUnits[ adUnit ]?

	refreshAll: ->
		if ( false === $.isEmptyObject( dfpAdUnits ) )
			# DFP needs a numerical indexed array
			unitsToRefresh = [];
			for adUnit in dfpAdUnits
				unitsToRefresh.push dfpAdUnits[ adUnit ]

			googletag.pubads().refresh unitsToRefresh

	generateAd: (path, targets)->
		slotName = super()

		# Define the slot itself, call display() to register the div and
		# refresh() to fetch ad.
		googletag.cmd.push ->
			slot = googletag.defineSlot(path, [728, 90], slotName)

			for key, value of targets
				slot.setTargeting key, value

			slot.addService(googletag.pubads())

			# Display has to be called before refresh and after the slot div is in
			# the page.
			googletag.display(slotName)
			googletag.pubads().refresh([slot])
