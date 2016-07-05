
[bioDigit](https://play.google.com/store/apps/details?id=me.haza.biodigit) remade with [Kala](https://github.com/hazagames/Kala). WIP.

###NOTES

- The game framerate is capped at 30fps when 'cap_30' is defined and building in release mode, this is to make sure the game can run stably targeting HTML5 on low-end mobile devices. Currently Kha is not yet implemented a way for us to limit rendering framerate so you will have to directly change Kha source codes for that. Without limiting the rendering rate, it's best to just let the framerate maxed at 60fps, doing this by removing `project.addDefine('cap_30');` in `khafile.js`.

- Art assets were packed with [TexturePacker](https://www.codeandweb.com/texturepacker) free version.

###LICENSE

Source codes are under MIT.

>The MIT License (MIT)

>Copyright (c) 2016 Nguyen Phuc Sinh

>Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

>The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

The art assets are belonged to [Dinh Quoc Nam](https://twitter.com/DINHQUOCNAM), you will need to personally ask for his permission if you want to use the arts outside of learning & prototying purposes.

The fonts are under public domain.

Other assets like music, sound effects added into the project in the future will be credited to their respected authors with the licenses they are under. 
