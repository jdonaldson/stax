/*
 HaXe library written by Franco Ponticelli <franco.ponticelli@gmail.com>

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the
 distribution.

 THIS SOFTWARE IS PROVIDED BY FRANCO PONTICELLI "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL SOCIAL MEDIA NETWORKS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
package haxe.test.ui.common;

import haxe.test.TestResult;
import haxe.test.Assertation;

/**
* @todo add documentation
* @todo add tests for this class
*/
class PackageResult {
	public var packageName(default, null) : String;
	var classes : Hash<ClassResult>;
	var packages : Hash<PackageResult>;

	public var stats(default, null) : ResultStats;

	public function new(packageName : String) {
		this.packageName = packageName;
		classes = new Hash();
		packages = new Hash();
		stats = new ResultStats();
	}

	public function addResult(result : TestResult, flattenPackage : Bool) {
		var pack = getOrCreatePackage(result.pack, flattenPackage, this);
		var cls = getOrCreateClass(pack, result.cls, result.setup, result.teardown);
		var fix = createFixture(result.method, result.assertations);
		cls.add(fix);
	}

	public function addClass(result : ClassResult) {
		classes.set(result.className, result);
		stats.wire(result.stats);
	}

	public function addPackage(result : PackageResult) {
		packages.set(result.packageName, result);
		stats.wire(result.stats);
	}

	public function existsPackage(name : String) {
		return packages.exists(name);
	}

	public function existsClass(name : String) {
		return classes.exists(name);
	}

	public function getPackage(name : String) {
		if (packageName == null && name == "") return this;
		return packages.get(name);
	}

	public function getClass(name : String) {
		return classes.get(name);
	}

	public function classNames(errorsHavePriority = true) : Array<String> {
		var names = [];
		for(name in classes.keys())
			names.push(name);
		if(errorsHavePriority) {
			var me = this;
			names.sort(function(a, b) {
				var as = me.getClass(a).stats;
				var bs = me.getClass(b).stats;
				if(as.hasErrors) {
					return (!bs.hasErrors) ? -1 : (as.errors == bs.errors ? Reflect.compare(a, b) : Reflect.compare(as.errors, bs.errors));
				} else if(bs.hasErrors) {
					return 1;
				} else if(as.hasFailures) {
					return (!bs.hasFailures) ? -1 : (as.failures == bs.failures ? Reflect.compare(a, b) : Reflect.compare(as.failures, bs.failures));
				} else if(bs.hasFailures) {
					return 1;
				} else if(as.hasWarnings) {
					return (!bs.hasWarnings) ? -1 : (as.warnings == bs.warnings ? Reflect.compare(a, b) : Reflect.compare(as.warnings, bs.warnings));
				} else if(bs.hasWarnings) {
					return 1;
				} else {
					return Reflect.compare(a, b);
				}
			});
		} else {
			names.sort(function(a, b) {
				return Reflect.compare(a, b);
			});
		}
		return names;
	}

	public function packageNames(errorsHavePriority = true) : Array<String> {
		var names = [];
		if (packageName == null) names.push("");
		for(name in packages.keys())
			names.push(name);
		if(errorsHavePriority) {
			var me = this;
			names.sort(function(a, b) {
				var as = me.getPackage(a).stats;
				var bs = me.getPackage(b).stats;
				if(as.hasErrors) {
					return (!bs.hasErrors) ? -1 : (as.errors == bs.errors ? Reflect.compare(a, b) : Reflect.compare(as.errors, bs.errors));
				} else if(bs.hasErrors) {
					return 1;
				} else if(as.hasFailures) {
					return (!bs.hasFailures) ? -1 : (as.failures == bs.failures ? Reflect.compare(a, b) : Reflect.compare(as.failures, bs.failures));
				} else if(bs.hasFailures) {
					return 1;
				} else if(as.hasWarnings) {
					return (!bs.hasWarnings) ? -1 : (as.warnings == bs.warnings ? Reflect.compare(a, b) : Reflect.compare(as.warnings, bs.warnings));
				} else if(bs.hasWarnings) {
					return 1;
				} else {
					return Reflect.compare(a, b);
				}
			});
		} else {
			names.sort(function(a, b) {
				return Reflect.compare(a, b);
			});
		}
		return names;
	}
	
	function createFixture(method : String, assertations : Iterable<Assertation>) {
		var f = new FixtureResult(method);
		for(assertation in assertations)
			f.add(assertation);
		return f;
	}

	function getOrCreateClass(pack : PackageResult, cls : String, setup : String, teardown : String) {
		if(pack.existsClass(cls)) return pack.getClass(cls);
		var c = new ClassResult(cls, setup, teardown);
		pack.addClass(c);
		return c;
	}

	function getOrCreatePackage(pack : String, flat : Bool, ref : PackageResult) {
		if(pack == null || pack == '') return ref;
		if(flat) {
			if(ref.existsPackage(pack))
				return ref.getPackage(pack);
			var p = new PackageResult(pack);
			ref.addPackage(p);
			return p;
		} else {
			var parts = pack.split('.');
			for(part in parts) {
				ref = getOrCreatePackage(part, true, ref);
			}
			return ref;
		}
	}
}