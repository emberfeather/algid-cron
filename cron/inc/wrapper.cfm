<cfscript>
	
	profiler = request.managers.singleton.getProfiler();
	
	profiler.start('startup');
	
	// Setup a transport object to transport scopes
	transport = {
		theApplication = application,
		theCGI = cgi,
		theCookie = cookie,
		theForm = form,
		theRequest = request,
		theServer = server,
		theSession = session,
		theUrl = url
	};
	
	// Retrieve the admin objects
	i18n = transport.theApplication.managers.singleton.getI18N();
	locale = transport.theSession.managers.singleton.getSession().getLocale();
	modelSerial = transport.theApplication.factories.transient.getModelSerial(transport);
	
	// Create and store the services manager
	services = transport.theApplication.factories.transient.getManagerService(transport);
	transport.theRequest.managers.singleton.setManagerService(services);
	
	// Create and store the model manager
	models = transport.theApplication.factories.transient.getManagerModel(transport, i18n, locale);
	transport.theRequest.managers.singleton.setManagerModel(models);
	
	// Create and store the api manager
	crons = transport.theApplication.factories.transient.getManagerCron(transport);
	transport.theRequest.managers.singleton.setManagerCron(crons);
	
	profiler.stop('startup');
	
	profiler.start('processing');
	
	// Make the request last a long time if needed
	setting requesttimeout="500";
	
	servTask = services.get('cron', 'task');
	servUnit = services.get('cron', 'unit');
	
	tasks = servTask.getTasks({ 'task': transport.theUrl.task });
	task = servTask.getTask( tasks.taskID );
	
	units = servUnit.getUnits(task);
	
	// Execute all waiting crons
	for(i = 1; i <= units.recordCount; i++) {
		cron = crons.get(units.plugin[i], units.cron[i], task);
		cron.execute();
	}
	
	if(units.recordCount == 0) {
		writeOutput('<div>No units found for task.</div>')
	}
	
	writeOutput('<div><strong>Cron Task Completed.</strong></div>');
	
	profiler.stop('processing');
</cfscript>
