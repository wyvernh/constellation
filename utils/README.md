# Utils

Here is a collection of simple utilities for my operating systems. All that are useful on a Guix system will be packaged in mhguix, and some rely on other packages (mhdisk is a dependency of guix-installer). Note that mhdisk is interpreted rather than compiled so that it could be used by someone with a fork of mhguix that may have a different load path. (The load paths are dynamically evaluated by a call to guix repl.)

These utilities will be tangled from org files