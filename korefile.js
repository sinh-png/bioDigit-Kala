var solution = new Solution('bioDigit - HTML5');
var project = new Project('bioDigit - HTML5');
project.targetOptions = {"flash":{},"android":{}};
project.setDebugDir('build/android-native');
project.addSubProject(Solution.createProject('build/android-native-build'));
project.addSubProject(Solution.createProject('W:/Projects/Haxe/kala/kha'));
project.addSubProject(Solution.createProject('W:/Projects/Haxe/kala/kha/Kore'));
solution.addProject(project);
if (fs.existsSync(path.join('W:/HaxeToolkit/haxe/lib/kala', 'korefile.js'))) {
	project.addSubProject(Solution.createProject('W:/HaxeToolkit/haxe/lib/kala'));
}
return solution;
