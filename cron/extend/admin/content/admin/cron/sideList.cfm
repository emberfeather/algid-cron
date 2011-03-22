<cfset viewCron = views.get('cron', 'cron') />

<cfset filter = {
		'search' = theURL.search('search')
	} />

<cfoutput>
	#viewCron.filter( filter )#
</cfoutput>
