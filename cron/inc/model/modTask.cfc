component extends="algid.inc.resource.base.model" {
	public component function init(required component i18n, required string locale) {
		super.init(arguments.i18n, arguments.locale);
		
		// Set the bundle information for translation
		add__bundle('plugins/cron/i18n/inc/model', 'modTask');
		
		// Task ID
		add__attribute(
			attribute = 'taskID'
		);
		
		// Task
		add__attribute(
			attribute = 'task'
		);
		
		return this;
	}
}
