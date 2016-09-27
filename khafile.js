var project = new Project('bioDigit - HTML5');

project.addAssets('Assets/**');
project.addLibrary('kala');
project.addSources('Sources');

project.windowOptions.width = 700;
project.windowOptions.height = 495;

project.addDefine('cap_30');
project.addDefine('kala_keyboard');
project.addDefine('kala_mouse');
project.addDefine('kala_touch');

resolve(project);
