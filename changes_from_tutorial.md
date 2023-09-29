# Code architecture changes

* Avoid references to owning objects
* Avoid reference to higher-level objects; instead pass in to methods that require it
  * e.g. why does everything have a reference to the engine?!
