let fs = require('fs');
let path = require('path');
let project = new Project('bioDigit - HTML5', __dirname);
project.targetOptions = {"html5":{},"flash":{},"android":{},"ios":{}};
project.setDebugDir('build/windows');
Promise.all([Project.createProject('build/windows-build', __dirname), Project.createProject('W:/Projects/Haxe/kala/Kha', __dirname), Project.createProject('W:/Projects/Haxe/kala/Kha/Kore', __dirname)]).then((projects) => {
	for (let p of projects) project.addSubProject(p);
	let libs = [];
	if (fs.existsSync(path.join('w:/HaxeToolkit/haxe/lib/kala', 'korefile.js'))) {
		libs.push(Project.createProject('w:/HaxeToolkit/haxe/lib/kala', __dirname));
	}
	Promise.all(libs).then((libprojects) => {
		for (let p of libprojects) project.addSubProject(p);
		resolve(project);
	});
});
